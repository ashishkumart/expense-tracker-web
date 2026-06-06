import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' show ColorPicker;

import '../../../core/utils/formatters.dart';
import '../../../shared/models/category.dart';
import '../logic/category_cubit.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  Future<void> _showEditor(BuildContext context, [Category? category]) async {
    await showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CategoryCubit>(),
        child: _CategoryDialog(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryCubit, CategoryState>(
      listenWhen: (previous, current) =>
          current.message != null && previous.message != current.message,
      listener: (context, state) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message!))),
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categories',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const Text(
                          'Organize income and expenses with custom colors.',
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showEditor(context),
                    icon: const Icon(Icons.add),
                    label: const Text('New category'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: state.status == CategoryStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.categories.isEmpty
                    ? const Center(child: Text('Create your first category.'))
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 320,
                              mainAxisExtent: 140,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: state.categories.length,
                        itemBuilder: (context, index) {
                          final category = state.categories[index];
                          final color = colorFromHex(category.color);
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: color,
                                        foregroundColor:
                                            ThemeData.estimateBrightnessForColor(
                                                  color,
                                                ) ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        child: Icon(
                                          category.type ==
                                                  TransactionType.income
                                              ? Icons.south_west
                                              : Icons.north_east,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        tooltip: 'Edit',
                                        onPressed: () =>
                                            _showEditor(context, category),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete',
                                        onPressed: () =>
                                            _confirmDelete(context, category),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    category.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  Text(category.type.apiValue),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Category category) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete category?'),
            content: Text(
              'Delete "${category.name}"? Categories used by transactions cannot be deleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed && context.mounted) {
      context.read<CategoryCubit>().delete(category.id);
    }
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.category});
  final Category? category;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late TransactionType _type;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.category?.name);
    _type = widget.category?.type ?? TransactionType.expense;
    _color = colorFromHex(widget.category?.color ?? '#6750A4');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saving =
        context.watch<CategoryCubit>().state.status == CategoryStatus.saving;
    return AlertDialog(
      title: Text(widget.category == null ? 'New category' : 'Edit category'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: TransactionType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.apiValue),
                      ),
                    )
                    .toList(),
                onChanged: widget.category == null
                    ? (value) => setState(() => _type = value!)
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Text('Category color')),
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: _pickColor,
                    child: CircleAvatar(backgroundColor: _color),
                  ),
                  const SizedBox(width: 10),
                  Text(colorToHex(_color)),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: saving ? null : _save,
          child: Text(widget.category == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _pickColor() async {
    var selected = _color;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selected,
            onColorChanged: (color) => selected = color,
            enableAlpha: false,
            displayThumbColor: true,
            hexInputBar: true,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (mounted) setState(() => _color = selected);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final saved = await context.read<CategoryCubit>().save(
      existing: widget.category,
      name: _name.text.trim(),
      type: _type,
      color: colorToHex(_color),
    );
    if (saved && mounted) Navigator.pop(context);
  }
}
