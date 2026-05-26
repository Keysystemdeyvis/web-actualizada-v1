const express              = require("express");
const router               = express.Router();
const supabase             = require("../supabaseClient");
const { requireAuth }      = require("../middleware/auth");

// POST /api/orders — crear pedido (requiere login)
router.post("/", requireAuth, async (req, res) => {
  const { items } = req.body; // [{ product_id, quantity, price }]
  if (!items?.length) return res.status(400).json({ error: "Items requeridos" });

  const total = items.reduce((sum, i) => sum + i.price * i.quantity, 0);

  const { data: order, error } = await supabase
    .from("orders")
    .insert({ user_id: req.user.id, items, total, status: "pending" })
    .select()
    .single();

  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json(order);
});

// GET /api/orders/me — pedidos del usuario logueado
router.get("/me", requireAuth, async (req, res) => {
  const { data, error } = await supabase
    .from("orders")
    .select("*")
    .eq("user_id", req.user.id)
    .order("created_at", { ascending: false });

  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

module.exports = router;
