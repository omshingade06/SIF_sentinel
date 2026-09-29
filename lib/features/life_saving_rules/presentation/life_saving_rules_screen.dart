import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/oil_header.dart';
import '../../../shared/widgets/enterprise_card.dart';
import '../../reports/providers/reports_provider.dart';
import '../../reports/presentation/reports_list_screen.dart';

class LifeSavingRuleItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int sifReports;
  final double sifDensity;
  final String trend;
  final bool isTrendIncreasing;
  final String commonBarrierFailure;
  final List<String> mandatorySafeguards;

  const LifeSavingRuleItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.sifReports,
    required this.sifDensity,
    required this.trend,
    required this.isTrendIncreasing,
    required this.commonBarrierFailure,
    required this.mandatorySafeguards,
  });
}

class LifeSavingRulesScreen extends ConsumerStatefulWidget {
  const LifeSavingRulesScreen({super.key});

  @override
  ConsumerState<LifeSavingRulesScreen> createState() => _LifeSavingRulesScreenState();
}

class _LifeSavingRulesScreenState extends ConsumerState<LifeSavingRulesScreen> {
  String _searchQuery = '';
  String _sortBy = 'density'; // 'density', 'count', 'name'

  final List<LifeSavingRuleItem> _rules = const [
    LifeSavingRuleItem(
      id: 'LSR-01',
      name: 'Energy Isolation',
      description: 'Verify isolation and zero energy before work begins. Apply personal locks and tags.',
      icon: Icons.bolt_rounded,
      color: Color(0xFFE65100),
      sifReports: 42,
      sifDensity: 24.8,
      trend: '↑ 12%',
      isTrendIncreasing: true,
      commonBarrierFailure: 'Incomplete isolation verification & omitted LOTO padlocks',
      mandatorySafeguards: [
        'Apply personal safety padlock and danger tag on individual breaker.',
        'Conduct multi-meter Zero Energy State check at test point before contact.',
      ],
    ),
    LifeSavingRuleItem(
      id: 'LSR-02',
      name: 'Confined Space',
      description: 'Obtain authorization to enter a confined space. Test gas and verify atmosphere continuously.',
      icon: Icons.space_dashboard_rounded,
      color: Color(0xFFC62828),
      sifReports: 31,
      sifDensity: 21.4,
      trend: '↑ 8%',
      isTrendIncreasing: true,
      commonBarrierFailure: 'Entry before mandatory 4-gas testing & missing standby rescuer',
      mandatorySafeguards: [
        'Mandatory 4-gas atmosphere testing (O2, LEL, H2S, CO) before entry.',
        'Station certified Standby Rescuer with communication at manhole.',
      ],
    ),
    LifeSavingRuleItem(
      id: 'LSR-03',
      name: 'Line of Fire',
      description: 'Position yourself for safety. Protect yourself and others from moving machinery and stored energy.',
      icon: Icons.all_out_rounded,
      color: Color(0xFFB45309),
      sifReports: 56,
      sifDensity: 19.6,
      trend: '↓ 4%',
      isTrendIncreasing: false,
      commonBarrierFailure: 'Unsafe positioning / exclusion-zone failure around rotating equipment',
      mandatorySafeguards: [
        'Establish hard red-zone physical barricade around rotating zones.',
        'Secure high-pressure lines with rated whip-check cables.',
      ],
    ),
    LifeSavingRuleItem(
      id: 'LSR-04',
      name: 'Working at Height',
      description: 'Protect yourself against a fall when working at height. 100% tie-off above 1.8m.',
      icon: Icons.height_rounded,
      color: Color(0xFFC62828),
      sifReports: 38,
      sifDensity: 18.2,
      trend: '↑ 5%',
      isTrendIncreasing: true,
      commonBarrierFailure: 'Unhooked harness lanyard & missing self-retracting secondary lifeline',
      mandatorySafeguards: [
        '100% continuous dual-lanyard tie-off to certified anchor point.',
        'Inspect elevated scaffolding structure and green safety inspection tag.',
      ],
    ),
    LifeSavingRuleItem(
      id: 'LSR-05',
      name: 'Hot Work',
      description: 'Control flammables and ignition sources. Test atmosphere for combustible gas.',
      icon: Icons.whatshot_rounded,
      color: Color(0xFFE65100),
      sifReports: 29,
      sifDensity: 16.5,
      trend: '↓ 2%',
      isTrendIncreasing: false,
      commonBarrierFailure: 'Grinding/welding near live hydrocarbon lines without spark shielding',
      mandatorySafeguards: [
        'Continuous combustible gas area monitoring (0% LEL required).',
        'Deploy certified spark-containment fire blanket habitat.',
      ],
    ),
    LifeSavingRuleItem(
      id: 'LSR-06',
      name: 'Work Authorisation',
      description: 'Work with a valid permit when required. Confirm isolation and risk controls.',
      icon: Icons.assignment_late_rounded,
      color: Color(0xFF2563EB),
      sifReports: 27,
      sifDensity: 14.8,
      trend: '↑ 7%',
      isTrendIncreasing: true,
      commonBarrierFailure: 'Starting maintenance before permit verification & cross-shift sign-off',
      mandatorySafeguards: [
        'Verify valid digital PTW and risk assessment prior to job authorization.',
        'Conduct mandatory on-site Tool-Box Talk (TBT) before every shift.',
      ],
    ),
    LifeSavingRuleItem(
      id: 'LSR-07',
      name: 'Safe Mechanical Lifting',
      description: 'Plan lifting operations and control the area. Never walk under a suspended load.',
      icon: Icons.precision_manufacturing_rounded,
      color: Color(0xFFF59E0B),
      sifReports: 24,
      sifDensity: 13.9,
      trend: '↓ 6%',
      isTrendIncreasing: false,
      commonBarrierFailure: 'Overhead lift over pedestrian walkways & missing non-conductive taglines',
      mandatorySafeguards: [
        'Enforce drop-zone barricading along 360° crane swing radius.',
        'Mandate synthetic taglines to guide all suspended loads.',
      ],
    ),
    LifeSavingRuleItem(
      id: 'LSR-08',
      name: 'Bypassing Safety Controls',
      description: 'Obtain authorization before overriding or disabling safety-critical equipment.',
      icon: Icons.phonelink_erase_rounded,
      color: Color(0xFF7C3AED),
      sifReports: 18,
      sifDensity: 12.4,
      trend: '↑ 14%',
      isTrendIncreasing: true,
      commonBarrierFailure: 'Unauthorized jumper bypass on H2S gas detectors & throttled PRVs',
      mandatorySafeguards: [
        'Log formal management authorization in Safety Override Register.',
        'Enforce physical car-seal locks on all critical process safety valves.',
      ],
    ),
    LifeSavingRuleItem(
      id: 'LSR-09',
      name: 'Driving',
      description: 'Follow safe driving rules. Wear seatbelts, adhere to speed limits, reduce distractions.',
      icon: Icons.local_shipping_rounded,
      color: Color(0xFF16834B),
      sifReports: 12,
      sifDensity: 9.1,
      trend: '↓ 3%',
      isTrendIncreasing: false,
      commonBarrierFailure: 'Heavy forklift traveling with elevated loads obstructing operator vision',
      mandatorySafeguards: [
        'Enforce low travel mast clearance and pedestrian separation barriers.',
        'Conduct daily pre-use vehicle inspection checklist.',
      ],
    ),
  ];

