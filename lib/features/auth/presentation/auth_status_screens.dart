import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/oil_constants.dart';
import '../providers/auth_provider.dart';

/// Screen displayed when an authenticated user's account is deactivated (`isActive == false`)
class AccountInactiveScreen extends ConsumerWidget {
  const AccountInactiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E5E8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Danger Status Indicator
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFDC2626), width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.block_flipped,
                          color: Color(0xFFDC2626),
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Account Inactive',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2B2A29),
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Description
                    const Text(
                      'Your SIF Sentinel account is currently inactive.\n\nPlease contact your administrator.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF687078),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () => ref.read(authProvider.notifier).logout(),
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text(
                          'Logout',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE31E24),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // OIL Footer Note
                    Text(
                      '${OilConstants.orgName} • HSE Access Governance',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Screen displayed when user exists in Firestore but role is not assigned or null
class AccountPendingScreen extends ConsumerWidget {
  final String? employeeId;
  const AccountPendingScreen({super.key, this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final empId = employeeId ?? authState.employeeId ?? authState.currentUser?.employeeId ?? 'OIL-EMP';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E5E8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pending Status Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD97706), width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.hourglass_top_rounded,
                          color: Color(0xFFD97706),
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Access Request Pending',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2B2A29),
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Description
                    const Text(
                      'Your employee access request has been submitted to the SIF Sentinel administrator.\n\nOnce accepted by the administrator, your role dashboard will be automatically unlocked.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF687078),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Employee ID Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E5E8)),
                      ),
                      child: Text(
                        'Employee ID: $empId',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2B2A29),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.hourglass_top_rounded, size: 14, color: Color(0xFFD97706)),
                          SizedBox(width: 6),
                          Text(
                            'STATUS: AWAITING ADMIN APPROVAL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions: Refresh & Logout
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: () => ref.read(authProvider.notifier).refreshProfile(),
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text(
                                'Check Status',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2B2A29),
                                side: const BorderSide(color: Color(0xFFE2E5E8)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: () => ref.read(authProvider.notifier).logout(),
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: const Text(
                                'Back to Login',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE31E24),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Screen displayed when Firebase Authentication succeeds, but users/{uid} is missing in Firestore
class ProfileNotFoundScreen extends ConsumerWidget {
  const ProfileNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E5E8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Not Found Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFDC2626), width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_search_rounded,
                          color: Color(0xFFDC2626),
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Profile Not Found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2B2A29),
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Description
                    const Text(
                      'Your authentication was successful, but your SIF Sentinel employee profile could not be found.\n\nPlease contact your administrator.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF687078),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Actions: Retry & Logout
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: () => ref.read(authProvider.notifier).refreshProfile(),
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text(
                                'Retry',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2B2A29),
                                side: const BorderSide(color: Color(0xFFE2E5E8)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: () => ref.read(authProvider.notifier).logout(),
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: const Text(
                                'Logout',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE31E24),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Screen displayed when the Firestore role does not match supported roles
class AccessConfigErrorScreen extends ConsumerWidget {
  const AccessConfigErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E5E8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Config Error Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFDC2626), width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.rule_folder_outlined,
                          color: Color(0xFFDC2626),
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Access Configuration Error',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2B2A29),
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Description
                    const Text(
                      'Your account role is not configured correctly.\n\nPlease contact your administrator.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF687078),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () => ref.read(authProvider.notifier).logout(),
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text(
                          'Logout',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE31E24),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
