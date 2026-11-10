import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

class SuccessPaymentBoutiquePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const mainColor = Color(0xFFE41E26);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Extract arguments from the route with null safety
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final String token = args['token'] ?? '';
    final Map<String, dynamic> order = args['order'] ?? {};
    final String? organizationId = args['organizationId'];
    final Map<String, dynamic>? paymentData = args['paymentData'];

    // Save token to keep user logged in
    if (token.isNotEmpty) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('token', token);
        if (organizationId != null) {
          prefs.setString('organizationId', organizationId);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/acceuil', arguments: {
              'token': token,
              'organizationId': organizationId,
            });
          },
        ),
        title: Text(
          l10n.paymentSuccess,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontFamily: 'Urbanist',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green,
              ),
              SizedBox(height: 24),
              Text(
                l10n.paymentSuccessful,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontFamily: 'Urbanist',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              if (paymentData != null) ...[
                Text(
                  '${l10n.orderNumber}: ${paymentData!['order_number']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    fontFamily: 'Urbanist',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  '${l10n.paymentDate}: ${paymentData!['payment_date']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    fontFamily: 'Urbanist',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
              ],
              Text(
                l10n.orderProcessedSuccess,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  fontFamily: 'Urbanist',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/acceuil', arguments: {
                    'token': token,
                    'organizationId': organizationId,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  l10n.backToHome,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Urbanist',
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