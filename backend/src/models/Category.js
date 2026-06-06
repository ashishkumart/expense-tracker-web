import mongoose from 'mongoose';

const categorySchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true, maxlength: 60 },
    type: { type: String, required: true, enum: ['Income', 'Expense'], index: true },
    color: {
      type: String,
      required: true,
      uppercase: true,
      match: [/^#[0-9A-F]{6}$/, 'Color must be a 6-digit hex value'],
    },
  },
  { timestamps: true, versionKey: false },
);

categorySchema.index({ name: 1, type: 1 }, { unique: true });

export const Category = mongoose.model('Category', categorySchema);
