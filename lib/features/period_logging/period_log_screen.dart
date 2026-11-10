import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/date_utils.dart';
import '../../models/daily_log.dart';
import '../../models/period.dart';
import '../../providers/daily_log_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/period_provider.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/confirm_dialog.dart';

class PeriodLogScreen extends StatefulWidget {
  const PeriodLogScreen({
    super.key,
    this.existingPeriod,
    this.initialStartDate,
  });

  final Period? existingPeriod;
  final DateTime? initialStartDate;

  @override
  State<PeriodLogScreen> createState() => _PeriodLogScreenState();
}

class _PeriodLogScreenState extends State<PeriodLogScreen> {
  late DateTime _startDate;
  DateTime? _endDate;
  bool _isOngoing = false;
  bool _knowsDuration = true;
  FlowIntensity _flowIntensity = FlowIntensity.medium;
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPeriod;
    final settings = context.read<PeriodProvider>().settings;
    _knowsDuration = settings.knowsPeriodDuration;
    if (settings.isBoyfriendMode) {
      _flowIntensity = FlowIntensity.notSure;
    }

    if (p != null) {
      _startDate = p.startDate;
      _endDate = p.endDate;
      _isOngoing = p.isOngoing;
    } else {
      _startDate =
          AppDateUtils.dateOnly(widget.initialStartDate ?? DateTime.now());
      _endDate = _startDate.add(
        Duration(days: settings.averagePeriodDuration - 1),
      );
      _isOngoing = false;
    }
    _loadExistingNotes();
  }

  Future<void> _loadExistingNotes() async {
    final dailyLog = await context.read<DailyLogProvider>().getLogForDate(_startDate);
    if (dailyLog != null && mounted) {
      if (dailyLog.flowIntensity != null) {
        setState(() => _flowIntensity = dailyLog.flowIntensity!);
      }
      if (dailyLog.notes != null) {
        _notesController.text = dailyLog.notes!;
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _startDate = AppDateUtils.dateOnly(picked);
        if (!_knowsDuration) {
          _endDate = _startDate.add(const Duration(days: 4));
        } else if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() {
        _endDate = AppDateUtils.dateOnly(picked);
        _isOngoing = false;
      });
    }
  }

  Future<void> _savePeriod() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final periodProvider = context.read<PeriodProvider>();
      final dailyLogProvider = context.read<DailyLogProvider>();

      final period = Period(
        id: widget.existingPeriod?.id,
        startDate: _startDate,
        endDate: _isOngoing ? null : _endDate,
      );

      if (widget.existingPeriod != null) {
        await periodProvider.updatePeriod(period);
      } else {
        await periodProvider.addPeriod(period);
      }

      // Also persist flow intensity and notes into daily log for start date
      final existingLog = await dailyLogProvider.getLogForDate(_startDate);
      final updatedLog = (existingLog ?? DailyLog(logDate: _startDate)).copyWith(
        flowIntensity: _flowIntensity,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );
      await dailyLogProvider.saveLog(updatedLog);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ValidationException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to save period: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deletePeriod() async {
    final periodId = widget.existingPeriod?.id;
    if (periodId == null) return;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Period',
      message:
          'Are you sure you want to delete this recorded period? This action will recalculate your cycle history.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      setState(() => _isSaving = true);
      try {
        await context.read<PeriodProvider>().deletePeriod(periodId);
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete period: $e')),
        );
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = context.watch<LocaleProvider>().tr;
    final isEditing = widget.existingPeriod != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Period' : 'Log Period'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete Period',
              onPressed: _deletePeriod,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Dates Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Period Dates',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start date picker row
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.calendar_today_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Start Date'),
                      trailing: Text(
                        AppDateUtils.formatDisplay(_startDate),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: _pickStartDate,
                    ),
                    const Divider(),

                    // Do you know the period duration?
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        tr(
                          'Do you know the period duration?',
                          'Apakah Anda tahu durasi haid?',
                        ),
                      ),
                      subtitle: Text(
                        _knowsDuration
                            ? tr(
                                'Pick exact end date or mark ongoing',
                                'Pilih tanggal selesai atau tandai sedang berlangsung',
                              )
                            : tr(
                                'Not sure — automatically using 5-day duration',
                                'Tidak tahu — otomatis menggunakan durasi standar 5 hari',
                              ),
                      ),
                      value: _knowsDuration,
                      onChanged: (val) {
                        setState(() {
                          _knowsDuration = val;
                          if (!val) {
                            _isOngoing = false;
                            _endDate = _startDate.add(const Duration(days: 4));
                          }
                        });
                      },
                    ),

                    if (_knowsDuration) ...[
                      const Divider(),

                      // Ongoing toggle
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Period is ongoing'),
                        subtitle: const Text('Leave end date open'),
                        value: _isOngoing,
                        onChanged: (val) {
                          setState(() {
                            _isOngoing = val;
                            if (!val && _endDate == null) {
                              _endDate =
                                  _startDate.add(const Duration(days: 4));
                            }
                          });
                        },
                      ),

                      // End date picker (if not ongoing)
                      if (!_isOngoing) ...[
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.event_available_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('End Date'),
                          trailing: Text(
                            _endDate != null
                                ? AppDateUtils.formatDisplay(_endDate!)
                                : 'Select',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onTap: _pickEndDate,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Flow Intensity Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flow Intensity',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr(
                        'Boyfriend or not sure if the period blood is a lot or not? Select "Not Sure".',
                        'Pacar atau tidak tahu apakah darah haid banyak atau sedikit? Pilih "Not Sure".',
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
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
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                          ),
                          label: Text(flow.displayName),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _flowIntensity = flow);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notes Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes (Optional)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Add notes about flow, cramps, or symptoms...',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Save button
              AppButton(
                text: isEditing ? 'Update Period' : 'Save Period',
                isFullWidth: true,
                isLoading: _isSaving,
                onPressed: _savePeriod,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
