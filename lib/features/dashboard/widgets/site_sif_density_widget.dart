import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/enterprise_card.dart';

class SiteDensityItem {
  final String siteName;
  final int totalReports;
  final int sifReports;
  final double density;
  final String trend;
  final String primaryActivity;

  const SiteDensityItem({
    required this.siteName,
    required this.totalReports,
    required this.sifReports,
    required this.density,
    required this.trend,
    required this.primaryActivity,
  });
}

class SiteSifDensityWidget extends StatefulWidget {
  const SiteSifDensityWidget({super.key});

  @override
  State<SiteSifDensityWidget> createState() => _SiteSifDensityWidgetState();
}

class _SiteSifDensityWidgetState extends State<SiteSifDensityWidget> {
  bool _sortHighToLow = true;
  String _selectedActivityFilter = 'All Activities';
  final String _selectedPeriod = '30D';

  final List<SiteDensityItem> _siteData = const [
    SiteDensityItem(siteName: 'Duliajan Main Complex', totalReports: 34, sifReports: 8, density: 23.5, trend: '↑ 2.1%', primaryActivity: 'Maintenance'),
    SiteDensityItem(siteName: 'Digboi Oil Field', totalReports: 19, sifReports: 4, density: 21.1, trend: '↓ 1.4%', primaryActivity: 'Drilling'),
    SiteDensityItem(siteName: 'Naharkatiya Gathering Station', totalReports: 14, sifReports: 2, density: 14.3, trend: '↑ 0.8%', primaryActivity: 'Pipeline Operations'),
    SiteDensityItem(siteName: 'Moran Drilling Unit', totalReports: 27, sifReports: 5, density: 18.5, trend: '↑ 3.2%', primaryActivity: 'Drilling'),
    SiteDensityItem(siteName: 'Jorhat Crude Terminal', totalReports: 11, sifReports: 1, density: 9.1, trend: '↓ 0.5%', primaryActivity: 'Pipeline Operations'),
    SiteDensityItem(siteName: 'Dibrugarh Logistics Base', totalReports: 8, sifReports: 1, density: 12.5, trend: '— 0.0%', primaryActivity: 'Lifting & Material Handling'),
  ];

  @override
  Widget build(BuildContext context) {
    var list = _siteData.where((s) {
      if (_selectedActivityFilter == 'All Activities') return true;
      return s.primaryActivity == _selectedActivityFilter;
    }).toList();

    list.sort((a, b) => _sortHighToLow ? b.density.compareTo(a.density) : a.density.compareTo(b.density));

    return EnterpriseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.location_on_outlined, color: AppColors.primaryRed, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'SIF Precursor Density by Site',
                        style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: _sortHighToLow ? 'Sort: Low → High' : 'Sort: High → Low',
                icon: Icon(
                  _sortHighToLow ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: AppColors.primaryRed,
                  size: 18,
                ),
                onPressed: () => setState(() => _sortHighToLow = !_sortHighToLow),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'SIF Density = SIF-Potential Reports / Total Reports per Asset',
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 10.5),
          ),
          const SizedBox(height: 12),

          // Activity & Period Filter Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedActivityFilter,
                    isExpanded: true,
                    underline: const SizedBox(),
                    isDense: true,
                    style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    items: const [
                      DropdownMenuItem(value: 'All Activities', child: Text('All Activities', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Drilling', child: Text('Drilling', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Pipeline Operations', child: Text('Pipeline', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Lifting & Material Handling', child: Text('Lifting', overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedActivityFilter = v);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text('Period: $_selectedPeriod', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Site Density Bars
          ...list.map((site) => _buildSiteDensityRow(site)),
        ],
      ),
    );
  }

  Widget _buildSiteDensityRow(SiteDensityItem site) {
    final fraction = (site.density / 30).clamp(0.0, 1.0);
    final Color barColor = site.density >= 20.0
        ? AppColors.critical
        : (site.density >= 15.0 ? AppColors.high : AppColors.low);

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
                  site.siteName,
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${site.sifReports} / ${site.totalReports} SIF',
                    style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 10.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${site.density.toStringAsFixed(1)}%',
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w800, color: barColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: AppColors.surfaceSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
