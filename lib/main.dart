import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'loading.dart';
import 'wallet_page.dart';
import 'wallet_add_beneficiary_page.dart';
import 'wallet_service.dart';
import 'wallet_recharge_page.dart';
import 'wallet_recharge_method_page.dart';
import 'wallet_recharge_rib_page.dart';
import 'wallet_recharge_cash_page.dart';
import 'wallet_transfer_page.dart';
import 'wallet_withdraw_page.dart';
import 'wallet_withdraw_bank_page.dart';
import 'wallet_withdraw_cash_page.dart';
import 'wallet_history_page.dart';
import 'wallet_all_services_page.dart';
import 'wallet_account_page.dart';
import 'wallet_change_account_page.dart';
import 'presentation_page.dart';
import 'login.dart';
import 'acceuil.dart';
import 'events.dart';
import 'boutique.dart';
import 'mesCommandes.dart';
import 'tickets.dart';
import 'singleTicket.dart';
import 'inscription.dart';
import 'ordersofoneevent.dart';
import 'AcheterTicketInEvent.dart';
import 'successPayment.dart';
import 'failPayment.dart';
import 'cmi_payment_boutique.dart';
import 'success_payment_boutique.dart';
import 'editProfile.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rateplayers.dart';
import 'formation.dart';
import 'wydadQuizz.dart';
import 'news_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'bottomnavigation.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  } else if (Platform.isIOS) {
    WebViewPlatform.instance = WebKitWebViewPlatform();
  }
  await initializeDateFormatting('fr_FR', null);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  String currentLocale = 'fr';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      currentLocale = prefs.getString('locale') ?? 'fr';
    });
  }

  void toggleTheme() async {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  void setLanguage(String newLocale) async {
    if (newLocale == currentLocale) return;
    setState(() {
      currentLocale = newLocale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', currentLocale);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData(
      fontFamily: 'Urbanist',
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: Color(0xFFE41E26),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFFE41E26)),
        titleTextStyle: TextStyle(
          color: Color(0xFFE41E26),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.bold,
        ),
      ),
      cardColor: Colors.white.withOpacity(0.95),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      colorScheme: ColorScheme.light(
        primary: Color(0xFFE41E26),
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFFE41E26),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle:
        TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Urbanist'),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      fontFamily: 'Urbanist',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Color(0xFFE41E26),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Color(0xFFE41E26)),
        titleTextStyle: TextStyle(
          color: Color(0xFFE41E26),
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.bold,
        ),
      ),
      cardColor: Colors.grey[800]!.withOpacity(0.95),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFE41E26),
        surface: Colors.black,
        onSurface: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Color(0xFFE41E26),
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle:
        TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Urbanist'),
      ),
    );

    return SecureApp(
      child: MaterialApp(
        title: 'WydadTicketing',
        locale: Locale(currentLocale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: isDarkMode ? darkTheme : lightTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final args = settings.arguments as Map<String, dynamic>? ?? {};

          switch (settings.name) {
          // ═══════════════════════════════════════════════════════
          // ENTRY POINTS
          // ═══════════════════════════════════════════════════════
            case '/':
              return MaterialPageRoute(builder: (_) => LoadingPage());

            case '/presentation':
              return MaterialPageRoute(
                builder: (_) => const PresentationPage(),
              );

            case '/inscription':
              return MaterialPageRoute(builder: (_) => InscriptionPage());

            case '/login':
              return MaterialPageRoute(
                builder: (_) => Theme(
                  data: lightTheme,
                  child: LoginPage(),
                ),
              );

          // ═══════════════════════════════════════════════════════
          // WALLET
          // ═══════════════════════════════════════════════════════
            case '/wallet':
              return MaterialPageRoute(
                builder: (_) => WalletPage(
                  token: args['token'] as String? ?? '',
                  organizationId: args['organizationId']?.toString(),
                ),
              );
            case '/walletAddBeneficiary':
              return MaterialPageRoute(
                builder: (_) => WalletAddBeneficiaryPage(
                  token: args['token'] as String? ?? '',
                  defaultPhone: args['phone']?.toString(),
                ),
              );
          // ✅ NOUVEAU : choix du mode d'alimentation
            case '/walletRechargeMethod':
              return MaterialPageRoute(
                builder: (_) => WalletRechargeMethodPage(
                    token: args['token'] as String? ?? ''),
              );

          // Alimentation par carte bancaire
            case '/walletRecharge':
              return MaterialPageRoute(
                builder: (_) =>
                    WalletRechargePage(token: args['token'] as String? ?? ''),
              );

          // ✅ NOUVEAU : alimentation par virement bancaire (RIB)
            case '/walletRechargeRib':
              return MaterialPageRoute(
                builder: (_) => WalletRechargeRibPage(
                    token: args['token'] as String? ?? ''),
              );

          // ✅ NOUVEAU : alimentation en espèces en agence
            case '/walletRechargeCash':
              return MaterialPageRoute(
                builder: (_) => WalletRechargeCashPage(
                    token: args['token'] as String? ?? ''),
              );

            case '/walletTransfer':
              return MaterialPageRoute(
                builder: (_) =>
                    WalletTransferPage(token: args['token'] as String? ?? ''),
              );

            case '/walletWithdraw':
              return MaterialPageRoute(
                builder: (_) =>
                    WalletWithdrawPage(token: args['token'] as String? ?? ''),
              );

            case '/walletWithdrawBank':
              return MaterialPageRoute(
                builder: (_) => WalletWithdrawBankPage(
                    token: args['token'] as String? ?? ''),
              );

            case '/walletWithdrawCash':
              return MaterialPageRoute(
                builder: (_) => WalletWithdrawCashPage(
                    token: args['token'] as String? ?? ''),
              );

            case '/walletHistory':
              return MaterialPageRoute(
                builder: (_) =>
                    WalletHistoryPage(token: args['token'] as String? ?? ''),
              );

            case '/walletTxDetail':
              return MaterialPageRoute(
                builder: (_) =>
                    WalletHistoryPage(token: args['token'] as String? ?? ''),
              );

            case '/walletAllServices':
              return MaterialPageRoute(
                builder: (_) => WalletAllServicesPage(
                    token: args['token'] as String? ?? ''),
              );

            case '/walletAccount':
              return MaterialPageRoute(
                builder: (_) =>
                    WalletAccountPage(token: args['token'] as String? ?? ''),
              );

            case '/walletChangeAccount':
              return MaterialPageRoute(
                builder: (_) => WalletChangeAccountPage(
                    token: args['token'] as String? ?? ''),
              );

            case '/walletChangePin':
              return MaterialPageRoute(
                builder: (_) =>
                    WalletAccountPage(token: args['token'] as String? ?? ''),
              );

          // ═══════════════════════════════════════════════════════
          // MAIN APP
          // ═══════════════════════════════════════════════════════
            case '/home':
            case '/events':
            case '/boutique':
            case '/acceuil':
            case '/editProfile':
              final token = args['token'] as String? ?? '';
              final organizationId = args['organizationId']?.toString();
              final initialIndex = _getInitialIndex(settings.name);

              return MaterialPageRoute(
                builder: (_) => HomePage(
                  token: token,
                  organizationId: organizationId,
                  toggleTheme: toggleTheme,
                  setLanguage: setLanguage,
                  isDarkMode: isDarkMode,
                  currentLocale: currentLocale,
                  initialIndex: initialIndex,
                ),
              );

            case '/tickets':
              return MaterialPageRoute(
                builder: (_) => TicketsPage(
                  token: args['token'] ?? '',
                  orderId: args['orderId'] ?? '',
                  currentOrganizationId: args['organizationId'],
                ),
              );

            case '/singleTicket':
              return MaterialPageRoute(
                builder: (_) => SingleTicketPage(
                  token: args['token'] ?? '',
                  orderId: args['orderId'] ?? 0,
                  currentOrganizationId: args['organizationId'],
                  ticket: args['ticket'] ?? {},
                  event: args['event'] ?? {},
                  isTransferable: args['isTransferable'] ?? 0,
                  isQrCode: args['isQrCode'] ?? 0,
                  transferStatus: args['transferStatus'] ?? 0,
                  userEmail: args['userEmail'],
                  isSender: args['isSender'] ?? false,
                  senderEmail: args['senderEmail'],
                  orderData: args['orderData'],
                  category: args['category'] ?? '',
                ),
              );

            case '/ordersOfOneEvent':
              return MaterialPageRoute(
                builder: (_) => OrdersOfOneEventPage(
                  eventId: args["eventId"] ?? 0,
                  token: args['token'] ?? '',
                  currentOrganizationId: args['organizationId'],
                ),
              );

            case '/acheterTicketInEvent':
              return MaterialPageRoute(
                builder: (_) => AcheterTicketInEventPage(
                  token: args['token'] ?? '',
                  eventId: args['eventId'] ?? 0,
                  currentOrganizationId: args['organizationId'],
                ),
              );

            case '/successPayment':
              return MaterialPageRoute(
                builder: (_) => SuccessPaymentPage(
                  token: args['token'] ?? '',
                  order: args['order'] ?? {},
                  eventId: args['eventId'] ?? 0,
                  currentOrganizationId: args['organizationId'],
                ),
              );

            case '/failPayment':
              return MaterialPageRoute(
                builder: (_) => FailPaymentPage(
                  token: args['token'] ?? '',
                  eventId: args['eventId'] ?? 0,
                  currentOrganizationId: args['organizationId'],
                ),
              );

            case '/cmiPaymentBoutique':
              return MaterialPageRoute(
                builder: (_) => CMIPaymentWebViewBoutique(
                  amount: (args['amount'] is int
                      ? (args['amount'] as int).toDouble()
                      : args['amount'] as double? ?? 0.0),
                  orderData: args['orderData'] ?? {},
                  orderNumber: args['orderNumber'] ?? '',
                ),
              );

            case '/successPaymentBoutique':
              return MaterialPageRoute(
                builder: (_) => SuccessPaymentBoutiquePage(),
              );

            case '/mesCommandes':
              return MaterialPageRoute(
                builder: (_) => MesCommandesPage(
                  token: args['token'] ?? '',
                ),
              );

            case '/ratePlayers':
              return MaterialPageRoute(
                builder: (_) => PlayerRatingPage(
                  token: args['token'] ?? '',
                  eventId: args['eventId']?.toString(),
                  organizationId: args['organizationId']?.toString(),
                  eventData: args['eventData'],
                ),
              );

            case '/news':
              return MaterialPageRoute(
                builder: (_) => WydadNewsPage(
                  token: args['token'],
                  currentOrganizationId: args['organizationId'],
                  facebookPageId: args['facebookPageId']?.toString(),
                  facebookPageToken: args['facebookPageToken']?.toString(),
                  graphApiVersion: args['graphApiVersion']?.toString(),
                ),
              );

            case '/wydadQuiz':
              return MaterialPageRoute(
                builder: (_) => WydadQuizPage(
                  token: args['token'],
                  currentOrganizationId: args['organizationId'],
                  userName: args['userName'] ?? 'Joueur',
                ),
              );

            case '/formation':
              return MaterialPageRoute(
                builder: (_) => FootballFormationPage(
                  token: args['token'] as String?,
                  eventId: args['eventId'] as String?,
                  organizationId: args['organizationId'] as String?,
                  eventData: args['eventData'] as Map<String, dynamic>?,
                ),
              );

            default:
              return null;
          }
        },
      ),
    );
  }

  int _getInitialIndex(String? routeName) {
    switch (routeName) {
      case '/events':
        return 0;
      case '/boutique':
        return 1;
      case '/acceuil':
      case '/home':
        return 2;
      case '/editProfile':
        return 3;
      case '/mesCommandes':
        return 2;
      default:
        return 2;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// HomePage — SANS bottomNavigationBar (gérée par chaque page)
// ─────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  final String token;
  final String? organizationId;
  final VoidCallback toggleTheme;
  final Function(String) setLanguage;
  final bool isDarkMode;
  final String currentLocale;
  final int initialIndex;

  const HomePage({
    Key? key,
    required this.token,
    this.organizationId,
    required this.toggleTheme,
    required this.setLanguage,
    required this.isDarkMode,
    required this.currentLocale,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initPages();
  }

  void _initPages() {
    _pages = [
      EventsPage(
        token: widget.token,
        currentOrganizationId: widget.organizationId,
      ),
      BoutiquePage(
        token: widget.token,
        organizationId: widget.organizationId,
        toggleTheme: widget.toggleTheme,
        toggleLanguage: () {},
        isDarkMode: widget.isDarkMode,
        currentLocale: widget.currentLocale,
      ),
      AcceuilPage(
        token: widget.token,
        organizationId: widget.organizationId,
        toggleTheme: widget.toggleTheme,
        setLanguage: widget.setLanguage,
        isDarkMode: widget.isDarkMode,
        currentLocale: widget.currentLocale,
      ),
      EditProfilePage(
        token: widget.token,
        toggleTheme: widget.toggleTheme,
        setLanguage: widget.setLanguage,
        isDarkMode: widget.isDarkMode,
        currentLocale: widget.currentLocale,
      ),
    ];
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLocale != oldWidget.currentLocale ||
        widget.isDarkMode != oldWidget.isDarkMode) {
      _initPages();
      setState(() {});
    }
  }

  // Navigation interne déclenchée par les pages enfants
  void _navigateTo(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      // ⚠️ PLUS de bottomNavigationBar ici.
      // Chaque page (acceuil, events, boutique, profile) affiche
      // sa propre CustomBottomNavigation en Positioned overlay.
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sécurisation app
// ─────────────────────────────────────────────────────────────
class SecureApp extends StatefulWidget {
  final Widget child;
  const SecureApp({required this.child});

  @override
  _SecureAppState createState() => _SecureAppState();
}

class _SecureAppState extends State<SecureApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSecurity();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeSecurity() async {
    try {
      if (Platform.isAndroid) {
        await ScreenProtector.preventScreenshotOn();
      } else if (Platform.isIOS) {
        await ScreenProtector.preventScreenshotOn();
        await ScreenProtector.protectDataLeakageWithBlur();
      }
    } catch (e) {
      debugPrint("Erreur d'initialisation de sécurité : $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (Platform.isIOS) {
      switch (state) {
        case AppLifecycleState.inactive:
        case AppLifecycleState.paused:
          _toggleBlur(true);
          break;
        case AppLifecycleState.resumed:
          _toggleBlur(false);
          break;
        default:
          break;
      }
    }
  }

  Future<void> _toggleBlur(bool enable) async {
    try {
      if (enable) {
        await ScreenProtector.protectDataLeakageWithBlur();
      } else {
        await ScreenProtector.protectDataLeakageWithBlurOff();
      }
    } catch (e) {
      debugPrint("Erreur lors du changement de flou : $e");
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}