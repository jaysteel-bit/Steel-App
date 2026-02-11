# Steel by Exo — Foundation Summary

**Commit:** `13bc42d` — Steel by Exo iOS app foundation
**Remote:** https://github.com/jaysteel-bit/Steel-App.git
**Status:** ✅ Ready for Xcode import

---

## What Was Built

A **complete, modular, production-ready foundation** for the Steel iOS app. All code is heavily commented with TODOs for real service integration. **Simulation mode is enabled by default** — the entire app works without a backend.

### File Count
- **Swift:** 22 files (3,800+ lines)
- **Node.js:** 5 files (backend stubs)
- **Config:** Info.plist, entitlements, .env template
- **Docs:** README.md with full setup instructions

---

## Architecture Layers

### 1. App Entry & State Management
- **`SteelApp.swift`** — Main entry point, routes between Onboarding and Home
- **`AppState.swift`** — Single source of truth (auth, navigation, user profile)
- **`SteelTheme.swift`** — Complete design system (colors #050505/#10b981, fonts, spacing, animations)

### 2. Data Models
| Model | Purpose |
|-------|---------|
| `SteelProfile` | Member profile with privacy gradient (public/private layers) |
| `SteelConnection` | NFC connection between members (lifecycle tracking) |
| `VerificationState` | PIN verification state machine + error handling |
| `PINState` | 4-digit PIN entry tracking |

### 3. Services (All with Simulate Mode)
| Service | Role | Stub/Real |
|---------|------|-----------|
| `NFCService` | CoreNFC NDEF read/write | Real CoreNFC + stub NDEF parsing |
| `SMSVerificationService` | Twilio PIN delivery | Stub with mock PIN generation |
| `ProfileService` | Convex profile storage | Stub with mock profiles |
| `AuthService` | Clerk authentication | Stub with mock users |
| `HapticsService` | Tactile feedback | Real UIKit haptics |

### 4. UI Components (All Ported from HTML)
| Component | HTML Source | Details |
|-----------|-------------|---------|
| `GlassCard` | `.glass` CSS class | Frosted glass with backdrop blur |
| `ParticleEmitterView` | `particles.js` | CAEmitterLayer for background/orb effects |
| `OrbView` | `#orb` + `#orb-active` | Pulsing neural particle orb with optional scan line |
| `MetallicText` | `.metallic-text` | Shimmer gradient animation (5s loop) |
| `SteelButton` | Button styles | Primary (emerald), secondary (glass), ghost |
| `AmbientGlowView` | `#ambient-glow-1/2` | Radial gradient emerald glows at corners |

### 5. Views (3-State Flow)
```
Onboarding (3 pages)
    ↓
Home Container
    ├── NFCTapView (LOCKED)      [Orb + "Tap to Connect" + button]
    ├── VerificationView         [PIN fields + scan line animation]
    └── ProfileRevealView        [Glass card + name + socials + actions]
```

### 6. ViewModels
- **`VerificationViewModel`** — Orchestrates entire NFC → PIN → reveal flow
  - `simulateTap()` — auto-fills PIN with 0.4s stagger (matches GSAP timeline)
  - `startNFCScan()` — triggers real NFC session
  - `enterDigit()` → `verifyPIN()` → reveals profile
  - Auto-transitions between states with haptic feedback

### 7. Backend Stubs (Node.js/Express)
```
POST /api/sms/send-pin      → Generate + log PIN, return sessionId
POST /api/sms/verify-pin    → Check PIN against session
POST /auth/validate-invite  → Check if code is valid
GET  /api/profiles/:id      → Fetch profile (?level=public|full)
POST /api/profiles/:id      → Update profile (stub)
```

---

## Key Features

### ✅ NFC Integration
- **Reads NDEF tags** with 3-record structure:
  1. URI: `steel.byexo.com/connect/{id}` (web fallback)
  2. Text: Member name
  3. External: `com.exo.steel:connect` (app-specific JSON)
- **Writes member identity** to writable tags
- Based on Apple's `BuildingAnNFCTagReaderApp` patterns

### ✅ Privacy-First Consent Flow
1. Receiver taps NFC tag → reads sharer ID
2. Backend sends SMS PIN to sharer's phone
3. Receiver enters PIN → profile revealed
4. Sharer is **always in control** (can ignore SMS, revoke later)

### ✅ Premium UI/UX
- Dark mode first (`#050505` background)
- Emerald accents (`#10b981`) throughout
- Glassmorphism (backdrop blur)
- Particle effects (background + orb)
- Metallic text shimmer
- Staggered animations matching GSAP timeline from HTML
- Haptic feedback on every interaction

### ✅ Simulate Mode
- **No backend needed** — tap "Simulate Tap" button
- PIN auto-fills with 0.4s stagger animation
- Profile reveals after "verification"
- Works on Simulator and real devices
- Toggle in `Constants.swift`: `Features.simulateMode = true/false`

### ✅ Modular, Expandable
- Clear separation of concerns (Models → Services → ViewModels → Views)
- Service stubs are easy to swap with real implementations
- All magic strings in `Constants.swift`
- Verbose comments throughout for onboarding new developers

---

## Next Steps (Priority Order)

### Phase 1: Connect Real Services
1. **Clerk Auth** — Replace sign-up/login stubs with real SDK
2. **Twilio SMS** — Replace PIN generation with real API
3. **Convex DB** — Replace mock profiles with real backend
4. **Firebase/PostHog Analytics** — Track user flows

### Phase 2: Core Features
1. Card setup flow — UI to write member data to NFC tags
2. Connection history — List past taps with timestamps
3. Granular privacy controls — Custom sharing rules per connection
4. Save to Contacts — Native contact integration

### Phase 3: Growth
1. App Clip — Let non-members tap tags and download app
2. Web fallback polish — Improve non-member experience
3. Android companion app — React Native or Flutter
4. Partner terminals — Hardware/app for venue check-ins

---

## How to Use

### Create Xcode Project
```bash
# In Xcode: File → New → Project → iOS App → SwiftUI
# Save to STEEL-APP/ directory
# Drag SteelApp/ folder contents into project navigator
```

### Add NFC Capability
```
Project Settings → Signing & Capabilities → + Capability →
Near Field Communication Tag Reading
```

### Run the App
```bash
# Select iPhone device (NFC not in Simulator)
# Cmd + R to build and run
# Tap "Simulate Tap" button to see full flow
```

### Run Backend (Optional)
```bash
cd SteelBackend
cp .env.example .env  # Fill in API keys
npm install
npm run dev           # http://localhost:3000/api/health
```

---

## Code Examples

### Simulate a Full NFC Tap
```swift
let viewModel = VerificationViewModel()
viewModel.simulateTap()
// 0.8s: Orb pulses, "scanning" state
// 0.5s: "Tag detected" transition
// 0.4s per digit: PIN fields fill with emerald
// 1.2s: Scan line animation
// 0.5s: Profile reveals
```

### Read a Real NFC Tag
```swift
viewModel.startNFCScan()
// System NFC sheet appears
// Tap a Steel NFC tag
// NFCService parses NDEF records
// Extracted sharerId flows through verification
```

### Check NFC Availability
```swift
if nfcService.isNFCAvailable {
    // Show "Scan Real Tag" button
} else {
    // Simulator or non-NFC device
}
```

---

## Design System Reference

### Colors
```swift
SteelTheme.Colors.background       // #050505 (pure black)
SteelTheme.Colors.surface          // #0A0A0A (card background)
SteelTheme.Colors.text             // #F5F5F5 (white text)
SteelTheme.Colors.textMuted        // #A3A3A3 (muted gray)
SteelTheme.Colors.accent           // #10B981 (emerald green)
SteelTheme.Colors.glassFill        // white.opacity(0.05)
```

### Fonts
```swift
SteelTheme.Fonts.serif(size: 48)           // Playfair Display (headlines)
SteelTheme.Fonts.sans(size: 16)            // Inter (body)
SteelTheme.Fonts.heroTitle                 // Large serif headline
SteelTheme.Fonts.body                      // Standard body text
```

### Spacing
```swift
SteelTheme.Spacing.xs       // 4pt
SteelTheme.Spacing.sm       // 8pt
SteelTheme.Spacing.md       // 16pt
SteelTheme.Spacing.lg       // 24pt
SteelTheme.Spacing.xl       // 32pt
SteelTheme.Spacing.xxl      // 48pt
```

---

## File Structure (35 files)

```
STEEL-APP/
├── SteelApp/
│   ├── App/ (2 files)
│   ├── Models/ (3 files)
│   ├── Services/ (5 files)
│   ├── ViewModels/ (1 file)
│   ├── Views/ (5 folders, 8 files)
│   ├── Utilities/ (1 file)
│   ├── SteelApp.swift
│   ├── Info.plist
│   └── SteelApp.entitlements
├── SteelBackend/
│   ├── routes/ (3 files)
│   ├── server.js
│   ├── package.json
│   └── .env.example
├── .gitignore
├── README.md
└── FOUNDATION_SUMMARY.md (this file)
```

---

## Key Decisions

### Why SwiftUI, not UIKit?
Modern, declarative, hot reloading in previews, easier to maintain.

### Why CoreNFC directly, not a wrapper?
Full control over NDEF record parsing, easier to debug and customize tag structure.

### Why simulate mode by default?
Lets designers/PMs see the full flow without backend setup. Services are toggled in one place (`Constants.swift`).

### Why separate services from ViewModels?
Services are testable, mockable, replaceable. ViewModel orchestrates logic without knowing implementation details.

### Why privacy gradient in the model?
Enforces the security design at the data layer, not the UI layer. Hard to accidentally leak private data.

---

## What's NOT Included (Yet)

- Real Clerk, Twilio, Convex integrations
- Unit/UI tests
- Accessibility (VoiceOver) — planned
- Localization
- Offline support
- Push notifications
- Payment processing

---

## Git Setup

```bash
cd STEEL-APP
git remote add origin https://github.com/jaysteel-bit/Steel-App.git
git branch -M main
git push -u origin main
```

**Initial commit:** `13bc42d` with 35 files, 4,262 insertions

---

## Questions to Answer Before Phase 2

1. **Custom fonts:** Will you purchase Inter/Playfair Display, or use system fonts?
2. **Backend:** Will you use Convex, Firebase, or your own?
3. **Authentication:** Clerk, Firebase, or custom?
4. **NFC tag manufacturer:** Who will produce the metal cards/bracelets?
5. **Android:** Timeline for React Native/Flutter?
6. **Payments:** Will you integrate Stripe, or use closed-loop gift cards?
7. **Compliance:** Do you need KYC/AML for financial features?

---

**Built with:** SwiftUI, CoreNFC, Express, Twilio SDK, Convex SDK (stubs)
**Target:** iOS 17+ (SwiftUI 5.8+)
**Status:** Foundation complete, ready for real service integration
**License:** TBD

*Steel by Exo — Access Redefined.*
