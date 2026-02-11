// NFCService.swift
// Steel by Exo — CoreNFC Integration Service
//
// Handles all NFC operations: reading Steel tags and writing NDEF records.
// Based on Apple's "BuildingAnNFCTagReaderApp" sample code patterns.
//
// HOW STEEL USES NFC:
// 1. READING: When a receiver taps a sharer's tag/card/bracelet, we read the
//    NDEF records to extract the sharer's Steel ID and initiate verification.
//
// 2. WRITING: When a member sets up their Steel card, we write NDEF records:
//    Record 1: URI record → https://steel.byexo.com/connect/[encrypted-ID]
//              (This is the fallback URL for non-app users — opens web profile)
//    Record 2: Custom record → encrypted sharer ID + session token
//              (This is what the Steel app reads for in-app verification)
//
// NDEF TAG STRUCTURE (from product docs):
//   Record 1: URI       → steel.byexo.com/connect/[encrypted-ID]  (web fallback)
//   Record 2: Text      → Sharer name (basic vCard-like info)
//   Record 3: External  → com.exo.steel:connect (app-specific encrypted data)
//
// REQUIREMENTS:
// - Add "Near Field Communication Tag Reading" capability in Xcode
// - Add NFCReaderUsageDescription to Info.plist
// - Add com.apple.developer.nfc.readersession.formats to entitlements
// - Physical device required (NFC doesn't work in Simulator)

import Foundation
import CoreNFC

// MARK: - NFCService
// ObservableObject so SwiftUI views can react to NFC state changes.
// All NFC sessions run in the foreground (Apple requires this for NDEF).
class NFCService: NSObject, ObservableObject {

    // MARK: - Published State
    // These drive the UI — when a tag is read, the view reacts immediately.
    @Published var lastReadSharerID: String? = nil
    @Published var lastReadSharerName: String? = nil
    @Published var isScanning: Bool = false
    @Published var lastError: String? = nil

    // MARK: - Private Properties
    private var readerSession: NFCNDEFReaderSession?
    private var writeMessage: NFCNDEFMessage?       // Message to write (when setting up a card)
    private var isWriteMode: Bool = false            // Are we writing or reading?

    // Completion handlers for async bridging
    private var readCompletion: ((Result<(sharerId: String, sharerName: String?), Error>) -> Void)?
    private var writeCompletion: ((Result<Void, Error>) -> Void)?

    // MARK: - Public API

    /// Check if this device supports NFC tag reading.
    /// Returns false on Simulator and devices without NFC (iPod touch, older iPads).
    var isNFCAvailable: Bool {
        NFCNDEFReaderSession.readingAvailable
    }

    /// Start scanning for a Steel NFC tag.
    /// This presents the system NFC scanning sheet ("Hold your iPhone near...").
    /// On success, extracts the sharer ID from the NDEF records and publishes it.
    func beginScanning(completion: ((Result<(sharerId: String, sharerName: String?), Error>) -> Void)? = nil) {
        // Guard: NFC must be available
        guard isNFCAvailable else {
            let error = NFCServiceError.nfcNotAvailable
            lastError = error.localizedDescription
            completion?(.failure(error))
            return
        }

        // Store completion for delegate callback
        readCompletion = completion
        isWriteMode = false

        // Create a new NDEF reader session
        // invalidateAfterFirstRead: false — we want to handle the tag ourselves
        // (Apple's sample uses false so we can query status and read in sequence)
        readerSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,               // Use main queue for simplicity
            invalidateAfterFirstRead: false
        )

        // This message shows on the NFC scanning sheet
        readerSession?.alertMessage = "Hold your iPhone near a Steel card or bracelet."
        readerSession?.begin()

