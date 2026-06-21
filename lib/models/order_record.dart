class OrderLineItem {
  const OrderLineItem({
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  final String name;
  final double unitPrice;
  final int quantity;

  double get subtotal => unitPrice * quantity;
}

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.placedAt,
    required this.items,
    required this.shippingLabel,
    required this.shippingFee,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  final int id;
  final DateTime placedAt;
  final List<OrderLineItem> items;
  final String shippingLabel;
  final double shippingFee;
  final double subtotal;
  final double tax;
  final double total;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}
