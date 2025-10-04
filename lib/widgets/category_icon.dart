import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/category_model.dart';

/// Reusable category icon widget
class CategoryIcon extends StatelessWidget {
  final CategoryModel category;
  final double size;
  final bool showBadge;
  final String? badgeText;
  final VoidCallback? onTap;

  const CategoryIcon({
    Key? key,
    required this.category,
    this.size = 48,
    this.showBadge = false,
    this.badgeText,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(size / 6),
            decoration: BoxDecoration(
              color: Color(category.color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(size / 4),
            ),
            child: Center(
              child: Text(category.icon, style: TextStyle(fontSize: size / 2)),
            ),
          ),
          if (showBadge && badgeText != null)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText!,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (category.offersCashback)
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.cashback,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard,
                  size: size / 4,
                  color: AppColors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Grid of category icons for selection
class CategoryIconGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  final Function(CategoryModel) onSelect;
  final int crossAxisCount;

  const CategoryIconGrid({
    Key? key,
    required this.categories,
    this.selectedCategory,
    required this.onSelect,
    this.crossAxisCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = selectedCategory?.id == category.id;

        return InkWell(
          onTap: () => onSelect(category),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Color(category.color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Color(category.color) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(category.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal category chips
class CategoryChipList extends StatelessWidget {
  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  final Function(CategoryModel?) onSelect;
  final bool showAllOption;

  const CategoryChipList({
    Key? key,
    required this.categories,
    this.selectedCategory,
    required this.onSelect,
    this.showAllOption = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (showAllOption)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: const Text('All'),
                selected: selectedCategory == null,
                onSelected: (selected) => onSelect(null),
                selectedColor: AppColors.primary.withOpacity(0.3),
                backgroundColor: AppColors.surfaceLight,
              ),
            ),
          ...categories.map((category) {
            final isSelected = selectedCategory?.id == category.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.icon),
                    const SizedBox(width: 6),
                    Text(category.name),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) => onSelect(category),
                selectedColor: Color(category.color).withOpacity(0.3),
                backgroundColor: AppColors.surfaceLight,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
