import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme.dart';
import '../data/app_state.dart';
import '../widgets/app_bottom_nav.dart';
import 'product_details.dart';

class Products extends StatefulWidget {
  final String initialSearch;

  const Products({super.key, this.initialSearch = ''});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  late TextEditingController searchController;

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> products = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: widget.initialSearch);
    loadFirestoreProducts();
  }

  Future<void> loadFirestoreProducts() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      allProducts = snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'price': data['price'] ?? 0,
          'category': data['category'] ?? '',
          'description': data['description'] ?? '',
          'images': List<String>.from(data['images'] ?? []),
          'color': data['color'] ?? 'Default',
          'rating': data['rating'] ?? 4.5,
          'sizes': List<String>.from(data['sizes'] ?? ['S', 'M', 'L', 'XL']),
        };
      }).toList();

      search(widget.initialSearch);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firestore error: $e')),
      );
    }
  }

  void search(String value) {
    final query = value.toLowerCase();

    setState(() {
      products = allProducts.where((item) {
        final name = item['name'].toString().toLowerCase();
        final category = item['category'].toString().toLowerCase();

        return name.contains(query) || category.contains(query);
      }).toList();
    });
  }

  void goBackOrHome() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  void toggleWishlist(Map<String, dynamic> item) {
    final bool liked = AppState.likedProducts.contains(item['name']);

    setState(() {
      if (liked) {
        AppState.likedProducts.remove(item['name']);
      } else {
        AppState.likedProducts.add(item['name'] as String);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          liked
              ? '${item['name']} removed from wishlist'
              : '${item['name']} added to wishlist',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget productImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => brokenImageBox(),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => brokenImageBox(),
    );
  }

  Widget brokenImageBox() {
    return Container(
      color: context.secondaryBgColor,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  Widget productCard(Map<String, dynamic> item) {
    final bool liked = AppState.likedProducts.contains(item['name']);
    final List images = item['images'] as List;
    final String imagePath = images.isNotEmpty ? images[0].toString() : '';

    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetails(product: item),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: productImage(imagePath),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => toggleWishlist(item),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: liked ? Colors.red : context.iconColor,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: GestureDetector(
                      onTap: () async {
                        await AppState.addToCart(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item['name']} added to cart'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                        setState(() {});
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2EA7FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: context.cardColor,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
              child: Text(
                item['name'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Text(
                AppState.formatMoney(item['price'] as num),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1450F0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      appBar: AppBar(
        backgroundColor: context.bgColor,
        foregroundColor: context.textColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBackOrHome,
        ),
        title: const Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: search,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: context.inputFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(color: context.textColor),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return productCard(products[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}