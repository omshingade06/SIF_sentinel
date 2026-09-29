import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isRequestAccessMode = false;

  // Sign In Controllers
  final _identifierController = TextEditingController(text: 'OIL-EMP-2491');
  final _passwordController = TextEditingController(text: 'OilIndia@2026');
  bool _rememberMe = true;
  bool _obscurePassword = true;
  final _resetEmailController = TextEditingController();
  bool _isResettingPassword = false;

  // New Employee Request Access Controllers
  final _reqEmpIdController = TextEditingController(text: 'OIL00123');
  final _reqNameController = TextEditingController(text: 'Rahul Sharma');
  final _reqEmailController = TextEditingController(text: 'rahul.sharma@oilindia.in');
  final _reqPasswordController = TextEditingController(text: 'OilIndia@2026');
  String _selectedRole = 'engineer';
  String _selectedSite = 'Duliajan Main Complex';
  bool _obscureReqPassword = true;

  final List<String> _availableSites = const [
    'Duliajan Main Complex',
    'Digboi Oil Field',
    'Moran Drilling Unit',
    'Naharkatiya Gathering Station',
    'Jorhat Crude Terminal',
    'Dibrugarh Logistics Base',
    'All Sites',
  ];

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    _reqEmpIdController.dispose();
    _reqNameController.dispose();
    _reqEmailController.dispose();
    _reqPasswordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    FocusScope.of(context).unfocus();
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Employee ID / Corporate Email and Password.'),
          backgroundColor: Color(0xFF2B2A29),
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).login(
          identifier,
          password,
          rememberMe: _rememberMe,
        );

    if (success && mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  void _handleRequestAccess() async {
    FocusScope.of(context).unfocus();
    final empId = _reqEmpIdController.text.trim();
    final name = _reqNameController.text.trim();
    final email = _reqEmailController.text.trim();
    final password = _reqPasswordController.text.trim();

    if (empId.isEmpty || name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields (Employee ID, Name, Email, Password).'),
          backgroundColor: Color(0xFF2B2A29),
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid corporate email address.'),
          backgroundColor: Color(0xFF2B2A29),
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).requestAccess(
          employeeId: empId,
          name: name,
          email: email,
          password: password,
          role: _selectedRole,
          requestedSite: _selectedSite,
        );

    if (!success && mounted) {
      final error = ref.read(authProvider).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  void _handleSsoSignIn() async {
    FocusScope.of(context).unfocus();
    final success = await ref.read(authProvider.notifier).loginWithSso();
    if (success && mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _handleBiometricSignIn() async {
    FocusScope.of(context).unfocus();
    final success = await ref.read(authProvider.notifier).loginWithBiometrics();
    if (success && mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _showForgotPasswordDialog() {
    _resetEmailController.text = _identifierController.text.contains('@') ? _identifierController.text.trim() : '';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFFFFFFFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E5E8)),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE31E24).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lock_reset_rounded, color: Color(0xFFE31E24), size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF2B2A29)),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your official Oil India Limited corporate email to receive secure password reset instructions.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF687078), height: 1.4),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF2B2A29)),
                  decoration: InputDecoration(
                    labelText: 'Corporate Email Address',
                    hintText: 'e.g. pj_baruah@oilindia.in',
                    prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18, color: Color(0xFF687078)),
                    filled: true,
                    fillColor: const Color(0xFFF7F8FA),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E5E8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E5E8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE31E24), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: _isResettingPassword ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF687078), fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE31E24),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: _isResettingPassword
                    ? null
                    : () async {
                        final email = _resetEmailController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid email address.')),
                          );
                          return;
                        }

                        final messenger = ScaffoldMessenger.of(context);
                        final nav = Navigator.of(ctx);
                        setDialogState(() => _isResettingPassword = true);
                        final sent = await ref.read(authProvider.notifier).sendPasswordReset(email);
                        setDialogState(() => _isResettingPassword = false);

                        if (ctx.mounted) {
                          nav.pop();
                        }
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(sent
                                  ? 'Password reset instructions dispatched to $email'
                                  : 'Failed to send reset email. Contact administrator.'),
                              backgroundColor: const Color(0xFF2B2A29),
                            ),
                          );
                        }
                      },
                child: _isResettingPassword
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Send Reset Link', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Logo & Title Header
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Authentication Error / Alert Banners
                  if (authState.errorMessage != null && authState.errorMessage!.isNotEmpty) ...[
                    _buildErrorBanner(authState.errorMessage!, authState.errorCode),
                    const SizedBox(height: 16),
                  ],

                  // Session Expired Banner
                  if (authState.isSessionExpired) ...[
                    _buildSessionExpiredBanner(),
                    const SizedBox(height: 16),
                  ],

                  // Main Login Form Card
                  _buildLoginFormCard(authState),
                  const SizedBox(height: 16),

                  // SSO & Biometric Alternate Secure Access
                  _buildAlternateEnterpriseAccess(authState),
                  const SizedBox(height: 24),

                  // Footer: Secure Enterprise Login
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // SIF Sentinel App Logo
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E5E8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // SIF SENTINEL Title
        const Text(
          'SIF SENTINEL',
          style: TextStyle(
            color: Color(0xFF2B2A29),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Safety Intelligence Platform Subtitle
        const Text(
          'Safety Intelligence Platform',
          style: TextStyle(
            color: Color(0xFF687078),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

        // Problem Statement Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E5E8)),
          ),
          child: const Text(
            'OIL INDIA LIMITED • SIH26165',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE31E24),
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message, String? errorCode) {
    IconData icon = Icons.error_outline_rounded;
    Color borderColor = const Color(0xFFE31E24);
    Color bgColor = const Color(0xFFFEE2E2);

    if (errorCode == 'ROLE_UNASSIGNED') {
      icon = Icons.admin_panel_settings_outlined;
      borderColor = const Color(0xFFD97706);
      bgColor = const Color(0xFFFEF3C7);
    } else if (errorCode == 'USER_DISABLED') {
      icon = Icons.block_flipped;
      borderColor = const Color(0xFFDC2626);
      bgColor = const Color(0xFFFEE2E2);
    } else if (errorCode == 'NETWORK_ERROR') {
      icon = Icons.wifi_off_rounded;
      borderColor = const Color(0xFF64748B);
      bgColor = const Color(0xFFF1F5F9);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: borderColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errorCode == 'ROLE_UNASSIGNED'
                      ? 'Role Not Configured'
                      : errorCode == 'USER_DISABLED'
                          ? 'Account Deactivated'
                          : 'Authentication Failed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: borderColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF2B2A29),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionExpiredBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_clock_outlined, color: Color(0xFFD97706), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your session has expired. Please sign in again.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginFormCard(AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E5E8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mode Toggle: Sign In vs Request Access
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E5E8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isRequestAccessMode = false),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isRequestAccessMode ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: !_isRequestAccessMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.login_rounded,
                            size: 14,
                            color: !_isRequestAccessMode ? const Color(0xFFE31E24) : const Color(0xFF687078),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: !_isRequestAccessMode ? FontWeight.w800 : FontWeight.w600,
                                color: !_isRequestAccessMode ? const Color(0xFF2B2A29) : const Color(0xFF687078),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isRequestAccessMode = true),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isRequestAccessMode ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: _isRequestAccessMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_add_alt_1_outlined,
                            size: 14,
                            color: _isRequestAccessMode ? const Color(0xFFE31E24) : const Color(0xFF687078),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Request Access',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _isRequestAccessMode ? FontWeight.w800 : FontWeight.w600,
                                color: _isRequestAccessMode ? const Color(0xFF2B2A29) : const Color(0xFF687078),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (!_isRequestAccessMode)
            _buildSignInForm(authState)
          else
            _buildRequestAccessForm(authState),
        ],
      ),
    );
  }

  Widget _buildSignInForm(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Employee ID / Email Label & Field
        const Text(
          'Employee ID / Email',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2B2A29),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _identifierController,
          style: const TextStyle(fontSize: 14, color: Color(0xFF2B2A29), fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Enter Employee ID or Email',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            prefixIcon: const Icon(Icons.badge_outlined, size: 18, color: Color(0xFF687078)),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E5E8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E5E8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE31E24), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Password Label & Field with 👁 toggle
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2B2A29),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(fontSize: 14, color: Color(0xFF2B2A29), fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Enter password',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF687078)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 18,
                color: const Color(0xFF687078),
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E5E8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E5E8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE31E24), width: 1.5),
            ),
          ),
          onSubmitted: (_) => _handleSignIn(),
        ),
        const SizedBox(height: 12),

        // Remember this device & Forgot Password
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8,
          children: [
            InkWell(
              onTap: () => setState(() => _rememberMe = !_rememberMe),
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: const Color(0xFFE31E24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      side: const BorderSide(color: Color(0xFFE2E5E8), width: 1.5),
                      onChanged: (v) => setState(() => _rememberMe = v ?? true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Remember device',
                      style: TextStyle(fontSize: 12, color: Color(0xFF687078), fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: _showForgotPasswordDialog,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFE31E24),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // [ SIGN IN ] Button
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: authState.isLoading ? null : _handleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE31E24),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: authState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                  )
                : const Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestAccessForm(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Employee ID
        const Text(
          'Employee ID *',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2B2A29)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _reqEmpIdController,
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF2B2A29), fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'e.g. OIL00123',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            prefixIcon: const Icon(Icons.badge_outlined, size: 18, color: Color(0xFF687078)),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E5E8))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E5E8))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE31E24), width: 1.5)),
          ),
        ),
        const SizedBox(height: 12),

        // Full Name
        const Text(
          'Full Name *',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2B2A29)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _reqNameController,
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF2B2A29), fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'e.g. Rahul Sharma',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF687078)),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E5E8))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E5E8))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE31E24), width: 1.5)),
          ),
        ),
        const SizedBox(height: 12),

        // Corporate Email
        const Text(
          'Corporate Email *',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2B2A29)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _reqEmailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF2B2A29), fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'e.g. rahul@oilindia.in',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            prefixIcon: const Icon(Icons.email_outlined, size: 18, color: Color(0xFF687078)),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E5E8))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E5E8))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE31E24), width: 1.5)),
          ),
        ),
        const SizedBox(height: 12),

        // Password
        const Text(
          'Password *',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2B2A29)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _reqPasswordController,
          obscureText: _obscureReqPassword,
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF2B2A29), fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Choose password',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF687078)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureReqPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 18,
                color: const Color(0xFF687078),
              ),
              onPressed: () => setState(() => _obscureReqPassword = !_obscureReqPassword),
            ),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E5E8))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E5E8))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE31E24), width: 1.5)),
          ),
        ),
        const SizedBox(height: 12),

        // Role Selection
        const Text(
          'Designation / Role *',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2B2A29)),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          initialValue: _selectedRole,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.work_outline_rounded, size: 18, color: Color(0xFF687078)),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E5E8))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E5E8))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE31E24), width: 1.5)),
          ),
          items: const [
            DropdownMenuItem(value: 'engineer', child: Text('Operations & Facilities Engineer', style: TextStyle(fontSize: 13))),
            DropdownMenuItem(value: 'site_supervisor', child: Text('Rig / Site Supervisor', style: TextStyle(fontSize: 13))),
            DropdownMenuItem(value: 'hse_officer', child: Text('Field HSE Officer', style: TextStyle(fontSize: 13))),
            DropdownMenuItem(value: 'hse_director', child: Text('HSE Directorate / Manager', style: TextStyle(fontSize: 13))),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _selectedRole = val);
          },
        ),
        const SizedBox(height: 12),

        // Requested Site
        const Text(
          'Primary Site / Operating Unit *',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2B2A29)),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          initialValue: _selectedSite,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF687078)),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E5E8))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E5E8))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE31E24), width: 1.5)),
          ),
          items: _availableSites.map((site) {
            return DropdownMenuItem(value: site, child: Text(site, style: const TextStyle(fontSize: 13)));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedSite = val);
          },
        ),
        const SizedBox(height: 14),

        // Informational Note
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your request will be submitted for System Administrator approval. Your role dashboard unlocks upon acceptance.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF92400E), height: 1.4, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // [ SUBMIT ACCESS REQUEST ] Button
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: authState.isLoading ? null : _handleRequestAccess,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE31E24),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: authState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                  )
                : const Text(
                    'SUBMIT ACCESS REQUEST',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlternateEnterpriseAccess(AuthState authState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 380;
        final textScaler = MediaQuery.textScalerOf(context);
        final isLargeText = textScaler.scale(12) > 14;
        final useSideBySide = isWide && !isLargeText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Responsive Enterprise SSO Divider
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFE2E5E8), thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 13,
                        color: Color(0xFF687078),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'OR ENTERPRISE SSO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF687078).withValues(alpha: 0.9),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFFE2E5E8), thickness: 1)),
              ],
            ),
            const SizedBox(height: 12),

            // SSO & Biometrics Action Container (Adaptive Side-by-Side or Stacked)
            if (useSideBySide)
              Row(
                children: [
                  Expanded(
                    child: _buildSsoButton(
                      authState: authState,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildBiometricButton(
                      authState: authState,
                      isCompact: true,
                    ),
                  ),
                ],
              )
            else ...[
              _buildSsoButton(
                authState: authState,
                isCompact: false,
              ),
              const SizedBox(height: 8),
              _buildBiometricButton(
                authState: authState,
                isCompact: false,
              ),
            ],

            const SizedBox(height: 10),

            // Responsive SSO Identity Providers & Security Badges
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E5E8), width: 0.8),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildProtocolPill('SAML 2.0', Icons.vpn_key_rounded),
                  _buildProtocolPill('Azure AD', Icons.cloud_done_outlined),
                  _buildProtocolPill('Okta / ADFS', Icons.security_rounded),
                  _buildProtocolPill('FIDO2 Biometrics', Icons.fingerprint_rounded),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSsoButton({
    required AuthState authState,
    required bool isCompact,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: OutlinedButton(
        onPressed: authState.isLoading ? null : _handleSsoSignIn,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFFFFFF),
          foregroundColor: const Color(0xFF2B2A29),
          side: const BorderSide(color: Color(0xFFE2E5E8), width: 1.2),
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 10 : 14,
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2A29).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.vpn_key_outlined,
                size: 15,
                color: Color(0xFF2B2A29),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isCompact ? 'Corporate SSO' : 'OIL Corporate SSO / SAML 2.0',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B2A29),
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricButton({
    required AuthState authState,
    required bool isCompact,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: OutlinedButton(
        onPressed: authState.isLoading ? null : _handleBiometricSignIn,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFFFFFF),
          foregroundColor: const Color(0xFF2B2A29),
          side: const BorderSide(color: Color(0xFFE2E5E8), width: 1.2),
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 10 : 14,
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE31E24).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                size: 16,
                color: Color(0xFFE31E24),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isCompact ? 'Biometrics' : 'Biometric Authorization',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B2A29),
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolPill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E5E8), width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: const Color(0xFF687078)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF687078),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_rounded, size: 14, color: Color(0xFF687078)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Secure Enterprise Login',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF687078),
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'AES-256 Encrypted Session • TLS 1.3 • Hardware Keystore Bound',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF9CA3AF),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
