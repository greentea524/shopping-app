import 'package:flutter/material.dart';
import 'package:flutter_shop/models/order_record.dart';

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key, required this.orders});

  final List<OrderRecord> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No orders yet. Complete a fake purchase to see it here.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.placedAt.toLocal()}'.split('.').first,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text('Items: ${order.itemCount}'),
                Text('Shipping: ${order.shippingLabel}'),
                Text('Total: \$${order.total.toStringAsFixed(2)}'),
                const Divider(height: 20),
                for (final item in order.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${item.quantity}x ${item.name} - \$${item.subtotal.toStringAsFixed(2)}',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
