import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_utils.dart';
import 'symptom.dart';

enum FlowIntensity {
  notSure('Not Sure', 'not_sure', AppColors.flowSpotting, Icons.help_outline_rounded),
  spotting('Spotting', 'spotting', AppColors.flowSpotting, Icons.water_drop_outlined),
  light('Light', 'light', AppColors.flowLight, Icons.water_drop),
  medium('Medium', 'medium', AppColors.flowMedium, Icons.opacity),
  heavy('Heavy', 'heavy', AppColors.flowHeavy, Icons.bloodtype);

  const FlowIntensity(this.displayName, this.value, this.color, this.icon);
  final String displayName;
  final String value;
  final Color color;
  final IconData icon;

  static FlowIntensity? fromValue(String? val) {
    if (val == null) return null;
    return FlowIntensity.values.firstWhere(
      (e) => e.value == val,
      orElse: () => FlowIntensity.medium,
    );
  }
}

class DailyLog {
  const DailyLog({
    this.id,
    required this.logDate,
    this.flowIntensity,
    this.notes,
    this.symptoms = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? logDate,
        updatedAt = updatedAt ?? logDate;

  final int? id;
  final DateTime logDate;
  final FlowIntensity? flowIntensity;
  final String? notes;
  final List<SymptomEntry> symptoms;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasSymptoms => symptoms.isNotEmpty;
  bool get hasNotes => notes != null && notes!.trim().isNotEmpty;
  bool get hasFlow => flowIntensity != null;
  bool get isEmpty => !hasSymptoms && !hasNotes && !hasFlow;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'log_date': AppDateUtils.formatIso(logDate),
      'flow_intensity': flowIntensity?.value,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DailyLog.fromMap(
    Map<String, dynamic> map, {
    List<SymptomEntry> symptoms = const [],
  }) {
    return DailyLog(
      id: map['id'] as int?,
      logDate: AppDateUtils.parseIso(map['log_date'] as String),
      flowIntensity: FlowIntensity.fromValue(map['flow_intensity'] as String?),
      notes: map['notes'] as String?,
      symptoms: symptoms,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  DailyLog copyWith({
    int? id,
    DateTime? logDate,
    FlowIntensity? flowIntensity,
    bool clearFlow = false,
    String? notes,
    bool clearNotes = false,
    List<SymptomEntry>? symptoms,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyLog(
      id: id ?? this.id,
      logDate: logDate ?? this.logDate,
      flowIntensity: clearFlow ? null : (flowIntensity ?? this.flowIntensity),
      notes: clearNotes ? null : (notes ?? this.notes),
      symptoms: symptoms ?? this.symptoms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
