import 'package:flutter_test/flutter_test.dart';
import 'package:sif_sentinel/features/ai_analysis/domain/oilfield_nlp_engine.dart';
import 'package:sif_sentinel/shared/models/sif_analysis_model.dart';

void main() {
  group('OilfieldNLPEngine Domain Extraction & SIF Classification Tests', () {
    test('Confined Space without gas testing is flagged as CRITICAL SIF precursor', () {
      const text =
          'During turnaround maintenance activity at Separator Vessel V-102, a contractor technician entered the confined space without completing mandatory 4-gas testing and forced ventilation. The entry permit was not properly verified by the shift engineer.';

      final analysis = OilfieldNLPEngine.analyzeObservation(text);

      expect(analysis.sifPotential, equals(SifPotential.critical));
      expect(analysis.detectedHazards, contains('Confined Space Entry'));
      expect(analysis.workerExposure, isTrue);
      expect(analysis.confidence, greaterThanOrEqualTo(0.85));
      expect(analysis.explanation, contains('CRITICAL SIF PRECURSOR'));
      expect(analysis.evidenceSpans.isNotEmpty, isTrue);
      expect(analysis.recommendedActions.any((a) => a.contains('4-gas atmosphere testing')), isTrue);
    });

    test('Hazardous Energy LOTO bypass on energized booster pump is flagged as CRITICAL', () {
      const text =
          'Electrician attempted to replace motor terminal connections on High Pressure Crude Booster Pump P-204 while the main breaker was still energized. Lockout/Tagout (LOTO) padlocks and zero energy verification were omitted because work was deemed urgent.';

      final analysis = OilfieldNLPEngine.analyzeObservation(text);

      expect(analysis.sifPotential, equals(SifPotential.critical));
      expect(analysis.detectedHazards, contains('Hazardous Energy (LOTO)'));
      expect(analysis.workerExposure, isTrue);
      expect(analysis.potentialConsequences.any((c) => c.contains('electrocution') || c.contains('Arc blast')), isTrue);
      expect(analysis.recommendedActions.any((a) => a.contains('Lockout/Tagout')), isTrue);
    });

    test('Working at height unhooked lanyard on rig derrick is flagged as HIGH SIF potential', () {
      const text =
          'Floorman was observed unhooking his full-body harness lanyard while maneuvering pipe racking board at 18 meters elevation on Rig Derrick #04 without engaging the secondary self-retracting lifeline during heavy rain.';

      final analysis = OilfieldNLPEngine.analyzeObservation(text);

      expect(analysis.sifPotential, equals(SifPotential.critical)); // severity + exposure + barrier failure
      expect(analysis.detectedHazards, contains('Working at Height'));
      expect(analysis.workerExposure, isTrue);
      expect(analysis.recommendedActions.any((a) => a.contains('100% continuous dual-lanyard')), isTrue);
    });

    test('Low-severity housekeeping report is classified with low SIF potential', () {
      const text = 'Worksite scrap wooden pallet was left on the walkway near storage yard.';

      final analysis = OilfieldNLPEngine.analyzeObservation(text);

      expect(analysis.sifPotential, equals(SifPotential.low));
      expect(analysis.confidence, greaterThanOrEqualTo(0.70));
    });
  });
}
