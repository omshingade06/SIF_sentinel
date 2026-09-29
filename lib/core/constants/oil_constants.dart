/// Oil India Limited (OIL) Domain Constants, Sites, Taxonomies & Safety Reference Data
class OilConstants {
  OilConstants._();

  static const String appName = 'SIF Sentinel';
  static const String appSubtitle = 'AI-Powered SIF Precursor Intelligence Platform';
  static const String orgName = 'Oil India Limited (OIL)';
  static const String systemCode = 'OIL-HSE-INTEL-2026';
  static const String enterpriseEdition =
      'Oil India Limited HSE Directorate — Production Live Operations';
  static const String operationalStatus =
      'OIL Operational Intelligence Feed • Duliajan / Digboi / Moran Assets';

  // Operational Sites of OIL
  static const List<Map<String, dynamic>> sites = [
    {
      'id': 'SITE-01',
      'name': 'Duliajan Main Complex',
      'code': 'DLN-HQ',
      'type': 'Central Processing & Headquarter',
      'latitude': 27.3592,
      'longitude': 95.3188,
      'activeRigs': 8,
      'openReports': 34,
      'criticalAlerts': 3,
    },
    {
      'id': 'SITE-02',
      'name': 'Digboi Oil Field',
      'code': 'DGB-01',
      'type': 'Historic Production & Processing Area',
      'latitude': 27.3820,
      'longitude': 95.6186,
      'activeRigs': 4,
      'openReports': 19,
      'criticalAlerts': 2,
    },
    {
      'id': 'SITE-03',
      'name': 'Moran Drilling Unit',
      'code': 'MRN-DRL',
      'type': 'Deep Well Exploration & Rig Site',
      'latitude': 27.1850,
      'longitude': 94.9310,
      'activeRigs': 6,
      'openReports': 27,
      'criticalAlerts': 4,
    },
    {
      'id': 'SITE-04',
      'name': 'Naharkatiya Gathering Station',
      'code': 'NHK-GGS',
      'type': 'Group Gathering & Separation Facility',
      'latitude': 27.2798,
      'longitude': 95.3411,
      'activeRigs': 3,
      'openReports': 14,
      'criticalAlerts': 1,
    },
    {
      'id': 'SITE-05',
      'name': 'Jorhat Crude Terminal',
      'code': 'JRH-TRM',
      'type': 'Pipeline Pump & Tank Farm Terminal',
      'latitude': 26.7509,
      'longitude': 94.2037,
      'activeRigs': 2,
      'openReports': 11,
      'criticalAlerts': 0,
    },
    {
      'id': 'SITE-06',
      'name': 'Dibrugarh Logistics Base',
      'code': 'DBR-LOG',
      'type': 'Heavy Equipment & Material Yard',
      'latitude': 27.4728,
      'longitude': 94.9120,
      'activeRigs': 1,
      'openReports': 8,
      'criticalAlerts': 0,
    },
  ];

  // Functional Departments
  static const List<String> departments = [
    'Drilling & Well Servicing',
    'Field Production Operations',
    'Mechanical Maintenance',
    'Electrical & Instrumentation (E&I)',
    'Pipeline & Transport',
    'HSE (Health, Safety & Environment)',
    'Civil Engineering & Infrastructure',
    'Logistics & Material Management',
  ];

  // High SIF Precursor Hazard Taxonomies
  static const List<Map<String, String>> hazardTaxonomy = [
    {
      'id': 'HAZ-01',
      'name': 'Hazardous Energy (LOTO)',
      'description': 'Failure to isolate electrical, pneumatic, mechanical, or pressure energy before intervention.',
      'icon': 'bolt',
      'color': '#E65100',
    },
    {
      'id': 'HAZ-02',
      'name': 'Working at Height',
      'description': 'Elevated work >1.8m without 100% tie-off, uncertified scaffolding, or edge protection failure.',
      'icon': 'height',
      'color': '#C62828',
    },
    {
      'id': 'HAZ-03',
      'name': 'Confined Space Entry',
      'description': 'Entry into tanks, vessels, cellar pits without gas testing, continuous ventilation, or standby rescue.',
      'icon': 'space_dashboard',
      'color': '#C62828',
    },
    {
      'id': 'HAZ-04',
      'name': 'Process Safety & Hydrocarbon Release',
      'description': 'Loss of primary containment, flaring anomalies, valve bypass, wellhead pressure surges.',
      'icon': 'local_fire_department',
      'color': '#E65100',
    },
    {
      'id': 'HAZ-05',
      'name': 'Lifting & Crane Operations',
      'description': 'Overhead suspended loads, damaged rigging slings, lifting in high wind without tag lines.',
      'icon': 'precision_manufacturing',
      'color': '#F59E0B',
    },
    {
      'id': 'HAZ-06',
      'name': 'Toxic Gas & H2S Exposure',
      'description': 'Sour gas release, detector calibration bypass, lack of escape breathing apparatus (EEBA).',
      'icon': 'cloud',
      'color': '#C62828',
    },
    {
      'id': 'HAZ-07',
      'name': 'Hot Work in Hazardous Area',
      'description': 'Welding/cutting near live hydrocarbon lines without combustible gas testing or spark containment.',
      'icon': 'whatshot',
      'color': '#E65100',
    },
    {
      'id': 'HAZ-08',
      'name': 'Permit-to-Work (PTW) Violation',
      'description': 'Starting hot work or confined entry without valid PTW, cross-shift handover, or JSA briefing.',
      'icon': 'assignment_late',
      'color': '#F59E0B',
    },
    {
      'id': 'HAZ-09',
      'name': 'Heavy Vehicle & Mobile Equipment',
      'description': 'Drill rig transport, blind spot incursions, rollover hazard on unpaved drill pads.',
      'icon': 'local_shipping',
      'color': '#16834B',
    },
  ];

  // Report Types
  static const List<String> reportTypes = [
    'Near Miss',
    'Unsafe Condition',
    'Unsafe Act',
    'Safety Observation',
  ];

  // User Roles
  static const String roleSafetyOfficer = 'Safety Officer';
  static const String roleSiteSupervisor = 'Site/Field Supervisor';
  static const String roleSafetyManager = 'Safety Manager';
  static const String roleAdministrator = 'Administrator';
}
