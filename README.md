# Steel by Exo — iOS App Foundation

**The definitive identity ecosystem for the exceptional.**
Tap. Verify. Connect — with absolute control.

*Early stage of development*
---

## What is Steel?

Steel is a privacy-first NFC tap-to-share social ecosystem. Members tap phones/cards to share profiles (name, bio, social links, phone), but sharing requires real-time consent via SMS PIN verification. The app is invitation-only and designed with a premium cyber-luxury aesthetic.

**Core Flow:**
```
NFC Tap → Read Sharer ID → SMS PIN to Sharer → Receiver Enters PIN → Profile Revealed
```

---

## Project Structure

```
STEEL-APP/
├── SteelApp/                          # iOS App (SwiftUI)
│   ├── SteelApp.swift                 # App entry point (@main)
│   ├── Info.plist                     # NFC permissions, URL schemes, ATS config
│   ├── SteelApp.entitlements          # NFC + Associated Domains capabilities
│   │
│   ├── App/
│   │   ├── AppState.swift             # Global state (auth, navigation)
│   │   └── SteelTheme.swift           # Design system (colors, fonts, spacing)
│   │
│   ├── Models/
│   │   ├── SteelProfile.swift         # Member profile (public/private layers)
│   │   ├── SteelConnection.swift      # NFC connection between members
│   │   └── VerificationState.swift    # PIN verification state machine
│   │
│   ├── Services/
│   │   ├── NFCService.swift           # CoreNFC read/write (NDEF tags)
│   │   ├── SMSVerificationService.swift  # Twilio SMS PIN (stub)
│   │   ├── ProfileService.swift       # Convex profile storage (stub)
│   │   ├── AuthService.swift          # Clerk authentication (stub)
│   │   └── HapticsService.swift       # Tactile feedback
│   │
│   ├── ViewModels/
│   │   └── VerificationViewModel.swift  # Orchestrates tap→verify→reveal flow
│   │
│   ├── Views/
│   │   ├── Onboarding/
│   │   │   └── OnboardingView.swift   # Welcome + brand intro + get started
│   │   ├── Home/
│   │   │   └── HomeView.swift         # Main screen (3-state container)
│   │   ├── NFC/
│   │   │   └── NFCTapView.swift       # Locked state: orb + "Tap to Connect"
│   │   ├── Verification/
│   │   │   └── VerificationView.swift # PIN entry + scan animation
│   │   ├── Profile/
│   │   │   └── ProfileRevealView.swift  # Unlocked profile card
│   │   └── Components/
│   │       ├── GlassCard.swift        # Glassmorphism container
│   │       ├── ParticleEmitterView.swift  # CAEmitterLayer particles
│   │       ├── OrbView.swift          # Animated particle orb
│   │       ├── MetallicText.swift     # Shimmer gradient text
│   │       ├── SteelButton.swift      # Branded button styles
│   │       └── AmbientGlowView.swift  # Background emerald glow
│   │
│   └── Utilities/
│       └── Constants.swift            # API URLs, feature flags, config
│
├── SteelBackend/                      # Node.js API Server (stubs)
│   ├── package.json
│   ├── server.js                      # Express entry point
│   ├── .env.example                   # Environment variables template
│   ├── .gitignore
│   └── routes/
│       ├── sms.js                     # POST /sms/send-pin, /sms/verify-pin
│       ├── auth.js                    # POST /auth/validate-invite, /auth/signup
│       └── profiles.js               # GET/PUT /profiles/:id
│
└── README.md
```

---

## Setup Instructions

### Prerequisites

- **macOS** with Xcode 15+ installed
- **iPhone** with NFC capability (iPhone 7+) — NFC doesn't work in Simulator
- **Node.js** 18+ (for backend stubs)
- Apple Developer account (for NFC entitlements)

### 1. Create Xcode Project

Since this project was scaffolded as source files (not a .xcodeproj), create the project in Xcode:

1. Open Xcode → **File → New → Project**
2. Choose **iOS → App**
3. Configure:
   - Product Name: `SteelApp`
   - Team: Your Apple Developer team
   - Organization Identifier: `com.exo`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: None
4. Save to the `STEEL-APP/` directory
5. **Delete** the auto-generated `ContentView.swift` (we have our own views)
6. **Drag** the `SteelApp/` folder contents into the Xcode project navigator

### 2. Configure NFC Capability

1. Select the project in Xcode → **Signing & Capabilities**
2. Click **+ Capability** → search for **Near Field Communication Tag Reading**
3. Ensure the `SteelApp.entitlements` file matches our provided one
4. The `Info.plist` already includes `NFCReaderUsageDescription`

### 3. Add Custom Fonts (Optional)

To match the web prototype exactly:

