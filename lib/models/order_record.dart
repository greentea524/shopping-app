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

  Map<String, dynamic> toJson() => {
        'name': name,
        'unitPrice': unitPrice,
        'quantity': quantity,
      };

  factory OrderLineItem.fromJson(Map<String, dynamic> json) => OrderLineItem(
        name: json['name'] as String,
        unitPrice: json['unitPrice'] as double,
        quantity: json['quantity'] as int,
      );
}

enum OrderStatus { completed, cancelled, archived }

class OrderRecord {
  OrderRecord({
    required this.id,
    required this.placedAt,
    required this.items,
    required this.shippingLabel,
    required this.shippingFee,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.status = OrderStatus.completed,
  });

  final int id;
  final DateTime placedAt;
  final List<OrderLineItem> items;
  final String shippingLabel;
  final double shippingFee;
  final double subtotal;
  final double tax;
  final double total;
  OrderStatus status;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() => {
        'id': id,
        'placedAt': placedAt.toIso8601String(),
        'items': items.map((item) => item.toJson()).toList(),
        'shippingLabel': shippingLabel,
        'shippingFee': shippingFee,
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'status': status.name,
      };

  factory OrderRecord.fromJson(Map<String, dynamic> json) => OrderRecord(
        id: json['id'] as int,
        placedAt: DateTime.parse(json['placedAt'] as String),
        items: (json['items'] as List<dynamic>)
            .map((item) => OrderLineItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        shippingLabel: json['shippingLabel'] as String,
        shippingFee: json['shippingFee'] as double,
        subtotal: json['subtotal'] as double,
        tax: json['tax'] as double,
        total: json['total'] as double,
        status: OrderStatus.values.firstWhere(
          (s) => s.name == json['status'] as String,
          orElse: () => OrderStatus.completed,
        ),
      );
}