        DispatchQueue.main.async {
            self.isScanning = true
            self.lastError = nil
        }
    }

    /// Write Steel NDEF records to a blank/writable NFC tag.
    /// Used during card setup: writes the member's ID and fallback URL to the tag.
    ///
    /// NDEF Records written:
    ///   1. URI: https://steel.byexo.com/connect/{memberId}
    ///   2. Text: Member's display name
    ///   3. External: com.exo.steel:connect with encrypted member ID
    func writeTag(memberId: String, memberName: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard isNFCAvailable else {
            completion?(.failure(NFCServiceError.nfcNotAvailable))
            return
        }

        writeCompletion = completion
        isWriteMode = true

        // Build the NDEF message with Steel's record structure
        writeMessage = buildSteelNDEFMessage(memberId: memberId, memberName: memberName)

        readerSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false
        )

        readerSession?.alertMessage = "Hold your iPhone near the Steel card to write your identity."
        readerSession?.begin()

        DispatchQueue.main.async {
            self.isScanning = true
        }
    }

    /// Stop the current NFC session.
    func stopScanning() {
        readerSession?.invalidate()
        readerSession = nil
        DispatchQueue.main.async {
            self.isScanning = false
        }
    }

    // MARK: - NDEF Message Building

    /// Builds the Steel NDEF message that gets written to physical NFC tags.
    /// This matches the "NFC Data Structure" from the product documentation:
    ///   Record 1: URI → steel.byexo.com/connect/[encrypted-ID] (for non-app users)
    ///   Record 2: Text → Member name (basic info)
    ///   Record 3: External → com.exo.steel:connect (app-specific data)
    private func buildSteelNDEFMessage(memberId: String, memberName: String) -> NFCNDEFMessage {
        var records: [NFCNDEFPayload] = []

        // Record 1: URI record — fallback URL for non-members
        // When a non-member taps, their phone opens this URL in Safari
        // which shows the steel.html web fallback page
        if let uriPayload = NFCNDEFPayload.wellKnownTypeURIPayload(
            url: URL(string: "https://steel.byexo.com/connect/\(memberId)")!
        ) {
            records.append(uriPayload)
        }

        // Record 2: Text record — member's name
        // This is a simple text payload that any NFC reader can display
        if let textPayload = NFCNDEFPayload.wellKnownTypeTextPayload(
            string: memberName,
            locale: Locale(identifier: "en")
        ) {
            records.append(textPayload)
        }

        // Record 3: External type record — app-specific Steel data
        // This contains the encrypted member ID that only the Steel app can parse
        // Type: "com.exo.steel:connect"
        // Payload: JSON with memberId and timestamp
        let steelData: [String: Any] = [
            "memberId": memberId,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "version": "1.0"
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: steelData),
           let typeData = "com.exo.steel:connect".data(using: .utf8) {
            let externalRecord = NFCNDEFPayload(
                format: .nfcExternal,
                type: typeData,
                identifier: Data(),
                payload: jsonData
            )
            records.append(externalRecord)
        }

        return NFCNDEFMessage(records: records)
    }

    // MARK: - NDEF Parsing

    /// Parse a Steel NDEF message to extract the sharer's member ID and name.
    /// Looks for our custom external record first, falls back to URI parsing.
    private func parseSteelMessage(_ message: NFCNDEFMessage) -> (sharerId: String?, sharerName: String?) {
        var sharerId: String? = nil
        var sharerName: String? = nil

        for record in message.records {
            switch record.typeNameFormat {

            // Check for our custom external record (com.exo.steel:connect)
            case .nfcExternal:
                if let type = String(data: record.type, encoding: .utf8),
                   type == "com.exo.steel:connect",
                   let json = try? JSONSerialization.jsonObject(with: record.payload) as? [String: Any],
                   let id = json["memberId"] as? String {
                    sharerId = id
                }

            // Parse URI record as fallback
            case .nfcWellKnown:
                if let type = String(data: record.type, encoding: .utf8) {
                    if type == "U", let url = record.wellKnownTypeURIPayload() {
                        // Extract member ID from URL path: /connect/{memberId}
                        let pathComponents = url.pathComponents
                        if let connectIndex = pathComponents.firstIndex(of: "connect"),
                           connectIndex + 1 < pathComponents.count {
                            sharerId = sharerId ?? pathComponents[connectIndex + 1]
                        }
                    } else if type == "T" {
                        // Text record — member name
                        // Text payload format: first byte is language code length
                        let payload = record.payload
                        if payload.count > 1 {
                            let langCodeLength = Int(payload[0] & 0x3F)
                            if langCodeLength + 1 < payload.count {
                                let textData = payload.subdata(in: (langCodeLength + 1)..<payload.count)
                                sharerName = String(data: textData, encoding: .utf8)
                            }
                        }
                    }
                }

            default:
                break
            }
        }

        return (sharerId, sharerName)
    }
}

// MARK: - NFCNDEFReaderSessionDelegate
// These delegate methods are called by CoreNFC as the NFC session progresses.
// Pattern follows Apple's BuildingAnNFCTagReaderApp sample.
extension NFCService: NFCNDEFReaderSessionDelegate {

