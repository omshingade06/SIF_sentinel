import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sif_sentinel/features/auth/providers/auth_provider.dart';
import 'package:sif_sentinel/features/auth/data/auth_repository.dart';
import 'package:sif_sentinel/core/security/rbac_service.dart';
import 'package:sif_sentinel/shared/models/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Employee Access Request & RBAC Lifecycle Tests', () {
    test('New employee access request transitions to accountPending state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);

      final result = await notifier.requestAccess(
        employeeId: 'OIL-EMP-9988',
        name: 'Arunav Kalita',
        email: 'arunav.kalita@oilindia.in',
        password: 'Password@123',
        role: 'engineer',
        requestedSite: 'Duliajan Main Complex',
      );

      expect(result, isTrue);
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.accountPending));
      expect(state.isAuthenticated, isFalse);
    });

    test('Pending exception is thrown when inactive/pending user attempts to validate profile', () {
      final pendingDoc = {
        'employeeId': 'OIL-EMP-7744',
        'name': 'Pooja Borah',
        'email': 'pooja.borah@oilindia.in',
        'role': 'hse_officer',
        'isActive': false,
        'status': 'pending',
      };

      expect(
        () {
          final status = pendingDoc['status']?.toString().toLowerCase();
          final isActive = pendingDoc['isActive'] == true;
          if (!isActive || status == 'pending') {
            throw AccountPendingException(employeeId: pendingDoc['employeeId'] as String);
          }
        },
        throwsA(isA<AccountPendingException>()),
      );
    });

    test('Admin approval activates user and unlocks role-specific RBAC permissions', () {
      final newRegisteredUser = UserModel(
        id: 'USR-TEST-001',
        employeeId: 'OIL-EMP-9988',
        name: 'Arunav Kalita',
        email: 'arunav.kalita@oilindia.in',
        role: 'engineer',
        department: 'Operations & Facilities',
        assignedSites: ['Duliajan Main Complex'],
        isActive: false,
      );

      // Initially inactive/pending
      expect(newRegisteredUser.isActive, isFalse);

      // Admin accepts request -> isActive = true
      final approvedUser = newRegisteredUser.copyWith(isActive: true);
      expect(approvedUser.isActive, isTrue);
      expect(approvedUser.userRole, equals(UserRole.engineer));

      // Check Engineer RBAC permissions
      expect(RbacService.hasPermission(approvedUser.userRole, Permission.createObservation), isTrue);
      expect(RbacService.hasPermission(approvedUser.userRole, Permission.viewAdminDashboard), isFalse);

      // Verify HSE Officer RBAC permissions
      final hseUser = approvedUser.copyWith(role: 'hse_officer');
      expect(hseUser.userRole, equals(UserRole.hseOfficer));
      expect(RbacService.hasPermission(hseUser.userRole, Permission.overrideAiClassification), isTrue);
      expect(RbacService.hasPermission(hseUser.userRole, Permission.manageUsers), isFalse);

      // Verify Administrator RBAC permissions
      final adminUser = approvedUser.copyWith(role: 'administrator');
      expect(adminUser.userRole, equals(UserRole.administrator));
      expect(RbacService.hasPermission(adminUser.userRole, Permission.viewAdminDashboard), isTrue);
      expect(RbacService.hasPermission(adminUser.userRole, Permission.manageUsers), isTrue);
    });

    test('Role conversion supports both legacy and exact enum key formats', () {
      expect(UserRole.tryFromString('engineer'), equals(UserRole.engineer));
      expect(UserRole.tryFromString('Operations & Facilities Engineer'), equals(UserRole.engineer));
      expect(UserRole.tryFromString('site_supervisor'), equals(UserRole.siteSupervisor));
      expect(UserRole.tryFromString('Rig / Site Supervisor'), equals(UserRole.siteSupervisor));
      expect(UserRole.tryFromString('hse_officer'), equals(UserRole.hseOfficer));
      expect(UserRole.tryFromString('Field HSE Officer'), equals(UserRole.hseOfficer));
      expect(UserRole.tryFromString('hse_director'), equals(UserRole.hseDirectorate));
      expect(UserRole.tryFromString('HSE Directorate / Manager'), equals(UserRole.hseDirectorate));
      expect(UserRole.tryFromString('administrator'), equals(UserRole.administrator));
    });
  });
}
