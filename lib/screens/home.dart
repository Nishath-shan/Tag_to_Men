import 'dart:io';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../data/app_state.dart';
import 'products.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
   

  
    



    // TEMPORARY: Run once to upload products to Firestore
    
  }

  void openProducts(BuildContext context, [String query = '']) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Products(initialSearch: query),
      ),
    );
  }

  Widget categoryItem(BuildContext context, String title, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          openProducts(context, title);
        },
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: context.highlightBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1450F0),
                size: 30,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: context.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget productCard(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        openProducts(context, product['name']);
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    product['images'][0],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF1F5FF),
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product['name'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              Text(
                AppState.formatMoney(product['price'] as num),
                style: const TextStyle(
                  color: Color(0xFF1450F0),
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (AppState.imagePath.isNotEmpty) {
      image = FileImage(File(AppState.imagePath));
    }

    final popularTop = AppState.products.take(4).toList();
    final popularBottom = AppState.products.skip(4).take(4).toList();

    return Scaffold(
      backgroundColor: context.bgColor,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: image,
                    backgroundColor: context.cardColor,
                    child: image == null
                        ? const Icon(
                            Icons.person,
                            color: Color(0xFF1450F0),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Welcome ${AppState.userName.isEmpty ? "User" : AppState.userName}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                onSubmitted: (value) {
                  openProducts(context, value);
                },
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: context.inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1450F0),
                      Color(0xFF2EA7FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "New Collection",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: context.cardColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Discover stylish outfits",
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.cardColor,
                                foregroundColor: const Color(0xFF1450F0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                openProducts(context);
                              },
                              child: const Text(
                                "Shop Now",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 90,
                      height: 100,
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          AppState.products[0]['images'][0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  categoryItem(context, "Shirt", Icons.checkroom),
                  categoryItem(context, "Jacket", Icons.dry_cleaning),
                  categoryItem(context, "Pant", Icons.shopping_bag),
                  categoryItem(context, "Shoes", Icons.hiking),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Popular",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      openProducts(context);
                    },
                    child: const Text(
                      "See All",
                      style: TextStyle(
                        color: Color(0xFF1450F0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularTop.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: productCard(context, popularTop[i]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularBottom.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: productCard(context, popularBottom[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}