import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

class TransferHistoryPage extends StatefulWidget {
  final String token;
  final String userEmail;
  final int eventId;

  const TransferHistoryPage({
    Key? key,
    required this.token,
    required this.userEmail,
    required this.eventId,
  }) : super(key: key);

  @override
  _TransferHistoryPageState createState() => _TransferHistoryPageState();
}

class _TransferHistoryPageState extends State<TransferHistoryPage> {
  List<dynamic> _transfers = [];
  bool _isLoading = true;
  String? _errorMessage;

  int _limit = 100;
  int _offset = 0;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  final Color primary = const Color(0xFFA8161F);
  final Color gold = const Color(0xFFF5CD52);
  final Color amber = const Color(0xFFFFC97A);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      if (mounted) {
        _loadTransferHistory();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreTransfers();
      }
    }
  }

  Future<void> _loadTransferHistory({bool reset = false}) async {
    final l10n = AppLocalizations.of(context)!;

    if (reset) {
      setState(() {
        _offset = 0;
        _transfers = [];
        _hasMoreData = true;
      });
    }

    if (!_hasMoreData && !reset) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      if (reset) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
      _errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? currentUserId = prefs.getString('user_id');

      if (currentUserId == null || currentUserId.isEmpty) {
        setState(() {
          _errorMessage = l10n.userNotConnected;
          _isLoading = false;
          _isLoadingMore = false;
        });
        return;
      }

      final queryParams = {
        'limit': _limit.toString(),
        'offset': _offset.toString(),
        'event_id': widget.eventId.toString(),
      };

      final uri = Uri.parse("https://ticketing.ma/api/customer/transfer-history")
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true && data["data"] != null) {
          final List<dynamic> allTransfers = data["data"];
          final List<dynamic> myTransfers = allTransfers
              .where((transfer) {
            final transferFrom = transfer["transfer_from"];
            return transferFrom != null && transferFrom.toString() == currentUserId;
          })
              .toList();

          setState(() {
            if (reset) {
              _transfers = myTransfers;
            } else {
              _transfers.addAll(myTransfers);
            }

            _hasMoreData = allTransfers.length >= _limit;
            if (_hasMoreData) {
              _offset += _limit;
            }

            _isLoading = false;
            _isLoadingMore = false;
          });
        } else {
          setState(() {
            _errorMessage = data["message"] ?? l10n.unknownError;
            _isLoading = false;
            _isLoadingMore = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "${l10n.serverError}: ${response.statusCode}";
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('❌ Erreur: $e');
      setState(() {
        _errorMessage = "${l10n.error}: $e";
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreTransfers() => _loadTransferHistory();
  Future<void> _refreshTransfers() => _loadTransferHistory(reset: true);

  String _formatDate(String? dateString) {
    final l10n = AppLocalizations.of(context)!;
    if (dateString == null) return l10n.unknownDate;
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getTransferStatusText(int status, AppLocalizations l10n) {
    switch (status) {
      case 0:
        return l10n.statusPending;
      case 1:
        return l10n.statusAccepted;
      case 2:
        return l10n.statusRejected;
      default:
        return l10n.statusUnknown;
    }
  }

  Color _getTransferStatusColor(int status) {
    switch (status) {
      case 0:
        return amber;
      case 1:
        return gold;
      case 2:
        return const Color(0xFFE5484D);
      default:
        return Colors.white60;
    }
  }

  IconData _getTransferStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.pending_actions;
      case 1:
        return Icons.check_circle;
      case 2:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A0710), Color(0xFF23030A), Color(0xFF120104)],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildHeader(l10n),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState(l10n)
                    : _errorMessage != null
                    ? _buildErrorWidget(l10n)
                    : _transfers.isEmpty
                    ? _buildEmptyWidget(l10n)
                    : _buildTransferList(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
            ),
          ),
          const Spacer(),
          Text(
            l10n.myTransfers,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _refreshTransfers,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: const Icon(Icons.refresh, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primary),
          const SizedBox(height: 16),
          Text(
            l10n.loadingTransfers,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Color(0xFFE5484D)),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _refreshTransfers,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD11A2A), Color(0xFFA8161F)],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.retry,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_outlined,
              size: 72,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTransfersSent,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noTransfersSentMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferList(AppLocalizations l10n) {
    int totalTransfers = _transfers.length;
    int acceptedCount = _transfers.where((t) => t["transfer_status"] == 1).length;
    int pendingCount = _transfers.where((t) => t["transfer_status"] == 0).length;
    int rejectedCount = _transfers.where((t) => t["transfer_status"] == 2).length;

    return Column(
      children: [
        // Carte stats
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFA8161F), Color(0xFF7A0D17), Color(0xFF4A0710)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.totalTransfers,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '$totalTransfers',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.check_circle, acceptedCount, l10n.accepted, gold),
                  _buildStatItem(Icons.pending_actions, pendingCount, l10n.pending, amber),
                  _buildStatItem(Icons.cancel, rejectedCount, l10n.rejected, const Color(0xFFE5484D)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshTransfers,
            color: primary,
            backgroundColor: const Color(0xFF23030A),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: _transfers.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _transfers.length) {
                  return _buildLoadingMoreIndicator();
                }
                return _buildTransferCard(_transfers[index], l10n);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingMoreIndicator() {
    if (!_hasMoreData) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(color: gold, strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildTransferCard(Map<String, dynamic> transfer, AppLocalizations l10n) {
    final transferStatus = transfer["transfer_status"] ?? 0;
    final statusColor = _getTransferStatusColor(transferStatus);
    final statusIcon = _getTransferStatusIcon(transferStatus);
    final statusText = _getTransferStatusText(transferStatus, l10n);

    final event = transfer["event"] ?? {};
    final ticket = transfer["ticket"] ?? {};
    final receiver = transfer["receiver"] ?? {};
    final createdAt = transfer["created_at"];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ligne 1 : Event + Status ──
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: event["image"] == null
                        ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFD11A2A), Color(0xFF6E0B12)],
                    )
                        : null,
                    image: event["image"] != null
                        ? DecorationImage(
                      image: NetworkImage(event["image"]),
                      fit: BoxFit.cover,
                    )
                        : null,
                    border: Border.all(color: Colors.white.withOpacity(0.14)),
                  ),
                  child: event["image"] == null
                      ? const Icon(Icons.event, color: Colors.white, size: 22)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    event["name"] ?? l10n.event,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Bloc ticket + receiver ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.confirmation_number, size: 16, color: gold),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ticket["name"] ?? l10n.ticket,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${ticket["price"] ?? 0} MAD",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(height: 1, color: Colors.white.withOpacity(0.08)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.white.withOpacity(0.6)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.recipient,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            Text(
                              '${receiver["name"] ?? ""} ${receiver["last_name"] ?? ""}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${transfer["quantity"]}x",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: gold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Date ──
            Row(
              children: [
                Icon(Icons.access_time, size: 13, color: Colors.white.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(
                  _formatDate(createdAt),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int count, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.16),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: Colors.white.withOpacity(0.75),
          ),
        ),
      ],
    );
  }
}