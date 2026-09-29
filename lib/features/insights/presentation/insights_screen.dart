import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/oil_header.dart';
import '../../../shared/widgets/enterprise_card.dart';
import '../../analytics/presentation/site_safety_map_screen.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = '30 Days';
  final List<String> _timeRanges = const ['7 Days', '30 Days', '90 Days', 'YTD 2026'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OilHeader(
        title: 'Safety Intelligence',
        subtitle: 'Precursor Detection & Analytics Hub',
        actions: [
          IconButton(
            tooltip: 'Site Geospatial Map',
            icon: const Icon(Icons.map_outlined, color: AppColors.primaryRed),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const SiteSafetyMapScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primaryRed,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primaryRed,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [
                Tab(text: 'Trends & KPIs'),
                Tab(text: 'Precursor Clusters'),
                Tab(text: 'Barrier Failures'),
                Tab(text: 'Density Rankings'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTrendsAndKpisTab(),
                _buildPrecursorClustersTab(),
                _buildBarrierFailuresTab(),
                _buildDensityAnalysisTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: Enterprise Trends & KPIs (Consolidated Analytics)
  Widget _buildTrendsAndKpisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Range Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Text('Horizon:', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _timeRanges.map((range) {
                        final isSelected = _selectedTimeRange == range;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(
                              range,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primaryRed,
                            backgroundColor: AppColors.surfaceSecondary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                            visualDensity: VisualDensity.compact,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedTimeRange = range);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Map Quick Action Callout
          EnterpriseCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const SiteSafetyMapScreen()),
              );
            },
            backgroundColor: AppColors.primaryBlack,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.location_searching_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Geospatial Site Safety Map',
                        style: AppTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        'View upstream rigs & precursor heatmaps across Upper Assam Basin',
                        style: AppTypography.caption.copyWith(color: const Color(0xFFD1D5DB)),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // SIF Precursors by Month Bar Chart
          EnterpriseCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Total Observations vs SIF Precursors',
                        style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(4)),
                      child: Text(_selectedTimeRange, style: AppTypography.caption.copyWith(fontSize: 10.5, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 45,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (val, meta) {
                              final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                              final idx = val.toInt();
                              if (idx >= 0 && idx < months.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(months[idx], style: AppTypography.caption.copyWith(fontSize: 9.5)),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: 10,
                            getTitlesWidget: (val, meta) => Text(
                              val.toInt().toString(),
                              style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 9.5),
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        _buildBarGroup(0, 32, 9),
                        _buildBarGroup(1, 38, 12),
                        _buildBarGroup(2, 35, 11),
                        _buildBarGroup(3, 44, 18),
                        _buildBarGroup(4, 39, 14),
                        _buildBarGroup(5, 41, 15),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _buildLegendDot(AppColors.primaryBlack, 'Total Observations'),
                    _buildLegendDot(AppColors.primaryRed, 'SIF Precursors Detected'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // SIF Precursor Density by Activity Ranking
          EnterpriseCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'SIF Precursor Density by Activity',
                        style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.criticalBg, borderRadius: BorderRadius.circular(4)),
                      child: const Text('Ranked by Density %', style: TextStyle(fontSize: 10, color: AppColors.critical, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Identifies high-consequence operations regardless of gross observation volume.',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),

                _buildActivityRankingRow('Confined Space Vessel Entry', 48, 36, 75.0, AppColors.critical, Icons.meeting_room_outlined),
                _buildActivityRankingRow('Well Operations & Workover', 68, 42, 61.8, AppColors.critical, Icons.oil_barrel_outlined),
                _buildActivityRankingRow('Working at Height (>1.8m)', 58, 26, 44.8, AppColors.high, Icons.height_outlined),
                _buildActivityRankingRow('Electrical & Mechanical Maintenance', 124, 52, 41.9, AppColors.high, Icons.build_outlined),
                _buildActivityRankingRow('Rigging & Heavy Lifting Operations', 72, 28, 38.9, AppColors.high, Icons.forklift),
                _buildActivityRankingRow('Hot Work & Spark Operations', 64, 22, 34.4, AppColors.medium, Icons.local_fire_department_outlined),
                _buildActivityRankingRow('Pipeline Pigging & Flange Work', 86, 21, 24.4, AppColors.medium, Icons.timeline_outlined),
                _buildActivityRankingRow('Vehicle Transit & Heavy Hauling', 92, 11, 12.0, AppColors.low, Icons.local_shipping_outlined),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Hazard Category Breakdown
          EnterpriseCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hazard Taxonomy Distribution', style: AppTypography.sectionTitle.copyWith(fontSize: 15)),
                const SizedBox(height: 4),
                Text('Distribution across 246 confirmed SIF precursors', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                _buildHazardProgressRow('Hazardous Energy (LOTO & Pressurized)', 0.28, '28% (69 SIF)', AppColors.critical),
                _buildHazardProgressRow('Working at Height & Mast Scaffolding', 0.21, '21% (52 SIF)', AppColors.high),
                _buildHazardProgressRow('Confined Space & Gas Exposure (H2S/LEL)', 0.19, '19% (47 SIF)', const Color(0xFFC2410C)),
                _buildHazardProgressRow('Line of Fire & Suspended Mechanical Loads', 0.14, '14% (34 SIF)', AppColors.medium),
                _buildHazardProgressRow('Work Authorisation & Isolation Bypassing', 0.11, '11% (27 SIF)', AppColors.info),
                _buildHazardProgressRow('Hot Work & Flammable Vapor Controls', 0.07, '7% (17 SIF)', AppColors.low),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Operational Site Risk Matrix
          EnterpriseCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Site Risk Intelligence Matrix',
                        style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(4)),
                      child: Text('6 Sites Tracked', style: AppTypography.caption.copyWith(fontSize: 10.5, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Multi-variable risk ranking including barrier failures and action backlog.', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 12),

                _buildSiteMatrixCard(
                  siteName: 'Moran Drilling Unit',
                  totalReports: 184,
                  sifPrecursors: 62,
                  sifDensity: '33.7%',
                  criticalCount: 14,
                  openBacklog: 12,
                  statusColor: AppColors.critical,
                ),
                const SizedBox(height: 8),
                _buildSiteMatrixCard(
                  siteName: 'Naharkatiya Gathering Station',
                  totalReports: 228,
                  sifPrecursors: 54,
                  sifDensity: '23.7%',
                  criticalCount: 7,
                  openBacklog: 9,
                  statusColor: AppColors.high,
                ),
                const SizedBox(height: 8),
                _buildSiteMatrixCard(
                  siteName: 'Digboi Oil Field Operations',
                  totalReports: 198,
                  sifPrecursors: 41,
                  sifDensity: '20.7%',
                  criticalCount: 4,
                  openBacklog: 8,
                  statusColor: AppColors.high,
                ),
                const SizedBox(height: 8),
                _buildSiteMatrixCard(
                  siteName: 'Jorhat Exploration Basin',
                  totalReports: 142,
                  sifPrecursors: 22,
                  sifDensity: '15.5%',
                  criticalCount: 1,
                  openBacklog: 5,
                  statusColor: AppColors.medium,
                ),
                const SizedBox(height: 8),
                _buildSiteMatrixCard(
                  siteName: 'Duliajan Main Complex',
                  totalReports: 412,
                  sifPrecursors: 58,
                  sifDensity: '14.1%',
                  criticalCount: 1,
                  openBacklog: 6,
                  statusColor: AppColors.medium,
                ),
                const SizedBox(height: 8),
                _buildSiteMatrixCard(
                  siteName: 'Numaligarh Refuelling & Terminal',
                  totalReports: 120,
                  sifPrecursors: 9,
                  sifDensity: '7.5%',
                  criticalCount: 0,
                  openBacklog: 2,
                  statusColor: AppColors.low,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // TAB 2: Precursor Pattern Clusters
  Widget _buildPrecursorClustersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Intelligence Callout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlack,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI PRECURSOR CLUSTER ENGINE',
                        style: AppTypography.overline.copyWith(color: AppColors.primaryRed, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '4 Recurring Precursor Clusters Detected',
                        style: AppTypography.headingMedium.copyWith(color: Colors.white, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Formed by multi-dimensional correlation: [Activity] + [Hazard] + [Barrier Failure].',
                        style: AppTypography.caption.copyWith(color: const Color(0xFFD1D5DB)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text('ACTIVE PRECURSOR PATTERNS (CORRELATED CLUSTERS)', style: AppTypography.overline),
          const SizedBox(height: 10),

          _buildClusterCard(
            clusterId: 'CLUSTER-2026-A1',
            activity: 'Well Intervention & Workover',
            hazard: 'High Pressure Hydrocarbon Release',
            barrierFailure: 'Missing Blind Flange & Incomplete LOTO',
            occurrences: 14,
            sifPotentialCount: 12,
            affectedSites: 'Moran Drilling Unit • Duliajan Wellhead #14',
            period: 'Last 30 Days',
            trend: '+28% Increase',
            trendIsUp: true,
            riskLevel: 'CRITICAL',
            riskColor: AppColors.critical,
            recommendedIntervention:
                'Execute mandatory verification of physical double-block-and-bleed before removing wellhead tree components.',
          ),
          const SizedBox(height: 14),

          _buildClusterCard(
            clusterId: 'CLUSTER-2026-B3',
            activity: 'Crude Vessel Entry & Sludge Desilt',
            hazard: 'Atmospheric Toxic H2S / LEL Explosion',
            barrierFailure: 'Omission of Continuous Gas Monitoring',
            occurrences: 9,
            sifPotentialCount: 9,
            affectedSites: 'Naharkatiya GGS • Duliajan Separators',
            period: 'Last 14 Days',
            trend: '+40% Spike',
            trendIsUp: true,
            riskLevel: 'CRITICAL',
            riskColor: AppColors.critical,
            recommendedIntervention:
                'Halt unmonitored vessel entries. Issue calibrated 4-gas continuous monitors and assign dedicated standby sentries.',
          ),
          const SizedBox(height: 14),

          _buildClusterCard(
            clusterId: 'CLUSTER-2026-C2',
            activity: 'Derrick Mast & Monkey Board Rigging',
            hazard: 'Personnel Fall From Height (>15m)',
            barrierFailure: 'Single Lanyard Hook & Missing Inertia Reel',
            occurrences: 11,
            sifPotentialCount: 8,
            affectedSites: 'Jorhat Exploration • Moran Rig #4',
            period: 'Last 30 Days',
            trend: '-12% Declining',
            trendIsUp: false,
            riskLevel: 'HIGH',
            riskColor: AppColors.high,
            recommendedIntervention:
                'Implement 100% tie-off twin-lanyard audit and inspect self-retracting lifelines across all mast ladders.',
          ),
          const SizedBox(height: 14),

          _buildClusterCard(
            clusterId: 'CLUSTER-2026-D5',
            activity: 'Rig Move & Heavy Coil Lifting',
            hazard: 'Suspended Load Inversion / Line of Fire',
            barrierFailure: 'Absence of Exclusion Zone & Tag Lines',
            occurrences: 8,
            sifPotentialCount: 6,
            affectedSites: 'Digboi Central Store • Moran Rig #2',
            period: 'Last 45 Days',
            trend: '+15% Increase',
            trendIsUp: true,
            riskLevel: 'HIGH',
            riskColor: AppColors.high,
            recommendedIntervention:
                'Deploy rigid perimeter barricades around crane swing radii; require dual tag line handlers for loads >2 tons.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // TAB 3: Dedicated Recurring Barrier Failures
  Widget _buildBarrierFailuresTab() {
    final barrierFailures = [
      {
        'name': 'Incomplete Energy Isolation (LOTO)',
        'total': 38,
        'sif': 31,
        'pct': '81.6% SIF Ratio',
        'trend': '+18% MoM',
        'isWorsening': true,
        'iogpRule': 'Energy Isolation',
        'severity': 'CRITICAL',
        'color': AppColors.critical,
        'sites': 'Moran Drilling, Duliajan Workshop, Digboi Station',
        'action': 'Implement mandatory QR-locked LOTO boards with dual-signatory verification.',
      },
      {
        'name': 'No Gas Test / Atmospheric Monitoring Bypass',
        'total': 29,
        'sif': 26,
        'pct': '89.7% SIF Ratio',
        'trend': '+24% MoM',
        'isWorsening': true,
        'iogpRule': 'Confined Space',
        'severity': 'CRITICAL',
        'color': AppColors.critical,
        'sites': 'Naharkatiya GGS, Duliajan Tanks, Moran Battery',
        'action': 'Mandate digital gas test upload before issuing Confined Space entry permits.',
      },
      {
        'name': 'Missing Exclusion Zone / Line of Fire Breach',
        'total': 34,
        'sif': 22,
        'pct': '64.7% SIF Ratio',
        'trend': '+11% MoM',
        'isWorsening': true,
        'iogpRule': 'Line of Fire',
        'severity': 'HIGH',
        'color': AppColors.high,
        'sites': 'Digboi Yard, Duliajan Crane Bay, Moran Rig #1',
        'action': 'Enforce 5-meter red-zone exclusion during pressurized testing and overhead lifts.',
      },
      {
        'name': 'Missing / Unsigned Work Authorisation (PTW)',
        'total': 42,
        'sif': 25,
        'pct': '59.5% SIF Ratio',
        'trend': '-4% MoM',
        'isWorsening': false,
        'iogpRule': 'Work Authorisation',
        'severity': 'HIGH',
        'color': AppColors.high,
        'sites': 'Jorhat Exploration, Duliajan Central, Digboi Rig',
        'action': 'Deploy mobile PTW cross-check scanners at active job site entrances.',
      },
      {
        'name': 'Inadequate Fall Protection (>1.8m Height)',
        'total': 21,
        'sif': 16,
        'pct': '76.2% SIF Ratio',
        'trend': '-8% MoM',
        'isWorsening': false,
        'iogpRule': 'Working at Height',
        'severity': 'HIGH',
        'color': AppColors.high,
        'sites': 'Moran Mast, Digboi WOR-07, Jorhat Rig',
        'action': 'Inspect and replace all worn inertia reels; mandate certified scaffold handrails.',
      },
      {
        'name': 'Safety Control Bypass / Interlock Bridging',
        'total': 15,
        'sif': 13,
        'pct': '86.7% SIF Ratio',
        'trend': '+30% MoM',
        'isWorsening': true,
        'iogpRule': 'Bypassing Safety Controls',
        'severity': 'HIGH',
        'color': AppColors.high,
        'sites': 'Duliajan Power Plant, Naharkatiya Gas Compressor',
        'action': 'Require Level-4 GM approval for any temporary ESD or high-pressure bypass bridging.',
      },
      {
        'name': 'Inadequate Mechanical Isolation / Blind Omission',
        'total': 18,
        'sif': 11,
        'pct': '61.1% SIF Ratio',
        'trend': '+5% MoM',
        'isWorsening': true,
        'iogpRule': 'Energy Isolation',
        'severity': 'MEDIUM',
        'color': AppColors.medium,
        'sites': 'Naharkatiya Pipeline #2, Moran Manifold',
        'action': 'Institute spade/blind registry with physical verification tags on all process piping.',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.primaryRed, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SYSTEMIC BARRIER FAILURE ANALYSIS', style: AppTypography.sectionTitle.copyWith(fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(
                        'Analysis of 7 recurrent barrier breakdowns across 1,284 safety reports.',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('RECURRING BARRIER FAILURE FREQUENCIES', style: AppTypography.overline),
          const SizedBox(height: 10),

          ...barrierFailures.map((bf) {
            final color = bf['color'] as Color;
            final isWorsening = bf['isWorsening'] as bool;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EnterpriseCard(
                indicatorColor: color,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bf['name'] as String,
                                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'IOGP Rule: ${bf['iogpRule']}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primaryRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            bf['severity'] as String,
                            style: AppTypography.overline.copyWith(color: color, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Metrics Row
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildMetricChip(
                          label: 'Total Reports',
                          value: '${bf['total']}',
                          color: AppColors.textPrimary,
                        ),
                        _buildMetricChip(
                          label: 'SIF Precursors',
                          value: '${bf['sif']}',
                          color: AppColors.critical,
                        ),
                        _buildMetricChip(
                          label: 'SIF Density',
                          value: bf['pct'] as String,
                          color: color,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isWorsening ? AppColors.criticalBg : AppColors.lowBg),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isWorsening ? Icons.trending_up : Icons.trending_down,
                                size: 14,
                                color: isWorsening ? AppColors.critical : AppColors.low,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                bf['trend'] as String,
                                style: AppTypography.caption.copyWith(
                                  color: isWorsening ? AppColors.critical : AppColors.low,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Sites
                    Text(
                      'Hotspot Locations: ${bf['sites']}',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),

                    // Action Container
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 14, color: AppColors.primaryRed),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Control: ${bf['action']}',
                              style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // TAB 4: SIF Precursor Density vs Report Count Analysis
  Widget _buildDensityAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Concept Explanation Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlack,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.compare_arrows_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ANALYTICAL RATIO INTELLIGENCE',
                            style: AppTypography.overline.copyWith(color: AppColors.primaryRed, letterSpacing: 1.1),
                          ),
                          Text(
                            'Report Volume vs SIF Precursor Density',
                            style: AppTypography.sectionTitle.copyWith(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Crucial HSE Insight: High reporting volume does NOT equal high risk. Sites with fewer total reports often carry dangerously high proportions of fatal precursors.',
                  style: AppTypography.bodySmall.copyWith(color: const Color(0xFFD1D5DB)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text('THE "VOLUME PARADOX" — FIELD COMPARISON', style: AppTypography.overline),
          const SizedBox(height: 10),

          _buildVolumeParadoxCard(
            siteA: 'Duliajan Main Complex',
            siteAReports: 412,
            siteASif: 58,
            siteADensity: '14.1%',
            siteAStatus: 'High Volume / Moderate Precursor Density',
            siteAColor: AppColors.medium,
            siteB: 'Moran Drilling Unit',
            siteBReports: 184,
            siteBSif: 62,
            siteBDensity: '33.7%',
            siteBStatus: 'Moderate Volume / CRITICAL Precursor Density',
            siteBColor: AppColors.critical,
            takeaway:
                'Moran Drilling logged less than half the reports of Duliajan, yet recorded MORE SIF precursors (62 vs 58) and 2.4x higher precursor density. Traditional counting would under-prioritize Moran.',
          ),
          const SizedBox(height: 16),

          Text('SITE RANKING BY SIF PRECURSOR DENSITY RATIO', style: AppTypography.overline),
          const SizedBox(height: 10),

          _buildDensityRankingCard(
            rank: 1,
            site: 'Moran Drilling Unit',
            totalReports: 184,
            sifCount: 62,
            densityPercent: 33.7,
            riskLevel: 'CRITICAL',
            primaryDriver: 'High-pressure energy isolation & rig floor pinch points',
            color: AppColors.critical,
          ),
          const SizedBox(height: 10),

          _buildDensityRankingCard(
            rank: 2,
            site: 'Naharkatiya GGS & Pipelines',
            totalReports: 228,
            sifCount: 54,
            densityPercent: 23.7,
            riskLevel: 'HIGH',
            primaryDriver: 'Confined space entry & flammable atmospheric purging',
            color: AppColors.high,
          ),
          const SizedBox(height: 10),

          _buildDensityRankingCard(
            rank: 3,
            site: 'Digboi Oil Field Operations',
            totalReports: 198,
            sifCount: 41,
            densityPercent: 20.7,
            riskLevel: 'HIGH',
            primaryDriver: 'Working at height on workover rigs & crane rigging',
            color: AppColors.high,
          ),
          const SizedBox(height: 10),

          _buildDensityRankingCard(
            rank: 4,
            site: 'Jorhat Exploration Basin',
            totalReports: 142,
            sifCount: 22,
            densityPercent: 15.5,
            riskLevel: 'MEDIUM',
            primaryDriver: 'Heavy vehicle transit & muddy access roads',
            color: AppColors.medium,
          ),
          const SizedBox(height: 10),

          _buildDensityRankingCard(
            rank: 5,
            site: 'Duliajan Main Complex',
            totalReports: 412,
            sifCount: 58,
            densityPercent: 14.1,
            riskLevel: 'MEDIUM',
            primaryDriver: 'Work authorization administrative paperwork & housekeeping',
            color: AppColors.medium,
          ),
          const SizedBox(height: 10),

          _buildDensityRankingCard(
            rank: 6,
            site: 'Numaligarh Refuelling & Terminal',
            totalReports: 120,
            sifCount: 9,
            densityPercent: 7.5,
            riskLevel: 'LOW',
            primaryDriver: 'Routine loading arm checks & slip hazards',
            color: AppColors.low,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- Helper Widget Builders ---

  static BarChartGroupData _buildBarGroup(int x, double total, double sif) {
    return BarChartGroupData(
      x: x,
      barsSpace: 3,
      barRods: [
        BarChartRodData(
          toY: total,
          color: AppColors.primaryBlack,
          width: 8.5,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2.5)),
        ),
        BarChartRodData(
          toY: sif,
          color: AppColors.primaryRed,
          width: 8.5,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2.5)),
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 10.5)),
      ],
    );
  }

  Widget _buildActivityRankingRow(
    String activity,
    int totalReports,
    int sifCount,
    double density,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    activity,
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${density.toStringAsFixed(1)}% SIF',
                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: density / 100,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reports: $totalReports', style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                Text('SIF Precursors: $sifCount', style: AppTypography.caption.copyWith(color: AppColors.critical, fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHazardProgressRow(String label, double pct, String countStr, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, fontSize: 11.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                countStr,
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700, color: color, fontSize: 10.5),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.surfaceSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteMatrixCard({
    required String siteName,
    required int totalReports,
    required int sifPrecursors,
    required String sifDensity,
    required int criticalCount,
    required int openBacklog,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  siteName,
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$sifDensity SIF Density',
                  style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildSiteMatrixMetric('Total', '$totalReports', AppColors.textPrimary)),
              const SizedBox(width: 4),
              Expanded(child: _buildSiteMatrixMetric('SIF Precursors', '$sifPrecursors', AppColors.critical)),
              const SizedBox(width: 4),
              Expanded(child: _buildSiteMatrixMetric('Critical', '$criticalCount', AppColors.critical)),
              const SizedBox(width: 4),
              Expanded(child: _buildSiteMatrixMetric('Open Actions', '$openBacklog', AppColors.medium)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSiteMatrixMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 9.5),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.w800),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildClusterCard({
    required String clusterId,
    required String activity,
    required String hazard,
    required String barrierFailure,
    required int occurrences,
    required int sifPotentialCount,
    required String affectedSites,
    required String period,
    required String trend,
    required bool trendIsUp,
    required String riskLevel,
    required Color riskColor,
    required String recommendedIntervention,
  }) {
    return EnterpriseCard(
      indicatorColor: riskColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlack,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  clusterId,
                  style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  riskLevel,
                  style: AppTypography.overline.copyWith(color: riskColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Triplet Correlation Breakdown
          _buildTripletRow(Icons.engineering_outlined, 'Activity', activity),
          const SizedBox(height: 6),
          _buildTripletRow(Icons.warning_amber_rounded, 'Hazard', hazard, valueColor: AppColors.critical),
          const SizedBox(height: 6),
          _buildTripletRow(Icons.shield_outlined, 'Barrier Flaw', barrierFailure, valueColor: AppColors.primaryRed),
          const SizedBox(height: 12),

          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Cluster Statistics
          Row(
            children: [
              Expanded(child: _buildClusterStat('Occurrences', '$occurrences Reports', AppColors.textPrimary)),
              const SizedBox(width: 6),
              Expanded(child: _buildClusterStat('SIF Precursors', '$sifPotentialCount Flagged', AppColors.critical)),
              const SizedBox(width: 6),
              Expanded(child: _buildClusterStat('Trend ($period)', trend, trendIsUp ? AppColors.critical : AppColors.low)),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            'Hotspot Units: $affectedSites',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // AI Recommended Action Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.primaryRed, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI RECOMMENDED INTERVENTION',
                        style: AppTypography.overline.copyWith(color: AppColors.primaryRed, fontSize: 9.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        recommendedIntervention,
                        style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripletRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        SizedBox(
          width: 80,
          child: Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(color: valueColor ?? AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildClusterStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 9.5), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(value, style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildMetricChip({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textSecondary)),
          Text(value, style: AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _buildVolumeParadoxCard({
    required String siteA,
    required int siteAReports,
    required int siteASif,
    required String siteADensity,
    required String siteAStatus,
    required Color siteAColor,
    required String siteB,
    required int siteBReports,
    required int siteBSif,
    required String siteBDensity,
    required String siteBStatus,
    required Color siteBColor,
    required String takeaway,
  }) {
    return EnterpriseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Site A
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(siteA, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: siteAColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                      child: Text(siteADensity, style: TextStyle(color: siteAColor, fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('Total Reports: $siteAReports', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(width: 12),
                    Text('SIF Precursors: $siteASif', style: AppTypography.caption.copyWith(color: AppColors.critical, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(siteAStatus, style: AppTypography.caption.copyWith(color: siteAColor, fontWeight: FontWeight.w600, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // VS Divider
          const Center(
            child: Text('VERSUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textTertiary, letterSpacing: 1.5)),
          ),
          const SizedBox(height: 10),

          // Site B (Critical Density)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: siteBColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: siteBColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(siteB, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: siteBColor, borderRadius: BorderRadius.circular(4)),
                      child: Text(siteBDensity, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('Total Reports: $siteBReports', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(width: 12),
                    Text('SIF Precursors: $siteBSif', style: AppTypography.caption.copyWith(color: AppColors.critical, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(siteBStatus, style: AppTypography.caption.copyWith(color: siteBColor, fontWeight: FontWeight.w700, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // AI Key Takeaway
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.primaryRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    takeaway,
                    style: AppTypography.caption.copyWith(color: AppColors.textPrimary, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDensityRankingCard({
    required int rank,
    required String site,
    required int totalReports,
    required int sifCount,
    required double densityPercent,
    required String riskLevel,
    required String primaryDriver,
    required Color color,
  }) {
    return EnterpriseCard(
      indicatorColor: color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: rank <= 3 ? AppColors.primaryBlack : AppColors.surfaceSecondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      color: rank <= 3 ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(site, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
                    Text('Risk Priority: $riskLevel', style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 10)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${densityPercent.toStringAsFixed(1)}%',
                    style: AppTypography.headingMedium.copyWith(color: color, fontSize: 16),
                  ),
                  Text('SIF Density', style: AppTypography.caption.copyWith(fontSize: 9.5, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: densityPercent / 50.0, // normalized against 50% max scale
              backgroundColor: AppColors.surfaceSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Reports: $totalReports', style: AppTypography.caption.copyWith(fontSize: 10)),
              Text('SIF Precursors: $sifCount', style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.critical, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Primary SIF Driver: $primaryDriver',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
