import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/security/rbac_service.dart';
import '../../../shared/widgets/oil_header.dart';
import '../../../shared/widgets/enterprise_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final role = user.userRole;
    final permissions = RbacService.getPermissionsForRole(role);

    Color roleColor;
    switch (role) {
      case UserRole.administrator:
        roleColor = const Color(0xFF2B2A29);
        break;
      case UserRole.hseDirectorate:
        roleColor = const Color(0xFFE31E24);
        break;
      case UserRole.hseOfficer:
        roleColor = const Color(0xFFD97706);
        break;
      case UserRole.siteSupervisor:
        roleColor = const Color(0xFFC2410C);
        break;
      case UserRole.engineer:
        roleColor = const Color(0xFF2563EB);
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: const OilHeader(
        title: 'User Profile & Identity',
        subtitle: 'Role-Based Access Control Scope',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 20 Requirement: Who am I? What role do I have? What site/scope do I have?
            EnterpriseCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: const Color(0xFFFFFFFF),
              border: BorderSide(color: roleColor.withValues(alpha: 0.3), width: 1.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: roleColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: roleColor.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2B2A29),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: roleColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    role.displayName.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: roleColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: user.isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    user.isActive ? 'ACTIVE ACCOUNT' : 'INACTIVE',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: user.isActive ? const Color(0xFF166534) : const Color(0xFF991B1B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${user.employeeId} • ${user.department}',
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF687078)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFE2E5E8)),

                  // Authorized Site Scope Callout
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E5E8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFE31E24)),
                            SizedBox(width: 4),
                            Text(
                              'AUTHORIZED OPERATIONAL SCOPE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF687078),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.siteScopeFormatted,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2B2A29),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Backend Firestore Security Rules strictly restrict queries to this assigned jurisdiction.',
                          style: TextStyle(fontSize: 10.5, color: Color(0xFF687078)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // What can I do? (Authorized RBAC Capabilities)
            EnterpriseCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ROLE PERMISSIONS & CAPABILITIES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF687078),
                          letterSpacing: 0.6,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE2E5E8)),
                        ),
                        child: Text(
                          '${permissions.length} Grants',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFE31E24)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Operational authorization granted by Oil India Limited HSE Security Policy:',
                    style: AppTypography.caption.copyWith(color: const Color(0xFF687078)),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: permissions.map((p) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E5E8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, size: 12, color: Color(0xFF166534)),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                p.description,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2B2A29),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Enterprise Security & Session Health
            EnterpriseCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ENTERPRISE SECURITY & SESSION HEALTH',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF687078),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSecurityRow(
                    'Session Encryption',
                    'AES-256 Hardware Keystore Bound',
                    Icons.lock_outline_rounded,
                    const Color(0xFF166534),
                  ),
                  const Divider(height: 16, color: Color(0xFFE2E5E8)),
                  _buildSecurityRow(
                    'Inactivity Watchdog',
                    '15-Minute Auto-Lock Active',
                    Icons.timer_outlined,
                    const Color(0xFF2563EB),
                  ),
                  const Divider(height: 16, color: Color(0xFFE2E5E8)),
                  _buildSecurityRow(
                    'Identity Authority',
                    'Oil India Limited Active Directory / Firebase Auth',
                    Icons.verified_user_outlined,
                    const Color(0xFFD97706),
                  ),
                  const Divider(height: 16, color: Color(0xFFE2E5E8)),
                  _buildSecurityRow(
                    'Biometric Quick Login',
                    'Hardware Fingerprint / Face ID Enabled',
                    Icons.fingerprint_rounded,
                    const Color(0xFFE31E24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Secure Logout Button
            CustomButton(
              label: 'Sign Out & Invalidate Enterprise Session',
              variant: ButtonVariant.outlined,
              icon: Icons.logout_rounded,
              width: double.infinity,
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityRow(String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2B2A29)),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF687078)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
