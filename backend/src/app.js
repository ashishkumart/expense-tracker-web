import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';
import { errorHandler, notFound } from './middleware/errorHandler.js';
import { categoryRouter } from './routes/categoryRoutes.js';
import { transactionRouter } from './routes/transactionRoutes.js';

export function createApp() {
  const app = express();
  const origins = (process.env.CLIENT_ORIGINS ?? 'http://localhost:3000')
    .split(',')
    .map((origin) => origin.trim());

  app.use(helmet());
  app.use(cors({ origin: origins, methods: ['GET', 'POST', 'PUT', 'DELETE'] }));
  app.use(express.json({ limit: '100kb' }));
  app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

  app.get('/api/health', (_req, res) => res.json({ status: 'ok' }));
  app.use('/api/categories', categoryRouter);
  app.use('/api/transactions', transactionRouter);
  app.use(notFound);
  app.use(errorHandler);
  return app;
}
