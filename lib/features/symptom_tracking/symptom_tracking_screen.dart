import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_utils.dart';
import '../../models/daily_log.dart';
import '../../models/symptom.dart';
import '../../providers/daily_log_provider.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';

class SymptomTrackingScreen extends StatefulWidget {
  const SymptomTrackingScreen({
    super.key,
    required this.date,
  });

  final DateTime date;

  @override
  State<SymptomTrackingScreen> createState() => _SymptomTrackingScreenState();
}

class _SymptomTrackingScreenState extends State<SymptomTrackingScreen> {
  final Map<String, SymptomSeverity> _selectedSymptoms = {};
  FlowIntensity? _flowIntensity;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dailyLogProvider = context.read<DailyLogProvider>();
    await dailyLogProvider.loadSymptoms();

    final log = await dailyLogProvider.getLogForDate(widget.date);
    if (log != null && mounted) {
      _flowIntensity = log.flowIntensity;
      if (log.notes != null) _notesController.text = log.notes!;
      for (final entry in log.symptoms) {
        _selectedSymptoms[entry.symptom.name] = entry.severity;
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _toggleSymptom(String symptomName) {
    setState(() {
      if (_selectedSymptoms.containsKey(symptomName)) {
        _selectedSymptoms.remove(symptomName);
      } else {
        _selectedSymptoms[symptomName] = SymptomSeverity.mild;
      }
    });
  }

  void _setSeverity(String symptomName, SymptomSeverity severity) {
    setState(() {
      _selectedSymptoms[symptomName] = severity;
    });
  }

  Future<void> _saveLog() async {
    setState(() => _isSaving = true);
    try {
      final dailyLogProvider = context.read<DailyLogProvider>();

      final entries = _selectedSymptoms.entries.map((e) {
        return SymptomEntry(
          symptom: Symptom(name: e.key),
          severity: e.value,
        );
      }).toList();

      final log = DailyLog(
        logDate: AppDateUtils.dateOnly(widget.date),
        flowIntensity: _flowIntensity,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        symptoms: entries,
      );

      await dailyLogProvider.saveLog(log);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save daily log: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allSymptoms = context.watch<DailyLogProvider>().allSymptoms;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Check-in'),
            Text(
              AppDateUtils.formatDisplay(widget.date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flow Intensity Section
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Flow Intensity',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (_flowIntensity != null)
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _flowIntensity = null),
                                  child: const Text('Clear'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Not sure if the period blood is a lot or not? Select "Not Sure".',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: FlowIntensity.values.map((flow) {
                              final isSelected = _flowIntensity == flow;
                              return ChoiceChip(
                                avatar: Icon(
                                  flow.icon,
                                  size: 16,
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
                                ),
                                label: Text(flow.displayName),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _flowIntensity = selected ? flow : null;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Symptoms Section
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Symptoms & Body Signals',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap to select symptoms, then adjust severity.',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 14),

                          // Symptoms chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: allSymptoms.map((sym) {
                              final isSelected =
                                  _selectedSymptoms.containsKey(sym.name);
                              return FilterChip(
                                label: Text(sym.name),
                                selected: isSelected,
                                onSelected: (_) => _toggleSymptom(sym.name),
                              );
                            }).toList(),
                          ),

                          // Severity details for each selected symptom
                          if (_selectedSymptoms.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Divider(),
                            Text(
                              'Severity Levels',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ..._selectedSymptoms.entries.map((entry) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        entry.key,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: SegmentedButton<SymptomSeverity>(
                                        segments: const [
                                          ButtonSegment(
                                            value: SymptomSeverity.mild,
                                            label: Text('Mild',
                                                style: TextStyle(fontSize: 11)),
                                          ),
                                          ButtonSegment(
                                            value: SymptomSeverity.moderate,
                                            label: Text('Mod',
                                                style: TextStyle(fontSize: 11)),
                                          ),
                                          ButtonSegment(
                                            value: SymptomSeverity.severe,
                                            label: Text('Sev',
                                                style: TextStyle(fontSize: 11)),
                                          ),
                                        ],
                                        selected: {entry.value},
                                        onSelectionChanged: (set) {
                                          _setSeverity(entry.key, set.first);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Daily Notes Section
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Notes',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText:
                                  'How was your energy, sleep, or mood today?',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    AppButton(
                      text: 'Save Check-in',
                      isFullWidth: true,
                      isLoading: _isSaving,
                      onPressed: _saveLog,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
