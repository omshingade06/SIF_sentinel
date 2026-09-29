import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/oil_constants.dart';
import 'core/security/rbac_service.dart';
import 'core/security/session_security_service.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/auth_status_screens.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/reports/presentation/reports_list_screen.dart';
import 'features/insights/presentation/insights_screen.dart';
import 'features/actions/presentation/action_center_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/admin/presentation/admin_screen.dart';
import 'features/life_saving_rules/presentation/life_saving_rules_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/auth/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SifSentinelApp()));
}

class SifSentinelApp extends StatelessWidget {
  const SifSentinelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIF Sentinel — OIL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const StartupAuthGate(),
    );
  }
}

/// Root Application Gateway enforcing Startup Flow, Auth State & Role-Based Access
class StartupAuthGate extends ConsumerWidget {
  const StartupAuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    switch (authState.status) {
      case AuthStatus.initial:
      case AuthStatus.initError:
      case AuthStatus.unauthenticated:
        return const LoginScreen();

      case AuthStatus.accountInactive:
        return const AccountInactiveScreen();

      case AuthStatus.accountPending:
        return AccountPendingScreen(employeeId: authState.employeeId);

      case AuthStatus.profileNotFound:
        return const ProfileNotFoundScreen();

      case AuthStatus.configError:
        return const AccessConfigErrorScreen();

      case AuthStatus.authenticated:
        if (authState.isSessionLocked) {
          return _buildSessionLockedScreen(context, ref);
        }
        return const MainNavigationShell();
    }
  }

  Widget _buildSessionLockedScreen(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFF2B2A29),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE31E24).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE31E24), width: 2),
                    ),
                    child: const Icon(Icons.lock_clock_rounded, color: Color(0xFFE31E24), size: 48),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SESSION LOCKED FOR SECURITY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your session has expired due to 15-minute user inactivity. Sensitive industrial safety data is protected.',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFE31E24),
                          child: Text(
                            user.name.isNotEmpty ? user.name.substring(0, 1) : 'O',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                              Text(
                                '${user.userRole.displayName} • ${user.employeeId}',
                                style: const TextStyle(color: Colors.white60, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(authProvider.notifier).unlockSession();
                    },
                    icon: const Icon(Icons.fingerprint_rounded, color: Colors.white),
                    label: const Text('Unlock Session with Biometrics / PIN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE31E24),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.white60, size: 16),
                    label: const Text('Sign Out & Return to Login', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final role = user.userRole;

    // Build role-specific navigation configuration
    final navConfig = _getNavConfigForRole(role);

    if (_currentIndex >= navConfig.screens.length) {
      _currentIndex = 0;
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => SessionSecurityService().recordUserActivity(),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: navConfig.screens,
        ),
        drawer: _buildAppDrawer(context, ref, user, role),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            border: Border(
              top: BorderSide(color: Color(0xFFE2E5E8), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: const Color(0xFFFFFFFF),
              selectedItemColor: const Color(0xFFE31E24),
              unselectedItemColor: const Color(0xFF687078),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: navConfig.items,
            ),
          ),
        ),
      ),
    );
  }

  _RoleNavConfig _getNavConfigForRole(UserRole role) {
    return _RoleNavConfig(
      screens: const [
        DashboardScreen(),
        ReportsListScreen(),
        InsightsScreen(),
        ActionCenterScreen(),
        ProfileScreen(),
      ],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard_rounded),
          label: 'Command',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment_rounded),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome_outlined),
          activeIcon: Icon(Icons.auto_awesome_rounded),
          label: 'Intelligence',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.checklist_rtl_outlined),
          activeIcon: Icon(Icons.checklist_rtl_rounded),
          label: 'Actions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildAppDrawer(BuildContext context, WidgetRef ref, dynamic user, UserRole role) {
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

    return Drawer(
      backgroundColor: const Color(0xFFFFFFFF),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Drawer Header with OIL Branding & RBAC Role Badge
                      Container(
                        padding: const EdgeInsets.all(20),
                        color: const Color(0xFF2B2A29),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE31E24),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'OIL',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
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
                                        OilConstants.appName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: roleColor.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: roleColor.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                'RBAC ROLE: ${role.displayName.toUpperCase()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Scope: ${user.siteScopeFormatted}',
                              style: const TextStyle(color: Colors.white60, fontSize: 10.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Navigation Links
                      ListTile(
                        leading: const Icon(Icons.shield_outlined, color: Color(0xFFE31E24)),
                        title: const Text('IOGP Life-Saving Rules', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                        subtitle: const Text('9 Rules Compliance & SIF Density', style: TextStyle(fontSize: 11, color: Color(0xFF687078))),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => const LifeSavingRulesScreen()),
                          );
                        },
                      ),

                      ListTile(
                        leading: const Icon(Icons.notifications_outlined, color: Color(0xFFE31E24)),
                        title: const Text('Safety Alerts & Notifications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => const NotificationsScreen()),
                          );
                        },
                      ),

                      if (role == UserRole.administrator || role == UserRole.hseDirectorate || role == UserRole.hseOfficer) ...[
                        ListTile(
                          leading: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF2B2A29)),
                          title: const Text('System Governance & Audit Vault', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                          subtitle: const Text('Users, Security & RBAC Matrix', style: TextStyle(fontSize: 11, color: Color(0xFF687078))),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => const AdminScreen()),
                            );
                          },
                        ),
                      ],

                      ListTile(
                        leading: const Icon(Icons.person_outline_rounded, color: Color(0xFF2B2A29)),
                        title: const Text('User Profile & Identity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => const ProfileScreen()),
                          );
                        },
                      ),

                      const Spacer(),
                      const Divider(color: Color(0xFFE2E5E8)),

                      // Secure Logout Tile
                      ListTile(
                        leading: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
                        title: const Text('Sign Out', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700, fontSize: 13.5)),
                        subtitle: const Text('End current session securely', style: TextStyle(fontSize: 10.5, color: Color(0xFF687078))),
                        onTap: () {
                          Navigator.of(context).pop();
                          ref.read(authProvider.notifier).logout();
                        },
                      ),

                      const Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OIL INDIA LIMITED • HSE DIRECTORATE',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF687078),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Enterprise Safety Intelligence • ISO 45001 Compliant',
                              style: TextStyle(fontSize: 9.5, color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoleNavConfig {
  final List<Widget> screens;
  final List<BottomNavigationBarItem> items;

  const _RoleNavConfig({required this.screens, required this.items});
}
