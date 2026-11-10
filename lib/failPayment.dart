import 'package:flutter/material.dart';

class FailPaymentPage extends StatefulWidget {
  final String token;
  final int eventId;
  final String? currentOrganizationId;

  FailPaymentPage({
    Key? key,
    required this.token,
    required this.eventId,
    this.currentOrganizationId,
  }) : super(key: key);

  @override
  _FailPaymentPageState createState() => _FailPaymentPageState();
}

class _FailPaymentPageState extends State<FailPaymentPage> {
  @override
  Widget build(BuildContext context) {
    const mainPurple = Color(0xFFE41E26);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paiement échoué',
          style: TextStyle(
              fontFamily: "Urbanist",
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: mainPurple),
        automaticallyImplyLeading: false, // Disable back button
      ),
      backgroundColor: Color(0xFFF7F9FC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 100,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                'Paiement échoué !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Urbanist",
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Une erreur s\'est produite lors du paiement. Veuillez réessayer.',
                style: TextStyle(
                  fontFamily: "Urbanist",
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
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
                    '/acheterTicketInEvent',
                    arguments: {
                      "token": widget.token,
                      "eventId": widget.eventId,
                      "organizationId": widget.currentOrganizationId,
                    },
                  );
                },
                child: Text(
                  'Réessayer',
                  style: TextStyle(
                    fontFamily: "Urbanist",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/orders',
                    arguments: {
                      "token": widget.token,
                      "organizationId": widget.currentOrganizationId,
                    },
                  );
                },
                child: Text(
                  'Retour aux événements',
                  style: TextStyle(
                    fontFamily: "Urbanist",
                    fontSize: 16,
                    color: mainPurple,
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
