import 'package:flutter/material.dart';
import './tickets.dart';
import 'l10n/app_localizations.dart';

class EventOrdersPage extends StatelessWidget {
  final Map<String, dynamic> event;
  final List<dynamic> orders;
  final String token;

  EventOrdersPage({
    required this.event,
    required this.orders,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final Color navyBlue = const Color(0xFF040836);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          event["name"],
          style: TextStyle(
            color: navyBlue,
            fontFamily: "Urbanist",
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : (theme.appBarTheme.backgroundColor ?? Colors.white),
        iconTheme: IconThemeData(color: navyBlue),
        elevation: 1,
      ),
      backgroundColor: isDarkMode ? Colors.black : theme.scaffoldBackgroundColor,
      body: orders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_outlined,
              size: 80,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              l10n.noOrdersFound,
              style: TextStyle(
                fontFamily: "Urbanist",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              l10n.noOrdersForThisEvent,
              style: TextStyle(
                fontFamily: "Urbanist",
                fontSize: 14,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final ticket = order["ticket"];
          final ticketName = ticket != null ? ticket["name"] : l10n.ticket;
          final quantity = order["quantity"] ?? 0;
          final payment = order["payment"] ?? 0;
          final orderId = order["order_id"] ?? order["id"];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 15),
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            child: ListTile(
              leading: Icon(
                Icons.confirmation_num,
                color: navyBlue,
              ),
              title: Text(
                "${l10n.order}: $orderId",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: "Urbanist",
                ),
              ),
              subtitle: Text(
                "${l10n.tickets}: $quantity • $ticketName • $payment DH",
                style: TextStyle(
                  fontFamily: "Urbanist",
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: navyBlue,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TicketsPage(
                      token: token,
                      orderId: order["id"],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}