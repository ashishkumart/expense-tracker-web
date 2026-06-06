import { Category } from '../models/Category.js';
import { Transaction } from '../models/Transaction.js';
import { ApiError } from '../utils/ApiError.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { getUtcMonthRange } from '../utils/dateRange.js';

async function ensureMatchingCategory(categoryId, type) {
  const category = await Category.findById(categoryId).lean();
  if (!category) throw new ApiError(422, 'Selected category does not exist');
  if (category.type !== type) {
    throw new ApiError(422, `Category type must match transaction type (${category.type})`);
  }
}

export const getTransactions = asyncHandler(async (req, res) => {
  const filter = {};
  if (req.query.month || req.query.year) {
    if (!req.query.month || !req.query.year) {
      throw new ApiError(400, 'month and year must be provided together');
    }
    const { start, end } = getUtcMonthRange(req.query.month, req.query.year);
    filter.date = { $gte: start, $lt: end };
  }
  if (req.query.type) filter.type = req.query.type;
  if (req.query.categoryId) filter.categoryId = req.query.categoryId;

  const transactions = await Transaction.find(filter)
    .populate('categoryId', 'name type color')
    .sort({ date: -1, createdAt: -1 })
    .lean();
  res.json(transactions);
});

export const createTransaction = asyncHandler(async (req, res) => {
  await ensureMatchingCategory(req.body.categoryId, req.body.type);
  const transaction = await Transaction.create(req.body);
  await transaction.populate('categoryId', 'name type color');
  res.status(201).json(transaction);
});

export const updateTransaction = asyncHandler(async (req, res) => {
  await ensureMatchingCategory(req.body.categoryId, req.body.type);
  const transaction = await Transaction.findByIdAndUpdate(req.params.id, req.body, {
    new: true,
    runValidators: true,
  }).populate('categoryId', 'name type color');
  if (!transaction) throw new ApiError(404, 'Transaction not found');
  res.json(transaction);
});

export const deleteTransaction = asyncHandler(async (req, res) => {
  const transaction = await Transaction.findByIdAndDelete(req.params.id);
  if (!transaction) throw new ApiError(404, 'Transaction not found');
  res.status(204).send();
});

export const getMonthlySummary = asyncHandler(async (req, res) => {
  const { start, end } = getUtcMonthRange(req.query.month, req.query.year);
  const totals = await Transaction.aggregate([
    { $match: { date: { $gte: start, $lt: end } } },
    { $group: { _id: '$type', total: { $sum: '$amount' } } },
  ]);

  const income = totals.find((item) => item._id === 'Income')?.total ?? 0;
  const expense = totals.find((item) => item._id === 'Expense')?.total ?? 0;
  res.json({ income, expense, balance: income - expense });
});

export const getCategoryBreakdown = asyncHandler(async (req, res) => {
  const { start, end } = getUtcMonthRange(req.query.month, req.query.year);
  const type = req.query.type ?? 'Expense';
  if (!['Income', 'Expense'].includes(type)) throw new ApiError(400, 'Invalid type');

  const rows = await Transaction.aggregate([
    { $match: { date: { $gte: start, $lt: end }, type } },
    { $group: { _id: '$categoryId', amount: { $sum: '$amount' } } },
    { $lookup: { from: 'categories', localField: '_id', foreignField: '_id', as: 'category' } },
    { $unwind: '$category' },
    { $sort: { amount: -1 } },
    { $project: { _id: 0, categoryId: '$_id', name: '$category.name', color: '$category.color', amount: 1 } },
  ]);
  const total = rows.reduce((sum, row) => sum + row.amount, 0);
  res.json({
    type,
    total,
    categories: rows.map((row) => ({
      ...row,
      percentage: total === 0 ? 0 : Number(((row.amount / total) * 100).toFixed(2)),
    })),
  });
});
