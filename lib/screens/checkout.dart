import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme.dart';
import '../data/app_state.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final addressController = TextEditingController(text: AppState.address);
  final phoneController = TextEditingController(text: AppState.phone);
  final emailController = TextEditingController(text: AppState.email);

  String shipping = "Standard";
  String paymentMethod = AppState.paymentMethod;
  bool isPaying = false;

  InputDecoration fieldStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
      filled: true,
      fillColor: context.inputFillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1450F0)),
      ),
    );
  }

  Future<void> goToSuccess() async {
    final items = AppState.activeCheckoutItems;

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items to order')),
      );
      return;
    }

    setState(() {
      isPaying = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final shippingCharge = shipping == "Express" ? 500 : 0;
      final total = AppState.checkoutTotal + shippingCharge;

      final orderData = {
        'userId': user?.uid ?? '',
        'userEmail': user?.email ?? AppState.email,
        'userName': AppState.userName,
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'address': addressController.text.trim().isEmpty
            ? 'Not added'
            : addressController.text.trim(),
        'shipping': shipping,
        'shippingCharge': shippingCharge,
        'paymentMethod': paymentMethod,
        'total': total,
        'status': 'Placed',
        'createdAt': FieldValue.serverTimestamp(),
        'items': items.map((item) {
          final images = item['images'] as List;
          return {
            'name': item['name'],
            'price': item['price'],
            'qty': item['qty'],
            'selectedSize': item['selectedSize'],
            'category': item['category'],
            'image': images.isNotEmpty ? images[0] : '',
          };
        }).toList(),
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PaymentSuccess(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isPaying = false;
        });
      }
    }
  }

  void showEditAddressPopup() {
    final editController = TextEditingController(text: addressController.text);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.bgColor,
        title: Text('Edit Address', style: TextStyle(color: context.textColor)),
        content: TextField(
          controller: editController,
          maxLines: 3,
          decoration: fieldStyle('Enter address'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                addressController.text = editController.text.trim();
                AppState.address = editController.text.trim();
              });
              await AppState.saveState();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void showEditContactPopup() {
    final phoneEdit = TextEditingController(text: phoneController.text);
    final emailEdit = TextEditingController(text: emailController.text);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.bgColor,
        title: Text(
          'Edit Contact Information',
          style: TextStyle(color: context.textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: phoneEdit, decoration: fieldStyle('Phone')),
            const SizedBox(height: 12),
            TextField(controller: emailEdit, decoration: fieldStyle('Email')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                phoneController.text = phoneEdit.text.trim();
                emailController.text = emailEdit.text.trim();
                AppState.phone = phoneEdit.text.trim();
                AppState.email = emailEdit.text.trim();
              });
              await AppState.saveState();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void showPaymentPopup() {
    String tempPayment = paymentMethod;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.bgColor,
        title: Text('Payment Method', style: TextStyle(color: context.textColor)),
        content: StatefulBuilder(
          builder: (context, setInnerState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  value: 'Card',
                  groupValue: tempPayment,
                  title: const Text('Card'),
                  onChanged: (value) {
                    setInnerState(() {
                      tempPayment = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  value: 'Cash on Delivery',
                  groupValue: tempPayment,
                  title: const Text('Cash on Delivery'),
                  onChanged: (value) {
                    setInnerState(() {
                      tempPayment = value!;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                paymentMethod = tempPayment;
                AppState.paymentMethod = tempPayment;
              });
              await AppState.saveState();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget infoCard({
    required String title,
    required String subtitle,
    required VoidCallback onEdit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.highlightBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle.isEmpty ? 'Not added yet' : subtitle,
                  style: TextStyle(color: context.subTextColor),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: Color(0xFF1450F0)),
          ),
        ],
      ),
    );
  }

  Widget productImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
    );
  }

  Widget productItem(Map<String, dynamic> item) {
    final images = item['images'] as List;
    final imagePath = images.isNotEmpty ? images[0].toString() : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: context.highlightBgColor,
            child: ClipOval(
              child: SizedBox(
                width: 64,
                height: 64,
                child: productImage(imagePath),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item['name'],
              style: TextStyle(fontSize: 17, color: context.textColor),
            ),
          ),
          Text(
            AppState.formatMoney((item['price'] as int) * (item['qty'] as int)),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget shippingOption({
    required String value,
    required String title,
    required String subtitle,
    required String priceText,
  }) {
    final selected = shipping == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          shipping = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: selected ? context.secondaryBgColor : context.highlightBgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_off,
              color: const Color(0xFF1450F0),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$title  •  $subtitle',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
            ),
            Text(
              priceText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = AppState.activeCheckoutItems;
    final shippingCharge = shipping == "Express" ? 500 : 0;
    final total = AppState.checkoutTotal + shippingCharge;

    return Scaffold(
      backgroundColor: context.cardColor,
      appBar: AppBar(
        title: const Text('Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: context.cardColor,
        foregroundColor: context.textColor,
        elevation: 0,
      ),
      body: items.isEmpty
          ? const Center(child: Text('No items selected'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoCard(
                    title: 'Shipping Address',
                    subtitle: addressController.text,
                    onEdit: showEditAddressPopup,
                  ),
                  infoCard(
                    title: 'Contact Information',
                    subtitle:
                        '${phoneController.text}\n${emailController.text}'.trim(),
                    onEdit: showEditContactPopup,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...items.map((item) => productItem(item)),
                  const SizedBox(height: 16),
                  Text(
                    'Shipping Options',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  shippingOption(
                    value: 'Standard',
                    title: 'Standard',
                    subtitle: '5-7 days',
                    priceText: 'FREE',
                  ),
                  shippingOption(
                    value: 'Express',
                    title: 'Express',
                    subtitle: '1-2 days',
                    priceText: 'Rs 500',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: context.textColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: showPaymentPopup,
                        icon: const Icon(Icons.edit, color: Color(0xFF1450F0)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paymentMethod,
                    style: const TextStyle(
                      color: Color(0xFF1450F0),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total ${AppState.formatMoney(total)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: context.textColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isPaying ? null : goToSuccess,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1450F0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: isPaying
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Pay',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class PaymentSuccess extends StatelessWidget {
  const PaymentSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: context.bgColor,
        foregroundColor: context.textColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.highlightBgColor,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Color(0xFF1450F0),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1450F0),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                AppState.completePayment();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}