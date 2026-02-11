// server.js
// Steel by Exo — Backend API Server
//
// Express server providing endpoints for:
//   - SMS PIN verification (Twilio)
//   - User authentication (Clerk Auth)
//   - Profile storage/retrieval (Convex)
//
// This is a STUB backend for development. Each route has
// simulated responses so the iOS app can be built and tested
// without real service credentials.
//
// To run:
//   cp .env.example .env   (then fill in your keys)
//   npm install
//   npm run dev             (uses nodemon for auto-reload)

require("dotenv").config();
const express = require("express");
const cors = require("cors");
const { v4: uuidv4 } = require("uuid");

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Import route modules
const smsRoutes = require("./routes/sms");
const authRoutes = require("./routes/auth");
const profileRoutes = require("./routes/profiles");

// Mount routes
app.use("/api/sms", smsRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/profiles", profileRoutes);

// Health check
app.get("/api/health", (req, res) => {
  res.json({
    status: "ok",
    service: "steel-backend",
    version: "0.1.0",
    timestamp: new Date().toISOString(),
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`\n  Steel Backend running on http://localhost:${PORT}`);
  console.log(`  Health check: http://localhost:${PORT}/api/health\n`);
});
