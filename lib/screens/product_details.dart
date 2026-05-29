import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/app_state.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late int selectedSizeIndex;
  late int selectedImageIndex;
  bool liked = false;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    selectedSizeIndex = 0;
    selectedImageIndex = 0;
    liked = AppState.likedProducts.contains(widget.product['name']);
  }

  void showImagePopup(int initialIndex) {
    final List images = widget.product['images'] as List;
    final PageController pageController = PageController(initialPage: initialIndex);
    int currentIndex = initialIndex;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          void goPrevious() {
            if (currentIndex > 0) {
              currentIndex--;
              pageController.animateToPage(
                currentIndex,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
              setDialogState(() {});
            }
          }

          void goNext() {
            if (currentIndex < images.length - 1) {
              currentIndex++;
              pageController.animateToPage(
                currentIndex,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
              setDialogState(() {});
            }
          }

          return Dialog(
            backgroundColor: context.bgColor,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              height: 430,
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: PageView.builder(
                            controller: pageController,
                            itemCount: images.length,
                            onPageChanged: (index) {
                              currentIndex = index;
                              setDialogState(() {});
                            },
                            itemBuilder: (context, index) {
                              return Image.asset(
                                images[index],
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image, size: 50),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          left: 8,
                          child: GestureDetector(
                            onTap: goPrevious,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_left,
                                size: 28,
                                color: Color(0xFF1450F0),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          child: GestureDetector(
                            onTap: goNext,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                size: 28,
                                color: Color(0xFF1450F0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${currentIndex + 1} / ${images.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 56,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final selected = currentIndex == index;
                        return GestureDetector(
                          onTap: () {
                            currentIndex = index;
                            pageController.jumpToPage(index);
                            setDialogState(() {});
                          },
                          child: Container(
                            width: 52,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: context.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF1450F0)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void addSelectedToCart() {
    final product = widget.product;
    final selectedSize = (product['sizes'] as List)[selectedSizeIndex];

    final index = AppState.cart.indexWhere(
      (item) =>
          item['name'] == product['name'] &&
          item['selectedSize'] == selectedSize,
    );

    if (index != -1) {
      AppState.cart[index]['qty'] =
          (AppState.cart[index]['qty'] as int) + quantity;
      AppState.cart[index]['selected'] = true;
    } else {
      AppState.cart.add({
        ...product,
        'qty': quantity,
        'selected': true,
        'selectedSize': selectedSize,
      });
    }
  }

  void buyNow() {
    final product = widget.product;
    final selectedSize = (product['sizes'] as List)[selectedSizeIndex];

    AppState.addSingleBuyNowItem(
      product,
      qty: quantity,
      selectedSize: selectedSize,
    );

    Navigator.pushNamed(context, '/checkout');
  }

  void toggleWishlist() {
    setState(() {
      liked = !liked;
      if (liked) {
        AppState.likedProducts.add(widget.product['name'] as String);
      } else {
        AppState.likedProducts.remove(widget.product['name']);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          liked
              ? '${widget.product['name']} added to wishlist'
              : '${widget.product['name']} removed from wishlist',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final List sizes = product['sizes'] as List;
    final List images = product['images'] as List;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text(
          "Product Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: context.bgColor,
        foregroundColor: context.textColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              color: liked ? Colors.red : const Color(0xFF1450F0),
            ),
            onPressed: toggleWishlist,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    images[selectedImageIndex],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image, size: 52)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final selected = selectedImageIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImageIndex = index;
                        });
                        showImagePopup(index);
                      },
                      child: Container(
                        width: 64,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF1450F0)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                product['category'],
                style: const TextStyle(
                  color: Color(0xFF1450F0),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product['name'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFF1450F0), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    "${product['rating']}",
                    style: TextStyle(
                      color: context.subTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppState.formatMoney(product['price']),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1450F0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                "Product Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product['description'],
                style: TextStyle(
                  color: context.subTextColor,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Size",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(
                  sizes.length,
                  (index) {
                    final selected = index == selectedSizeIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSizeIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF1450F0)
                              : context.cardColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          sizes[index],
                          style: TextStyle(
                            color: selected ? Colors.white : context.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Color: ${product['color']}",
                style: TextStyle(
                  color: context.subTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Quantity",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (quantity > 1) {
                        setState(() {
                          quantity--;
                        });
                      }
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1450F0),
                          width: 2,
                        ),
                        color: context.cardColor,
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: Color(0xFF1450F0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 18),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        quantity++;
                      });
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1450F0),
                      ),
                      child: Icon(
                        Icons.add,
                        color: context.cardColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.cardColor,
                          foregroundColor: const Color(0xFF1450F0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(color: Color(0xFF1450F0)),
                          ),
                        ),
                        onPressed: () {
                          addSelectedToCart();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Added to cart")),
                          );
                        },
                        child: const Text(
                          "Add to Cart",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1450F0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: buyNow,
                        child: const Text(
                          "Buy Now",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}