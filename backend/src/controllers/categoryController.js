import { Category } from '../models/Category.js';
import { Transaction } from '../models/Transaction.js';
import { ApiError } from '../utils/ApiError.js';
import { asyncHandler } from '../utils/asyncHandler.js';

export const getCategories = asyncHandler(async (req, res) => {
  const filter = req.query.type ? { type: req.query.type } : {};
  const categories = await Category.find(filter).sort({ type: 1, name: 1 }).lean();
  res.json(categories);
});

export const createCategory = asyncHandler(async (req, res) => {
  const category = await Category.create(req.body);
  res.status(201).json(category);
});

export const updateCategory = asyncHandler(async (req, res) => {
  const existing = await Category.findById(req.params.id);
  if (!existing) throw new ApiError(404, 'Category not found');

  if (req.body.type !== existing.type) {
    const used = await Transaction.exists({ categoryId: existing._id });
    if (used) throw new ApiError(409, 'Cannot change the type of a category used by transactions');
  }

  Object.assign(existing, req.body);
  await existing.save();
  res.json(existing);
});

export const deleteCategory = asyncHandler(async (req, res) => {
  const used = await Transaction.exists({ categoryId: req.params.id });
  if (used) throw new ApiError(409, 'Cannot delete a category used by transactions');

  const category = await Category.findByIdAndDelete(req.params.id);
  if (!category) throw new ApiError(404, 'Category not found');
  res.status(204).send();
});
