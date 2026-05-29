import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/app_state.dart';
import '../widgets/app_bottom_nav.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  void initState() {
    super.initState();
    AppState.enterCartMode();
  }

  Widget qtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1450F0), width: 2),
          color: context.cardColor,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF1450F0),
          size: 18,
        ),
      ),
    );
  }

  Widget cartItem(Map<String, dynamic> item, int i) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: context.secondaryBgColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    item['images'][0],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                bottom: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      AppState.removeItem(i);
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFD96B6B),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['color']}, Size ${item['selectedSize']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.subTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['qty'] > 0
                        ? AppState.formatMoney((item['price'] as int) * (item['qty'] as int))
                        : AppState.formatMoney(0),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      qtyButton(
                        icon: Icons.remove,
                        onTap: () {
                          setState(() {
                            AppState.decreaseQty(i);
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${item['qty']}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      qtyButton(
                        icon: Icons.add,
                        onTap: () {
                          setState(() {
                            AppState.increaseQty(i);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget wishlistItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: context.secondaryBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    item['images'][0],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                ),
              ),
              Positioned(
                left: 6,
                bottom: 6,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      AppState.removeFromWishlist(item['name'] as String);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item['name']} removed from wishlist'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFD96B6B),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['description'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.subTextColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppState.formatMoney(item['price']),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await AppState.addToCart(item);
                        setState(() {
                          AppState.addToCart(item);
                          AppState.removeFromWishlist(item['name'] as String);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item['name']} added to cart'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1450F0),
                        ),
                        child: Icon(
                          Icons.add,
                          color: context.cardColor,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = AppState.wishlistItems;
    final hasCartItems = AppState.cart.isNotEmpty;

    return Scaffold(
      backgroundColor: context.bgColor,
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        foregroundColor: context.textColor,
        centerTitle: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Text(
              'Cart',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF1450F0),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${AppState.cartCount}',
                style: TextStyle(
                  color: context.cardColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Column(
          key: ValueKey('${hasCartItems}_${wishlist.length}_${AppState.cart.length}'),
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!hasCartItems)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 18),
                        child: Center(
                          child: Text(
                            'Cart is empty',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    if (hasCartItems)
                      ...List.generate(
                        AppState.cart.length,
                        (i) => cartItem(AppState.cart[i], i),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      'From Your Wishlist',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (wishlist.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 28,
                        ),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 44,
                              color: Color(0xFF1450F0),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No items in wishlist',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.textColor,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Items you like will appear here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.subTextColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (wishlist.isNotEmpty)
                      ...wishlist.map((item) => wishlistItem(item)),
                  ],
                ),
              ),
            ),
            if (hasCartItems)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      color: Color(0x14000000),
                      offset: Offset(0, -2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total ${AppState.formatMoney(AppState.cartScreenTotal)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: context.textColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 145,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: AppState.hasCheckoutItems
                            ? () {
                                Navigator.pushNamed(context, '/checkout');
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1450F0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}