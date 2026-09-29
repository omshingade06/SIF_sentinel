/// Operational Safety Verification Scenarios for AI Model Testing & SIH Verification
class DemoScenario {
  final String title;
  final String description;
  final String reportType;
  final String site;
  final String department;
  final String observationText;
  final String expectedHazard;
  final String expectedLifeSavingRule;
  final String expectedBarrier;
  final String expectedClassification; // SIF-Potential or Non-SIF-Potential
  final String expectedSifPotential;
  final String keyReason;

  const DemoScenario({
    required this.title,
    required this.description,
    required this.reportType,
    required this.site,
    required this.department,
    required this.observationText,
    required this.expectedHazard,
    required this.expectedLifeSavingRule,
    required this.expectedBarrier,
    required this.expectedClassification,
    required this.expectedSifPotential,
    required this.keyReason,
  });
}

class DemoScenarios {
  DemoScenarios._();

  static const List<DemoScenario> judgeScenarios = [
    DemoScenario(
      title: 'Scenario 1 — Energy Isolation (LOTO Bypass)',
      description: 'Worker starts maintenance on crude booster pump before complete electrical isolation.',
      reportType: 'Unsafe Act',
      site: 'Moran Drilling Unit',
      department: 'Electrical & Instrumentation (E&I)',
      observationText:
          'Electrician attempted to replace motor terminal connections on High Pressure Crude Booster Pump P-204 while the main breaker was still energized. Lockout/Tagout (LOTO) padlocks and zero energy verification were omitted because work was deemed urgent.',
      expectedHazard: 'Hazardous Energy (LOTO)',
      expectedLifeSavingRule: 'Energy Isolation',
      expectedBarrier: 'Incomplete isolation verification & missing LOTO padlocks',
      expectedClassification: 'SIF-Potential',
      expectedSifPotential: 'CRITICAL',
      keyReason: 'High voltage electrical arc / electrocution risk directly coupled with failure of physical LOTO control barrier.',
    ),
    DemoScenario(
      title: 'Scenario 2 — Confined Space (No Gas Testing)',
      description: 'Worker enters production crude separator vessel before atmospheric gas testing.',
      reportType: 'Near Miss',
      site: 'Duliajan Main Complex',
      department: 'Mechanical Maintenance',
      observationText:
          'During turnaround maintenance activity at Separator Vessel V-102, a contractor technician entered the confined space without completing mandatory 4-gas testing and forced ventilation. The entry permit was not properly verified by the shift engineer.',
      expectedHazard: 'Confined Space Entry',
      expectedLifeSavingRule: 'Confined Space',
      expectedBarrier: 'Atmospheric testing / entry authorization',
      expectedClassification: 'SIF-Potential',
      expectedSifPotential: 'CRITICAL',
      keyReason: 'Direct worker exposure inside oxygen-deficient/toxic vessel without primary control verification (gas test & valid PTW).',
    ),
    DemoScenario(
      title: 'Scenario 3 — Working at Height (Unhooked Harness)',
      description: 'Worker not properly tied off at 18 meters on rig derrick.',
      reportType: 'Unsafe Act',
      site: 'Digboi Oil Field',
      department: 'Drilling & Well Servicing',
      observationText:
          'Floorman was observed unhooking his full-body harness lanyard while maneuvering pipe racking board at 18 meters elevation on Rig Derrick #04 without engaging the secondary self-retracting lifeline during heavy rain.',
      expectedHazard: 'Working at Height',
      expectedLifeSavingRule: 'Working at Height',
      expectedBarrier: 'Inadequate fall protection / missing secondary lifeline',
      expectedClassification: 'SIF-Potential',
      expectedSifPotential: 'HIGH',
      keyReason: 'High elevation (>1.8m) fall potential with complete absence of secondary fall arrest barrier.',
    ),
    DemoScenario(
      title: 'Scenario 4 — Line of Fire (Rotating Rig Zone & Suspended Load)',
      description: 'Worker stands in close proximity to moving machinery / suspended drill equipment.',
      reportType: 'Near Miss',
      site: 'Dibrugarh Logistics Base',
      department: 'Logistics & Material Management',
      observationText:
          'Roughneck stepped into the rotary table rotating zone while top drive was in low-gear rotation. Winch cable snagged the sleeve of his coverall, nearly pulling him into the rotating kelly bushing.',
      expectedHazard: 'Line of Fire Hazard',
      expectedLifeSavingRule: 'Line of Fire',
      expectedBarrier: 'Missing exclusion red zone & machine guarding',
      expectedClassification: 'SIF-Potential',
      expectedSifPotential: 'HIGH',
      keyReason: 'Direct personnel positioning in active rotating equipment line-of-fire without barrier barricade.',
    ),
    DemoScenario(
      title: 'Scenario 5 — Low-Risk Housekeeping (Non-SIF)',
      description: 'Minor housekeeping observation demonstrating system does NOT over-classify everything as high risk.',
      reportType: 'Safety Observation',
      site: 'Jorhat Crude Terminal',
      department: 'Logistics & Material Management',
      observationText:
          'Observed three empty wooden pallets and flattened cardboard packaging left beside the workshop walkway. Area is clean and unobstructed for pedestrian movement with zero flammable or hazardous materials nearby.',
      expectedHazard: 'Workplace Housekeeping',
      expectedLifeSavingRule: 'None / Non-LSR',
      expectedBarrier: 'General 5S Housekeeping standard',
      expectedClassification: 'Non-SIF-Potential',
      expectedSifPotential: 'LOW',
      keyReason: 'Routine low-severity housekeeping with zero high-energy exposure, no process hazard, and no barrier degradation.',
    ),
  ];
}
