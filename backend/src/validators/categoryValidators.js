import { body, param } from 'express-validator';

const fields = [
  body('name').trim().notEmpty().isLength({ max: 60 }),
  body('type').isIn(['Income', 'Expense']),
  body('color').matches(/^#[0-9a-fA-F]{6}$/),
];

export const createCategoryRules = fields;
export const updateCategoryRules = fields;
export const categoryIdRule = [param('id').isMongoId()];
