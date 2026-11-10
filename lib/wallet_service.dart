import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WalletService {
  static const String baseUrl = 'https://ticketing.ma/api/customer/wallet';

  // ─────────────────────────────────────────────
  // INFOS WALLET
  // ─────────────────────────────────────────────

  // GET /wallet — infos solde & KYC
  static Future<Map<String, dynamic>?> getWalletInfo(String token) async {
    try {
      final res = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      return null;
    } catch (e) {
      debugPrint('getWalletInfo error: $e');
      return null;
    }
  }

  // GET /wallet/rib — RIB du wallet (pour virement entrant)
  static Future<Map<String, dynamic>?> getRib(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/rib'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      return null;
    } catch (e) {
      debugPrint('getRib error: $e');
      return null;
    }
  }

  // GET /wallet/transactions — historique
  static Future<List<Map<String, dynamic>>> getTransactions(
      String token) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('getTransactions error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // INSCRIPTION / AUTH WALLET
  // ─────────────────────────────────────────────

  // POST /wallet/register — créer wallet
  static Future<Map<String, dynamic>?> register({
    required String token,
    required String phone,
    required String firstName,
    required String lastName,
    required String cin,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'first_name': firstName,
          'last_name': lastName,
          'cin': cin,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('registerWallet error: $e');
      return null;
    }
  }

  // POST /wallet/verify-otp
  static Future<Map<String, dynamic>?> verifyOtp({
    required String token,
    required String phone,
    required String otp,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('verifyOtp error: $e');
      return null;
    }
  }

  // POST /wallet/set-pin
  static Future<Map<String, dynamic>?> setPin({
    required String token,
    required String phone,
    required String pin,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/set-pin'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'pin': pin}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('setPin error: $e');
      return null;
    }
  }

  // POST /wallet/login
  static Future<Map<String, dynamic>?> login({
    required String token,
    required String phone,
    required String pin,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'pin': pin}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('wallet login error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // TRANSFERT
  // ─────────────────────────────────────────────

  // POST /wallet/transfer/preview
  static Future<Map<String, dynamic>?> transferPreview({
    required String token,
    required String recipientPhone,
    required double amount,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/transfer/preview'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body:
        jsonEncode({'recipient_phone': recipientPhone, 'amount': amount}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return null;
    }
  }

  // POST /wallet/transfer
  static Future<Map<String, dynamic>?> transfer({
    required String token,
    required String recipientPhone,
    required double amount,
    required String pin,
    String? note,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/transfer'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'recipient_phone': recipientPhone,
          'amount': amount,
          'pin': pin,
          if (note != null && note.isNotEmpty) 'note': note,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // ALIMENTATION (RECHARGE)
  // ─────────────────────────────────────────────

  // POST /wallet/recharge/preview
  static Future<Map<String, dynamic>?> rechargePreview({
    required String token,
    required double amount,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/recharge/preview'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'amount': amount}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return null;
    }
  }

  // POST /wallet/recharge (avec carte tokenisée)
  static Future<Map<String, dynamic>?> recharge({
    required String token,
    required double amount,
    required int cardId,
    required String cvv,
    required String redirectUrl,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/recharge'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'customerTokenizedCardId': cardId,
          'baas_card_cvv': cvv,
          'redirect_url': redirectUrl,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return null;
    }
  }

  // POST /wallet/recharge/agency — alimentation espèces en agence
  // Retourne selon le backend : deposit_code, code ou reference
  static Future<Map<String, dynamic>?> rechargeAgency({
    required String token,
    required double amount,
    String? description,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/recharge/agency'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          if (description != null && description.isNotEmpty)
            'description': description,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('rechargeAgency error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // RETRAIT (CASHOUT)
  // ─────────────────────────────────────────────

  // POST /wallet/cashout — virement vers RIB bancaire
  static Future<Map<String, dynamic>?> cashout({
    required String token,
    required double amount,
    required String rib,
    required String beneficiaryName,
    required String pin,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/cashout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'rib': rib,
          'beneficiary_name': beneficiaryName,
          'pin': pin,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('cashout error: $e');
      return null;
    }
  }

  // POST /wallet/cashout/agency — retrait espèces en agence
  // Retourne selon le backend : withdrawal_code, code ou reference
  static Future<Map<String, dynamic>?> cashoutAgency({
    required String token,
    required double amount,
    required String pin,
    String? description,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/cashout/agency'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'pin': pin,
          if (description != null && description.isNotEmpty)
            'description': description,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('cashoutAgency error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // CODE PIN
  // ─────────────────────────────────────────────

  // POST /wallet/change-pin
  static Future<Map<String, dynamic>?> changePin({
    required String token,
    required String oldPin,
    required String newPin,
    required String newPinConfirmation,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/change-pin'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'old_pin': oldPin,
          'new_pin': newPin,
          'new_pin_confirmation': newPinConfirmation,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('changePin error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // KYC
  // ─────────────────────────────────────────────

  // GET /wallet/kyc/status
  static Future<Map<String, dynamic>?> getKycStatus(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/kyc/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return jsonDecode(res.body);
    } catch (e) {
      return null;
    }
  }

  // POST /wallet/kyc/auth
  static Future<Map<String, dynamic>?> kycAuth({
    required String token,
    required int level,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/kyc/auth'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'level': level}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('kycAuth error: $e');
      return null;
    }
  }

  // POST /wallet/kyc/upgrade
  static Future<Map<String, dynamic>?> kycUpgrade({
    required String token,
    required int level,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/kyc/upgrade'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'level': level}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('kycUpgrade error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // CARTES BANCAIRES
  // ─────────────────────────────────────────────

  // GET /wallet/cards — cartes enregistrées
  static Future<List<Map<String, dynamic>>> getCards(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/cards'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']?['cards'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('getCards error: $e');
      return [];
    }
  }

  // DELETE /wallet/cards/{cardId}
  static Future<Map<String, dynamic>?> deleteCard({
    required String token,
    required int cardId,
  }) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/cards/$cardId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('deleteCard error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // BÉNÉFICIAIRES
  // ─────────────────────────────────────────────

  // GET /wallet/beneficiaries
  static Future<List<Map<String, dynamic>>> getBeneficiaries(
      String token) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/beneficiaries'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('getBeneficiaries error: $e');
      return [];
    }
  }

  // POST /wallet/beneficiaries — ajouter un bénéficiaire
  static Future<Map<String, dynamic>?> addBeneficiary({
    required String token,
    required String name,
    required String rib,
    required String recipientPhone,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/beneficiaries'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'rib': rib,
          'recipient_phone': recipientPhone,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('addBeneficiary error: $e');
      return null;
    }
  }

  // DELETE /wallet/beneficiaries/{id}
  static Future<Map<String, dynamic>?> deleteBeneficiary({
    required String token,
    required int id,
  }) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/beneficiaries/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('deleteBeneficiary error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // DIVERS
  // ─────────────────────────────────────────────

  // POST /wallet/close-account
  static Future<Map<String, dynamic>?> closeAccount({
    required String token,
    required int reason,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/close-account'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reason': reason}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('closeAccount error: $e');
      return null;
    }
  }

  // POST /wallet/logout
  static Future<void> logout(String token) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (e) {
      debugPrint('wallet logout error: $e');
    }
  }
}