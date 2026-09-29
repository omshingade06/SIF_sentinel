import '../../../shared/models/sif_analysis_model.dart';

/// Oilfield Safety Domain NLP Engine
/// Implements rule-based domain ontology matching, IOGP Life-Saving Rule mapping,
/// SIF factor multi-signal scoring, explainable reasoning generation, text phrase span highlighting,
/// and procedural recommendation synthesis for Oil India Limited.
class OilfieldNLPEngine {
  OilfieldNLPEngine._();

  static SifAnalysisModel analyzeObservation(String text) {
    final lower = text.toLowerCase();

    final detectedHazards = <String>[];
    final detectedUnsafeActs = <String>[];
    final detectedUnsafeConditions = <String>[];
    final potentialConsequences = <String>[];
    final evidenceSpans = <EvidenceSpan>[];
    final recommendedActions = <String>[];

    String lifeSavingRule = 'General Safety';
    String detectedActivity = 'General Field Operation';
    String detectedBarrierFailure = 'Primary safety control deviation';
    String potentialExposure = 'Personnel in active operational boundary';
    String recommendedReview = 'HSE Officer should review observation and verify standard operational controls.';

    // Check for Scenario 5: Low-risk Housekeeping / Minor Non-SIF Observation
    final bool isLowRiskHousekeeping = _containsAny(lower, [
          'housekeeping',
          'pallet',
          'cardboard',
          'water puddle',
          'waste bin',
          'sweeping',
          'lunch room',
          'untidy office',
          'loose gravel on pathway',
          'dirty boots',
          'empty plastic bottle',
          'minor dust'
        ]) &&
        !_containsAny(lower, [
          'confined space',
          'loto',
          'lockout',
          'energized',
          'derrick',
          'height',
          'harness',
          'gas leak',
          'lel',
          'crane',
          'h2s',
          'bop',
          'hydrocarbon'
        ]);

    if (isLowRiskHousekeeping) {
      detectedHazards.add('Workplace Housekeeping');
      detectedUnsafeConditions.add('Temporary storage of non-hazardous items or minor debris on transit path');
      potentialConsequences.add('Minor slip/trip without serious injury potential');
      detectedActivity = 'Housekeeping & Site Maintenance';
      detectedBarrierFailure = 'Minor housekeeping protocol adherence';
      potentialExposure = 'Low — No direct high-energy or fatal exposure mechanism';
      lifeSavingRule = 'None / Non-LSR';
      recommendedReview = 'Site supervisor to address during daily 5S / housekeeping rounds. No SIF intervention required.';
      _addEvidence(text, ['housekeeping', 'pallet', 'cardboard', 'water puddle', 'waste bin'], 'hazard', evidenceSpans);

      final riskFactors = [
        const RiskFactor(name: 'Hazard Severity', score: 0.15, description: 'Low energy — Negligible fatality or life-altering injury potential.'),
        const RiskFactor(name: 'Worker Exposure', score: 0.20, description: 'Minor walk-by exposure without high-energy mechanism in vicinity.'),
        const RiskFactor(name: 'Critical Barrier Failure', score: 0.10, description: 'No primary life-saving controls or process barriers compromised.'),
        const RiskFactor(name: 'Potential Consequence', score: 0.12, description: 'First-aid or minor slip/trip at worst.'),
      ];

      return SifAnalysisModel(
        sifPotential: SifPotential.low,
        classification: 'Non-SIF-Potential',
        lifeSavingRule: lifeSavingRule,
        confidence: 0.94,
        detectedHazards: detectedHazards,
        detectedUnsafeActs: detectedUnsafeActs,
        detectedUnsafeConditions: detectedUnsafeConditions,
        detectedActivity: detectedActivity,
        detectedBarrierFailure: detectedBarrierFailure,
        potentialExposure: potentialExposure,
        potentialConsequences: potentialConsequences,
        workerExposure: false,
        exposureDetails: 'Observation involves minor housekeeping with no high-energy fatality precursor mechanism.',
        explanation: 'Identified as NON-SIF-POTENTIAL. The observation represents routine low-severity housekeeping or minor non-hazardous worksite deviation without exposure to high energy, process hazards, or Life-Saving Rule failure.',
        recommendedReview: recommendedReview,
        evidenceSpans: evidenceSpans,
        riskFactors: riskFactors,
        recommendedActions: [
          'Clear work area and properly store materials in designated bin.',
          'Review 5S workplace housekeeping standard during routine toolbox talk.',
        ],
        modelVersion: 'SIF-Sentinel-NLP-v2.4-OIL',
        analyzedAt: DateTime.now(),
      );
    }

    // Detect Activity
    if (_containsAny(lower, ['turnaround', 'maintenance', 'repair', 'replacing', 'overhaul', 'pump overhaul', 'filter replacement'])) {
      detectedActivity = 'Maintenance';
    } else if (_containsAny(lower, ['tripping', 'drilling', 'pipe racking', 'derrick', 'rotary table', 'bop', 'mast lowering'])) {
      detectedActivity = 'Drilling & Well Servicing';
    } else if (_containsAny(lower, ['crane', 'lifting', 'rigging', 'sling', 'forklift', 'tubular transfer', 'loading'])) {
      detectedActivity = 'Lifting & Material Handling';
    } else if (_containsAny(lower, ['confined space', 'vessel entry', 'tank entry', 'cellar pit', 'manhole'])) {
      detectedActivity = 'Confined Space Entry';
    } else if (_containsAny(lower, ['electrical', 'switchgear', 'breaker', '11kv', 'transformer', 'motor terminal'])) {
      detectedActivity = 'Electrical Work';
    } else if (_containsAny(lower, ['hot work', 'grinding', 'welding', 'cutting', 'torch'])) {
      detectedActivity = 'Hot Work';
    } else if (_containsAny(lower, ['pig', 'launcher', 'receiver', 'pipeline', 'flange survey', 'gathering station'])) {
      detectedActivity = 'Pipeline & Gathering Operations';
    } else {
      detectedActivity = 'Well Operations';
    }

    // 1. Confined Space Detection (IOGP: Confined Space)
    if (_containsAny(lower, [
      'confined space',
      'vessel',
      'tank entry',
      'cellar pit',
      'inside vessel',
      'manhole',
      'separator v-102',
      'crude tank'
    ])) {
      detectedHazards.add('Confined Space Entry');
      lifeSavingRule = 'Confined Space';
      detectedBarrierFailure = 'Atmospheric testing / entry authorization';
      if (_containsAny(lower, ['without gas test', 'before gas testing', 'no gas test', 'without completing mandatory 4-gas testing'])) {
        detectedUnsafeActs.add('Entry into confined space without atmospheric gas testing');
        detectedUnsafeConditions.add('Bypassed gas detection protocol before vessel entry');
      }
      potentialConsequences.addAll([
        'Toxic gas inhalation / Asphyxiation in oxygen-deficient atmosphere',
        'Fatal loss of consciousness inside vessel',
      ]);
      potentialExposure = 'Worker directly inside enclosed hazardous vessel atmosphere';
      recommendedReview = 'Safety officer should verify confined-space entry controls and gas-testing requirements.';
      _addEvidence(text, ['confined space', 'vessel v-102', 'cellar pit', 'crude tank', 'inside vessel'], 'hazard', evidenceSpans);
      _addEvidence(text, ['without completing mandatory 4-gas testing', 'without gas test', 'before gas testing was completed', 'before gas testing', 'permit was not properly verified'], 'barrier_failure', evidenceSpans);
    }

    // 2. Hazardous Energy / LOTO Detection (IOGP: Energy Isolation)
    if (_containsAny(lower, [
      'loto',
      'lockout',
      'tagout',
      'energized',
      'breaker',
      'electrical motor',
      '415v',
      'live cable',
      'unisolated',
      'zero energy',
      'booster pump',
      'residual pressure',
      'bleeder valve'
    ])) {
      detectedHazards.add('Hazardous Energy (LOTO)');
      lifeSavingRule = 'Energy Isolation';
      detectedBarrierFailure = 'Incomplete isolation / zero energy verification';
      if (_containsAny(lower, ['energized', 'without isolating', 'breaker was still energized', 'omitted', 'unisolated'])) {
        detectedUnsafeActs.add('Intervention on live energized equipment without physical LOTO padlock');
        detectedUnsafeConditions.add('Unisolated electrical switchgear and failure of zero-energy verification');
      }
      potentialConsequences.addAll([
        'Severe electrical flashover / Arc blast injury',
        'Fatal electrocution',
        'Sudden mechanical startup / Crushing amputation',
      ]);
      potentialExposure = 'Technician in contact with unisolated high-voltage electrical / mechanical energy';
      recommendedReview = 'HSE Officer must verify physical LOTO lockout padlocks, danger tags, and documented zero energy state.';
      _addEvidence(text, ['energized', 'electrical motor', 'high pressure crude booster pump', 'live cable', 'breaker', 'residual pressure'], 'hazard', evidenceSpans);
      _addEvidence(text, ['lockout/tagout (loto) padlocks and zero energy verification were omitted', 'breaker was still energized', 'unisolated equipment', 'without isolating'], 'barrier_failure', evidenceSpans);
    }

    // 3. Working at Height Detection (IOGP: Working at Height)
    if (_containsAny(lower, [
      'working at height',
      'height',
      'scaffolding',
      'derrick',
      'racking board',
      'harness',
      'lanyard',
      '18 meters',
      'elevation',
      'fall arrest',
      'unhooking',
      'unclipped',
      'tie-off',
      'handrail'
    ])) {
      detectedHazards.add('Working at Height');
      lifeSavingRule = 'Working at Height';
      detectedBarrierFailure = 'Fall protection anchor / 100% tie-off';
      if (_containsAny(lower, ['unhooking', 'unclipped', 'without harness', 'without engaging', 'no tie-off', 'unanchored', 'handrail was heavily corroded'])) {
        detectedUnsafeActs.add('Work at elevated level without 100% harness tie-off / lifeline anchor');
        detectedUnsafeConditions.add('Absence of secondary fall-arrest barrier in slippery/elevated conditions');
      }
      potentialConsequences.addAll([
        'Catastrophic fall from elevated structure (>1.8m)',
        'Fatal blunt force trauma',
      ]);
      potentialExposure = 'Worker elevated >1.8m on rig superstructure without continuous fall arrest';
      recommendedReview = 'Rig safety supervisor must verify 100% dual-lanyard hook compliance and self-retracting lifelines.';
      _addEvidence(text, ['18 meters elevation', 'rig derrick #04', 'racking board', 'elevated', 'scaffolding', '14m height'], 'hazard', evidenceSpans);
      _addEvidence(text, ['unhooking his full-body harness lanyard', 'without engaging the secondary self-retracting lifeline', 'unclipped', 'without tie-off', 'handrail was heavily corroded'], 'barrier_failure', evidenceSpans);
    }

    // 4. Line of Fire Detection (IOGP: Line of Fire)
    if (_containsAny(lower, [
      'line of fire',
      'rotating zone',
      'rotary table',
      'kelly bushing',
      'suspended load',
      'drop zone',
      'winch cable',
      'whipped',
      'pressurized line',
      'snagged',
      'pressure testing'
    ])) {
      detectedHazards.add('Line of Fire Hazard');
      if (lifeSavingRule == 'General Safety') lifeSavingRule = 'Line of Fire';
      detectedBarrierFailure = 'Exclusion-zone / red-zone barricade failure';
      if (_containsAny(lower, ['rotating zone', 'rotary table', 'snagged', 'whipped', 'red-zone barricades had not been secured'])) {
        detectedUnsafeActs.add('Personnel positioned in active machine rotation / pressurized discharge line-of-fire');
        detectedUnsafeConditions.add('Absence of physical barricade or warning strobe around high-pressure test zone');
      }
      potentialConsequences.addAll([
        'Caught-in / entanglement in rotating drill equipment',
        'Struck-by whipped high-pressure line fitting or falling object',
        'Fatal crushing impact in line of fire',
      ]);
      potentialExposure = 'Worker standing directly in red zone / trajectory of high-energy equipment';
      recommendedReview = 'Drilling supervisor must enforce zero-tolerance exclusion red zones during rotating and pressure operations.';
      _addEvidence(text, ['rotary table rotating zone', 'high-pressure bop testing to 5000 psi', 'winch cable snagged', 'red-zone barricades had not been secured'], 'hazard', evidenceSpans);
      _addEvidence(text, ['stepped into the rotary table rotating zone', 'red-zone barricades had not been secured', 'whip line loosened'], 'barrier_failure', evidenceSpans);
    }

    // 5. Hot Work in Hazardous Area (IOGP: Hot Work)
    if (_containsAny(lower, ['hot work', 'grinding', 'welding', 'torch', 'cutting torch', 'spark'])) {
      detectedHazards.add('Hot Work in Hazardous Area');
      if (lifeSavingRule == 'General Safety' || lifeSavingRule == 'Line of Fire') lifeSavingRule = 'Hot Work';
      detectedBarrierFailure = 'Combustible gas monitoring & hot work containment';
      if (_containsAny(lower, ['gas hissing', 'flange', 'lel', 'combustible', 'gas leak', 'manifold'])) {
        detectedUnsafeActs.add('Conducting hot work/grinding in close proximity to flammable hydrocarbon release');
        detectedUnsafeConditions.add('High pressure gas leak with combustible LEL concentration exceeding safety threshold');
      }
      potentialConsequences.addAll([
        'Vapor cloud explosion (VCE) / Flash fire',
        'Major loss of primary containment (LOPC)',
        'Multi-casualty thermal radiation exposure',
      ]);
      potentialExposure = 'Hot work crew exposed to explosive hydrocarbon vapor cloud';
      recommendedReview = 'HSE Officer must enforce 0% LEL testing and certified spark-containment habitat before hot work.';
      _addEvidence(text, ['hot work grinding was concurrently ongoing', 'gas hissing was detected', 'lel reading spiking to 45%'], 'hazard', evidenceSpans);
      _addEvidence(text, ['within 10 meters without barrier shielding', 'hot work grinding', 'lel spiking'], 'barrier_failure', evidenceSpans);
    }

    // 6. Lifting & Crane Operations (IOGP: Safe Mechanical Lifting)
    if (_containsAny(lower, ['crane', 'lifting', 'suspended load', 'rigging', 'sling', 'tagline', 'drill collar', 'hoist'])) {
      detectedHazards.add('Lifting & Crane Operations');
      if (lifeSavingRule == 'General Safety' || lifeSavingRule == 'Line of Fire') lifeSavingRule = 'Safe Mechanical Lifting';
      detectedBarrierFailure = 'Tagline guide & crane drop-zone barricade';
      if (_containsAny(lower, ['no tagline', 'pedestrian walkway', 'unbarricaded', 'over personnel', 'transiting'])) {
        detectedUnsafeActs.add('Lifting heavy suspended load across active pedestrian walkway without secondary guidance');
        detectedUnsafeConditions.add('Unguided 3-ton suspended load and unbarricaded lift swing radius');
      }
      potentialConsequences.addAll([
        'Struck-by falling overhead 3-ton load',
        'Fatal crushing injury in drop zone',
      ]);
      potentialExposure = 'Pedestrians and rig workers transiting directly beneath suspended load';
      recommendedReview = 'Yard supervisor must verify 100% barricading of lift radius and mandatory synthetic taglines.';
      _addEvidence(text, ['3-ton drill collar bundle', 'mobile crane operator lifted', 'suspended load'], 'hazard', evidenceSpans);
      _addEvidence(text, ['across the main pedestrian walkway while personnel were transiting', 'no tagline was attached', 'drop zone was unbarricaded'], 'barrier_failure', evidenceSpans);
    }

    // 7. Bypassing Safety Controls (IOGP: Bypassing Safety Controls)
    if (_containsAny(lower, ['bypassed', 'jumper', 'detector bypass', 'car-seal', 'interlock bypass', 'overridden', 'inhibit switch'])) {
      detectedHazards.add('Bypassing Safety Controls');
      lifeSavingRule = 'Bypassing Safety Controls';
      detectedBarrierFailure = 'Safety critical instrument / interlock integrity';
      detectedUnsafeConditions.add('Bypassed primary safety detector / disabled emergency shutdown barrier');
      potentialConsequences.addAll([
        'Undetected toxic H2S/flammable gas accumulation leading to fatal knockdown',
        'Failure of emergency pressure relief or fire suppression system',
      ]);
      potentialExposure = 'Facility personnel vulnerable to undetected toxic/flammable accumulation';
      recommendedReview = 'HSE Directorate must audit critical safety equipment override registers and instrument calibration.';
      _addEvidence(text, ['bypassed with a calibration jumper', 'car-seal on upstream block valve of safety relief valve prv-201 was found cut', 'warning inhibit switch had not been set'], 'barrier_failure', evidenceSpans);
    }

    // 8. Work Authorisation & PTW (IOGP: Work Authorisation)
    if (_containsAny(lower, ['permit', 'ptw', 'unauthorized', 'jsa omitted', 'clearance not signed'])) {
      if (!detectedHazards.contains('Permit-to-Work (PTW) Violation')) {
        detectedHazards.add('Permit-to-Work (PTW) Violation');
      }
      if (lifeSavingRule == 'General Safety') lifeSavingRule = 'Work Authorisation';
      _addEvidence(text, ['permit was not properly verified', 'without requesting electrical permit clearance', 'without valid permit'], 'barrier_failure', evidenceSpans);
    }

    // 9. Heavy Vehicles & Driving (IOGP: Driving)
    if (_containsAny(lower, ['driving', 'forklift', 'trailer', 'speeding', 'rollover', 'truck', 'access road'])) {
      detectedHazards.add('Heavy Vehicle & Mobile Equipment');
      if (lifeSavingRule == 'General Safety') lifeSavingRule = 'Driving';
      detectedBarrierFailure = 'Vehicle load positioning & pedestrian segregation';
      if (_containsAny(lower, ['forks raised higher than 1.5 meters', 'obstructing forward visibility', 'pedestrian movement nearby'])) {
        detectedUnsafeActs.add('Transporting heavy pipe joints with forks raised higher than safe clearance, obstructing driver view');
      }
      potentialConsequences.addAll([
        'Pedestrian vehicular impact / crushing incident',
        'Vehicle rollover or load spill on unpaved drill pad',
      ]);
      potentialExposure = 'Pedestrians in path of heavy mobile equipment with compromised driver visibility';
      recommendedReview = 'Logistics supervisor to enforce forklift transit height limits and designated pedestrian walkways.';
      _addEvidence(text, ['forklift operator was transporting', 'forks raised higher than 1.5 meters', 'obstructing forward visibility'], 'hazard', evidenceSpans);
      _addEvidence(text, ['forks raised higher than 1.5 meters', 'uneven gravel roadway with pedestrian movement'], 'barrier_failure', evidenceSpans);
    }

    // 10. Toxic Gas (H2S) & Chemical Release Detection
    if (_containsAny(lower, ['h2s', 'rotten eggs', 'sour gas', '25 ppm', 'toxic gas', 'gas leak', 'sulfide', 'respiratory'])) {
      detectedHazards.add('Toxic Gas (H2S) & Hazardous Atmosphere');
      if (lifeSavingRule == 'General Safety') lifeSavingRule = 'Confined Space';
      detectedBarrierFailure = 'Gas detection calibration & personal respiratory barrier';
      detectedUnsafeConditions.add('Atmospheric H2S concentration exceeding permissible threshold');
      potentialConsequences.addAll([
        'Immediate toxic knockdown and respiratory paralysis',
        'Fatal H2S poisoning / acute chemical asphyxiation',
      ]);
      potentialExposure = 'Field workers in unventilated proximity to toxic H2S release plume';
      recommendedReview = 'HSSE Officer must immediately quarantine the wellhead sector and inspect all personal H2S monitor calibrations.';
      _addEvidence(text, ['h2s alarm triggered', 'h2s', 'rotten eggs', '25 ppm', 'toxic gas'], 'hazard', evidenceSpans);
      _addEvidence(text, ['gas detector calibration was expired', 'no emergency escape pack was available'], 'barrier_failure', evidenceSpans);
    }

    // 11. Well Control & Kick / High Pressure Blowout
    if (_containsAny(lower, ['gas kick', 'well control', 'kick while', 'bop accumulator', 'blowout', 'mud weight', 'christmas tree'])) {
      detectedHazards.add('Well Control & Hydrocarbon Release Precursor');
      if (lifeSavingRule == 'General Safety') lifeSavingRule = 'Energy Isolation';
      detectedBarrierFailure = 'Primary hydrostatic mud column & secondary BOP barrier';
      detectedUnsafeConditions.add('Underbalanced wellbore conditions and compromised secondary BOP pressure');
      potentialConsequences.addAll([
        'Catastrophic subsurface hydrocarbon blowout',
        'Surface explosion, fire, and total rig destruction',
      ]);
      potentialExposure = 'Drilling rig personnel directly on drill floor and cellar pit area';
      recommendedReview = 'Senior Drilling Superintendent must suspend tripping, shut in the well, and recalculate kill mud weight.';
      _addEvidence(text, ['gas kick', 'pulling out of hole', 'bop accumulator bottle pressure dropped'], 'hazard', evidenceSpans);
      _addEvidence(text, ['mud weight was inadequate', 'pressure dropped below minimum operating limit'], 'barrier_failure', evidenceSpans);
    }

    // Fallback if no specific high hazard is matched
    if (detectedHazards.isEmpty) {
      if (_containsAny(lower, ['ppe', 'helmet', 'glasses', 'gloves', 'boots'])) {
        detectedHazards.add('Personal Protective Equipment (PPE) Compliance');
        detectedUnsafeActs.add('Worker observed without prescribed PPE in active work area');
        potentialConsequences.add('Minor to moderate impact or abrasion injury');
        lifeSavingRule = 'General Safety';
        detectedBarrierFailure = 'Personal protective equipment barrier';
      } else {
        detectedHazards.add('General Industrial Safety Observation');
        detectedUnsafeConditions.add('Worksite procedural deviation');
        potentialConsequences.add('Minor localized non-critical injury');
        lifeSavingRule = 'General Safety';
      }
    }

    // Determine Worker Exposure
    final bool workerExposure = _containsAny(lower, [
          'worker',
          'technician',
          'electrician',
          'floorman',
          'roustabout',
          'crew',
          'driller',
          'operator',
          'personnel',
          'contractor',
          'entered',
          'working',
          'attempted',
          'transiting',
          'observed'
        ]) &&
        !_containsAny(lower, ['no personnel present', 'remote area unoccupied', 'area evacuated']);

    final String exposureDetails = workerExposure
        ? 'Direct physical personnel exposure identified in the active line-of-fire / hazardous zone.'
        : 'Hazard detected with no personnel in direct line-of-fire during observation.';

    if (workerExposure) {
      _addEvidence(text, ['worker entered', 'contractor technician', 'electrician attempted', 'floorman was observed', 'personnel were transiting', 'worker was', 'operator was'], 'exposure', evidenceSpans);
    }

    // Calculate SIF Factor Scores
    double hazardSeverity = 0.35;
    double barrierFailureScore = 0.40;
    double consequenceScore = 0.30;
    double workerExposureScore = workerExposure ? 0.88 : 0.25;

    if (detectedHazards.any((h) => [
          'Confined Space Entry',
          'Hazardous Energy (LOTO)',
          'Process Safety & Hydrocarbon Release',
          'Toxic Gas (H2S) & Hazardous Atmosphere',
          'Well Control & Hydrocarbon Release Precursor',
          'Working at Height',
          'Hot Work in Hazardous Area',
          'Bypassing Safety Controls'
        ].contains(h))) {
      hazardSeverity = 0.92;
      consequenceScore = 0.90;
    } else if (detectedHazards.any((h) => ['Lifting & Crane Operations', 'Permit-to-Work (PTW) Violation', 'Line of Fire Hazard'].contains(h))) {
      hazardSeverity = 0.82;
      consequenceScore = 0.78;
    }

    if (detectedHazards.contains('General Industrial Safety Observation')) {
      hazardSeverity = 0.20;
      barrierFailureScore = 0.25;
      consequenceScore = 0.20;
    } else if (detectedUnsafeActs.isNotEmpty || detectedUnsafeConditions.isNotEmpty) {
      barrierFailureScore = 0.91;
    }

    // Determine SIF Potential
    SifPotential sifPotential;
    double confidence;

    if (hazardSeverity >= 0.85 && workerExposureScore >= 0.70 && barrierFailureScore >= 0.75) {
      sifPotential = SifPotential.critical;
      confidence = 0.92;
    } else if (hazardSeverity >= 0.75 && workerExposureScore >= 0.60) {
      sifPotential = SifPotential.high;
      confidence = 0.87;
    } else if (hazardSeverity >= 0.50 && (barrierFailureScore >= 0.60 || workerExposureScore >= 0.50)) {
      sifPotential = SifPotential.medium;
      confidence = 0.81;
    } else {
      sifPotential = SifPotential.low;
      confidence = 0.85;
    }

    final String classification = (sifPotential == SifPotential.critical || sifPotential == SifPotential.high || sifPotential == SifPotential.medium)
        ? 'SIF-Potential'
        : 'Non-SIF-Potential';

    // Build Risk Factors Breakdown
    final riskFactors = [
      RiskFactor(
        name: 'Hazard Severity',
        score: hazardSeverity,
        description: 'Intrinsic energy potential and fatality-causing capacity of the recognized hazard category.',
      ),
      RiskFactor(
        name: 'Worker Exposure',
        score: workerExposureScore,
        description: 'Proximity, duration, and direct vulnerability of personnel in the incident line-of-fire.',
      ),
      RiskFactor(
        name: 'Critical Barrier Failure',
        score: barrierFailureScore,
        description: 'Degradation, bypass, or absence of procedural, physical, or engineering safety barriers.',
      ),
      RiskFactor(
        name: 'Potential Consequence',
        score: consequenceScore,
        description: 'Projected severity outcome under reasonable worst-case operational circumstances.',
      ),
    ];

    // Generate Explainable AI Reasoning Summary
    final explanation = _generateExplanation(
      sifPotential: sifPotential,
      hazards: detectedHazards,
      workerExposure: workerExposure,
      barrierFailure: detectedUnsafeActs.isNotEmpty || detectedUnsafeConditions.isNotEmpty,
      primaryHazard: detectedHazards.first,
      lifeSavingRule: lifeSavingRule,
    );

    // Generate Procedural Recommendations
    recommendedActions.addAll(_generateRecommendations(detectedHazards, sifPotential));

    return SifAnalysisModel(
      sifPotential: sifPotential,
      classification: classification,
      lifeSavingRule: lifeSavingRule,
      confidence: confidence,
      detectedHazards: detectedHazards,
      detectedUnsafeActs: detectedUnsafeActs,
      detectedUnsafeConditions: detectedUnsafeConditions,
      detectedActivity: detectedActivity,
      detectedBarrierFailure: detectedBarrierFailure,
      potentialExposure: potentialExposure,
      potentialConsequences: potentialConsequences,
      workerExposure: workerExposure,
      exposureDetails: exposureDetails,
      explanation: explanation,
      recommendedReview: recommendedReview,
      evidenceSpans: evidenceSpans,
      riskFactors: riskFactors,
      recommendedActions: recommendedActions,
      modelVersion: 'SIF-Sentinel-NLP-v2.4-OIL',
      analyzedAt: DateTime.now(),
    );
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  static void _addEvidence(String fullText, List<String> searchPhrases, String category, List<EvidenceSpan> spans) {
    final lowerFull = fullText.toLowerCase();
    for (final phrase in searchPhrases) {
      final index = lowerFull.indexOf(phrase);
      if (index != -1) {
        final actualText = fullText.substring(index, index + phrase.length);
        if (!spans.any((s) => s.phrase.toLowerCase() == phrase)) {
          spans.add(EvidenceSpan(
            phrase: actualText,
            category: category,
            startIndex: index,
            endIndex: index + phrase.length,
          ));
        }
      }
    }
  }

  static String _generateExplanation({
    required SifPotential sifPotential,
    required List<String> hazards,
    required bool workerExposure,
    required bool barrierFailure,
    required String primaryHazard,
    required String lifeSavingRule,
  }) {
    switch (sifPotential) {
      case SifPotential.critical:
        return 'Flagged as CRITICAL SIF PRECURSOR. The observation documents direct worker exposure to a high-energy hazard ($primaryHazard) combined with the simultaneous collapse of a critical safety control barrier under the IOGP Life-Saving Rule "$lifeSavingRule". Under realistic worst-case oilfield conditions, this scenario presents an imminent likelihood of a Serious Injury or Fatality.';
      case SifPotential.high:
        return 'Flagged as HIGH SIF POTENTIAL. The event exhibits elevated energy characteristics associated with $primaryHazard and impaired protective barriers under the "$lifeSavingRule" Life-Saving Rule. Immediate supervisor review and control verification are recommended to eliminate precursor risk.';
      case SifPotential.medium:
        return 'Identified as MODERATE SIF POTENTIAL. While primary containment and isolation controls were partially present, procedural deviations were observed under "$lifeSavingRule" that could escalate if compounded with secondary process failures.';
      case SifPotential.low:
        return 'Identified as NON-SIF-POTENTIAL. The observation represents localized non-critical maintenance or housekeeping deviation without direct exposure to high-energy fatality-associated mechanisms.';
    }
  }

  static List<String> _generateRecommendations(List<String> hazards, SifPotential potential) {
    final list = <String>[];

    if (potential == SifPotential.critical || potential == SifPotential.high) {
      list.add('Recommend immediate HSE review / Stop-Work consideration until barrier verification is completed.');
    }

    if (hazards.contains('Confined Space Entry')) {
      list.add('Enforce mandatory 4-gas atmosphere testing (O2, LEL, H2S, CO) and continuous mechanical ventilation.');
      list.add('Re-validate Confined Space Entry Permit (CSEP) and verify assigned Standby Rescuer presence.');
    }

    if (hazards.contains('Hazardous Energy (LOTO)')) {
      list.add('Perform immediate physical Lockout/Tagout (LOTO) with personal safety padlocks and danger tags.');
      list.add('Conduct documented Zero Energy State verification at test point prior to work resumption.');
    }

    if (hazards.contains('Working at Height')) {
      list.add('Mandate 100% continuous dual-lanyard tie-off with certified anchor points and self-retracting lifelines.');
      list.add('Inspect elevated scaffolding structure and re-certify green safety tag before access.');
    }

    if (hazards.contains('Hot Work in Hazardous Area') || hazards.contains('Process Safety & Hydrocarbon Release')) {
      list.add('Halt all hot work within 30m radius and deploy calibrated combustible gas area monitors.');
      list.add('Isolate affected manifold section, depressurize, and inspect flange gasket integrity.');
    }

    if (hazards.contains('Lifting & Crane Operations')) {
      list.add('Establish full physical barricades around 360° crane swing radius and enforce drop zone clearance.');
      list.add('Mandate non-conductive synthetic taglines to guide all suspended loads.');
    }

    if (hazards.contains('Line of Fire Hazard')) {
      list.add('Establish hard physical red-zone exclusion barriers around rotating and pressurized equipment.');
      list.add('Verify that whip checks and secondary retention cables are installed on high-pressure flexible lines.');
    }

    // General procedural closures
    list.add('Conduct an immediate Tool-Box Talk (TBT) with the crew to review OIL Life-Saving Rules.');
    list.add('Assign site safety supervisor to log closure verification in the SIF Sentinel Action Center.');

    return list;
  }
}

