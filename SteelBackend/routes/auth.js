// routes/auth.js
// Steel by Exo — Authentication Routes (Clerk Auth Stub)
//
// Endpoints:
//   POST /api/auth/validate-invite  — Check if an invite code is valid
//   POST /api/auth/signup           — Create a new Steel member account
//   POST /api/auth/signin           — Sign in an existing member
//
// Steel is INVITATION-ONLY. New members need a valid invite code
// from an existing member or from the Steel team.
//
// TODO: Replace stubs with real Clerk SDK integration
// Clerk Node SDK: https://clerk.com/docs/references/node/overview

const express = require("express");
const router = express.Router();
const { v4: uuidv4 } = require("uuid");

// Simulated valid invite codes (replace with Convex lookup in production)
const validInviteCodes = new Set([
  "STEEL2026",
  "EXOACCESS",
  "FOUNDING100",
  "STEELMEMBER",
]);

// POST /api/auth/validate-invite
// Body: { "code": "STEEL2026" }
// Response: { "valid": true/false }
router.post("/validate-invite", (req, res) => {
  const { code } = req.body;

  if (!code) {
    return res.status(400).json({ error: "Invite code is required" });
  }

  const isValid = validInviteCodes.has(code.toUpperCase());
  console.log(`[AUTH] Invite code "${code}": ${isValid ? "VALID" : "INVALID"}`);

  res.json({ valid: isValid });
});

// POST /api/auth/signup
// Body: { "email": "...", "password": "...", "inviteCode": "...", "firstName": "...", "lastName": "..." }
// Response: { "userId": "steel_xxx", "token": "..." }
router.post("/signup", (req, res) => {
  const { email, password, inviteCode, firstName, lastName } = req.body;

  // TODO: Validate invite code, create user via Clerk SDK

  const userId = `steel_${uuidv4().slice(0, 8)}`;
  console.log(`[AUTH] New user created: ${userId} (${email})`);

  res.json({
    userId,
    email,
    firstName,
    lastName,
    token: `mock_token_${uuidv4()}`,
    membershipTier: "digital",
  });
});

// POST /api/auth/signin
// Body: { "email": "...", "password": "..." }
// Response: { "userId": "steel_xxx", "token": "..." }
router.post("/signin", (req, res) => {
  const { email } = req.body;

  // TODO: Authenticate via Clerk SDK

  console.log(`[AUTH] Sign in: ${email}`);

  res.json({
    userId: "steel_001",
    email,
    token: `mock_token_${uuidv4()}`,
  });
});

module.exports = router;
