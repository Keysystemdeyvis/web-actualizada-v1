require("dotenv").config();
const express = require("express");
const cors = require("cors");
const path = require("path");

const productRoutes = require("./routes/products");
const authRoutes = require("./routes/auth");
const orderRoutes = require("./routes/orders");

const app = express();
const PORT = process.env.PORT || 3001;

// ── Middleware ──────────────────────────────────────────────
app.use(
  cors({
    origin: [
      "http://localhost:5173",
      "http://localhost:3001",
    ],
    credentials: true,
  })
);

app.use(express.json());

console.log("productRoutes:", productRoutes);
console.log("authRoutes:", authRoutes);
console.log("orderRoutes:", orderRoutes);
// ── API Routes ──────────────────────────────────────────────
app.use("/api/products", productRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/orders", orderRoutes);

// Health check
app.get("/api/health", (_req, res) => {
  res.json({
    status: "ok",
    message: "Super Store Hub API running 🚀",
  });
});

// ── Servir React build (dist) ───────────────────────────────
const distPath = path.join(__dirname, "../dist");

// Archivos estáticos
app.use(express.static(distPath));

// Soporte React Router DOM
app.get("*", (req, res) => {
  // Ignorar APIs
  if (req.path.startsWith("/api")) {
    return res.status(404).json({
      error: "Ruta API no encontrada",
    });
  }

  res.sendFile(path.join(distPath, "index.html"));
});

// ── Start server ────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`✅ Server running on http://localhost:${PORT}`);
});