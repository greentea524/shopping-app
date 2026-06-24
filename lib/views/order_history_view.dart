import 'package:flutter/material.dart';
import 'package:flutter_shop/models/order_record.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({
    super.key,
    required this.orders,
    required this.onCancelOrder,
    required this.onArchiveOrder,
  });

  final List<OrderRecord> orders;
  final Function(int) onCancelOrder;
  final Function(int) onArchiveOrder;

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  @override
  Widget build(BuildContext context) {
    if (widget.orders.isEmpty) {
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
      itemCount: widget.orders.length,
      itemBuilder: (context, index) {
        final order = widget.orders[index];
        final isCancelled = order.status == OrderStatus.cancelled;
        final isArchived = order.status == OrderStatus.archived;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isCancelled
              ? Colors.red.shade50
              : isArchived
                  ? Colors.grey.shade50
                  : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCancelled
                            ? Colors.red
                            : isArchived
                                ? Colors.grey
                                : Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.status.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
                if (order.status == OrderStatus.completed) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            widget.onCancelOrder(order.id),
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () =>
                            widget.onArchiveOrder(order.id),
                        icon: const Icon(Icons.archive),
                        label: const Text('Archive'),
                      ),
                    ],
                  ),
                ] else if (order.status == OrderStatus.cancelled) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () =>
                        widget.onArchiveOrder(order.id),
                    icon: const Icon(Icons.archive),
                    label: const Text('Archive'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
