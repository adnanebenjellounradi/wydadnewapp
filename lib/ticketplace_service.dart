import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TicketplaceService {
  static const String baseUrl = 'https://ticketing.ma/api/customer/ticketplace';

  // ─────────────────────────────────────────────
  // GET /events — Matchs avec offres de revente
  // ─────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getEvents({
    required String token,
    int? organizationId,
  }) async {
    try {
      final qp = organizationId != null ? '?organization_id=$organizationId' : '';
      final res = await http.get(
        Uri.parse('$baseUrl/events$qp'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('ticketplace getEvents error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // GET /events/{id}/listings — Offres d'un match
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getEventListings({
    required String token,
    required int eventId,
    int? ticketId,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) async {
    try {
      final params = <String, String>{};
      if (ticketId != null) params['ticket_id'] = '$ticketId';
      if (minPrice != null) params['min_price'] = '$minPrice';
      if (maxPrice != null) params['max_price'] = '$maxPrice';
      if (sortBy != null) params['sort_by'] = sortBy;
      final qp = params.isEmpty ? '' : '?${Uri(queryParameters: params).query}';

      final res = await http.get(
        Uri.parse('$baseUrl/events/$eventId/listings$qp'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      return null;
    } catch (e) {
      debugPrint('getEventListings error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // GET /listings/{id} — Détail d'une annonce
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getListingDetail({
    required String token,
    required int listingId,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/listings/$listingId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      return null;
    } catch (e) {
      debugPrint('getListingDetail error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // POST /calculate-pricing — Calcul des frais
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>?> calculatePricing({
    required String token,
    required double resalePrice,
    int? organizationId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/calculate-pricing'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'resale_price': resalePrice,
          if (organizationId != null) 'organization_id': organizationId,
        }),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      return null;
    } catch (e) {
      debugPrint('calculatePricing error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // POST /resale — Publier une annonce
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>?> publishResale({
    required String token,
    required List<int> orderChildIds,
    required double resalePrice,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/resale'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'order_child_ids': orderChildIds,
          'resale_price': resalePrice,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('publishResale error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // POST /cancel — Annuler une annonce
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>?> cancelResale({
    required String token,
    required int resaleTicketId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'resale_ticket_id': resaleTicketId}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('cancelResale error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // GET /my-listings — Mes annonces
  // ─────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getMyListings({
    required String token,
    int? status,
  }) async {
    try {
      final qp = status != null ? '?status=$status' : '';
      final res = await http.get(
        Uri.parse('$baseUrl/my-listings$qp'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('getMyListings error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // POST /listings/{id}/checkout — Achat
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>?> checkoutListing({
    required String token,
    required int listingId,
    required String paymentType, // 'BAAS_WALLET' | 'BAAS_CARD'
    String? customerName,
    String? customerCin,
    String? pin,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/listings/$listingId/checkout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'payment_type': paymentType,
          if (customerName != null) 'customer_name': customerName,
          if (customerCin != null) 'customer_cin': customerCin,
          if (pin != null) 'pin': pin,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('checkoutListing error: $e');
      return null;
    }
  }
}