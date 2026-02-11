// routes/sms.js
// Steel by Exo — SMS PIN Verification Routes
//
// Endpoints:
//   POST /api/sms/send-pin    — Send a 4-digit PIN to the sharer's phone
//   POST /api/sms/verify-pin  — Verify the PIN entered by the receiver
//
// HOW THE CONSENT FLOW WORKS:
//   1. Receiver taps sharer's NFC tag → iOS app reads sharer ID
//   2. App calls POST /api/sms/send-pin with sharerId
//   3. Server looks up sharer's phone number, generates 4-digit PIN
//   4. Server sends SMS via Twilio: "Someone wants your Steel profile. PIN: 7293"
//   5. Sharer reads PIN, tells receiver verbally
//   6. Receiver enters PIN → app calls POST /api/sms/verify-pin
//   7. Server checks PIN → returns { verified: true/false }
//
// This ensures REAL-TIME CONSENT — the sharer must be present and willing.
//
// TODO: Replace in-memory store with Redis/Convex for production

const express = require("express");
const router = express.Router();
const { v4: uuidv4 } = require("uuid");

// In-memory session store (replace with Redis/Convex in production)
const verificationSessions = new Map();

// Generate a random 4-digit PIN
function generatePIN() {
  return Math.floor(1000 + Math.random() * 9000).toString();
}

// POST /api/sms/send-pin
// Body: { "sharerId": "steel_001" }
// Response: { "sessionId": "uuid", "expiresAt": "iso-date", "pinLength": 4 }
router.post("/send-pin", async (req, res) => {
  try {
    const { sharerId } = req.body;

    if (!sharerId) {
      return res.status(400).json({ error: "sharerId is required" });
    }

    const pin = generatePIN();
    const sessionId = uuidv4();
    const expiresAt = new Date(Date.now() + 2 * 60 * 1000); // 2 minutes

    // Store the session
    verificationSessions.set(sessionId, {
      sharerId,
      pin,
      expiresAt,
      verified: false,
    });

    // Auto-cleanup expired sessions after timeout
    setTimeout(() => {
      verificationSessions.delete(sessionId);
    }, 2 * 60 * 1000);

    // TODO: Send SMS via Twilio
    // In production, uncomment and configure:
    //
    // const twilio = require('twilio')(
    //   process.env.TWILIO_ACCOUNT_SID,
    //   process.env.TWILIO_AUTH_TOKEN
    // );
    //
    // // Look up sharer's phone from Convex
    // const sharerPhone = await getSharerPhone(sharerId);
    //
    // await twilio.messages.create({
    //   body: `Someone is requesting your Steel profile. Your PIN: ${pin}\nIf this wasn't you, ignore this message.`,
    //   from: process.env.TWILIO_PHONE_NUMBER,
    //   to: sharerPhone
    // });

    console.log(`[SMS] PIN for sharer ${sharerId}: ${pin} (session: ${sessionId})`);

    res.json({
      sessionId,
      sharerId,
      expiresAt: expiresAt.toISOString(),
      pinLength: 4,
    });
  } catch (error) {
    console.error("[SMS] Error sending PIN:", error);
    res.status(500).json({ error: "Failed to send verification PIN" });
  }
});

// POST /api/sms/verify-pin
// Body: { "sessionId": "uuid", "pin": "7293" }
// Response: { "verified": true/false }
router.post("/verify-pin", (req, res) => {
  try {
    const { sessionId, pin } = req.body;

    if (!sessionId || !pin) {
      return res.status(400).json({ error: "sessionId and pin are required" });
    }

    const session = verificationSessions.get(sessionId);

    if (!session) {
      return res.json({ verified: false, reason: "Session not found or expired" });
    }

    if (new Date() > new Date(session.expiresAt)) {
      verificationSessions.delete(sessionId);
      return res.json({ verified: false, reason: "Session expired" });
    }

    if (session.pin === pin) {
      session.verified = true;
      console.log(`[SMS] PIN verified for session ${sessionId}`);
      return res.json({ verified: true });
    }

    console.log(`[SMS] Wrong PIN for session ${sessionId}: got ${pin}, expected ${session.pin}`);
    return res.json({ verified: false, reason: "Incorrect PIN" });
  } catch (error) {
    console.error("[SMS] Error verifying PIN:", error);
    res.status(500).json({ error: "Failed to verify PIN" });
  }
});

module.exports = router;
