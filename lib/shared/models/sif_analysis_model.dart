enum SifPotential {
  critical,
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case SifPotential.critical:
        return 'CRITICAL';
      case SifPotential.high:
        return 'HIGH';
      case SifPotential.medium:
        return 'MEDIUM';
      case SifPotential.low:
        return 'LOW';
    }
  }

  String get priorityText {
    switch (this) {
      case SifPotential.critical:
        return 'IMMEDIATE INTERVENTION REQUIRED';
      case SifPotential.high:
        return 'HIGH RISK PRIORITY';
      case SifPotential.medium:
        return 'MODERATE RISK PRIORITY';
      case SifPotential.low:
        return 'STANDARD MONITORING';
    }
  }
}

class RiskFactor {
  final String name;
  final double score; // 0.0 to 1.0
  final String description;

  const RiskFactor({
    required this.name,
    required this.score,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'score': score,
        'description': description,
      };

  factory RiskFactor.fromJson(Map<String, dynamic> json) => RiskFactor(
        name: json['name'] as String,
        score: (json['score'] as num).toDouble(),
        description: json['description'] as String,
      );
}

class EvidenceSpan {
  final String phrase;
  final String category; // 'hazard', 'barrier_failure', 'unsafe_act', 'exposure'
  final int startIndex;
  final int endIndex;

  const EvidenceSpan({
    required this.phrase,
    required this.category,
    this.startIndex = 0,
    this.endIndex = 0,
  });

  Map<String, dynamic> toJson() => {
        'phrase': phrase,
        'category': category,
        'startIndex': startIndex,
        'endIndex': endIndex,
      };

  factory EvidenceSpan.fromJson(Map<String, dynamic> json) => EvidenceSpan(
        phrase: json['phrase'] as String,
        category: json['category'] as String,
        startIndex: json['startIndex'] as int? ?? 0,
        endIndex: json['endIndex'] as int? ?? 0,
      );
}

class SifAnalysisModel {
  final SifPotential sifPotential;
  final String classification; // 'SIF-Potential' or 'Non-SIF-Potential'
  final String lifeSavingRule; // e.g. 'Confined Space', 'Energy Isolation', 'Working at Height', etc.
  final double confidence; // e.g. 0.91
  final List<String> detectedHazards;
  final List<String> detectedUnsafeActs;
  final List<String> detectedUnsafeConditions;
  final String detectedActivity;
  final String detectedBarrierFailure;
  final String potentialExposure;
  final List<String> potentialConsequences;
  final bool workerExposure;
  final String exposureDetails;
  final String explanation;
  final String recommendedReview;
  final List<EvidenceSpan> evidenceSpans;
  final List<RiskFactor> riskFactors;
  final List<String> recommendedActions;
  final String modelVersion;
  final DateTime analyzedAt;
  final bool isHumanValidated;
  final String? validatedBy;
  final String? validationNotes;

  const SifAnalysisModel({
    required this.sifPotential,
    this.classification = 'SIF-Potential',
    this.lifeSavingRule = 'General Safety',
    required this.confidence,
    required this.detectedHazards,
    required this.detectedUnsafeActs,
    required this.detectedUnsafeConditions,
    this.detectedActivity = 'General Field Operation',
    this.detectedBarrierFailure = 'Primary safety control degradation',
    this.potentialExposure = 'Worker in line-of-fire',
    required this.potentialConsequences,
    required this.workerExposure,
    required this.exposureDetails,
    required this.explanation,
    this.recommendedReview = 'Safety officer should verify critical barrier controls and compliance before authorization.',
    required this.evidenceSpans,
    required this.riskFactors,
    required this.recommendedActions,
    this.modelVersion = 'SIF-Sentinel-NLP-v2.4-OIL',
    required this.analyzedAt,
    this.isHumanValidated = false,
    this.validatedBy,
    this.validationNotes,
  });

  bool get isSifPotential => classification == 'SIF-Potential' || sifPotential == SifPotential.critical || sifPotential == SifPotential.high;

  SifAnalysisModel copyWith({
    SifPotential? sifPotential,
    String? classification,
    String? lifeSavingRule,
    double? confidence,
    List<String>? detectedHazards,
    List<String>? detectedUnsafeActs,
    List<String>? detectedUnsafeConditions,
    String? detectedActivity,
    String? detectedBarrierFailure,
    String? potentialExposure,
    List<String>? potentialConsequences,
    bool? workerExposure,
    String? exposureDetails,
    String? explanation,
    String? recommendedReview,
    List<EvidenceSpan>? evidenceSpans,
    List<RiskFactor>? riskFactors,
    List<String>? recommendedActions,
    String? modelVersion,
    DateTime? analyzedAt,
    bool? isHumanValidated,
    String? validatedBy,
    String? validationNotes,
  }) {
    return SifAnalysisModel(
      sifPotential: sifPotential ?? this.sifPotential,
      classification: classification ?? this.classification,
      lifeSavingRule: lifeSavingRule ?? this.lifeSavingRule,
      confidence: confidence ?? this.confidence,
      detectedHazards: detectedHazards ?? this.detectedHazards,
      detectedUnsafeActs: detectedUnsafeActs ?? this.detectedUnsafeActs,
      detectedUnsafeConditions:
          detectedUnsafeConditions ?? this.detectedUnsafeConditions,
      detectedActivity: detectedActivity ?? this.detectedActivity,
      detectedBarrierFailure:
          detectedBarrierFailure ?? this.detectedBarrierFailure,
      potentialExposure: potentialExposure ?? this.potentialExposure,
      potentialConsequences:
          potentialConsequences ?? this.potentialConsequences,
      workerExposure: workerExposure ?? this.workerExposure,
      exposureDetails: exposureDetails ?? this.exposureDetails,
      explanation: explanation ?? this.explanation,
      recommendedReview: recommendedReview ?? this.recommendedReview,
      evidenceSpans: evidenceSpans ?? this.evidenceSpans,
      riskFactors: riskFactors ?? this.riskFactors,
      recommendedActions: recommendedActions ?? this.recommendedActions,
      modelVersion: modelVersion ?? this.modelVersion,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      isHumanValidated: isHumanValidated ?? this.isHumanValidated,
      validatedBy: validatedBy ?? this.validatedBy,
      validationNotes: validationNotes ?? this.validationNotes,
    );
  }

  Map<String, dynamic> toJson() => {
        'sif_potential': sifPotential.label,
        'classification': classification,
        'life_saving_rule': lifeSavingRule,
        'confidence': confidence,
        'detected_hazards': detectedHazards,
        'detected_unsafe_acts': detectedUnsafeActs,
        'detected_unsafe_conditions': detectedUnsafeConditions,
        'detected_activity': detectedActivity,
        'detected_barrier_failure': detectedBarrierFailure,
        'potential_exposure': potentialExposure,
        'potential_consequences': potentialConsequences,
        'worker_exposure': workerExposure,
        'exposure_details': exposureDetails,
        'explanation': explanation,
        'recommended_review': recommendedReview,
        'evidence_spans': evidenceSpans.map((e) => e.toJson()).toList(),
        'risk_factors': riskFactors.map((e) => e.toJson()).toList(),
        'recommended_actions': recommendedActions,
        'model_version': modelVersion,
        'analyzed_at': analyzedAt.toIso8601String(),
        'is_human_validated': isHumanValidated,
        'validated_by': validatedBy,
        'validation_notes': validationNotes,
      };
}
