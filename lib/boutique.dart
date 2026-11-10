import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'l10n/app_localizations.dart';
import 'bottomnavigation.dart';

class BoutiquePage extends StatefulWidget {
  final String token;
  final String? organizationId;
  final VoidCallback toggleTheme;
  final VoidCallback toggleLanguage;
  final bool isDarkMode;
  final String currentLocale;

  BoutiquePage({
    Key? key,
    required this.token,
    this.organizationId,
    required this.toggleTheme,
    required this.toggleLanguage,
    required this.isDarkMode,
    required this.currentLocale,
  }) : super(key: key);

  @override
  _BoutiquePageState createState() => _BoutiquePageState();
}

class _BoutiquePageState extends State<BoutiquePage> {
  bool isLoading = true;
  bool isCreatingOrder = false;
  bool isLoggedIn = false;
  int? selectedCategoryId;
  Map<String, Map<String, dynamic>> selectedProducts = {};

  String _truncateName(String? name, {int max = 20}) {
    if (name == null) return '';
    final trimmed = name.trim();
    if (trimmed.length <= max) return trimmed;
    return '${trimmed.substring(0, max)}…';
  }

  List<String> categories = [];
  List<Map<String, dynamic>> categoryObjects = [];
  List<Map<String, dynamic>> sizeObjects = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> allProducts = [];

  String customerName = '';
  String customerPhone = '';
  String customerAddress = '';
  bool isCasablancaDelivery = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool phoneTouched = false;
  String? fullNameError;
  String? phoneError;
  String? addressError;

  String selectedCountryCode = '+212';
  String? selectedCategory;
  String selectedSize = '';
  List<String> sizes = [];

  String _activeCatId = 'tout';

  final Color primary = const Color(0xFFA8161F);

