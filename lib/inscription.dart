import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'l10n/app_localizations.dart';

class InscriptionPage extends StatefulWidget {
  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool showSuccessModal = false;
  bool acceptTerms = false;

  final Color primary = const Color(0xFFA8161F);

  bool emailTouched = false;
  bool phoneTouched = false;

  /// l10n helper
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  // ---------- VALIDATION ----------

  String? validateEmail(String? value, AppLocalizations l10n) {
    if (!emailTouched) return null;
    if (value != null && value.isNotEmpty) {
      final emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(value)) {
        return l10n.invalidEmail;
      }
    }
    return null;
  }

  String? validatePhoneNumber(String? value, AppLocalizations l10n) {
    if (!phoneTouched) return null;
    if (value != null && value.isNotEmpty) {
      String cleanedPhone = value.replaceAll(' ', '');
      final phoneRegex = RegExp(r'^[6-7][0-9]{8}$');
      if (!phoneRegex.hasMatch(cleanedPhone)) {
        return l10n.phoneInvalid;
      }
    }
    return null;
  }

  // ---------- SNACKBAR / MODALS ----------

  void showError(String message) {
    if (showSuccessModal) {
      Navigator.of(context).pop();
      setState(() => showSuccessModal = false);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE41E26),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void showErrorModal(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              const Icon(Icons.error_outline,
                  color: Color(0xFFE41E26), size: 60),
              const SizedBox(height: 16),
              Text(
                l10n.registrationError,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE41E26),
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Inter',
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE41E26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.close,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showSuccessModalDialog() {
    setState(() => showSuccessModal = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              Text(
                l10n.registrationSuccess,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE41E26),
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            l10n.verifyEmailMessage,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Inter',
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE41E26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  },
                  child: Text(
                    l10n.close,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      setState(() => showSuccessModal = false);
    });
  }

  // ---------- API ----------

  String _extractErrorMessage(Map<String, dynamic> data) {
    try {
      if (data.containsKey('data') && data['data'] is Map) {
        final errorData = data['data'] as Map<String, dynamic>;
        if (errorData.containsKey('email') && errorData['email'] is List) {
          final emailErrors = errorData['email'] as List<dynamic>;
          if (emailErrors.isNotEmpty) return emailErrors.first.toString();
        }
        if (errorData.containsKey('phone') && errorData['phone'] is List) {
          final phoneErrors = errorData['phone'] as List<dynamic>;
          if (phoneErrors.isNotEmpty) return phoneErrors.first.toString();
        }
        final errorMessages = <String>[];
        errorData.forEach((key, value) {
          if (value is List) {
            errorMessages.addAll(value.map((e) => e.toString()));
          }
        });
        if (errorMessages.isNotEmpty) return errorMessages.join(', ');
      }
      return data["message"] ?? l10n.registrationErrorGeneric;
    } catch (_) {
      return l10n.registrationErrorGeneric;
    }
  }

  Future<void> register() async {
    setState(() {
      emailTouched = true;
      phoneTouched = true;
    });

    final email = emailController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    final emailValidationError = validateEmail(email, l10n);
    if (emailValidationError != null) {
      showError(emailValidationError);
      return;
    }
    final phoneValidationError = validatePhoneNumber(phone, l10n);
    if (phoneValidationError != null) {
      showError(phoneValidationError);
      return;
    }
    if (password != confirmPassword) {
      showError(l10n.passwordsDoNotMatch);
      return;
    }
    if (!acceptTerms) {
      showError(l10n.acceptTermsRequired);
      return;
    }

    setState(() => isLoading = true);

    try {
      String cleanedPhone = phone.replaceAll(' ', '');
      String internationalPhone = '+212$cleanedPhone';

      final Map<String, dynamic> bodyData = {
        "email": email,
        "password": password,
        "confirm_password": password,
        "organization_id": "20",
        "name": firstName,
        "last_name": lastName,
        "phone": internationalPhone,
      };

      final response = await http.post(
        Uri.parse("https://ticketing.ma/api/customer/register"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(bodyData),
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        showSuccessModalDialog();
      } else {
        final errorMessage = _extractErrorMessage(data);
        if (errorMessage.toLowerCase().contains("email") ||
            errorMessage.toLowerCase().contains("already") ||
            response.statusCode == 422) {
          showErrorModal(errorMessage);
        } else {
          showError(errorMessage);
        }
      }
    } catch (e) {
      String errorMessage = l10n.connectionError;
      if (e is http.ClientException) {
        errorMessage = l10n.internetConnectionError;
      }
      showError(errorMessage);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ---------- PHONE FORMATTING ----------

  void formatPhoneNumber(String value) {
    if (value.isEmpty) return;
    String cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.startsWith('0')) cleaned = cleaned.substring(1);
    if (cleaned.length > 9) cleaned = cleaned.substring(0, 9);

    String formatted = '';
    if (cleaned.isNotEmpty) {
      formatted = cleaned.substring(0, 1);
      if (cleaned.length > 1) formatted += ' ${cleaned.substring(1, 3)}';
      if (cleaned.length > 3) formatted += ' ${cleaned.substring(3, 5)}';
      if (cleaned.length > 5) formatted += ' ${cleaned.substring(5, 7)}';
      if (cleaned.length > 7) formatted += ' ${cleaned.substring(7)}';
    }

    if (phoneController.text != formatted) {
      phoneController.value = phoneController.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  // ---------- BACK NAVIGATION ----------

  void _navigateBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, '/presentation');
    }
  }

  void _continueAsGuest() {
    Navigator.pushReplacementNamed(context, '/acceuil', arguments: {
      'token': '',
      'organizationId': "20",
    });
  }

  // ---------- BUILD ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A0710),
              Color(0xFF23030A),
              Color(0xFF120104),
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: Stack(
          children: [
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
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──
                    SizedBox(
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _navigateBack,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withOpacity(0.08),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.14),
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _continueAsGuest,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 44),
                            ),
                            child: Text(
                              l10n.later,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xC7FFFFFF),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Title ──
                    const SizedBox(height: 20),
                    Text(
                      l10n.createYourAccount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.6,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.registerSubtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Prénom + Nom ──
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel(l10n.firstNameLabel),
                              const SizedBox(height: 6),
                              _darkInput(
                                controller: firstNameController,
                                hint: l10n.firstNameLabel,
                                autofillHints: const [AutofillHints.givenName],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel(l10n.lastNameLabel),
                              const SizedBox(height: 6),
                              _darkInput(
                                controller: lastNameController,
                                hint: l10n.lastNameLabel,
                                autofillHints: const [AutofillHints.familyName],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Email ──
                    _fieldLabel(l10n.emailLabel),
                    const SizedBox(height: 6),
                    _darkInput(
                      controller: emailController,
                      hint: l10n.emailHint,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      errorText: validateEmail(emailController.text, l10n),
                      onChanged: (_) => setState(() => emailTouched = true),
                    ),

                    const SizedBox(height: 16),

                    // ── Phone ──
                    _fieldLabel(l10n.phoneLabel),
                    const SizedBox(height: 6),
                    _phoneField(l10n),
                    const SizedBox(height: 6),
                    Text(
                      l10n.phoneVerificationNote,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                        fontFamily: 'Inter',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Password ──
                    _fieldLabel(l10n.passwordLabel),
                    const SizedBox(height: 6),
                    _passwordField(
                      controller: passwordController,
                      hint: l10n.passwordMinHint,
                      visible: isPasswordVisible,
                      onToggle: () => setState(
                              () => isPasswordVisible = !isPasswordVisible),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        _strengthBar(active: true),
                        const SizedBox(width: 6),
                        _strengthBar(active: true),
                        const SizedBox(width: 6),
                        _strengthBar(active: false),
                        const SizedBox(width: 6),
                        _strengthBar(active: false),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.passwordStrengthHint,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                        fontFamily: 'Inter',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Confirm password ──
                    _fieldLabel(l10n.confirmPasswordLabel),
                    const SizedBox(height: 6),
                    _passwordField(
                      controller: confirmPasswordController,
                      hint: l10n.confirmPasswordHint,
                      visible: isConfirmPasswordVisible,
                      onToggle: () => setState(() =>
                      isConfirmPasswordVisible =
                      !isConfirmPasswordVisible),
                    ),

                    const SizedBox(height: 16),

                    // ── Terms ──
                    GestureDetector(
                      onTap: () => setState(() => acceptTerms = !acceptTerms),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: acceptTerms,
                                onChanged: (v) =>
                                    setState(() => acceptTerms = v ?? false),
                                activeColor: Colors.white,
                                checkColor: primary,
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1.5,
                                ),
                                materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: Colors.white.withOpacity(0.86),
                                  fontFamily: 'Inter',
                                ),
                                children: [
                                  TextSpan(text: l10n.acceptTermsText),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Button ──
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primary,
                          disabledBackgroundColor:
                          Colors.white.withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                            AlwaysStoppedAnimation(primary),
                          ),
                        )
                            : Text(
                          l10n.createMyAccount,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),

                    // ── Footer ──
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginPage()),
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Inter',
                              color: Colors.white.withOpacity(0.72),
                            ),
                            children: [
                              TextSpan(text: l10n.alreadyRegistered),
                              TextSpan(
                                text: l10n.loginLink,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
            ),
          ],
        ),
      ),
    );
  }

  // ---------- WIDGET HELPERS ----------

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white.withOpacity(0.72),
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _darkInput({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    Iterable<String>? autofillHints,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      cursorColor: Colors.white,
      onChanged: onChanged,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontFamily: 'Inter',
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontFamily: 'Inter',
          fontSize: 15,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        isDense: false,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        errorText: errorText,
        errorStyle: const TextStyle(
          color: Color(0xFFE5484D),
          fontSize: 11,
          fontFamily: 'Inter',
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
        ),
      ),
    );
  }

  Widget _phoneField(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          alignment: Alignment.center,
          child: const Text(
            '+212',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _darkInput(
            controller: phoneController,
            hint: '6 00 00 00 00',
            keyboardType: TextInputType.phone,
            errorText: validatePhoneNumber(phoneController.text, l10n),
            onChanged: (v) {
              setState(() => phoneTouched = true);
              formatPhoneNumber(v);
            },
          ),
        ),
      ],
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return Stack(
      children: [
        TextField(
          controller: controller,
          obscureText: !visible,
          cursorColor: Colors.white,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontFamily: 'Inter',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontFamily: 'Inter',
              fontSize: 15,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            isDense: false,
            contentPadding: const EdgeInsets.only(
                left: 14, right: 52, top: 16, bottom: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
            ),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: Icon(
                visible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white.withOpacity(0.72),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _strengthBar({required bool active}) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: active
              ? const Color(0xFFF5CD52)
              : Colors.white.withOpacity(0.16),
        ),
      ),
    );
  }
}