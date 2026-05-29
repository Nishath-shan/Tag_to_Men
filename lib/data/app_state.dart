import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppState {
  static bool isLoggedIn = false;
  static String userName = 'User';
  static String phone = '';
  static String email = '';
  static String password = '';
  static String imagePath = '';
  static String language = 'English';
  static String address = '';
  static String paymentMethod = 'Card';

  static final Set<String> likedProducts = {};
  static final List<Map<String, dynamic>> cart = [];

  static bool isBuyNowMode = false;
  static final List<Map<String, dynamic>> buyNowItems = [];

  static Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();

    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    userName = prefs.getString('userName') ?? 'User';
    phone = prefs.getString('phone') ?? '';
    email = prefs.getString('email') ?? '';
    password = prefs.getString('password') ?? '';
    imagePath = prefs.getString('imagePath') ?? '';
    language = prefs.getString('language') ?? 'English';
    address = prefs.getString('address') ?? '';
    paymentMethod = prefs.getString('paymentMethod') ?? 'Card';

    final likedList = prefs.getStringList('likedProducts') ?? [];
    likedProducts.clear();
    likedProducts.addAll(likedList);

    await loadCart();
  }

  static Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', isLoggedIn);
    await prefs.setString('userName', userName);
    await prefs.setString('phone', phone);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setString('imagePath', imagePath);
    await prefs.setString('language', language);
    await prefs.setString('address', address);
    await prefs.setString('paymentMethod', paymentMethod);
    await prefs.setStringList('likedProducts', likedProducts.toList());
  }

  static Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = jsonEncode(cart);
    await prefs.setString('cartItems', cartString);
  }

  static Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cartItems');

    if (cartString == null || cartString.isEmpty) return;

    final List decoded = jsonDecode(cartString);

    cart.clear();
    cart.addAll(
      decoded.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList(),
    );
  }

  static Future<void> saveUserProfileToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': userName,
      'email': email.isEmpty ? user.email : email,
      'phone': phone,
      'imagePath': imagePath,
      'language': language,
      'address': address,
      'paymentMethod': paymentMethod,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> loadUserProfileFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!doc.exists) return;

    final data = doc.data()!;

    userName = data['name'] ?? userName;
    email = data['email'] ?? email;
    phone = data['phone'] ?? phone;
    imagePath = data['imagePath'] ?? imagePath;
    language = data['language'] ?? language;
    address = data['address'] ?? address;
    paymentMethod = data['paymentMethod'] ?? paymentMethod;

    await saveState();
  }

  static Future<void> uploadProductsToFirestoreDisabled() async {
    final firestore = FirebaseFirestore.instance;

    for (var product in products) {
      final docId = product['name']
          .toString()
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll('-', '_');

      await firestore.collection('products').doc(docId).set({
        'name': product['name'],
        'price': product['price'],
        'category': product['category'],
        'description': product['description'],
        'images': product['images'],
        'color': product['color'],
        'rating': product['rating'],
        'sizes': product['sizes'],
      });
    }
  }

  static Map<String, dynamic> makeProduct({
    required String name,
    required int price,
    required String category,
    required String color,
    required double rating,
    required String description,
    required List<String> sizes,
    required String folder,
  }) {
    return {
      'name': name,
      'price': price,
      'category': category,
      'color': color,
      'rating': rating,
      'description': description,
      'sizes': sizes,
      'images': [
        'assets/images/items/$folder/img1.jpg',
        'assets/images/items/$folder/img2.jpg',
        'assets/images/items/$folder/img3.jpg',
        'assets/images/items/$folder/img4.jpg',
        'assets/images/items/$folder/img5.jpg',
      ],
    };
  }

  static final List<Map<String, dynamic>> products = [
    makeProduct(name: 'Beige Jacket', price: 11500, category: 'Jacket', color: 'Beige', rating: 4.6, description: 'Elegant beige jacket with a premium finish and stylish casual look.', sizes: ['M', 'L', 'XL'], folder: 'Beige_Jacket'),
    makeProduct(name: 'Black Formal Suit', price: 18500, category: 'Suit', color: 'Black', rating: 4.9, description: 'Elegant black formal suit for office, business meetings, and special occasions.', sizes: ['M', 'L', 'XL'], folder: 'Black_Formal_Suit'),
    makeProduct(name: 'Black Hoodie', price: 6200, category: 'Hoodie', color: 'Black', rating: 4.6, description: 'Warm black hoodie with a simple premium style for everyday wear.', sizes: ['S', 'M', 'L'], folder: 'Black_Hoodie'),
    makeProduct(name: 'Black T-Shirt', price: 2500, category: 'T-Shirt', color: 'Black', rating: 4.4, description: 'Simple black t-shirt with a clean premium design.', sizes: ['S', 'M', 'L', 'XL'], folder: 'Black_T_Shirt'),
    makeProduct(name: 'Blue Denim Jacket', price: 9500, category: 'Jacket', color: 'Blue', rating: 4.6, description: 'Classic blue denim jacket with a casual trendy finish.', sizes: ['M', 'L', 'XL'], folder: 'Blue_Denim_Jacket'),
    makeProduct(name: 'Brown Formal Shoes', price: 14000, category: 'Shoes', color: 'Brown', rating: 4.8, description: 'Classic brown formal shoes with a polished and elegant finish.', sizes: ['40', '41', '42', '43'], folder: 'Brown_Formal_Shoes'),
    makeProduct(name: 'Brown Leather Jacket', price: 12500, category: 'Jacket', color: 'Brown', rating: 4.8, description: 'Premium brown leather jacket with a strong modern style.', sizes: ['S', 'M', 'L', 'XL'], folder: 'Brown_Leather_Jacket'),
    makeProduct(name: 'Casual Shorts', price: 4000, category: 'Pant', color: 'Grey', rating: 4.3, description: 'Comfortable casual shorts for relaxed daily wear.', sizes: ['S', 'M', 'L'], folder: 'Casual_Shorts'),
    makeProduct(name: 'Casual Sneakers', price: 9000, category: 'Shoes', color: 'White', rating: 4.7, description: 'Lightweight casual sneakers for a stylish everyday look.', sizes: ['40', '41', '42'], folder: 'Casual_Sneakers'),
    makeProduct(name: 'Checked Shirt', price: 4800, category: 'Shirt', color: 'Red', rating: 4.4, description: 'Casual checked shirt with a smart relaxed fit.', sizes: ['S', 'M', 'L'], folder: 'Checked_Shirt'),
    makeProduct(name: 'Digital Watch', price: 8500, category: 'Watch', color: 'Black', rating: 4.6, description: 'Modern digital watch with a sporty and smart design.', sizes: ['Free'], folder: 'Digital_Watch'),
    makeProduct(name: 'Formal Trousers', price: 7000, category: 'Pant', color: 'Black', rating: 4.5, description: 'Formal trousers with a clean professional look.', sizes: ['30', '32', '34'], folder: 'Formal_Trousers'),
    makeProduct(name: 'Grey Hoodie', price: 6000, category: 'Hoodie', color: 'Grey', rating: 4.7, description: 'Comfortable grey hoodie made for casual wear.', sizes: ['S', 'M', 'L', 'XL'], folder: 'Grey_Hoodie'),
    makeProduct(name: 'Linen Shirt', price: 5200, category: 'Shirt', color: 'White', rating: 4.5, description: 'Breathable linen shirt for a clean stylish look.', sizes: ['S', 'M', 'L'], folder: 'Linen_Shirt'),
    makeProduct(name: 'Luxury Watch', price: 15000, category: 'Watch', color: 'Brown', rating: 4.9, description: 'Luxury watch with a classy premium appearance.', sizes: ['Free'], folder: 'Luxury_Watch'),
    makeProduct(name: 'Navy Blue Shirt', price: 5200, category: 'Shirt', color: 'Blue', rating: 4.5, description: 'Slim-fit navy blue shirt with a modern finish.', sizes: ['S', 'M', 'L', 'XL'], folder: 'Navy_Blue_Shirt'),
    makeProduct(name: 'Olive Green Jacket', price: 11000, category: 'Jacket', color: 'Green', rating: 4.6, description: 'Trendy olive green jacket with a casual premium touch.', sizes: ['M', 'L', 'XL'], folder: 'Olive_Green_Jacket'),makeProduct(name: 'Oversized Hoodie', price: 6500, category: 'Hoodie', color: 'Grey', rating: 4.6, description: 'Oversized hoodie made for relaxed comfort and fashion.', sizes: ['M', 'L', 'XL'], folder: 'Oversized_Hoodie'),
    makeProduct(name: 'Printed T-Shirt', price: 3000, category: 'T-Shirt', color: 'White', rating: 4.3, description: 'Printed t-shirt with a trendy casual look.', sizes: ['S', 'M', 'L'], folder: 'Printed_T_Shirt'),
    makeProduct(name: 'Running Shoes', price: 10000, category: 'Shoes', color: 'Black', rating: 4.7, description: 'Running shoes with sporty support and daily comfort.', sizes: ['40', '41', '42'], folder: 'Running_Shoes'),
    makeProduct(name: 'Slim Fit Jeans', price: 7500, category: 'Pant', color: 'Blue', rating: 4.5, description: 'Slim fit jeans for a sharp everyday style.', sizes: ['30', '32', '34'], folder: 'Slim_Fit_Jeans'),
    makeProduct(name: 'Smart Wrist Watch', price: 9800, category: 'Watch', color: 'Black', rating: 4.7, description: 'Smart wrist watch with a modern premium style.', sizes: ['Free'], folder: 'Smart_Wrist_Watch'),
    makeProduct(name: 'Sports T-Shirt', price: 2800, category: 'T-Shirt', color: 'Blue', rating: 4.3, description: 'Breathable sports t-shirt for active and casual use.', sizes: ['S', 'M', 'L'], folder: 'Sports_T_Shirt'),
    makeProduct(name: 'White Casual Shirt', price: 4500, category: 'Shirt', color: 'White', rating: 4.5, description: 'Soft cotton white casual shirt for everyday style.', sizes: ['S', 'M', 'L', 'XL'], folder: 'White_Casual_Shirt'),
    makeProduct(name: 'Winter Jacket', price: 13500, category: 'Jacket', color: 'Brown', rating: 4.8, description: 'Warm winter jacket with a premium stylish design.', sizes: ['L', 'XL'], folder: 'Winter_Jacket'),
  ];

  static String formatMoney(num amount) {
    final value = amount.toInt();

    if (value < 1000) {
      return 'Rs $value';
    }

    final text = value.toString();
    final buffer = StringBuffer();

    int count = 0;

    for (int i = text.length - 1; i >= 0; i--) {
      buffer.write(text[i]);
      count++;

      if (count == 3 && i != 0) {
        buffer.write(',');
        count = 0;
      }
    }

    return 'Rs ${buffer.toString().split('').reversed.join()}';
  }

  static Future<void> addToCart(
    Map<String, dynamic> product,
  ) async {

    final defaultSize =
        (product['sizes'] as List).isNotEmpty
            ? (product['sizes'] as List).first
            : '';

    final index = cart.indexWhere(
      (item) =>
          item['name'] == product['name'] &&
          item['selectedSize'] == defaultSize,
    );

    if (index != -1) {

      cart[index]['qty'] =
          (cart[index]['qty'] as int) + 1;

      cart[index]['selected'] = true;

    } else {

      cart.add({
        ...product,
        'qty': 1,
        'selected': true,
        'selectedSize': defaultSize,
      });
    }

    await saveCart();
  }

  static void addSingleBuyNowItem(
    Map<String, dynamic> product, {
    int qty = 1,
    String selectedSize = '',
  }) {

    isBuyNowMode = true;

    buyNowItems.clear();

    buyNowItems.add({
      ...product,
      'qty': qty,
      'selected': true,
      'selectedSize': selectedSize,
    });
  }

  static void enterCartMode() {
    isBuyNowMode = false;
    buyNowItems.clear();
  }

  static List<Map<String, dynamic>>
      get wishlistItems {

    return products.where(
      (item) =>
          likedProducts.contains(item['name']),
    ).toList();
  }

  static int get cartCount {

    return cart.where(
      (item) =>
          (item['qty'] as int) > 0,
    ).length;
  }

  static Future<void> increaseQty(
      int index) async {

    cart[index]['qty'] =
        (cart[index]['qty'] as int) + 1;

    cart[index]['selected'] = true;

    await saveCart();
  }

  static Future<void> decreaseQty(
      int index) async {

    final currentQty =
        cart[index]['qty'] as int;

    if (currentQty > 0) {
      cart[index]['qty'] =
          currentQty - 1;
    }

    if ((cart[index]['qty'] as int) == 0) {
      cart[index]['selected'] = false;
    }

    await saveCart();
  }

  static Future<void> removeItem(
      int index) async {

    cart.removeAt(index);

    await saveCart();
  }

  static void removeFromWishlist(
      String name) {

    likedProducts.remove(name);
  }

  static List<Map<String, dynamic>>
      get activeCheckoutItems {

    if (isBuyNowMode) {

      return buyNowItems.where(
        (item) =>
            (item['selected'] == true) &&
            ((item['qty'] as int) > 0),
      ).toList();
    }

    return cart.where(
      (item) =>
          (item['selected'] == true) &&
          ((item['qty'] as int) > 0),
    ).toList();
  }

  static bool get hasCheckoutItems =>
      activeCheckoutItems.isNotEmpty;

  static int get cartScreenTotal {

    int total = 0;

    for (final item in cart) {

      final qty = item['qty'] as int;

      if (qty > 0) {
        total +=
            (item['price'] as int) * qty;
      }
    }

    return total;
  }

  static int get checkoutTotal {

    int total = 0;

    for (final item in activeCheckoutItems) {
      total +=
          (item['price'] as int) *
              (item['qty'] as int);
    }

    return total;
  }

  static Future<void>
      completePayment() async {

    if (isBuyNowMode) {

      buyNowItems.clear();

      isBuyNowMode = false;

      return;
    }

    cart.removeWhere(
      (item) =>
          (item['selected'] == true) &&
          ((item['qty'] as int) > 0),
    );

    await saveCart();
  }

  static List<Map<String, dynamic>>
      searchProducts(String query) {

    final q =
        query.trim().toLowerCase();

    if (q.isEmpty) return products;

    final words = q
        .split(' ')
        .where((e) => e.isNotEmpty)
        .toList();

    return products.where((item) {

      final name =
          (item['name'] as String)
              .toLowerCase();

      final category =
          (item['category'] as String)
              .toLowerCase();

      final color =
          (item['color'] as String)
              .toLowerCase();

      return words.every(
        (word) =>
            name.contains(word) ||
            category.contains(word) ||
            color.contains(word),
      );
    }).toList();
  }

  static Future<void> clearCart() async {

    cart.clear();

    await saveCart();
  }

  static Future<void>
      resetUserData() async {

    isLoggedIn = false;

    userName = 'User';

    phone = '';

    email = '';

    password = '';

    imagePath = '';

    language = 'English';

    address = '';

    paymentMethod = 'Card';

    likedProducts.clear();

    cart.clear();

    buyNowItems.clear();

    isBuyNowMode = false;

    await saveState();

    await saveCart();
  }
}