const express  = require("express");
const router   = express.Router();
const supabase = require("../supabaseClient");

// POST /api/auth/register
router.post("/register", async (req, res) => {
  const { email, password, full_name } = req.body;
  if (!email || !password) return res.status(400).json({ error: "Email y contraseña requeridos" });

  const { data, error } = await supabase.auth.admin.createUser({
    email,
    password,
    user_metadata: { full_name },
    email_confirm: true,
  });

  if (error) return res.status(400).json({ error: error.message });
  res.status(201).json({ message: "Usuario creado", user: data.user });
});

// POST /api/auth/login
router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) return res.status(401).json({ error: "Credenciales incorrectas" });

  res.json({ session: data.session, user: data.user });
});

module.exports = router;
