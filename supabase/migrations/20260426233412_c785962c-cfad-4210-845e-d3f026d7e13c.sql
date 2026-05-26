-- ============================================================
--  TECHGEN — Supabase SQL Migration
--  Ejecuta en: Supabase Dashboard → SQL Editor
-- ============================================================

-- 1. Tabla de configuración (admin emails, WhatsApp, etc.)
CREATE TABLE IF NOT EXISTS public.app_config (
  id              INTEGER PRIMARY KEY DEFAULT 1,
  admin_emails    TEXT[]      NOT NULL DEFAULT ARRAY['admin@techgen.com'],
  whatsapp_number TEXT        NOT NULL DEFAULT '+51999999999',
  store_name      TEXT        NOT NULL DEFAULT 'Techgen',
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT singleton CHECK (id = 1)
);

INSERT INTO public.app_config (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read config"
  ON public.app_config FOR SELECT USING (true);

CREATE POLICY "Only admins can update config"
  ON public.app_config FOR UPDATE USING (public.is_admin());


-- 2. Función helper: comprueba si el usuario actual es admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.app_config c
    WHERE (auth.jwt() ->> 'email') = ANY(c.admin_emails)
  );
$$;


-- 3. Tabla de productos
CREATE TABLE IF NOT EXISTS public.products (
  id             UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  name           TEXT          NOT NULL,
  description    TEXT          NOT NULL DEFAULT '',
  features       TEXT          NOT NULL DEFAULT '',
  price          NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  original_price NUMERIC(10,2),
  image_url      TEXT          NOT NULL DEFAULT '',
  category       TEXT          NOT NULL DEFAULT 'office'
                               CHECK (category IN ('office','windows','antivirus','vpn','otros')),
  in_stock       BOOLEAN       NOT NULL DEFAULT true,
  rating         INTEGER       NOT NULL DEFAULT 5 CHECK (rating BETWEEN 1 AND 5),
  created_at     TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ   NOT NULL DEFAULT now()
);

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view products"   ON public.products FOR SELECT USING (true);
CREATE POLICY "Admins can insert products" ON public.products FOR INSERT WITH CHECK (public.is_admin());
CREATE POLICY "Admins can update products" ON public.products FOR UPDATE USING (public.is_admin());
CREATE POLICY "Admins can delete products" ON public.products FOR DELETE USING (public.is_admin());


-- 4. Trigger updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;

DROP TRIGGER IF EXISTS update_products_updated_at ON public.products;
CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON public.products
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


-- 5. Tabla de órdenes
CREATE TABLE IF NOT EXISTS public.orders (
  id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID          REFERENCES auth.users(id) ON DELETE SET NULL,
  user_email  TEXT,
  items       JSONB         NOT NULL DEFAULT '[]',
  total       NUMERIC(10,2) NOT NULL DEFAULT 0,
  status      TEXT          NOT NULL DEFAULT 'pending'
                            CHECK (status IN ('pending','paid','cancelled','delivered')),
  notes       TEXT,
  created_at  TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ   NOT NULL DEFAULT now()
);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own orders" ON public.orders FOR SELECT USING (auth.uid() = user_id OR public.is_admin());
CREATE POLICY "Users can insert own orders" ON public.orders FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins can update orders" ON public.orders FOR UPDATE USING (public.is_admin());

DROP TRIGGER IF EXISTS update_orders_updated_at ON public.orders;
CREATE TRIGGER update_orders_updated_at
  BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


-- 6. Productos de ejemplo
INSERT INTO public.products (name, description, features, price, original_price, image_url, category, rating) VALUES
('Microsoft Office 2021 Professional Plus','Licencia digital original para Office 2021 Pro Plus. Activación de por vida en 1 PC.','Word, Excel, PowerPoint, Outlook, Access, Publisher'||chr(10)||'Licencia de por vida'||chr(10)||'1 PC con Windows 10/11'||chr(10)||'Entrega inmediata 24/7',35.00,120.00,'https://images.unsplash.com/photo-1633419461186-7d40a38105ec?w=600','office',5),
('Microsoft Office 2019 Professional Plus','Licencia genuina Office 2019 con activación permanente.','Word, Excel, PowerPoint, Outlook'||chr(10)||'Activación permanente'||chr(10)||'1 PC Windows'||chr(10)||'Soporte por correo',25.00,90.00,'https://images.unsplash.com/photo-1611174743420-3d7df880ce32?w=600','office',5),
('Windows 11 Pro — Licencia Digital','Clave original Windows 11 Pro. Activación online inmediata.','Activación online permanente'||chr(10)||'1 PC'||chr(10)||'Upgrade desde Win 10 disponible'||chr(10)||'Incluye actualizaciones gratuitas',45.00,150.00,'https://images.unsplash.com/photo-1624571409108-e9a41746af53?w=600','windows',5),
('Windows 10 Pro — Licencia Digital','Licencia original Windows 10 Pro de por vida.','Activación de por vida'||chr(10)||'BitLocker incluido'||chr(10)||'Remote Desktop'||chr(10)||'1 PC',35.00,120.00,'https://images.unsplash.com/photo-1535303311164-664fc9ec6532?w=600','windows',5)
ON CONFLICT DO NOTHING;


-- ⚠️  IMPORTANTE: Cambia este email por el tuyo antes de ejecutar
UPDATE public.app_config
SET admin_emails = ARRAY['tu@email.com']
WHERE id = 1;
