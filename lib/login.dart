import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'l10n/app_localizations.dart';

import 'forgotPassword.dart';
import 'inscription.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  bool isDarkMode = false;

  final Color primary = const Color(0xFFA8161F);

  /// l10n helper
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _clearTokenAndUserData();
  }

  Future<void> _clearTokenAndUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_last_name');
    await prefs.remove('user_email');
    await prefs.remove('user_image');
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void _navigateBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, '/presentation');
    }
  }

  Future<String> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      } else if (Platform.isWindows) {
        final WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.computerName;
      } else if (Platform.isMacOS) {
        final MacOsDeviceInfo macInfo = await deviceInfo.macOsInfo;
        return macInfo.computerName;
      } else if (Platform.isLinux) {
        final LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
        return linuxInfo.name ?? 'linux_device';
      }
    } catch (e) {
      print('Error getting device ID: $e');
    }
    return 'unknown_device';
  }

  void _showErrorModal(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              const Icon(Icons.error_outline,
                  color: Color(0xFFE41E26), size: 50),
              const SizedBox(height: 12),
              Text(
                l10n.loginError,
                style: const TextStyle(
                  fontSize: 17,
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
              fontSize: 13,
              fontFamily: 'Inter',
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: SizedBox(
                width: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE41E26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.close,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
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

  void _showAlreadyConnectedModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              const Icon(Icons.devices_other, color: Colors.orange, size: 50),
              const SizedBox(height: 12),
              Text(
                l10n.alreadyConnected,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.alreadyConnectedMessage,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Inter',
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.blue, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.disconnectInstructions,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: SizedBox(
                width: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE41E26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.close,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
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

  Future<void> _login(BuildContext context) async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty) {
      _showErrorModal(l10n.emailRequired);
      return;
    }
    if (password.isEmpty) {
      _showErrorModal(l10n.passwordRequired);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? existingToken = prefs.getString('token');

      if (existingToken != null && existingToken.isNotEmpty) {
        try {
          await http.post(
            Uri.parse("https://ticketing.ma/api/customer/logout"),
            headers: {
              "Authorization": "Bearer $existingToken",
              "Content-Type": "application/json",
            },
          );
        } catch (e) {
          print('Logout error (non-critical): $e');
        }
        await prefs.clear();
      }

      final String deviceId = await _getDeviceId();
      final response = await http.post(
        Uri.parse("https://ticketing.ma/api/customer/login"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
          "organization_id": "20",
          "device_token": deviceId,
          "device_id": deviceId,
          "appversion": "27",
        }),
      );

      final Map<String, dynamic> resBody = jsonDecode(response.body);

      if (response.statusCode == 401 &&
          (resBody['message']
              ?.toString()
              .toLowerCase()
              .contains('déja connecté') ==
              true ||
              resBody['message']
                  ?.toString()
                  .toLowerCase()
                  .contains('connecté') ==
                  true)) {
        _showAlreadyConnectedModal();
        setState(() => _isLoading = false);
        return;
      }

      if (response.statusCode == 200 && resBody['success'] == true) {
        final data = resBody['data'];
        if (data != null && data is Map<String, dynamic>) {
          final token = data['token'];
          if (token != null && token is String) {
            await prefs.setString('user_id', data['id'].toString());
            await prefs.setString(
                'user_name', data['name']?.toString() ?? '');
            await prefs.setString(
                'user_last_name', data['last_name']?.toString() ?? '');
            await prefs.setString(
                'user_email', data['email']?.toString() ?? '');
            await prefs.setString('user_image',
                data['image']?.toString() ?? 'defaultuser.png');
            await prefs.setString(
                'phone', data['phone']?.toString() ?? '');
            await prefs.setString('token', token);
            await prefs.setString('deviceIdPrefrences', deviceId);
            await prefs.setString('appversion', '27');
            await prefs.setString('organizationId', "20");

            Navigator.pushReplacementNamed(
              context,
              '/acceuil',
              arguments: {'token': token, 'organizationId': "20"},
            );
            return;
          }
        }
        _showErrorModal(l10n.invalidServerResponse);
      } else {
        final errorMessage =
            resBody['message'] ?? l10n.incorrectCredentials;
        _showErrorModal(errorMessage);
      }
    } catch (e) {
      String errorMessage = l10n.connectionError;
      if (e is http.ClientException) {
        errorMessage = l10n.internetConnectionError;
      }
      _showErrorModal("$errorMessage\n\n${l10n.details}: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openTicketingWebsite() async {
    const url = 'https://ticketing.ma';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      _showErrorModal(l10n.cannotOpenWebsite);
    }
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InscriptionPage()),
    );
  }

  void _navigateForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
    );
  }

  void _continueAsGuest() {
    Navigator.pushReplacementNamed(
      context,
      '/acceuil',
      arguments: {
        'token': '',
        'organizationId': "20",
        'toggleTheme': _toggleTheme,
        'isDarkMode': isDarkMode,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF170205),
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
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    SizedBox(
                      height: 42,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _navigateBack,
                            child: Container(
                              width: 42,
                              height: 42,
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
                                size: 18,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _continueAsGuest,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 42),
                            ),
                            child: Text(
                              l10n.later,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xC7FFFFFF),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Logo
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Image.asset(
                        'assets/logo1.png',
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.shield,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title
                    Text(
                      l10n.welcomeBack,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.loginSubtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 13,
                        fontFamily: 'Inter',
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Email field
                    _buildFieldLabel(l10n.emailLabel),
                    const SizedBox(height: 5),
                    _buildInput(
                      controller: emailController,
                      hint: l10n.emailHint,
                      keyboardType: TextInputType.emailAddress,
                      autofill: const [AutofillHints.email],
                    ),

                    const SizedBox(height: 14),

                    // Password field
                    _buildFieldLabel(l10n.passwordLabel),
                    const SizedBox(height: 5),
                    _buildPasswordInput(),

                    const SizedBox(height: 6),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _navigateForgotPassword,
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          child: Text(
                            l10n.forgotPassword,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xDBFFFFFF),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _login(context),
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
                        child: _isLoading
                            ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor:
                            AlwaysStoppedAnimation(primary),
                          ),
                        )
                            : Text(
                          l10n.loginButton,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Sign up link
                    Center(
                      child: GestureDetector(
                        onTap: _navigateToSignUp,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Inter',
                              color: Colors.white.withOpacity(0.72),
                            ),
                            children: [
                              TextSpan(text: l10n.noAccountYet),
                              TextSpan(
                                text: l10n.createAccountLink,
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

  // ---------- Helpers ----------

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.white.withOpacity(0.72),
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    Iterable<String>? autofill,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autofillHints: autofill,
        cursorColor: Colors.white,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontFamily: 'Inter',
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.14),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.14),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: passwordController,
        obscureText: _obscureText,
        cursorColor: Colors.white,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          hintText: l10n.passwordHintLogin,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontFamily: 'Inter',
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          contentPadding:
          const EdgeInsets.only(left: 16, right: 56, top: 16, bottom: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.14),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.14),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.white.withOpacity(0.72),
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}