import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/period_provider.dart';
import '../../shared/widgets/app_button.dart';

class DietaryPreferencesDialog extends StatefulWidget {
  const DietaryPreferencesDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DietaryPreferencesDialog(),
    );
  }

  @override
  State<DietaryPreferencesDialog> createState() =>
      _DietaryPreferencesDialogState();
}

class _DietaryPreferencesDialogState extends State<DietaryPreferencesDialog> {
  late List<String> _selectedAllergies;
  late List<String> _selectedCravings;
  bool _isSaving = false;

  static const List<Map<String, String>> availableAllergies = [
    {'id': 'dairy', 'label': '🥛 Dairy / Lactose', 'labelId': '🥛 Susu / Laktosa'},
    {'id': 'nuts', 'label': '🥜 Peanuts & Tree Nuts', 'labelId': '🥜 Kacang-kacangan'},
    {'id': 'gluten', 'label': '🌾 Gluten / Wheat', 'labelId': '🌾 Gluten / Gandum'},
    {'id': 'seafood', 'label': '🐟 Seafood & Fish', 'labelId': '🐟 Makanan Laut & Ikan'},
    {'id': 'eggs', 'label': '🥚 Eggs', 'labelId': '🥚 Telur'},
    {'id': 'soy', 'label': '🌱 Soy', 'labelId': '🌱 Kedelai'},
  ];

  static const List<Map<String, String>> availableCravings = [
    {'id': 'chocolate', 'label': '🍫 Chocolate & Sweets', 'labelId': '🍫 Cokelat & Manis'},
    {'id': 'cheese', 'label': '🧀 Cheese & Savory Melts', 'labelId': '🧀 Keju & Hidangan Gurih'},
    {'id': 'tea', 'label': '🍵 Warm Teas & Soups', 'labelId': '🍵 Teh Hangat & Sup'},
    {'id': 'berries', 'label': '🍓 Fresh Berries & Fruits', 'labelId': '🍓 Buah & Beri Segar'},
    {'id': 'oats', 'label': '🍪 Warm Oats & Bakes', 'labelId': '🍪 Oat Hangat & Kue'},
    {'id': 'healthy_fats', 'label': '🥑 Healthy Fats & Nuts', 'labelId': '🥑 Lemak Sehat & Kacang'},
    {'id': 'pasta_rice', 'label': '🍝 Comfort Pasta & Rice', 'labelId': '🍝 Pasta & Nasi Hangat'},
  ];

  @override
  void initState() {
    super.initState();
    final settings = context.read<PeriodProvider>().settings;
    _selectedAllergies = List<String>.from(settings.dietaryAllergies);
    _selectedCravings = List<String>.from(settings.favoriteFoods);
  }

  void _toggleAllergy(String id) {
    setState(() {
      if (_selectedAllergies.contains(id)) {
        _selectedAllergies.remove(id);
      } else {
        _selectedAllergies.add(id);
      }
    });
  }

  void _toggleCraving(String id) {
    setState(() {
      if (_selectedCravings.contains(id)) {
        _selectedCravings.remove(id);
      } else {
        _selectedCravings.add(id);
      }
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final periodProvider = context.read<PeriodProvider>();
    final current = periodProvider.settings;
    final updated = current.copyWith(
      dietaryAllergies: _selectedAllergies,
      favoriteFoods: _selectedCravings,
    );
    await periodProvider.updateSettings(updated);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tr = context.watch<LocaleProvider>().tr;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('Diet & Comfort Preferences', 'Preferensi Diet & Makanan'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tr(
                'Customize your food and comfort snack recommendations for red days.',
                'Sesuaikan rekomendasi makanan dan camilan nyaman saat haid.',
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),

            // Allergies
            Text(
              tr('FOOD ALLERGIES OR SENSITIVITIES', 'ALERGI ATAU SENSITIVITAS MAKANAN'),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableAllergies.map((item) {
                final isSelected = _selectedAllergies.contains(item['id']);
                return FilterChip(
                  selected: isSelected,
                  label: Text(tr(item['label']!, item['labelId']!)),
                  onSelected: (_) => _toggleAllergy(item['id']!),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Cravings
            Text(
              tr('FAVORITE COMFORT FOODS & CRAVINGS', 'MAKANAN NYAMAN & FAVORIT'),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableCravings.map((item) {
                final isSelected = _selectedCravings.contains(item['id']);
                return FilterChip(
                  selected: isSelected,
                  label: Text(tr(item['label']!, item['labelId']!)),
                  onSelected: (_) => _toggleCraving(item['id']!),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            AppButton(
              text: tr('Save Preferences', 'Simpan Preferensi'),
              isFullWidth: true,
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