1. Download [Inter](https://fonts.google.com/specimen/Inter) and [Playfair Display](https://fonts.google.com/specimen/Playfair+Display) and [**Urbanist**](https://fonts.google.com/specimen/Urbanist) - double check the urbanist font URL
2. Add `.ttf` files to the Xcode project
3. Add them to `Info.plist` under `Fonts provided by application`
4. Update `SteelTheme.Fonts` to use `.custom("Inter-Regular", size:)` etc.

Until then, the app uses system fonts with `.serif` and `.default` designs as close approximations.

### 4. Run the Backend (Optional)

The iOS app works in **simulate mode** without the backend. To run it:

```bash
cd STEEL-APP/SteelBackend
cp .env.example .env        # Edit with your API keys
npm install
npm run dev                  # Starts on http://localhost:3000
```

Then in `Constants.swift`, set `Features.simulateMode = false`.

### 5. Build & Run

1. Connect your iPhone via USB (or use wireless debugging)
2. Select your device as the run target
3. **Build & Run** (Cmd + R)
4. On the simulator, the full UI works with the "Simulate Tap" button
5. On a real device, you can also tap real NFC tags

---

## Design System

All visual constants are in `SteelTheme.swift`. The design language:

| Token | Value | Usage |
|-------|-------|-------|
| `Colors.background` | `#050505` | App background |
| `Colors.surface` | `#0A0A0A` | Card/container background |
| `Colors.surfaceAlt` | `#1F1F1F` | Inputs, PIN fields |
| `Colors.text` | `#F5F5F5` | Primary text |
| `Colors.textMuted` | `#A3A3A3` | Secondary text |
| `Colors.accent` | `#10B981` | Emerald — CTAs, badges, accents |
| `Fonts.serif()` | Playfair Display | Headlines, names |
| `Fonts.sans()` | Inter | Body, labels, buttons |

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│                    SwiftUI Views                 │
│  OnboardingView → HomeView → ProfileRevealView  │
├─────────────────────────────────────────────────┤
│                   ViewModels                     │
│           VerificationViewModel                  │
│     (orchestrates NFC → PIN → Reveal flow)       │
├─────────────────────────────────────────────────┤
│                    Services                      │
│  NFCService │ SMSService │ ProfileService │ Auth │
├─────────────────────────────────────────────────┤
│                  Backend API                     │
│     Express + Twilio + Convex + Clerk            │
└─────────────────────────────────────────────────┘
```

**Key pattern:** All services have a `simulateMode` flag. When `true`, they return mock data with realistic delays — no backend needed for UI development.

---

## NFC Integration

Steel uses **CoreNFC** for foreground NDEF tag sessions. The NDEF record structure written to physical tags:

| Record | Type | Content | Purpose |
|--------|------|---------|---------|
| 1 | URI | `steel.byexo.com/connect/{id}` | Web fallback for non-app users |
| 2 | Text | Member name | Basic info for any NFC reader |
| 3 | External | `com.exo.steel:connect` + JSON | App-specific encrypted member data |

**Reading:** `NFCService.beginScanning()` → parses records → extracts `sharerId`
**Writing:** `NFCService.writeTag(memberId:memberName:)` → builds NDEF → writes to tag

---

## Verification Flow (Consent-First)

```
1. Receiver taps Sharer's NFC tag
2. App reads Sharer ID from tag
3. App calls backend → SMS PIN sent to Sharer's phone
4. Sharer reads PIN aloud (or shows their phone)
5. Receiver enters 4-digit PIN
6. Backend verifies → Profile revealed if correct
```

The sharer is **always in control**:
- They must be present (SMS goes to their phone)
- They can ignore the SMS (connection expires in 2 min)
- They can revoke a connection at any time

---

## What's Next

This is the **foundation**. Priority additions:

1. **Clerk Auth integration** — real sign-up/login flow
2. **Convex backend** — real-time profile storage
3. **Twilio SMS** — real PIN delivery
4. **Contacts integration** — save profiles to native Contacts
5. **Card setup flow** — UI for writing member data to NFC tags
6. **Connection history** — list of past connections
7. **Privacy controls** — granular sharing settings per connection
8. **App Clip** — for non-members tapping Steel tags

---

## Tech Stack (Current → Planned)

| Layer | Current (Stubs) | Planned |
|-------|----------------|---------|
| Frontend | SwiftUI (iOS 17+) | SwiftUI |
| Auth | Mock | Clerk |
| Database | In-memory | Convex |
| SMS | Console log | Twilio |
| NFC | CoreNFC | CoreNFC |
| Backend | Express (Node.js) | TBD (may change) |
| Analytics | — | PostHog |

---

## Git Setup

```bash
cd STEEL-APP
git init
git add .
git commit -m "Initial Steel by Exo foundation: SwiftUI + CoreNFC + backend stubs"
```

---

*Steel by Exo — Access Redefined.*
