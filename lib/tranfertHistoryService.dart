import 'dart:convert';
import 'package:http/http.dart' as http;

class TransferHistoryService {
  static Future<List<Map<String, dynamic>>> fetchTransferHistory({
    required String token,
    required String userEmail,
    int? orderId,
  }) async {
    try {
      // URL de l'API - utiliser orderId si fourni
      String url = orderId != null 
          ? "https://ticketing.ma/api/customer/orders/$orderId"
          : "https://ticketing.ma/api/customer/orders";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        print("ooooooooooo");
        // Si un orderId spécifique est fourni, la réponse est un objet unique
        if (orderId != null) {
          if (data["success"] == true && data["data"] != null) {
            final order = data["data"];
            
            // Vérifier si c'est un transfert où l'utilisateur est l'expéditeur
            if (order["order_type"] == "Transfer" &&
                order["sender"] != null &&
                order["sender"]["email"] == userEmail) {
              
              final event = order["event"] ?? {};
              final receiver = order["receiver"] ?? {};
              final tickets = order["order_child"] ?? [];

              int pendingCount = 0;
              int acceptedCount = 0;
              int rejectedCount = 0;

              for (var ticket in tickets) {
                final transferStatus = ticket["transfer_status"] ?? 20;
                if (transferStatus == 0) pendingCount++;
                else if (transferStatus == 1) acceptedCount++;
                else if (transferStatus == 2) rejectedCount++;
              }

              return [{
                'orderId': order["id"],
                'orderNumber': order["order_id"],
                'eventId': event["id"],
                'eventName': event["name"] ?? "Événement",
                'eventDate': event["date"],
                'eventImage': event["image"],
                'eventAddress': event["address"],
                'receiverName': receiver["name"] != null && receiver["last_name"] != null
                    ? "${receiver["name"]} ${receiver["last_name"]}"
                    : (receiver["email"] ?? "Inconnu"),
                'receiverEmail': receiver["email"],
                'receiverId': receiver["id"],
                'transferDate': order["transfer_at"] ?? order["created_at"],
                'transferStatus': order["transfer_status"] ?? 20,
                'totalTickets': tickets.length,
                'pendingCount': pendingCount,
                'acceptedCount': acceptedCount,
                'rejectedCount': rejectedCount,
                'tickets': tickets,
                'createdAt': order["created_at"],
              }];
            }
          }
          return [];
        }
        
        // Sinon, récupérer toutes les commandes (comportement original)
        if (data["success"] == true && data["data"] != null) {
          final List<dynamic> allOrders = data["data"];

          // Filtrer les commandes de type "Transfer" où l'utilisateur est l'expéditeur
          final transferOrders = allOrders.where((order) {
            return order["order_type"] == "Transfer" &&
                order["sender"] != null &&
                order["sender"]["email"] == userEmail;
          }).toList();

          // Transformer les données pour l'affichage
          return transferOrders.map((order) {
            final event = order["event"] ?? {};
            final receiver = order["receiver"] ?? {};
            final tickets = order["order_child"] ?? [];

            // Compter les tickets par statut
            int pendingCount = 0;
            int acceptedCount = 0;
            int rejectedCount = 0;

            for (var ticket in tickets) {
              final transferStatus = ticket["transfer_status"] ?? 20;
              if (transferStatus == 0) pendingCount++;
              else if (transferStatus == 1) acceptedCount++;
              else if (transferStatus == 2) rejectedCount++;
            }

            return {
              'orderId': order["id"],
              'orderNumber': order["order_id"],
              'eventId': event["id"],
              'eventName': event["name"] ?? "Événement",
              'eventDate': event["date"],
              'eventImage': event["image"],
              'eventAddress': event["address"],
              'receiverName': receiver["name"] != null && receiver["last_name"] != null
                  ? "${receiver["name"]} ${receiver["last_name"]}"
                  : (receiver["email"] ?? "Inconnu"),
              'receiverEmail': receiver["email"],
              'receiverId': receiver["id"],
              'transferDate': order["transfer_at"] ?? order["created_at"],
              'transferStatus': order["transfer_status"] ?? 20,
              'totalTickets': tickets.length,
              'pendingCount': pendingCount,
              'acceptedCount': acceptedCount,
              'rejectedCount': rejectedCount,
              'tickets': tickets,
              'createdAt': order["created_at"],
            };
          }).toList()
            ..sort((a, b) {
              // Trier par date de transfert (plus récent en premier)
              final dateA = DateTime.parse(a['transferDate'] ?? a['createdAt'] ?? DateTime.now().toIso8601String());
              final dateB = DateTime.parse(b['transferDate'] ?? b['createdAt'] ?? DateTime.now().toIso8601String());
              return dateB.compareTo(dateA);
            });
        }
      }
      return [];
    } catch (e) {
      print('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  // Récupérer les détails d'un transfert spécifique
  static Future<Map<String, dynamic>?> fetchTransferDetails({
    required String token,
    required int orderId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("https://ticketing.ma/api/customer/orders/$orderId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["data"] != null) {
          return data["data"];
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération des détails: $e');
      return null;
    }
  }
}