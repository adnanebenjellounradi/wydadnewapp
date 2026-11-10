import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool codeSent = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool emailTouched = false;
  bool codeTouched = false;
  bool passwordTouched = false;
  bool confirmPasswordTouched = false;

  final String organizationId = "20";
  final Color primary = const Color(0xFFA8161F);

  // ───── VALIDATION ─────
  String? validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.emailRequired;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) return l10n.invalidEmail;
    return null;
  }

  String? validateCode(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.resetCodeRequired;
    if (value.length != 6) return l10n.resetCodeLength;
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return l10n.resetCodeDigitsOnly;
    return null;
  }

  String? validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.passwordRequired;
    if (value.length < 6) return l10n.passwordMinLength;
    return null;
  }

  String? validateConfirmPassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.confirmPasswordRequired;
    if (value != passwordController.text) return l10n.passwordsDoNotMatch;
    return null;
  }

  // ───── API ─────
  Future<void> sendResetCode() async {
    final l10n = AppLocalizations.of(context)!;
    if (!codeSent && !_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://ticketing.ma/api/customer/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailController.text.trim(),
          'organization_id': organizationId,
        }),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        setState(() => codeSent = true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            jsonResponse['message'] ?? l10n.codeSentToEmail,
            style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
      } else {
        throw Exception(jsonResponse['message'] ?? l10n.errorSendingCode);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${l10n.error}: $e',
            style: const TextStyle(color: Colors.white, fontFamily: 'Inter')),
        backgroundColor: const Color(0xFFE41E26),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> resetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://ticketing.ma/api/customer/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailController.text.trim(),
          'organization_id': organizationId,
          'reset_token': codeController.text.trim(),
          'password': passwordController.text,
          'confirm_password': confirmPasswordController.text,
        }),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            jsonResponse['message'] ?? l10n.passwordResetSuccess,
            style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.pop(context);
      } else {
        throw Exception(
            jsonResponse['message'] ?? l10n.errorResettingPassword);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${l10n.error}: $e',
            style: const TextStyle(color: Colors.white, fontFamily: 'Inter')),
        backgroundColor: const Color(0xFFE41E26),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ───── BUILD ─────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A0710), Color(0xFF23030A), Color(0xFF120104)],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Glow radial
            Positioned(
              top: -140,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 520,
                  height: 520,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFC8172A).withOpacity(0.55),
                        const Color(0xFFC8172A).withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.62],
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildHeader(l10n),
                  ),

                  // Formulaire
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Icône
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFD11A2A),
                                    Color(0xFFA8161F),
                                    Color(0xFF6E0B12)
                                  ],
                                ),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
                              ),
                              child: const Icon(
                                Icons.lock_reset,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Titre
                            Text(
                              l10n.forgotPassword,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                codeSent
                                    ? l10n.enterCodeAndNewPassword
                                    : l10n.enterEmailToReceiveCode,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.72),
                                  fontSize: 14,
                                  height: 1.5,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Form fields
                            if (!codeSent) ...[
                              _darkField(
                                label: l10n.email,
                                controller: emailController,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => validateEmail(v, l10n),
                                onChanged: (_) =>
                                    setState(() => emailTouched = true),
                              ),
                              const SizedBox(height: 20),
                              _buildPrimaryButton(
                                label: l10n.sendCode,
                                onPressed: isLoading ? null : sendResetCode,
                                loading: isLoading,
                              ),
                            ] else ...[
                              _darkField(
                                label: l10n.resetCode,
                                controller: codeController,
                                icon: Icons.lock_outline,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                validator: (v) => validateCode(v, l10n),
                                onChanged: (_) =>
                                    setState(() => codeTouched = true),
                              ),
                              const SizedBox(height: 14),
                              _darkField(
                                label: l10n.newPassword,
                                controller: passwordController,
                                icon: Icons.lock_outline,
                                obscure: true,
                                validator: (v) => validatePassword(v, l10n),
                                onChanged: (_) =>
                                    setState(() => passwordTouched = true),
                              ),
                              const SizedBox(height: 14),
                              _darkField(
                                label: l10n.confirmPassword,
                                controller: confirmPasswordController,
                                icon: Icons.lock_outline,
                                obscure: true,
                                validator: (v) =>
                                    validateConfirmPassword(v, l10n),
                                onChanged: (_) => setState(
                                        () => confirmPasswordTouched = true),
                              ),
                              const SizedBox(height: 20),
                              _buildPrimaryButton(
                                label: l10n.resetPassword,
                                onPressed: isLoading ? null : resetPassword,
                                loading: isLoading,
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () =>
                                    setState(() => codeSent = false),
                                child: Text(
                                  l10n.changeEmail,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white.withOpacity(0.86),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Info box
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.white.withOpacity(0.05),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFFF5CD52),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      l10n.resetCodeInfo,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.white.withOpacity(0.72),
                                        fontSize: 12,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 20),
            ),
          ),
          const Spacer(),
          Text(
            l10n.forgotPassword,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const Spacer(),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _darkField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.72),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          cursorColor: Colors.white,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon,
                color: Colors.white.withOpacity(0.6), size: 18),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            isDense: true,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
            ),
            errorStyle: const TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFFE5484D),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
    required bool loading,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primary,
          disabledBackgroundColor: Colors.white.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: loading
            ? SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation(primary),
          ),
        )
            : Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}