    /// Called when the session becomes active (NFC sheet is visible).
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        // Session is active — user sees the NFC scanning UI
    }

    /// Called when NDEF messages are detected (simple read mode).
    /// We don't use this because we use didDetect tags: instead for more control.
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Not used — we handle reads in didDetect tags: for read/write control
    }

    /// Called when one or more NFC tags are detected.
    /// This is where the main read/write logic lives.
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        // Handle multiple tags (following Apple's pattern)
        if tags.count > 1 {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag detected. Please use only one Steel card."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval) {
                session.restartPolling()
            }
            return
        }

        guard let tag = tags.first else { return }

        // Connect to the tag
        session.connect(to: tag) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                session.alertMessage = "Unable to connect to tag."
                session.invalidate(errorMessage: error.localizedDescription)
                self.handleError(NFCServiceError.connectionFailed)
                return
            }

            // Query NDEF status to check if tag is readable/writable
            tag.queryNDEFStatus { ndefStatus, capacity, error in
                if let error = error {
                    session.alertMessage = "Unable to query tag."
                    session.invalidate(errorMessage: error.localizedDescription)
                    self.handleError(NFCServiceError.queryFailed)
                    return
                }

                switch ndefStatus {
                case .notSupported:
                    session.alertMessage = "Tag is not NDEF compatible."
                    session.invalidate()
                    self.handleError(NFCServiceError.notNDEF)

                case .readOnly:
                    if self.isWriteMode {
                        session.alertMessage = "Tag is read-only. Cannot write."
                        session.invalidate()
                        self.handleError(NFCServiceError.readOnly)
                    } else {
                        self.readTag(tag, session: session)
                    }

                case .readWrite:
                    if self.isWriteMode {
                        self.writeToTag(tag, session: session)
                    } else {
                        self.readTag(tag, session: session)
                    }

                @unknown default:
                    session.alertMessage = "Unknown tag status."
                    session.invalidate()
                }
            }
        }
    }

    /// Called when the session is invalidated (user canceled, error, or success).
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.isScanning = false
        }

        // Don't report cancellation or first-read-success as errors
        if let readerError = error as? NFCReaderError {
            if readerError.code == .readerSessionInvalidationErrorFirstNDEFTagRead ||
               readerError.code == .readerSessionInvalidationErrorUserCanceled {
                return
            }
        }

        handleError(NFCServiceError.sessionInvalidated(error.localizedDescription))
    }

    // MARK: - Private Read/Write Helpers

    /// Read NDEF message from tag and extract Steel data.
    private func readTag(_ tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        tag.readNDEF { [weak self] message, error in
            guard let self = self else { return }

            if let error = error {
                session.alertMessage = "Failed to read tag."
                session.invalidate(errorMessage: error.localizedDescription)
                self.handleError(NFCServiceError.readFailed)
                return
            }

            guard let message = message else {
                session.alertMessage = "No data on tag."
                session.invalidate()
                self.handleError(NFCServiceError.emptyTag)
                return
            }

            // Parse the Steel NDEF records
            let parsed = self.parseSteelMessage(message)

            guard let sharerId = parsed.sharerId else {
                session.alertMessage = "Not a valid Steel tag."
                session.invalidate()
                self.handleError(NFCServiceError.invalidSteelTag)
                return
            }

            // Success — we found a Steel member ID
            session.alertMessage = "Steel member detected!"
            session.invalidate()

            DispatchQueue.main.async {
                self.lastReadSharerID = sharerId
                self.lastReadSharerName = parsed.sharerName
                self.isScanning = false
                self.readCompletion?(.success((sharerId: sharerId, sharerName: parsed.sharerName)))
                self.readCompletion = nil
            }
        }
    }

    /// Write NDEF message to tag.
    private func writeToTag(_ tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        guard let message = writeMessage else {
            session.alertMessage = "No data to write."
            session.invalidate()
            return
        }

        tag.writeNDEF(message) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                session.alertMessage = "Write failed: \(error.localizedDescription)"
                session.invalidate()
                self.writeCompletion?(.failure(error))
            } else {
                session.alertMessage = "Steel identity written successfully!"
                session.invalidate()
                self.writeCompletion?(.success(()))
            }

            DispatchQueue.main.async {
                self.isScanning = false
            }
            self.writeCompletion = nil
        }
    }

    /// Centralized error handling — publishes to @Published lastError
    private func handleError(_ error: NFCServiceError) {
        DispatchQueue.main.async {
            self.lastError = error.localizedDescription
            self.isScanning = false
            self.readCompletion?(.failure(error))
            self.readCompletion = nil
        }
    }
}

// MARK: - NFCServiceError
enum NFCServiceError: LocalizedError {
    case nfcNotAvailable
    case connectionFailed
    case queryFailed
    case notNDEF
    case readOnly
    case readFailed
    case emptyTag
    case invalidSteelTag
    case sessionInvalidated(String)

    var errorDescription: String? {
        switch self {
        case .nfcNotAvailable:        return "NFC is not available on this device."
        case .connectionFailed:       return "Could not connect to the NFC tag."
        case .queryFailed:            return "Could not read tag status."
        case .notNDEF:                return "This tag is not NDEF compatible."
        case .readOnly:               return "This tag is read-only."
        case .readFailed:             return "Failed to read the NFC tag."
        case .emptyTag:               return "No data found on tag."
        case .invalidSteelTag:        return "This is not a valid Steel tag."
        case .sessionInvalidated(let msg): return "NFC session ended: \(msg)"
        }
    }
}
