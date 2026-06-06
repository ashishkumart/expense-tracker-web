import { Router } from 'express';
import {
  createTransaction,
  deleteTransaction,
  getCategoryBreakdown,
  getMonthlySummary,
  getTransactions,
  updateTransaction,
} from '../controllers/transactionController.js';
import { validate } from '../middleware/validate.js';
import {
  createTransactionRules,
  transactionIdRule,
  updateTransactionRules,
} from '../validators/transactionValidators.js';

export const transactionRouter = Router();
transactionRouter.get('/summary', getMonthlySummary);
transactionRouter.get('/breakdown', getCategoryBreakdown);
transactionRouter.get('/', getTransactions);
transactionRouter.post('/', createTransactionRules, validate, createTransaction);
transactionRouter.put('/:id', [...transactionIdRule, ...updateTransactionRules], validate, updateTransaction);
transactionRouter.delete('/:id', transactionIdRule, validate, deleteTransaction);
