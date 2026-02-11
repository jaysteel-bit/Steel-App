// routes/profiles.js
// Steel by Exo — Profile Routes (Convex Storage Stub)
//
// Endpoints:
//   GET  /api/profiles/:id         — Fetch a member's profile
//   PUT  /api/profiles/:id         — Update a member's profile
//
// PRIVACY GRADIENT:
//   ?level=public  → Returns only the public layer (name, photo, headline, tier)
//   ?level=full    → Returns all layers (requires valid verification session)
//
// The public layer is what shows during NFC verification (blurred/teaser).
// The full layer is revealed after successful PIN verification.
//
// TODO: Replace mock data with real Convex queries

const express = require("express");
const router = express.Router();

// Mock profile database (replace with Convex in production)
const profiles = {
  steel_001: {
    id: "steel_001",
    firstName: "Alex",
    lastName: "Rivera",
    headline: "Creative Director | NYC",
    bio: "Building the future of digital identity and curated experiences.",
    avatarURL: "https://randomuser.me/api/portraits/men/32.jpg",
    membershipTier: "steel",
    publicSocials: [
      {
        id: "s1",
        platform: "instagram",
        handle: "@alex.rivera",
        url: "https://instagram.com/alex.rivera",
      },
      {
        id: "s2",
        platform: "linkedin",
        handle: "LinkedIn",
        url: "https://linkedin.com/in/alexrivera",
      },
      {
        id: "s3",
        platform: "phone",
        handle: "Contact",
      },
    ],
    phoneNumber: "+1 (555) 123-4567",
    email: "alex@exo.dev",
    privateSocials: [
      {
        id: "s4",
        platform: "twitter",
        handle: "@alexr_creates",
        url: "https://twitter.com/alexr_creates",
      },
    ],
  },
};

// GET /api/profiles/:id
// Query: ?level=public|full&session=sessionId
router.get("/:id", (req, res) => {
  const { id } = req.params;
  const { level } = req.query;

  const profile = profiles[id];

  if (!profile) {
    return res.status(404).json({ error: "Profile not found" });
  }

  // Public level — only share public layer
  if (level === "public") {
    return res.json({
      id: profile.id,
      firstName: profile.firstName,
      lastName: profile.lastName,
      headline: profile.headline,
      avatarURL: profile.avatarURL,
      membershipTier: profile.membershipTier,
      publicSocials: profile.publicSocials,
      // Private fields omitted
      phoneNumber: null,
      email: null,
      privateSocials: [],
    });
  }

  // Full level — return everything
  // TODO: Validate session ID to ensure PIN was verified
  return res.json(profile);
});

// PUT /api/profiles/:id
// Body: Full profile object
router.put("/:id", (req, res) => {
  const { id } = req.params;

  // TODO: Validate auth token, update in Convex
  profiles[id] = { ...profiles[id], ...req.body };

  console.log(`[PROFILE] Updated profile: ${id}`);
  res.json({ success: true, profile: profiles[id] });
});

module.exports = router;
