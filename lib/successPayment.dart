import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

class SuccessPaymentPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> order;
  final int eventId;
  final String? currentOrganizationId;

  SuccessPaymentPage({
    Key? key,
    required this.token,
    required this.order,
    required this.eventId,
    this.currentOrganizationId,
  }) : super(key: key);

  @override
  _SuccessPaymentPageState createState() => _SuccessPaymentPageState();
}

class _SuccessPaymentPageState extends State<SuccessPaymentPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const mainPurple = Color(0xFFE41E26);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Save token to keep user logged in
    if (widget.token.isNotEmpty) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('token', widget.token);
        if (widget.currentOrganizationId != null) {
          prefs.setString('organizationId', widget.currentOrganizationId!);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.paymentSuccess,
          style: TextStyle(
            fontFamily: "Urbanist",
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: mainPurple),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: isDarkMode ? Colors.black : Color(0xFFF7F9FC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green,
              ),
              SizedBox(height: 20),
              Text(
                l10n.paymentSuccessful,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Urbanist",
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                shadowColor: mainPurple.withOpacity(0.15),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.orderDetails,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Urbanist",
                          color: mainPurple,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '${l10n.orderNumber}: ${widget.order["order_number"]}',
                        style: TextStyle(
                          fontFamily: "Urbanist",
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${l10n.amount}: ${widget.order["amount"]} MAD',
                        style: TextStyle(
                          fontFamily: "Urbanist",
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${l10n.paymentType}: ${widget.order["payment_type"]}',
                        style: TextStyle(
                          fontFamily: "Urbanist",
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/ordersOfOneEvent',
                    arguments: {
                      "token": widget.token,
                      "eventId": widget.eventId,
                      "organizationId": widget.currentOrganizationId,
                    },
                  );
                },
                child: Text(
                  l10n.viewMyOrders,
                  style: TextStyle(
                    fontFamily: "Urbanist",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(height: 20),
              Expanded(
                child: Text(
                  l10n.continueShoppingMessage,
                  style: TextStyle(
                    fontFamily: "Urbanist",
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                  foregroundColor: mainPurple,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: mainPurple, width: 2),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/boutique',
                    arguments: {
                      "token": widget.token,
                      "organizationId": widget.currentOrganizationId,
                    },
                  );
                },
                child: Text(
                  l10n.goToStore,
                  style: TextStyle(
                    fontFamily: "Urbanist",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}