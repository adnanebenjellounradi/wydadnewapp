import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

class SingleTicketPage extends StatefulWidget {
  final String token;
  final int orderId;
  final String? currentOrganizationId;
  final Map<String, dynamic> ticket;
  final Map<String, dynamic> event;
  final int isTransferable;
  final int isQrCode;
  final int transferStatus;
  final String? userEmail;
  final bool isSender;
  final String? senderEmail;
  final Map<String, dynamic>? orderData;
  final String category;

  const SingleTicketPage({
    Key? key,
    required this.token,
    required this.orderId,
    this.currentOrganizationId,
    required this.ticket,
    required this.event,
    required this.isTransferable,
    required this.transferStatus,
    this.userEmail,
    required this.isSender,
    this.senderEmail,
    this.orderData,
    required this.isQrCode,
    required this.category,
  }) : super(key: key);

  @override
  _SingleTicketPageState createState() => _SingleTicketPageState();
}

class _SingleTicketPageState extends State<SingleTicketPage>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _controller;

  /// l10n helper
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    secureScreen();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  bool _hasTicketData(Map<String, dynamic>? ticketData) {
    if (ticketData == null) return false;

    final porte = ticketData["porte"]?.toString().trim() ?? "";
    final access = ticketData["access"]?.toString().trim() ?? "";
    final secteur = ticketData["secteur"]?.toString().trim() ?? "";

    return porte.isNotEmpty || access.isNotEmpty || secteur.isNotEmpty;
  }

  Future<void> secureScreen() async {
    try {
      const platform = MethodChannel('secure_channel');
      await platform.invokeMethod('secure');
    } on PlatformException catch (e) {
      debugPrint("Secure screen error: ${e.message}");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void logout() async {
    try {
      await http.post(
        Uri.parse("https://ticketing.ma/api/customer/logout"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }

  String formatDate(String rawDate) {
    try {
      DateTime parsed = DateTime.parse(rawDate);
      String datePart = DateFormat("dd-MM-yyyy").format(parsed);
      String hour = parsed.minute == 0
          ? "${parsed.hour}h"
          : "${parsed.hour}h${parsed.minute.toString().padLeft(2, '0')}";
      return "$datePart ${l10n.at} $hour";
    } catch (e) {
      return rawDate;
    }
  }

  String getTimeRemaining(String eventDate) {
    try {
      String localDateString = eventDate.replaceAll('Z', '');
      DateTime eventDateTime = DateTime.parse(localDateString);
      DateTime now = DateTime.now();

      if (now.millisecondsSinceEpoch < eventDateTime.millisecondsSinceEpoch) {
        Duration remaining = eventDateTime.difference(now);
        return formatDuration(remaining);
      } else {
        DateTime oneHourAfterStart =
        eventDateTime.add(const Duration(hours: 1));

        if (now.millisecondsSinceEpoch <
            oneHourAfterStart.millisecondsSinceEpoch) {
          Duration remaining = oneHourAfterStart.difference(now);
          int minutes = remaining.inMinutes.remainder(60);
          int seconds = remaining.inSeconds.remainder(60);

          if (remaining.inMinutes > 0) {
            return "${remaining.inMinutes}${l10n.min} ${seconds}${l10n.sec}";
          } else {
            return "${seconds}${l10n.sec}";
          }
        } else {
          return l10n.eventOngoing;
        }
      }
    } catch (e) {
      return l10n.invalidDate;
    }
  }

  String formatDuration(Duration duration) {
    int days = duration.inDays;
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    if (days > 0) {
      return "$days${l10n.daysShort} $hours${l10n.hoursShort} ${minutes}${l10n.min}";
    } else if (hours > 0) {
      return "$hours${l10n.hoursShort} ${minutes}${l10n.min} ${seconds}${l10n.sec}";
    } else if (minutes > 0) {
      return "${minutes}${l10n.min} ${seconds}${l10n.sec}";
    } else {
      return "${seconds}${l10n.sec}";
    }
  }

  bool canStillTransfer(String rawDate) {
    try {
      String localDateString = rawDate.replaceAll('Z', '');
      DateTime eventLocal = DateTime.parse(localDateString);
      DateTime nowLocal = DateTime.now();

      DateTime sixHoursBefore = eventLocal.subtract(const Duration(hours: 6));

      return nowLocal.isBefore(sixHoursBefore);
    } catch (e) {
      return false;
    }
  }

  bool isEventPast(String rawDate) {
    try {
      String localDateString = rawDate.replaceAll('Z', '');
      DateTime eventLocal = DateTime.parse(localDateString);
      DateTime oneHourAfterEventEnd =
      eventLocal.add(const Duration(hours: 1));
      DateTime nowLocal = DateTime.now();
      return nowLocal.isAfter(oneHourAfterEventEnd);
    } catch (e) {
      return false;
    }
  }

  bool isEventStarted(String rawDate) {
    try {
      String localDateString = rawDate.replaceAll('Z', '');
      DateTime eventLocal = DateTime.parse(localDateString);
      DateTime nowLocal = DateTime.now();
      return nowLocal.millisecondsSinceEpoch >
          eventLocal.millisecondsSinceEpoch;
    } catch (e) {
      return false;
    }
  }

  bool isEventEnded(String eventDate) {
    try {
      DateTime eventDateTime = DateTime.parse(eventDate);
      DateTime now = DateTime.now();
      DateTime twoHoursAfterStart =
      eventDateTime.add(const Duration(hours: 1));
      return now.isAfter(twoHoursAfterStart);
    } catch (e) {
      return false;
    }
  }

  bool shouldShowCountdown(String eventDate) {
    try {
      String localDateString = eventDate.replaceAll('Z', '');
      DateTime eventDateTime = DateTime.parse(localDateString);
      DateTime now = DateTime.now();
      DateTime nowLocal = DateTime(
          now.year, now.month, now.day, now.hour, now.minute, now.second);
      DateTime sixHoursBefore =
      eventDateTime.subtract(const Duration(hours: 6));
      DateTime endOfEventDay = DateTime(
        eventDateTime.year,
        eventDateTime.month,
        eventDateTime.day + 1,
      );
      return nowLocal.isAfter(sixHoursBefore) &&
          nowLocal.isBefore(endOfEventDay);
    } catch (e) {
      return false;
    }
  }

  bool shouldShowQRCode(String eventDate) {
    try {
      DateTime eventDateTime = DateTime.parse(eventDate);
      DateTime now = DateTime.now();
      DateTime sixHoursBefore =
      eventDateTime.subtract(const Duration(hours: 6));
      return now.isAfter(sixHoursBefore);
    } catch (e) {
      return false;
    }
  }

  bool isTransferAllowed(
      String eventDate,
      int ticketStatus,
      int isTransferable,
      ) {
    if (isTransferable == 0) {
      return false;
    }
    if (ticketStatus == 1 || ticketStatus == 2 || ticketStatus == 3) {
      return false;
    }
    return canStillTransfer(eventDate);
  }

  Future<void> acceptTransfer() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loaderContext) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)
            ],
          ),
          child: const CircularProgressIndicator(color: Color(0xFFE41E26)),
        ),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse("https://ticketing.ma/api/customer/accept-transfer"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "order_id": widget.orderId,
        }),
      );

      Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("🎉 ${l10n.transferAcceptedSuccess}"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "❌ ${data["message"] ?? l10n.acceptTransferError}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "❌ ${l10n.serverError}: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ ${l10n.error}: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> rejectTransfer() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loaderContext) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)
            ],
          ),
          child: const CircularProgressIndicator(color: Color(0xFFE41E26)),
        ),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse("https://ticketing.ma/api/customer/reject-transfer"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "order_id": widget.orderId,
        }),
      );

      Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ ${l10n.transferRejectedSuccess}"),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "❌ ${data["message"] ?? l10n.rejectTransferError}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "❌ ${l10n.serverError}: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ ${l10n.error}: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> showTransferTicketModal(int ticketId) async {
    String email = "";

    final emailEntered = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  l10n.transferTicketTitle,
                  style: const TextStyle(
                    fontFamily: "Urbanist",
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Color(0xFFE41E26),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.transferTicketPrompt,
                style: const TextStyle(
                  fontFamily: "Urbanist",
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  fontFamily: "Urbanist",
                  fontSize: 12,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  prefixIcon:
                  const Icon(Icons.email, color: Color(0xFFE41E26)),
                  hintText: l10n.emailExample,
                  hintStyle: const TextStyle(
                    fontFamily: "Urbanist",
                    fontSize: 11,
                    color: Colors.black38,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F6FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE41E26)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                    const BorderSide(color: Color(0xFFE41E26), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                onChanged: (value) => email = value.trim(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close, size: 16),
                      label: Text(
                        l10n.cancel,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (email.isEmpty || !email.contains("@")) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.enterValidEmail),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context, true);
                      },
                      icon: const Icon(Icons.send, size: 16),
                      label: Text(
                        l10n.confirm,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE41E26),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (emailEntered != true) return;

    bool emailExists = false;
    int? customerId;

    final uri = Uri.parse("https://ticketing.ma/api/customer/search")
        .replace(queryParameters: {"email": email});

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["success"] == true && data["data"] != null) {
        final customer = data["data"];
        if (customer["organization_id"].toString() ==
            widget.currentOrganizationId.toString()) {
          emailExists = true;
          customerId = customer["id"];
        }
      }
    }

    if (!emailExists) {
      final invite = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.userNotFound,
                  style: const TextStyle(
                    fontFamily: "Urbanist",
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Color(0xFFE41E26),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "${l10n.userNotFoundMessage} $email,\n${l10n.inviteQuestion}",
                  style: const TextStyle(
                      fontFamily: "Urbanist", fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final resp = await http.post(
                              Uri.parse(
                                  "https://ticketing.ma/api/customer/send-invitation"),
                              headers: {
                                "Authorization": "Bearer ${widget.token}",
                                "Content-Type": "application/json",
                              },
                              body: jsonEncode({"email": email}),
                            );

                            Navigator.pop(context, true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "🎟️ ${l10n.invitationSentSuccess} 🎉"),
                                backgroundColor: resp.statusCode == 200
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          } catch (e) {
                            Navigator.pop(context, false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.invitationError),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE41E26),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(l10n.invite),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      if (invite == null || invite == false) return;
    }

    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorCustomerId),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmSend = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  l10n.confirmationSend,
                  style: const TextStyle(
                    fontFamily: "Urbanist",
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Color(0xFFE41E26),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "${l10n.aboutToSend} $email.\n${l10n.irreversibleAction}\n${l10n.continueQuestion}",
                style: const TextStyle(
                    fontFamily: "Urbanist",
                    fontSize: 12,
                    color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE41E26),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        l10n.confirm,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmSend != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loaderContext) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)
            ],
          ),
          child: const CircularProgressIndicator(color: Color(0xFFE41E26)),
        ),
      ),
    );

    try {
      final resp = await http.post(
        Uri.parse("https://ticketing.ma/api/customer/send-ticket"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "order_child_id": ticketId,
          "customer_id": customerId,
        }),
      );

      Navigator.of(context, rootNavigator: true).pop();

      dynamic respData;
      try {
        respData = jsonDecode(resp.body);
      } catch (jsonErr) {
        respData = {"message": l10n.invalidServerResponse};
      }

      if (resp.statusCode == 200 && respData["success"] == true) {
        setState(() {});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(respData["message"] ?? l10n.transferDone),
          backgroundColor: resp.statusCode == 200 ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.transferError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSeatingInfo(Map<String, dynamic> ticketData) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.black
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: theme.brightness == Brightness.dark
                ? Colors.white24
                : Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(l10n.gate, ticketData["porte"]?.toString() ?? "-",
              Icons.door_front_door_rounded, theme),
          _buildInfoItem(l10n.access, ticketData["access"]?.toString() ?? "-",
              Icons.directions_rounded, theme),
          _buildInfoItem(l10n.block, ticketData["secteur"]?.toString() ?? "-",
              Icons.grid_view_rounded, theme),
          _buildInfoItem(l10n.seat, ticketData["place"]?.toString() ?? "-",
              Icons.chair_rounded, theme),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFE41E26), size: 16),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: "Urbanist",
            fontWeight: FontWeight.w600,
            fontSize: 10,
            color: theme.brightness == Brightness.dark
                ? Colors.white70
                : Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: "Urbanist",
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFFE41E26);
    final theme = Theme.of(context);

    final child = widget.ticket;
    final ticketData = child["ticket_data"];
    final ticketNumber = child["ticket_number"];
    final ticketStatus = child["status"];
    final event = widget.event;
    final isTransferable = widget.isTransferable;

    String statusText = "";
    Color statusColor = Colors.grey;

    switch (ticketStatus) {
      case 0:
        statusText = l10n.statusNotPrinted;
        statusColor = Colors.green;
        break;
      case 1:
        statusText = l10n.statusPrinted;
        statusColor = mainColor;
        break;
      case 2:
        statusText = l10n.statusTransferred;
        statusColor = Colors.green;
        break;
      case 3:
        statusText = l10n.statusUsed;
        statusColor = Colors.red;
        break;
      default:
        statusText = l10n.statusUnknown;
    }

    Widget mainContent;
    if (isEventEnded(event["date"])) {
      mainContent = _buildStatusBlock(
        icon: Icons.event_busy,
        text: l10n.eventEnded,
        theme: theme,
        mainColor: mainColor,
      );
    } else if (isTransferable == 0) {
      mainContent = _buildStatusBlock(
        icon: Icons.block,
        text: l10n.qrCodeNotAuthorized,
        theme: theme,
        mainColor: mainColor,
        backgroundColor: const Color(0xFFF8F9FF),
      );
    } else if (ticketStatus == 3) {
      mainContent = _buildStatusBlock(
        icon: Icons.confirmation_number,
        text: l10n.ticketAlreadyUsed,
        theme: theme,
        mainColor: mainColor,
      );
    } else if (ticketStatus == 2) {
      mainContent = _buildStatusBlock(
        icon: Icons.confirmation_number,
        text: l10n.ticketAlreadyTransferred,
        theme: theme,
        mainColor: mainColor,
      );
    } else if (ticketStatus == 1) {
      mainContent = _buildStatusBlock(
        icon: Icons.confirmation_number,
        text: l10n.usePhysicalTicket,
        theme: theme,
        mainColor: mainColor,
        backgroundColor: const Color(0xFFF8F9FF),
      );
    } else if (!shouldShowQRCode(event["date"])) {
      mainContent = _buildStatusBlock(
        icon: Icons.schedule,
        text: widget.isQrCode == 0
            ? l10n.usePhysicalTicket
            : l10n.qrCodeWillAppearBeforeMatch,
        theme: theme,
        mainColor: mainColor,
        backgroundColor: const Color(0xFFF8F9FF),
      );
    } else if (widget.isQrCode == 0) {
      mainContent = _buildStatusBlock(
        icon: Icons.qr_code,
        text: l10n.qrCodeNotAvailableForCategory,
        theme: theme,
        mainColor: mainColor,
        backgroundColor: const Color(0xFFF8F9FF),
      );
    } else {
      mainContent = CustomPaint(
        painter: _AnimatedBorderPainter(
          animation: _controller,
          radius: 20,
          color: mainColor,
          strokeWidth: 15,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: l10n.categoryLabel,
                      style: const TextStyle(
                        fontFamily: "Urbanist",
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color(0xFFE41E26),
                      ),
                    ),
                    TextSpan(
                      text: widget.category,
                      style: const TextStyle(
                        fontFamily: "Urbanist",
                        fontWeight: FontWeight.w700,
                        fontSize: 25,
                        color: Color(0xFFE41E26),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: QrImageView(
                        data: ticketNumber,
                        size: 220,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    if (ticketStatus != 0 || (isEventPast(event["date"])))
                      Transform.rotate(
                        angle: -0.785398,
                        child: Container(
                          width: 180,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.used.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: "Urbanist",
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.confirmation_num, color: Color(0xFFE41E26)),
            const SizedBox(width: 8),
            Text(
              l10n.ticketDetailTitle,
              style: const TextStyle(
                fontFamily: "Urbanist",
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFFE41E26),
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor:
        theme.brightness == Brightness.dark ? Colors.black : Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Color(0xFFE41E26)),
        actions: [
          IconButton(
            icon: Icon(
              Icons.power_settings_new,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFFE41E26),
            ),
            onPressed: logout,
          ),
        ],
      ),
      backgroundColor:
      theme.brightness == Brightness.dark ? Colors.black : Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!widget.isSender && widget.transferStatus == 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pending_actions, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.receivedTransferPending,
                          style: const TextStyle(
                            fontFamily: "Urbanist",
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (isTransferable == 0)
                Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        l10n.ticketNotTransferable,
                        style: const TextStyle(
                          fontFamily: "Urbanist",
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              if (shouldShowCountdown(event["date"]) &&
                  isTransferable != 0 &&
                  !isEventStarted(event["date"])) ...[
                Builder(
                  builder: (context) {
                    String timeRemaining = getTimeRemaining(event["date"]);
                    if (timeRemaining != l10n.eventOngoing &&
                        ticketStatus != 2 &&
                        ticketStatus != 3) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0),
                            child: Center(
                              child: Text(
                                (!isEventPast(event["date"]) ||
                                    !isEventStarted(event["date"]))
                                    ? ""
                                    : l10n.eventStartsIn,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "Urbanist",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white
                                      : mainColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isEventPast(event["date"])
                                      ? Icons.info_outline
                                      : Icons.access_time,
                                  color: Colors.red,
                                  size: 24,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  timeRemaining,
                                  style: const TextStyle(
                                    fontFamily: "Urbanist",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 27,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
              ticketStatus != 0
                  ? Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.ticketStatusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox.shrink(),
              const SizedBox(height: 12),
              Text(
                event["name"],
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: 27,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF030836),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                formatDate(event["date"]),
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF030836),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                event["address"],
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF282828),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              mainContent,
              const SizedBox(height: 20),
              if (_hasTicketData(ticketData))
                Center(
                  child: _buildSeatingInfo(ticketData),
                ),
              const SizedBox(height: 20),
              if (!widget.isSender && widget.transferStatus == 0)
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: acceptTransfer,
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: Text(
                        l10n.acceptTransfer,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        minimumSize: const Size(250, 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: rejectTransfer,
                      icon: const Icon(Icons.cancel, size: 20),
                      label: Text(
                        l10n.rejectTransfer,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        minimumSize: const Size(250, 50),
                      ),
                    ),
                  ],
                )
              else if (widget.isSender &&
                  isTransferAllowed(
                      event["date"], ticketStatus, isTransferable))
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => showTransferTicketModal(child["id"]),
                    icon: const Icon(Icons.send, size: 20),
                    label: Text(
                      l10n.transferTicket,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      minimumSize: const Size(250, 50),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBlock({
    required IconData icon,
    required String text,
    required ThemeData theme,
    required Color mainColor,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (theme.brightness == Brightness.dark
                ? Colors.black
                : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mainColor),
      ),
      child: Column(
        children: [
          Icon(icon,
              size: 50,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : mainColor),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              fontFamily: "Urbanist",
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFFE41E26),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AnimatedBorderPainter extends CustomPainter {
  final Animation<double> animation;
  final double radius;
  final Color color;
  final double strokeWidth;

  _AnimatedBorderPainter({
    required this.animation,
    required this.radius,
    required this.color,
    required this.strokeWidth,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = SweepGradient(
      colors: [color, Colors.transparent, color],
      stops: const [0.0, 0.5, 1.0],
      transform: GradientRotation(animation.value * 2 * pi),
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}