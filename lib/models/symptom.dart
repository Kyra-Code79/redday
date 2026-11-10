enum SymptomSeverity {
  mild('Mild', 'mild'),
  moderate('Moderate', 'moderate'),
  severe('Severe', 'severe');

  const SymptomSeverity(this.displayName, this.value);
  final String displayName;
  final String value;

  static SymptomSeverity fromValue(String val) {
    return SymptomSeverity.values.firstWhere(
      (e) => e.value == val,
      orElse: () => SymptomSeverity.mild,
    );
  }
}

class Symptom {
  const Symptom({
    this.id,
    required this.name,
  });

  final int? id;
  final String name;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
    };
  }

  factory Symptom.fromMap(Map<String, dynamic> map) {
    return Symptom(
      id: map['id'] as int?,
      name: map['name'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Symptom && runtimeType == other.runtimeType && id == other.id && name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class SymptomEntry {
  const SymptomEntry({
    required this.symptom,
    this.severity = SymptomSeverity.mild,
  });

  final Symptom symptom;
  final SymptomSeverity severity;

  SymptomEntry copyWith({
    Symptom? symptom,
    SymptomSeverity? severity,
  }) {
    return SymptomEntry(
      symptom: symptom ?? this.symptom,
      severity: severity ?? this.severity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomEntry &&
          runtimeType == other.runtimeType &&
          symptom == other.symptom &&
          severity == other.severity;

  @override
  int get hashCode => symptom.hashCode ^ severity.hashCode;
}
