import { body, param } from 'express-validator';

const fields = [
  body('amount').isFloat({ gt: 0 }).toFloat(),
  body('date').isISO8601({ strict: true }).toDate(),
  body('categoryId').isMongoId(),
  body('note').optional().trim().isLength({ max: 300 }),
  body('type').isIn(['Income', 'Expense']),
];

export const createTransactionRules = fields;
export const updateTransactionRules = fields;
export const transactionIdRule = [param('id').isMongoId()];