  @override
  void initState() {
    super.initState();
    isLoggedIn = widget.token.isNotEmpty;
    _loadCartFromStorage();
    fetchData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['refreshCart'] == true) {
      _refreshCartAfterPayment();
    }
  }

  Future<void> _refreshCartAfterPayment() async {
    await _loadCartFromStorage();
    if (mounted) setState(() {});
  }

  Future<void> _loadCartFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('selectedProducts');
    if (cartData != null) {
      setState(() {
        selectedProducts = Map<String, Map<String, dynamic>>.from(
          json.decode(cartData).map((k, v) =>
              MapEntry(k, Map<String, dynamic>.from(v))),
        );
      });
    }
  }

  Future<void> _saveCartToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedProducts', json.encode(selectedProducts));
  }

  Future<void> _loadUserInfoFromPrefs(TextEditingController fullNameCtrl,
      TextEditingController phoneCtrl) async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name') ?? '';
    final userLastName = prefs.getString('user_last_name') ?? '';
    final phone = (prefs.getString('phone') ?? '').replaceAll('+212', '');
    customerName = '$userName $userLastName'.trim();
    customerPhone = phone;
    fullNameCtrl.text = customerName;
    if (customerPhone.isNotEmpty) {
      formatPhoneNumber(customerPhone, phoneCtrl);
    } else {
      phoneCtrl.text = '';
    }
  }

  String? validateFullName(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return null;
    final cleaned = v.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.split(' ').length < 2) return l10n.fullNameRequired;
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s\-]+$').hasMatch(cleaned)) {
      return l10n.fullNameLettersOnly;
    }
    if (cleaned.length < 2) return l10n.fullNameMinLength;
    return null;
  }

  String? validatePhoneNumber(String? v, AppLocalizations l10n) {
    if (v == null || v.isEmpty) return null;
    if (!RegExp(r'^[6-7][0-9]{8}$').hasMatch(v.replaceAll(' ', ''))) {
      return l10n.phoneInvalid;
    }
    return null;
  }

  String? validateAddress(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return l10n.addressRequired;
    if (v.trim().length < 10) return l10n.addressMinLength;
    return null;
  }

  String formatPhoneNumber(String value, [TextEditingController? controller]) {
    if (value.isEmpty) return '';
    String cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.startsWith('0')) cleaned = cleaned.substring(1);
    if (cleaned.length > 9) cleaned = cleaned.substring(0, 9);
    String formatted = '';
    if (cleaned.isNotEmpty) {
      formatted = cleaned.substring(0, 1);
      if (cleaned.length > 1) formatted += ' ${cleaned.substring(1, 3)}';
      if (cleaned.length > 3) formatted += ' ${cleaned.substring(3, 5)}';
      if (cleaned.length > 5) formatted += ' ${cleaned.substring(5, 7)}';
      if (cleaned.length > 7) formatted += ' ${cleaned.substring(7)}';
    }
    if (controller != null && controller.text != formatted) {
      controller.value = controller.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    customerPhone = formatted;
    return formatted;
  }

  Future<void> fetchData() async {
    try {
      await Future.wait([fetchProducts(), fetchCategories(), fetchSizes()]);
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> fetchProducts({int? categoryId, int? sizeId}) async {
    setState(() => isLoading = true);
    final url = 'https://ticketing.ma/api/customer/store/products';
    final params = <String, String>{'limit': '100', 'organization_id': '20'};
    if (categoryId != null) params['category_id'] = categoryId.toString();
    if (sizeId != null) params['size_id'] = sizeId.toString();
    try {
      final res = await http.get(
        Uri.parse(url).replace(queryParameters: params),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          allProducts = List<Map<String, dynamic>>.from(data['data'] ?? []);
          products = allProducts;
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<Map<String, dynamic>> fetchProductDetails(int id) async {
    final res = await http.get(
      Uri.parse('https://ticketing.ma/api/customer/store/products/$id')
          .replace(queryParameters: {'organization_id': '20'}),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) return json.decode(res.body)['data'];
    throw Exception('Failed to load details');
  }

  Future<void> fetchCategories() async {
    final res = await http.get(
      Uri.parse('https://ticketing.ma/api/customer/store/categories'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        categoryObjects = List<Map<String, dynamic>>.from(data['data'] ?? []);
        categories = [l10n.allCategories] +
            categoryObjects.map((c) => c['name'] as String).toList();
        selectedCategory = l10n.allCategories;
      });
    }
  }

  Future<void> fetchSizes() async {
    final res = await http.get(
      Uri.parse('https://ticketing.ma/api/customer/store/sizes'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        sizeObjects = List<Map<String, dynamic>>.from(data['data'] ?? []);
        sizes = [l10n.allSizes] +
            sizeObjects.map((s) => s['name'] as String).toList();
        selectedSize = l10n.allSizes;
      });
    }
  }

  List<Map<String, dynamic>> get filteredProducts {
    if (_activeCatId == 'tout') return products;
    final cat = categoryObjects.firstWhere(
          (c) => (c['name'] as String).toLowerCase() == _activeCatId,
      orElse: () => {},
    );
    if (cat.isEmpty) return products;
    return products
        .where((p) =>
    p['categories']?.any((c) => c['id'] == cat['id']) ?? false)
        .toList();
  }

  double get productsTotal {
    double t = 0;
    selectedProducts.forEach((k, d) {
      t += (d['price'] ?? 0.0) * (d['quantity'] ?? 0);
    });
    return t;
  }

  double get deliveryFee => isCasablancaDelivery ? 30.0 : 40.0;
  double get totalAmount => productsTotal + deliveryFee;
  bool get hasSelectedProducts => selectedProducts.isNotEmpty;
  int get _totalQty => selectedProducts.values
      .fold<int>(0, (s, p) => s + ((p['quantity'] as int?) ?? 0));

  void _addToCart(int productId, String size) {
    if (!isLoggedIn) {
      _showLoginDialog();
      return;
    }
    final product = products.firstWhere((p) => p['id'] == productId);
    final sizeMap =
    (product['sizes'] as List).firstWhere((s) => s['name'] == size);
    final price = product['price'] is int
        ? (product['price'] as int).toDouble()
        : product['price'];

    setState(() {
      final key = '${productId}_$size';
      final qty = selectedProducts.containsKey(key)
          ? (selectedProducts[key]!['quantity'] ?? 0) + 1
          : 1;
      selectedProducts[key] = {
        'quantity': qty,
        'size': size,
        'size_id': sizeMap['id'],
        'productId': productId,
        'product': product,
        'price': price,
      };
    });
    _saveCartToStorage();
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l10n.productAddedToCart,
          style: const TextStyle(color: Colors.white, fontFamily: 'Inter')),
      backgroundColor: primary,
      duration: const Duration(seconds: 1),
    ));
  }

  void _updateQuantity(String productKey, int qty) {
    setState(() {
      if (qty <= 0) {
        selectedProducts.remove(productKey);
      } else {
        selectedProducts[productKey]!['quantity'] = qty;
      }
      _saveCartToStorage();
    });
  }

  void _removeProduct(String productKey) {
    setState(() {
      selectedProducts.remove(productKey);
      _saveCartToStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      body: Stack(
        children: [
          _backgroundDecor(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 14),
                      _buildCategoriesRow(),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFA8161F)))
                      : filteredProducts.isEmpty
                      ? _buildEmpty()
                      : SingleChildScrollView(
                    padding:
                    const EdgeInsets.fromLTRB(20, 14, 20, 120),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(),
                      itemCount: filteredProducts.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.52,
                      ),
                      itemBuilder: (context, i) =>
                          _buildProductCard(filteredProducts[i]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: CustomBottomNavigation(
              currentIndex: 1,
              onTap: (index) {
                switch (index) {
                  case 0:
                  // Événements
                    Navigator.pushReplacementNamed(context, '/events', arguments: {
                      'token': widget.token,
                      'organizationId': widget.organizationId,
                    });
                    break;
                  case 1:
                  // Déjà sur Boutique
                    break;
                  case 2:
                  // Accueil
                    Navigator.pushReplacementNamed(context, '/acceuil',
                        arguments: {
                          'token': widget.token,
                          'organizationId': widget.organizationId,
                        });
                    break;
                  case 3:
                  // Profil
                    if (widget.token.isNotEmpty) {
                      Navigator.pushNamed(context, '/editProfile', arguments: {
                        'token': widget.token,
                        'toggleTheme': widget.toggleTheme,
                        'setLanguage': widget.toggleLanguage,
                        'isDarkMode': widget.isDarkMode,
                        'currentLocale': widget.currentLocale,
                      });
                    } else {
                      _showLoginDialog();
                    }
                    break;
                }
              },
              token: widget.token,
              organizationId: widget.organizationId,
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundDecor() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF4A0710),
                Color(0xFF23030A),
                Color(0xFF120104),
              ],
              stops: [0.0, 0.3, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -140,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 520,
              height: 520,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFC8172A).withOpacity(0.55),
                    const Color(0xFFC8172A).withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.62],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              'assets/logo1.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.shield, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Store',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              if (!isLoggedIn) {
                _showLoginDialog();
              } else {
                Navigator.pushNamed(context, '/mesCommandes',
                    arguments: {'token': widget.token});
              }
            },
            child: _glassIconButton(Icons.inventory_2_outlined),
          ),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  if (widget.token.isEmpty) {
                    _showLoginDialog();
                  } else {
                    _showCartSheet();
                  }
                },
                child: _glassIconButton(Icons.shopping_bag_outlined),
              ),
              if (_totalQty > 0)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$_totalQty',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFA8161F),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _glassIconButton(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildCategoriesRow() {
    final l10n = AppLocalizations.of(context)!;

    final chips = <Map<String, dynamic>>[
      {'id': 'tout', 'label': l10n.allCategories},
      ...categoryObjects.map((c) => {
        'id': (c['name'] as String).toLowerCase(),
        'label': c['name'] as String,
      }),
    ];

    final selected = chips.firstWhere(
          (c) => c['id'] == _activeCatId,
      orElse: () => chips.first,
    );

    return SizedBox(
      height: 44,
      child: GestureDetector(
        onTap: () => _showCategoryPicker(context, chips),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.category_outlined,
                color: Colors.white.withOpacity(0.7),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  selected['label'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker(
      BuildContext context, List<Map<String, dynamic>> chips) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF23030A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white.withOpacity(0.24),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    const Text(
                      'Choisir une catégorie',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(sheetCtx),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.08),
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: Colors.white.withOpacity(0.08)),
              Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: chips.length,
                  itemBuilder: (_, i) {
                    final chip = chips[i];
                    final isSelected = _activeCatId == chip['id'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _activeCatId = chip['id'] as String;
                          if (chip['id'] == 'tout') {
                            selectedCategoryId = null;
                          } else {
                            final c = categoryObjects.firstWhere(
                                  (c) =>
                              (c['name'] as String).toLowerCase() ==
                                  chip['id'],
                              orElse: () => {},
                            );
                            selectedCategoryId = c['id'];
                          }
                        });
                        Navigator.pop(sheetCtx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                chip['label'] as String,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.75),
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFFF5CD52),
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final l10n = AppLocalizations.of(context)!;
    final sizesData = List<Map<String, dynamic>>.from(product['sizes'] ?? []);
    final isOut = sizesData.isNotEmpty &&
        sizesData.every((s) => (s['available_qty'] ?? 0) == 0);
    final imageUrl = product['image'] as String?;

    return GestureDetector(
      onTap: () => _showProductDetails(product['id']),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(4),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            final total = loadingProgress.expectedTotalBytes;
                            final loaded = loadingProgress.cumulativeBytesLoaded;
                            final progress = (total != null && total > 0)
                                ? loaded / total
                                : null;
                            return Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: const Color(0xFFA8161F),
                                  value: progress,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/default_logo.png',
                            fit: BoxFit.cover,
                          ),
                        )
                            : Image.asset(
                          'assets/default_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (isOut)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          height: 20,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA8161F),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.outOfStock,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _truncateName(product['name']?.toString()),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product['price']} MAD',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: ElevatedButton(
                        onPressed: isOut
                            ? null
                            : () {
                          if (sizesData.length > 1) {
                            _showProductDetails(product['id']);
                          } else {
                            _addToCart(
                                product['id'],
                                sizesData.isNotEmpty
                                    ? sizesData.first['name']
                                    : 'M');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primary,
                          disabledBackgroundColor:
                          Colors.white.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                        ),
                        child: Text(
                          isOut ? l10n.outOfStock : l10n.addToCart,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
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
      ),
    );
  }

  Widget _buildEmpty() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.white38),
          const SizedBox(height: 16),
          Text(
            l10n.noProductsFound,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(int productId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final details = await fetchProductDetails(productId);
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => _ProductDetailsSheet(
          productDetails: details,
          onAddToCart: (String size, int qty) {
            if (!isLoggedIn) {
              Navigator.of(context).pop();
              _showLoginDialog();
              return;
            }
            for (var i = 0; i < qty; i++) {
              _addToCart(productId, size);
            }
            Navigator.of(context).pop();
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.errorLoadingProductDetails,
            style: const TextStyle(fontFamily: 'Inter')),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showCartSheet() {
    final l10n = AppLocalizations.of(context)!;
    if (selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.cartIsEmpty,
            style: const TextStyle(fontFamily: 'Inter', color: Colors.white)),
        backgroundColor: primary,
      ));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4A0710), Color(0xFF120104)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      _glassBackButton(() => Navigator.pop(context)),
                      const Spacer(),
                      Text(
                        '${l10n.cartTitle} · ${_totalQty} ${l10n.items}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: selectedProducts.entries.map((entry) {
                      final key = entry.key;
                      final data = entry.value;
                      final product = data['product'];
                      final qty = data['quantity'] as int;
                      final price = (data['price'] as num).toDouble();
                      final imgUrl = product['image'] as String?;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withOpacity(0.07),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.10)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: imgUrl != null && imgUrl.isNotEmpty
                                      ? Image.network(imgUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          Image.asset(
                                              'assets/default_logo.png',
                                              fit: BoxFit.contain))
                                      : Image.asset(
                                      'assets/default_logo.png',
                                      fit: BoxFit.contain),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['name'] ?? '',
                                              maxLines: 1,
                                              overflow:
                                              TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              'Taille ${data['size']}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white
                                                    .withOpacity(0.6),
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _removeProduct(key);
                                          setModal(() {});
                                        },
                                        child: Icon(
                                          Icons.delete_outline,
                                          color:
                                          Colors.white.withOpacity(0.6),
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${(price * qty).toStringAsFixed(0)} MAD',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      _qtyStepper(
                                        qty: qty,
                                        onMinus: () {
                                          _updateQuantity(key, qty - 1);
                                          setModal(() {});
                                        },
                                        onPlus: () {
                                          _updateQuantity(key, qty + 1);
                                          setModal(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.10)),
                        ),
                        child: Column(
                          children: [
                            _summaryLine(l10n.productsSubtotal,
                                '${productsTotal.toStringAsFixed(0)} MAD'),
                            const SizedBox(height: 8),
                            _summaryLine(l10n.deliveryFee,
                                '${deliveryFee.toStringAsFixed(0)} MAD'),
                            const SizedBox(height: 8),
                            Container(
                                height: 1,
                                color: Colors.white.withOpacity(0.10)),
                            const SizedBox(height: 8),
                            _summaryLine(
                              l10n.total,
                              '${totalAmount.toStringAsFixed(0)} MAD',
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showDeliveryForm();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.order,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _qtyStepper(
      {required int qty,
        required VoidCallback onMinus,
        required VoidCallback onPlus}) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onMinus,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: Colors.white.withOpacity(0.10),
              ),
              child: const Icon(Icons.remove, color: Colors.white, size: 14),
            ),
          ),
          SizedBox(
            width: 20,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
          ),
          GestureDetector(
            onTap: onPlus,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: Colors.white.withOpacity(0.10),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryLine(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            color: bold ? Colors.white : Colors.white.withOpacity(0.72),
            fontFamily: 'Inter',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 20 : 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: Colors.white,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _glassBackButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }

  void _showDeliveryForm() {
    final l10n = AppLocalizations.of(context)!;
    _loadUserInfoFromPrefs(_fullNameController, phoneController);
    String paymentMethod = 'wallet';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) {
          return Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: const Color(0xFF170205),
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4A0710),
                    Color(0xFF23030A),
                    Color(0xFF120104)
                  ],
                  stops: [0.0, 0.3, 1.0],
                ),
              ),
              child: SafeArea(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Row(
                          children: [
                            _glassBackButton(() => Navigator.pop(context)),
                            const Spacer(),
                            Text(
                              l10n.deliveryAndPayment,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 44),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.deliveryAddress,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.86),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _darkInput(
                                      controller: _fullNameController,
                                      label: l10n.fullNameHint,
                                      hint: l10n.fullNameHint,
                                      errorText: fullNameError,
                                      onChanged: (v) {
                                        setModal(() {
                                          customerName = v.trim();
                                          fullNameError =
                                              validateFullName(v, l10n);
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _darkInput(
                                      controller: phoneController,
                                      label: l10n.phoneHint,
                                      hint: l10n.phoneHint,
                                      keyboardType: TextInputType.phone,
                                      errorText: phoneError,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      onChanged: (v) {
                                        setModal(() {
                                          phoneTouched = true;
                                          phoneError =
                                              validatePhoneNumber(v, l10n);
                                        });
                                        formatPhoneNumber(v);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _darkInput(
                                controller: _addressController,
                                label: l10n.fullAddress,
                                hint: l10n.addressHint,
                                errorText: addressError,
                                onChanged: (v) {
                                  setModal(() {
                                    customerAddress = v;
                                    addressError =
                                        validateAddress(v, l10n);
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${l10n.estimatedDelivery}: ${isCasablancaDelivery ? "1-2" : "3-5"} ${l10n.days} · ${deliveryFee.toStringAsFixed(0)} MAD',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.6),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                l10n.payWith,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.86),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 10),
                              _paymentTile(
                                icon: Icons.account_balance_wallet,
                                title: 'Wydad Pay',
                                subtitle: '${l10n.balance}: 1 250,00 MAD',
                                selected: paymentMethod == 'wallet',
                                highlightSub: true,
                                onTap: () => setModal(
                                        () => paymentMethod = 'wallet'),
                              ),
                              const SizedBox(height: 8),
                              _paymentTile(
                                icon: Icons.credit_card,
                                title: l10n.bankCard,
                                subtitle: 'Visa, Mastercard · 3D Secure',
                                selected: paymentMethod == 'card',
                                onTap: () =>
                                    setModal(() => paymentMethod = 'card'),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.totalInclDelivery,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.72),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  Text(
                                    '${totalAmount.toStringAsFixed(0)} MAD',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: isCreatingOrder
                                      ? null
                                      : () {
                                    if (_formKey.currentState!
                                        .validate()) {
                                      Navigator.pop(context);
                                      _createOrder();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isCreatingOrder
                                      ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      valueColor:
                                      AlwaysStoppedAnimation(
                                          primary),
                                    ),
                                  )
                                      : Text(
                                    l10n.payOrder,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _darkInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    Iterable<String>? autofillHints,
    String? errorText,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.72),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          cursorColor: Colors.white,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontFamily: 'Inter',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
              fontFamily: 'Inter',
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            isDense: true,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            errorText: errorText,
            errorStyle: const TextStyle(
              fontSize: 11,
              color: Color(0xFFE5484D),
              fontFamily: 'Inter',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: Colors.white.withOpacity(0.6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _paymentTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
    bool highlightSub = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? Colors.white.withOpacity(0.10)
              : Colors.white.withOpacity(0.04),
          border: Border.all(
            color: selected
                ? Colors.white
                : Colors.white.withOpacity(0.12),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD11A2A), Color(0xFF6E0B12)],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: highlightSub
                          ? const Color(0xFFF5CD52)
                          : Colors.white.withOpacity(0.6),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: Colors.white, width: 7)
                    : Border.all(
                    color: Colors.white.withOpacity(0.35), width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createOrder() async {
    setState(() => isCreatingOrder = true);
    try {
      final availabilityData = await checkProductAvailability();
      final list = List<Map<String, dynamic>>.from(
          availabilityData['data'] ?? []);
      final outOfStock = <Map<String, dynamic>>[];

      selectedProducts.forEach((key, data) {
        final pid = data['productId'];
        final sid = data['size_id'];
        if (pid == null || sid == null) return;
        final item = list.firstWhere(
              (i) => i['product_id'] == pid && i['size_id'] == sid,
          orElse: () => {},
        );
        if (item.isNotEmpty) {
          final selQty = (data['quantity'] as int?) ?? 0;
          final availQty = (item['available_quantity'] as int?) ?? 0;
          if (selQty > availQty) {
            outOfStock.add({
              'product_name': item['product_name'] ?? 'Inconnu',
              'size_name': item['size_name'] ?? 'Inconnu',
              'message':
              'Quantité demandée ($selQty) > stock ($availQty)',
            });
          }
        } else {
          outOfStock.add({
            'product_name': data['product']?['name'] ?? 'Inconnu',
            'size_name': data['size'] ?? 'Inconnu',
            'message': 'Produit non disponible',
          });
        }
      });

      if (outOfStock.isNotEmpty) {
        setState(() => isCreatingOrder = false);
        _showOutOfStockModal(outOfStock);
        return;
      }

      final items = <Map<String, dynamic>>[];
      selectedProducts.forEach((key, data) {
        final pid = data['productId'];
        final sid = data['size_id'];
        final qty = data['quantity'];
        if (pid != null && sid != null && qty != null) {
          items.add({
            'product_id': pid as int,
            'size_id': sid as int,
            'quantity': qty as int,
          });
        }
      });

      if (items.isEmpty) throw Exception('Panier invalide');

      final body = {
        'items': items,
        'delivery_type': isCasablancaDelivery ? 1 : 2,
        'customer_name': customerName,
        'customer_phone': '0' + customerPhone.replaceAll(' ', ''),
        'customer_address': customerAddress,
      };

      final res = await http.post(
        Uri.parse('https://ticketing.ma/api/customer/store/orders'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = json.decode(res.body);
        final orderId = data['data']['order_id'];
        if (mounted) {
          Navigator.of(context).popUntil((r) => r.isFirst);
          _navigateToCMIPayment(orderId);
        }
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      _showErrorDialog('Erreur: $e');
    } finally {
      if (mounted) setState(() => isCreatingOrder = false);
    }
  }

  void _navigateToCMIPayment(int orderId) {
    final orderData = {
      'token': widget.token,
      'organizationId': widget.organizationId,
      'order': {
        'order_id': orderId,
        'order_number':
        'BOUTIQUE-${DateTime.now().millisecondsSinceEpoch}',
      },
      'eventId': null,
      'products': selectedProducts.entries.map((e) {
        final p = e.value['product'];
        return {
          'id': e.value['productId'],
          'name': p['name'],
          'price': (p['price'] as int?) ?? 0,
          'quantity': e.value['quantity'],
          'size': e.value['size'],
        };
      }).toList(),
    };

    Navigator.pushNamed(
      context,
      '/cmiPaymentBoutique',
      arguments: {'amount': totalAmount, 'orderData': orderData},
    );
  }

  Future<Map<String, dynamic>> checkProductAvailability() async {
    final list = selectedProducts.entries
        .map((e) => {
      'product_id': e.value['productId'],
      'size_id': e.value['size_id'],
    })
        .toList();
    final res = await http.post(
      Uri.parse('https://ticketing.ma/api/customer/store/check-availability'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({'products': list}),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data is Map<String, dynamic> ? data : {'out_of_stock': []};
    }
    throw Exception('Failed check availability');
  }

  void _showOutOfStockModal(List<Map<String, dynamic>> list) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF07060F),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.unavailableProducts,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...list.map((p) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                  Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${p['product_name']} - ${p['size_name']}\n${p['message']}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    l10n.close,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA8161F),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String msg) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.error, style: const TextStyle(fontFamily: 'Inter')),
        content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok, style: const TextStyle(fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    size: 28, color: Color(0xFFA8161F)),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.loginRequired,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.loginToAccess,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    l10n.login,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
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

// ─────────────────────────────────────────────────────────────
// FICHE PRODUIT
// ─────────────────────────────────────────────────────────────
class _ProductDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> productDetails;
  final Function(String size, int qty) onAddToCart;

  const _ProductDetailsSheet(
      {required this.productDetails, required this.onAddToCart});

  @override
  State<_ProductDetailsSheet> createState() => _ProductDetailsSheetState();
}

class _ProductDetailsSheetState extends State<_ProductDetailsSheet> {
  int _qty = 1;
  String? _selectedSize;
  int _imgIdx = 0;
  late PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    final sizes =
    List<Map<String, dynamic>>.from(widget.productDetails['sizes'] ?? []);
    if (sizes.isNotEmpty) _selectedSize = sizes.first['name'];
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = widget.productDetails;
    final images = List<Map<String, dynamic>>.from(p['images'] ?? []);
    final sizes = List<Map<String, dynamic>>.from(p['sizes'] ?? []);
    final allImages = images.isNotEmpty
        ? images.map((i) => i['image'] as String).toList()
        : [p['image']];

    return Container(
      constraints:
      BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      decoration: const BoxDecoration(
        color: Color(0xFF07060F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 280,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageCtrl,
                          itemCount: allImages.length,
                          onPageChanged: (i) => setState(() => _imgIdx = i),
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.network(
                                    allImages[i],
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 32,
                                          height: 32,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: Color(0xFFA8161F),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) =>
                                        Image.asset(
                                          'assets/default_logo.png',
                                          fit: BoxFit.contain,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 24,
                          right: 24,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black.withOpacity(0.4),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MAILLOTS · OFFICIEL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                            color: Colors.white.withOpacity(0.6),
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                p['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  height: 1.2,
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${p['price']} MAD',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (sizes.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.size,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              Text(
                                l10n.sizeGuide,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.72),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: sizes.map((s) {
                              final name = s['name'] as String;
                              final available = (s['available_qty'] ?? 0) > 0;
                              final selected = _selectedSize == name;
                              return GestureDetector(
                                onTap: available
                                    ? () =>
                                    setState(() => _selectedSize = name)
                                    : null,
                                child: Container(
                                  width: (MediaQuery.of(context).size.width -
                                      40 -
                                      5 * 8) /
                                      6,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: selected
                                        ? Colors.white.withOpacity(0.18)
                                        : Colors.white.withOpacity(0.06),
                                    border: Border.all(
                                      color: selected
                                          ? Colors.white.withOpacity(0.45)
                                          : Colors.white.withOpacity(0.16),
                                    ),
                                  ),
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: available
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.35),
                                      decoration: available
                                          ? null
                                          : TextDecoration.lineThrough,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.quantity,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                            Container(
                              height: 44,
                              padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withOpacity(0.06),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.14)),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(
                                            () => _qty = (_qty - 1).clamp(1, 5)),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(9),
                                        color:
                                        Colors.white.withOpacity(0.10),
                                      ),
                                      child: const Icon(Icons.remove,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      '$_qty',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(
                                            () => _qty = (_qty + 1).clamp(1, 5)),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(9),
                                        color:
                                        Colors.white.withOpacity(0.10),
                                      ),
                                      child: const Icon(Icons.add,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        if (p['description'] != null) ...[
                          Text(
                            p['description'],
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.55,
                              color: Colors.white.withOpacity(0.72),
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            Icon(Icons.local_shipping_outlined,
                                color: Colors.white.withOpacity(0.72),
                                size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.deliveryHomeMorocco,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.72),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF07060F),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _selectedSize == null
                    ? null
                    : () => widget.onAddToCart(_selectedSize!, _qty),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFA8161F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.addToCart,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}