import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'l10n/app_localizations.dart';
import 'login.dart';
import 'package:country_flags/country_flags.dart';

class EditProfilePage extends StatefulWidget {
  final String token;
  final VoidCallback toggleTheme;
  final Function(String) setLanguage;
  final bool isDarkMode;
  final String currentLocale;

  EditProfilePage({
    required this.token,
    required this.toggleTheme,
    required this.setLanguage,
    required this.isDarkMode,
    required this.currentLocale,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool isLoading = true;
  bool isUpdating = false;
  Map<String, dynamic> profile = {};
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cinController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();

  bool _selectedThemeIsDark = false;
  final Color primary = const Color(0xFFA8161F);

  @override
  void initState() {
    super.initState();
    _selectedThemeIsDark = widget.isDarkMode;
    fetchProfile();
    _loadSavedTheme();
  }

  @override
  void didUpdateWidget(EditProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDarkMode != oldWidget.isDarkMode) {
      setState(() => _selectedThemeIsDark = widget.isDarkMode);
    }
    if (widget.currentLocale != oldWidget.currentLocale) {
      setState(() {});
    }
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('isDarkMode');
    if (saved != null && saved != _selectedThemeIsDark) {
      setState(() => _selectedThemeIsDark = saved);
      if (saved != widget.isDarkMode) widget.toggleTheme();
    }
  }

  Future<void> _saveThemePreference(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  Future<void> _saveLanguagePreference(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);
  }

  // ───── VALIDATION ─────
  String? validateName(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return l10n.firstNameRequired;
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s\-]+$').hasMatch(v)) return l10n.firstNameLettersOnly;
    if (v.length < 2) return l10n.firstNameMinLength;
    return null;
  }