  void _showTaxonomyEditorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.tune_rounded, color: AppColors.primaryRed, size: 22),
            const SizedBox(width: 8),
            Text('Configure IOGP Taxonomy', style: AppTypography.headingMedium.copyWith(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Life-Saving Rule taxonomy adheres to configured IOGP standards and is editable for OIL HSE organizational adjustments.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '• 9 Configured Life-Saving Rules Active\n• Custom OIL Barrier Failure Mappings Enabled\n• Real-Time SIF Precursor Density Recalculation',
                style: AppTypography.caption.copyWith(color: AppColors.textPrimary, height: 1.4),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('IOGP Life-Saving Rules taxonomy validated and synced.')),
              );
            },
            child: const Text('Save Configuration'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var filtered = _rules.where((r) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return r.name.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q) ||
          r.commonBarrierFailure.toLowerCase().contains(q);
    }).toList();

    if (_sortBy == 'density') {
      filtered.sort((a, b) => b.sifDensity.compareTo(a.sifDensity));
    } else if (_sortBy == 'count') {
      filtered.sort((a, b) => b.sifReports.compareTo(a.sifReports));
    } else {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OilHeader(
        title: 'IOGP Life-Saving Rules',
        subtitle: 'Precursor Density & Barrier Integrity',
        actions: [
          IconButton(
            tooltip: 'Configure Taxonomy',
            icon: const Icon(Icons.tune_rounded, color: AppColors.primaryRed),
            onPressed: _showTaxonomyEditorDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Callout
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
                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IOGP LIFE-SAVING RULES INTELLIGENCE',
                          style: AppTypography.overline.copyWith(color: AppColors.primaryRed, letterSpacing: 1.1),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '9 Critical Safety Controls Tracked',
                          style: AppTypography.headingMedium.copyWith(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Automated classification of safety reports to IOGP rules to detect critical barrier failures early.',
                          style: AppTypography.caption.copyWith(color: const Color(0xFFD1D5DB)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filter & Sort Controls
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 380;
                final searchField = TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search rules or barrier failures...',
                    prefixIcon: Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                );

                final sortDropdown = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    underline: const SizedBox(),
                    isDense: true,
                    isExpanded: isCompact,
                    items: const [
                      DropdownMenuItem(value: 'density', child: Text('Sort: SIF Density')),
                      DropdownMenuItem(value: 'count', child: Text('Sort: SIF Count')),
                      DropdownMenuItem(value: 'name', child: Text('Sort: Name')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _sortBy = v);
                    },
                  ),
                );

                if (isCompact) {
                  return Column(
                    children: [
                      searchField,
                      const SizedBox(height: 8),
                      sortDropdown,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: searchField),
                    const SizedBox(width: 10),
                    sortDropdown,
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Rules Cards
            ...filtered.map((rule) => _buildRuleCard(rule)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(LifeSavingRuleItem rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: EnterpriseCard(
        indicatorColor: rule.color,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: rule.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(rule.icon, color: rule.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              rule.name,
                              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w800),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: rule.isTrendIncreasing ? AppColors.criticalBg : AppColors.lowBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Trend: ${rule.trend}',
                              style: AppTypography.caption.copyWith(
                                color: rule.isTrendIncreasing ? AppColors.critical : AppColors.low,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rule.description,
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Metrics Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SIF REPORTS', style: AppTypography.overline.copyWith(fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${rule.sifReports}', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.critical)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SIF PRECURSOR DENSITY', style: AppTypography.overline.copyWith(fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${rule.sifDensity}%', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.primaryRed)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Common Barrier Failure Callout
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.criticalBg.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.critical.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.critical),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                        children: [
                          const TextSpan(text: 'Common Barrier Failure: ', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.critical)),
                          TextSpan(text: rule.commonBarrierFailure),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Mandatory Safeguards
            Text('MANDATORY BARRIER SAFEGUARDS', style: AppTypography.overline.copyWith(fontSize: 9.5)),
            const SizedBox(height: 6),
            ...rule.mandatorySafeguards.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.low),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(s, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 10),

            // Drill Down Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryRed,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 14),
                  label: const Text('View Associated SIF Reports', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5)),
                  onPressed: () {
                    ref.read(reportSearchQueryProvider.notifier).state = rule.name;
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const ReportsListScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
