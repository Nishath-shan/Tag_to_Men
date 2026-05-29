import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme.dart';
import '../data/app_state.dart';

class OrderHistory extends StatelessWidget {
  const OrderHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: context.bgColor,
        foregroundColor: context.textColor,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userEmail', isEqualTo: user?.email ?? '')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading orders',
                style: TextStyle(color: context.textColor),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No orders yet',
                style: TextStyle(
                  fontSize: 18,
                  color: context.textColor,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final order = docs[index];
              final data = order.data() as Map<String, dynamic>;

              final items = data['items'] as List<dynamic>? ?? [];

              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.highlightBgColor,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ${index + 1}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Status: ${data['status']}',
                      style: const TextStyle(
                        color: Color(0xFF1450F0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Payment: ${data['paymentMethod']}',
                      style: TextStyle(
                        color: context.subTextColor,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Shipping: ${data['shipping']}',
                      style: TextStyle(
                        color: context.subTextColor,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Total: ${AppState.formatMoney(data['total'] ?? 0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Divider(),

                    const SizedBox(height: 10),

                    Text(
                      'Products',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  item['image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return const Icon(Icons.broken_image);
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: context.textColor,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    'Qty: ${item['qty']}',
                                    style: TextStyle(
                                      color: context.subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Text(
                              AppState.formatMoney(item['price']),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: context.textColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}