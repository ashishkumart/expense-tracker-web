# Expense Tracker Web

A responsive Flutter Web application backed by an Express/MongoDB REST API.
The frontend uses Material 3 and `flutter_bloc`; the API follows an MVC
structure with Mongoose models, request validation, and aggregation pipelines.

## Structure

```text
backend/
  src/
    config/       Database configuration
    controllers/  CRUD and aggregation handlers
    middleware/   Validation and error handling
    models/       Mongoose schemas
    routes/       Express routers
    validators/   Request validation rules
frontend/
  lib/
    core/         Configuration, networking, theme, formatting
    features/
      categories/ Data, Cubit, and UI
      dashboard/  Data, Cubit, and UI
    shared/models/
```

## Prerequisites

- Node.js 20 or newer
- Flutter 3.22 or newer with Web enabled
- MongoDB 7+ locally, in Docker, or through MongoDB Atlas

## Backend setup

```bash
cd backend
cp .env.example .env
npm install
npm run dev
```

Configure `backend/.env`:

```dotenv
PORT=5000
MONGODB_URI=mongodb://127.0.0.1:27017/expense_tracker
CLIENT_ORIGINS=http://localhost:3000,http://localhost:8080
NODE_ENV=development
```

For Atlas, replace `MONGODB_URI` with the connection string and keep the
database name in the URI. `CLIENT_ORIGINS` is a comma-separated allowlist; add
the exact origin printed by `flutter run`.

The API is available at `http://localhost:5000/api`. Check it with:

```bash
curl http://localhost:5000/api/health
```

## Frontend setup

```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port 3000 \
  --dart-define=API_BASE_URL=http://localhost:5000/api
```

For a production build:

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://api.example.com/api
```

The default API URL is `http://localhost:5000/api`; `--dart-define` overrides
it at compile time.

## API

### Categories

- `GET /api/categories`
- `POST /api/categories`
- `PUT /api/categories/:id`
- `DELETE /api/categories/:id`

Example body:

```json
{
  "name": "Food",
  "type": "Expense",
  "color": "#E53935"
}
```

Category names are unique within a type. A category referenced by a transaction
cannot be deleted, and its type cannot be changed.

### Transactions

- `GET /api/transactions?month=6&year=2026`
- `POST /api/transactions`
- `PUT /api/transactions/:id`
- `DELETE /api/transactions/:id`
- `GET /api/transactions/summary?month=6&year=2026`
- `GET /api/transactions/breakdown?month=6&year=2026&type=Expense`

Example body:

```json
{
  "amount": 1250.5,
  "date": "2026-06-05T00:00:00.000Z",
  "categoryId": "683f...",
  "note": "Weekly groceries",
  "type": "Expense"
}
```

## Dates and timezones

The UI treats transaction dates as calendar dates. Before sending a date it
constructs midnight UTC (`YYYY-MM-DDT00:00:00.000Z`), and the API calculates
month boundaries in UTC. This prevents browser timezone offsets from moving a
transaction into the preceding or following day. Dates are displayed as
`DD/MM/YYYY`, and amounts use the Indian `en_IN` currency format.
