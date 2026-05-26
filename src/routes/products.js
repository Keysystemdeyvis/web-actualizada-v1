const express  = require("express");
const router   = express.Router();
const supabase = require("../supabaseClient");

// GET /api/products — listar todos (con filtro opcional por categoría)
router.get("/", async (req, res) => {
  const { category } = req.query;

  let query = supabase
    .from("products")
    .select("*")
    .eq("active", true)
    .order("created_at", { ascending: false });

  if (category) query = query.eq("category", category);

  const { data, error } = await query;
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

// GET /api/products/:id — detalle de un producto
router.get("/:id", async (req, res) => {
  const { data, error } = await supabase
    .from("products")
    .select("*")
    .eq("id", req.params.id)
    .single();

  if (error) return res.status(404).json({ error: "Producto no encontrado" });
  res.json(data);
});

module.exports = router;