  String? validateLastName(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return l10n.lastNameRequired;
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s\-]+$').hasMatch(v)) return l10n.lastNameLettersOnly;
    if (v.length < 2) return l10n.lastNameMinLength;
    return null;
  }

  String? validatePhone(String? v, AppLocalizations l10n) {
    if (v == null || v.isEmpty) return l10n.phoneRequired;
    final cleaned = v.replaceAll(' ', '');
    if (!RegExp(r'^[6-7][0-9]{8}$').hasMatch(cleaned)) return l10n.phoneInvalid;
    return null;
  }

  String? validateCIN(String? v, AppLocalizations l10n) {
    if (v != null && v.isNotEmpty && v.length < 5) return l10n.cinMinLength;
    return null;
  }

  String? validatePassword(String? v, AppLocalizations l10n) {
    if (v != null && v.isNotEmpty) {
      if (v.length < 8) return l10n.passwordMinLength;
      if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(v)) {
        return l10n.passwordRequirements;
      }
    }
    return null;
  }

  String? validateCurrentPassword(String? v, AppLocalizations l10n) {
    if (passwordController.text.isNotEmpty && (v == null || v.isEmpty)) {
      return l10n.currentPasswordRequired;
    }
    return null;
  }

  String formatPhoneNumber(String value) {
    if (value.isEmpty) return '';
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
    return formatted;
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
  }

  Future<void> _launchDeleteAccountUrl() async {
    final Uri url = Uri.parse('https://wydad.ticketing.ma/user/profile');
    if (!await launchUrl(url)) throw Exception('Could not launch $url');
  }

  // ───── API ─────
  Future<void> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse('https://ticketing.ma/api/customer/profile'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        setState(() {
          profile = data['data'];
          nameController.text = profile['name'] ?? '';
          lastNameController.text = profile['last_name'] ?? '';
          emailController.text = profile['email'] ?? '';
          phoneController.text = profile['phone']?.replaceAll('+212', '') ?? '';
          cinController.text = profile['cin'] ?? '';
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.errorLoadingProfile),
        backgroundColor: primary,
      ));
      setState(() => isLoading = false);
    }
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => isUpdating = true);

    try {
      Map<String, dynamic> body = {
        'name': nameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'phone': '+212${phoneController.text.replaceAll(' ', '')}',
      };
      if (cinController.text.trim().isNotEmpty) {
        body['cin'] = cinController.text.trim();
      }
      if (passwordController.text.isNotEmpty) {
        body['password'] = passwordController.text;
        body['current_password'] = currentPasswordController.text;
      }

      final response = await http.post(
        Uri.parse('https://ticketing.ma/api/customer/profile/update'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(jsonResponse['message'] ?? l10n.profileUpdatedSuccess),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context, true);
      } else {
        throw Exception(jsonResponse['message'] ?? l10n.updateProfileFailed);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${l10n.errorUpdatingProfile}: $e'),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      setState(() => isUpdating = false);
    }
  }

  // ───── QR MODAL ─────
  void _showQRCodeModal() {
    final l10n = AppLocalizations.of(context)!;
    final userEmail = emailController.text;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    l10n.myProfile,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA8161F),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: userEmail,
                  version: QrVersions.auto,
                  size: 170,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.scanToGetContact,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _shareProfileViaWhatsApp,
                  icon: const Icon(Icons.share, size: 16),
                  label: Text(
                    l10n.shareProfile,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: const BorderSide(color: Color(0xFFA8161F)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.close,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareProfileViaWhatsApp() async {
    final l10n = AppLocalizations.of(context)!;
    final userEmail = emailController.text;
    final userName = "${nameController.text} ${lastNameController.text}".trim();

    String message = l10n.shareProfileMessage(
      userEmail.isNotEmpty ? userEmail : l10n.email,
    );
    if (userName.isNotEmpty) {
      message += "\n ${l10n.user} :${userName.isNotEmpty ? " $userName" : ""} ";
    }
    final encoded = Uri.encodeComponent(message);

    final appUrl = Uri.parse("whatsapp://send?text=$encoded");
    final webUrl = Uri.parse("https://wa.me/?text=$encoded");

    try {
      await launchUrl(appUrl);
    } catch (e) {
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.whatsappNotInstalled),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _showLanguageMenu() {
    final languages = [
      {'code': 'fr', 'countryCode': 'FR', 'label': 'FR'},
      {'code': 'ar', 'countryCode': 'MA', 'label': 'AR'},
      {'code': 'en', 'countryCode': 'GB', 'label': 'EN'},
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF23030A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            final selected = widget.currentLocale == lang['code'];
            return ListTile(
              dense: true,
              leading: SizedBox(
                width: 26,
                height: 18,
                child: CountryFlag.fromCountryCode(lang['countryCode'] as String),
              ),
              title: Text(
                lang['label'] as String,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
              onTap: () {
                Navigator.pop(context);
                if (lang['code'] != widget.currentLocale) {
                  _saveLanguagePreference(lang['code'] as String);
                  widget.setLanguage(lang['code'] as String);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName =
    "${nameController.text} ${lastNameController.text}".trim();
    final initials = displayName.isNotEmpty
        ? displayName
        .split(' ')
        .take(2)
        .map((s) => s.isNotEmpty ? s[0].toUpperCase() : '')
        .join()
        : 'AB';

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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildHeader(),
                  ),

                  Expanded(
                    child: isLoading
                        ? Center(
                      child: CircularProgressIndicator(color: primary),
                    )
                        : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildIdentitySection(displayName, initials),
                            const SizedBox(height: 14),
                            _buildShareProfileButton(),
                            const SizedBox(height: 18),
                            _sectionTitle('MES INFORMATIONS'),
                            const SizedBox(height: 8),
                            _buildFormSection(l10n),
                            const SizedBox(height: 18),
                            _sectionTitle('MOT DE PASSE'),
                            const SizedBox(height: 8),
                            _buildPasswordSection(l10n),
                            const SizedBox(height: 20),
                            _buildActionButtons(l10n),
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

  Widget _buildHeader() {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: const Icon(Icons.chevron_left, color: Colors.white, size: 18),
            ),
          ),
          const Spacer(),
          const Text(
            'Modifier le profil',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: logout,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: const Icon(Icons.power_settings_new,
                  color: Color(0xFFFF9C9C), size: 17),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitySection(String displayName, String initials) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD11A2A), Color(0xFFA8161F), Color(0xFF6E0B12)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName.isNotEmpty ? displayName : '[PRÉNOM NOM]',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Supporter · WAC',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _showLanguageMenu,
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: Row(
              children: [
                Text(
                  widget.currentLocale.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(Icons.keyboard_arrow_down,
                    color: Colors.white, size: 11),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShareProfileButton() {
    return GestureDetector(
      onTap: _showQRCodeModal,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD11A2A), Color(0xFFA8161F), Color(0xFF6E0B12)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.qr_code_2, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Partager mon profil',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: Colors.white.withOpacity(0.6),
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildFormSection(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _darkField(
                label: l10n.firstNameLabel,
                controller: nameController,
                validator: (v) => validateName(v, l10n),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _darkField(
                label: l10n.lastNameLabel,
                controller: lastNameController,
                validator: (v) => validateLastName(v, l10n),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Email read-only
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel(l10n.emailLabel),
            const SizedBox(height: 5),
            Container(
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.03),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      emailController.text,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                  Icon(Icons.lock_outline,
                      color: Colors.white.withOpacity(0.5), size: 14),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "L'e-mail ne peut pas être modifié.",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: Colors.white.withOpacity(0.55),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Téléphone
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel(l10n.phoneLabel),
            const SizedBox(height: 5),
            Row(
              children: [
                Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.06),
                    border: Border.all(color: Colors.white.withOpacity(0.14)),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '+212',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.white,
                    ),
                    validator: (v) => validatePhone(v, l10n),
                    onChanged: formatPhoneNumber,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.14)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.14)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.6)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // CIN
        _darkField(
          label: l10n.cinLabel,
          controller: cinController,
          validator: (v) => validateCIN(v, l10n),
          hint: "Numéro de carte d'identité",
        ),
      ],
    );
  }

  Widget _buildPasswordSection(AppLocalizations l10n) {
    return Column(
      children: [
        _darkField(
          label: l10n.currentPasswordLabel,
          controller: currentPasswordController,
          validator: (v) => validateCurrentPassword(v, l10n),
          obscure: true,
          hint: '••••••••',
        ),
        const SizedBox(height: 10),
        _darkField(
          label: l10n.newPasswordLabel,
          controller: passwordController,
          validator: (v) => validatePassword(v, l10n),
          obscure: true,
          hint: '8 caractères minimum',
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
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

  Widget _darkField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    String? hint,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscure,
          cursorColor: Colors.white,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white.withOpacity(0.5),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            isDense: true,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
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
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isUpdating ? null : updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isUpdating
                  ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(primary),
                ),
              )
                  : Text(
                l10n.save,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}