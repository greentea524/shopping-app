import 'package:flutter/material.dart';
import 'package:flutter_shop/models/order_record.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({
    super.key,
    required this.orders,
    required this.onCancelOrder,
    required this.onArchiveOrder,
    required this.onUpdateTracking,
    required this.onDeleteOrder,
  });

  final List<OrderRecord> orders;
  final Function(String) onCancelOrder;
  final Function(String) onArchiveOrder;
  final Function(String) onUpdateTracking;
  final Function(String) onDeleteOrder;

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  OrderStatus? _selectedFilter = OrderStatus.completed;

  List<OrderRecord> get _filteredOrders {
    if (_selectedFilter == null) {
      return widget.orders;
    }
    return widget.orders
        .where((order) => order.status == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Orders',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Active'),
                    selected: _selectedFilter == OrderStatus.completed,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter =
                            selected ? OrderStatus.completed : null;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Cancelled'),
                    selected: _selectedFilter == OrderStatus.cancelled,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter =
                            selected ? OrderStatus.cancelled : null;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Archived'),
                    selected: _selectedFilter == OrderStatus.archived,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter =
                            selected ? OrderStatus.archived : null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_filteredOrders.length} order${_filteredOrders.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Total spent: \$${_filteredOrders.fold(0.0, (sum, o) => sum + o.total).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildOrdersList(),
        ),
      ],
    );
  }

  Widget _buildOrdersList() {
    if (_filteredOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _selectedFilter == null
                ? 'No orders yet. Complete a fake purchase to see it here.'
                : 'No ${_selectedFilter!.name} orders.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
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
                const SizedBox(height: 12),
                if (order.status == OrderStatus.completed) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tracking: ${order.trackingStatus.name.replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m.group(0)!}').trim()}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Est. ${order.estimatedDelivery.toLocal().toString().split(' ')[0]}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: order.progressPercent,
                            minHeight: 6,
                            backgroundColor: Colors.blue.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              order.trackingStatus == TrackingStatus.delivered
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilledButton.icon(
                        onPressed: order.trackingStatus == TrackingStatus.delivered
                            ? null
                            : () => widget.onUpdateTracking(order.id),
                        icon: const Icon(Icons.local_shipping),
                        label: Text(
                          order.trackingStatus == TrackingStatus.delivered
                              ? 'Delivered'
                              : 'Update Tracking',
                        ),
                      ),
                      if (order.trackingStatus == TrackingStatus.delivered)
                        FilledButton.icon(
                          onPressed: () => widget.onArchiveOrder(order.id),
                          icon: const Icon(Icons.archive),
                          label: const Text('Archive'),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () => widget.onCancelOrder(order.id),
                          icon: const Icon(Icons.close),
                          label: const Text('Cancel'),
                        ),
                    ],
                  ),
                ] else if (order.status == OrderStatus.cancelled) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilledButton.icon(
                        onPressed: () =>
                            widget.onArchiveOrder(order.id),
                        icon: const Icon(Icons.archive),
                        label: const Text('Archive'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                if (order.status == OrderStatus.archived)
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Order?'),
                              content: Text(
                                'Are you sure you want to delete order #${order.id.substring(0, 8)}...?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onDeleteOrder(order.id);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
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
