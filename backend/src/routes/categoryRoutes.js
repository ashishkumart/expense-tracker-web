import { Router } from 'express';
import {
  createCategory,
  deleteCategory,
  getCategories,
  updateCategory,
} from '../controllers/categoryController.js';
import { validate } from '../middleware/validate.js';
import {
  categoryIdRule,
  createCategoryRules,
  updateCategoryRules,
} from '../validators/categoryValidators.js';

export const categoryRouter = Router();
categoryRouter.get('/', getCategories);
categoryRouter.post('/', createCategoryRules, validate, createCategory);
categoryRouter.put('/:id', [...categoryIdRule, ...updateCategoryRules], validate, updateCategory);
categoryRouter.delete('/:id', categoryIdRule, validate, deleteCategory);
