import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'l10n/app_localizations.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;
  final String token;

  ProductDetailsPage({required this.productId, required this.token});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Map<String, dynamic>? productDetails;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    final l10n = AppLocalizations.of(context);
    try {
      final response = await http.get(
        Uri.parse(
            'https://ticketing.ma/api/customer/store/products/${widget.productId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          productDetails = data['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = l10n?.failedToLoadProductDetails ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '${l10n?.error ?? ''}: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.productDetails,
          style: TextStyle(
            fontFamily: "Urbanist",
            fontWeight: FontWeight.bold,
            color: Color(0xFFE41E26),
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 2,
        iconTheme: IconThemeData(color: Color(0xFFE41E26)),
      ),
      backgroundColor: isDarkMode ? Colors.black : Color(0xFFF7F9FC),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor:
          AlwaysStoppedAnimation<Color>(Color(0xFFE41E26)),
        ),
      )
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: TextStyle(
            fontFamily: "Urbanist",
            color: Colors.red,
          ),
        ),
      )
          : productDetails == null
          ? Center(
        child: Text(
          l10n.productNotFound,
          style: TextStyle(
            fontFamily: "Urbanist",
            color: isDarkMode
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    productDetails!['image'],
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                        Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag,
                              size: 100,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              l10n.productImage,
                              style: TextStyle(
                                fontFamily: "Urbanist",
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Product Name
            Text(
              productDetails!['name'],
              style: TextStyle(
                fontFamily: "Urbanist",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? Colors.white
                    : Color(0xFF030836),
              ),
            ),
            SizedBox(height: 8),

            // Product Price
            Text(
              '${productDetails!['price']} MAD',
              style: TextStyle(
                fontFamily: "Urbanist",
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE41E26),
              ),
            ),
            SizedBox(height: 16),

            // Product Description
            Text(
              l10n.description,
              style: TextStyle(
                fontFamily: "Urbanist",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE41E26),
              ),
            ),
            SizedBox(height: 8),
            Text(
              productDetails!['description'] ??
                  l10n.noDescriptionAvailable,
              style: TextStyle(
                fontFamily: "Urbanist",
                fontSize: 16,
                color: isDarkMode
                    ? Colors.grey[400]
                    : Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),

            // Sizes
            if (productDetails!['sizes'] != null &&
                (productDetails!['sizes'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.availableSizes,
                    style: TextStyle(
                      fontFamily: "Urbanist",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE41E26),
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (productDetails!['sizes'] as List)
                        .map<Widget>((sizeMap) {
                      final sizeData =
                      sizeMap as Map<String, dynamic>;
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey[800]
                              : Color(0xFFF5F6FA),
                          borderRadius:
                          BorderRadius.circular(20),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey[600]!
                                : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          sizeData['name'],
                          style: TextStyle(
                            fontFamily: "Urbanist",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

            // Categories
            if (productDetails!['categories'] != null &&
                (productDetails!['categories'] as List)
                    .isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text(
                    l10n.categories,
                    style: TextStyle(
                      fontFamily: "Urbanist",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE41E26),
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                    (productDetails!['categories'] as List)
                        .map<Widget>((categoryMap) {
                      final categoryData =
                      categoryMap as Map<String, dynamic>;
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFFE41E26)
                              .withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFFE41E26)
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          categoryData['name'],
                          style: TextStyle(
                            fontFamily: "Urbanist",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE41E26),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}