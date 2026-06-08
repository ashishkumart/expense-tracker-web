import 'dotenv/config';
import { createApp } from './app.js';
import { connectDatabase } from './config/db.js';

const port = Number(process.env.PORT ?? 5000);
const mongoUri = process.env.MONGODB_URI ?? process.env.MONGO_URI;

if (!mongoUri) {
  console.error('MONGODB_URI is required');
  process.exit(1);
}

connectDatabase(mongoUri)
  .then(() => createApp().listen(port, () => console.log(`API listening on port ${port}`)))
  .catch((error) => {
    console.error('Failed to start API', error);
    process.exit(1);
  });
