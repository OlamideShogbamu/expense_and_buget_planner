import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../models/category_model.dart';
import '../../models/transaction_type.dart';
import '../../services/data_service.dart';

/// Screen for creating or editing custom categories
class AddCategoryScreen extends StatefulWidget {
  final CategoryModel? category;

  const AddCategoryScreen({Key? key, this.category}) : super(key: key);

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedIcon = '📦';
  Color _selectedColor = AppColors.primary;
  TransactionType? _categoryType;
  bool _isCashbackEligible = false;
  double _cashbackRate = 0.05;
  bool _isLoading = false;

  final List<String> _availableIcons = [
    '💰',
    '💵',
    '💳',
    '🏦',
    '📈',
    '📊',
    '💼',
    '🎯',
    '🍽️',
    '🛒',
    '🏪',
    '🛍️',
    '👕',
    '👟',
    '📱',
    '💻',
    '🚗',
    '⛽',
    '🚕',
    '🚌',
    '✈️',
    '🏨',
    '🏖️',
    '🎫',
    '🏥',
    '💊',
    '🏋️',
    '⚽',
    '🎮',
    '🎬',
    '🎵',
    '📚',
    '🏠',
    '🔧',
    '💡',
    '📱',
    '📺',
    '🎁',
    '🎉',
    '❤️',
    '📦',
    '📄',
    '📌',
    '🔔',
    '⭐',
    '✨',
    '🌟',
    '💫',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description ?? '';
      _selectedIcon = widget.category!.icon;
      _selectedColor = Color(widget.category!.color);
      _categoryType = widget.category!.categoryType;
      _isCashbackEligible = widget.category!.isCashbackEligible;
      _cashbackRate = widget.category!.cashbackRate ?? 0.05;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final category = CategoryFactory.createCustom(
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor.value,
        categoryType: _categoryType,
        isCashbackEligible: _isCashbackEligible,
        cashbackRate: _isCashbackEligible ? _cashbackRate : null,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (widget.category == null) {
        await DataService.addCategory(category);
        _showSnackBar('Category created successfully', isError: false);
      } else {
        // Update existing category
        final categories = DataService.getAllCategories();
        final index = categories.indexWhere((c) => c.id == widget.category!.id);
        if (index != -1) {
          await DataService.updateCategory(
            index,
            category.copyWith(
              id: widget.category!.id,
              isDefault: widget.category!.isDefault,
            ),
          );
          _showSnackBar('Category updated successfully', isError: false);
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar('Failed to save category', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.category == null ? 'Create Category' : 'Edit Category',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Preview card
                _buildPreviewCard(),
                const SizedBox(height: 24),

                // Name input
                _buildNameInput(),
                const SizedBox(height: 20),

                // Icon selector
                _buildIconSelector(),
                const SizedBox(height: 20),

                // Color selector
                _buildColorSelector(),
                const SizedBox(height: 20),

                // Type selector
                _buildTypeSelector(),
                const SizedBox(height: 20),

                // Cashback toggle (only for expense categories)
                if (_categoryType == null ||
                    _categoryType == TransactionType.expense) ...[
                  _buildCashbackToggle(),
                  if (_isCashbackEligible) ...[
                    const SizedBox(height: 12),
                    _buildCashbackRateSlider(),
                  ],
                  const SizedBox(height: 20),
                ],

                // Description input
                _buildDescriptionInput(),
                const SizedBox(height: 32),

                // Save button
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _selectedColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _selectedColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(_selectedIcon, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            _nameController.text.isEmpty
                ? 'Category Name'
                : _nameController.text,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Category Name',
        hintText: 'e.g., Entertainment, Groceries',
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a category name';
        }
        if (value.length > 30) {
          return 'Name must be 30 characters or less';
        }
        return null;
      },
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Icon',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final icon = _availableIcons[index];
              final isSelected = _selectedIcon == icon;
              return InkWell(
                onTap: () => setState(() => _selectedIcon = icon),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _selectedColor.withOpacity(0.2)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: _selectedColor, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    final colors = AppColors.categoryColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Color',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            final isSelected = _selectedColor.value == color.value;
            return InkWell(
              onTap: () => setState(() => _selectedColor = color),
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: AppColors.white, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: AppColors.white, size: 24)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Type',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _buildTypeChip('All', null),
            _buildTypeChip('Income', TransactionType.income),
            _buildTypeChip('Expense', TransactionType.expense),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String label, TransactionType? type) {
    final isSelected = _categoryType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _categoryType = type;
          if (type == TransactionType.income) {
            _isCashbackEligible = false;
          }
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.3),
      backgroundColor: AppColors.surfaceLight,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildCashbackToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.card_giftcard, color: AppColors.cashback, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cashback Eligible',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Enable cashback rewards for this category',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isCashbackEligible,
            onChanged: (value) {
              setState(() {
                _isCashbackEligible = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCashbackRateSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cashback Rate',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(_cashbackRate * 100).toInt()}%',
                style: TextStyle(
                  color: AppColors.cashback,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.cashback,
              inactiveTrackColor: AppColors.surfaceLight,
              thumbColor: AppColors.cashback,
              overlayColor: AppColors.cashback.withOpacity(0.2),
            ),
            child: Slider(
              value: _cashbackRate,
              min: 0.01,
              max: 0.10,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _cashbackRate = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Add a description for this category',
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      maxLength: 100,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveCategory,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text(
                widget.category == null ? 'Create Category' : 'Update Category',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
      ),
    );
  }
}
