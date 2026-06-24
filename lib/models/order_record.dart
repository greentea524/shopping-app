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

enum TrackingStatus { processing, shipped, inTransit, outForDelivery, delivered }

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
    DateTime? estimatedDelivery,
    this.trackingStatus = TrackingStatus.processing,
  }) : estimatedDelivery = estimatedDelivery ?? _calculateDeliveryDate(placedAt, shippingLabel);

  final String id;
  final DateTime placedAt;
  final List<OrderLineItem> items;
  final String shippingLabel;
  final double shippingFee;
  final double subtotal;
  final double tax;
  final double total;
  OrderStatus status;
  final DateTime estimatedDelivery;
  TrackingStatus trackingStatus;

  static DateTime _calculateDeliveryDate(DateTime orderDate, String shippingLabel) {
    if (shippingLabel.contains('Overnight')) {
      return orderDate.add(const Duration(days: 1));
    } else if (shippingLabel.contains('Express')) {
      return orderDate.add(const Duration(days: 2));
    } else {
      // Standard: 3-5 days, use 4 days average
      return orderDate.add(const Duration(days: 4));
    }
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get progressPercent {
    switch (trackingStatus) {
      case TrackingStatus.processing:
        return 0.2;
      case TrackingStatus.shipped:
        return 0.4;
      case TrackingStatus.inTransit:
        return 0.6;
      case TrackingStatus.outForDelivery:
        return 0.85;
      case TrackingStatus.delivered:
        return 1.0;
    }
  }

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
        'estimatedDelivery': estimatedDelivery.toIso8601String(),
        'trackingStatus': trackingStatus.name,
      };

  factory OrderRecord.fromJson(Map<String, dynamic> json) => OrderRecord(
        id: json['id'] as String,
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
        estimatedDelivery: json['estimatedDelivery'] != null
            ? DateTime.parse(json['estimatedDelivery'] as String)
            : null,
        trackingStatus: TrackingStatus.values.firstWhere(
          (t) => t.name == json['trackingStatus'] as String,
          orElse: () => TrackingStatus.processing,
        ),
      );
}
