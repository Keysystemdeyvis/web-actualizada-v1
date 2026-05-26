# Backend — Super Store Hub

Node.js + Express + Supabase

## Instalación
```bash
cd backend
npm install
```

## Correr en desarrollo
```bash
npm run dev
```

## Endpoints

| Método | Ruta                  | Descripción                   | Auth |
|--------|-----------------------|-------------------------------|------|
| GET    | /api/health           | Estado del servidor           | No   |
| GET    | /api/products         | Listar productos              | No   |
| GET    | /api/products/:id     | Detalle de producto           | No   |
| POST   | /api/auth/register    | Registrar usuario             | No   |
| POST   | /api/auth/login       | Iniciar sesión                | No   |
| POST   | /api/orders           | Crear pedido                  | Sí   |
| GET    | /api/orders/me        | Mis pedidos                   | Sí   |
