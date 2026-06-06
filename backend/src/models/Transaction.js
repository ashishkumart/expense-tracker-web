import mongoose from 'mongoose';

const transactionSchema = new mongoose.Schema(
  {
    amount: { type: Number, required: true, min: 0.01 },
    date: { type: Date, required: true, index: true },
    categoryId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Category',
      required: true,
      index: true,
    },
    note: { type: String, trim: true, maxlength: 300, default: '' },
    type: { type: String, required: true, enum: ['Income', 'Expense'], index: true },
  },
  { timestamps: true, versionKey: false },
);

transactionSchema.index({ date: -1, type: 1 });

export const Transaction = mongoose.model('Transaction', transactionSchema);
