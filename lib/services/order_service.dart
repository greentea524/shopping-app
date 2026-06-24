import 'package:flutter_shop/models/order_record.dart';
import 'package:flutter_shop/models/product.dart';
import 'package:flutter_shop/models/shipping_option.dart';
import 'package:flutter_shop/services/cart_service.dart';
import 'package:uuid/uuid.dart';

class OrderService {
  OrderService({CartService? cartService})
    : _cartService = cartService ?? CartService();

  final CartService _cartService;
  static const uuid = Uuid();

  OrderRecord createOrder({
    required Map<Product, int> purchasedCart,
    required ShippingOption shipping,
    DateTime? placedAt,
  }) {
    final subtotal = _cartService.subtotal(purchasedCart);
    final tax = _cartService.taxFromSubtotal(subtotal);
    final total = subtotal + tax + shipping.fee;

    final items = purchasedCart.entries
        .map(
          (entry) => OrderLineItem(
            name: entry.key.name,
            unitPrice: entry.key.price,
            quantity: entry.value,
          ),
        )
        .toList();

    final record = OrderRecord(
      id: uuid.v4(),
      placedAt: placedAt ?? DateTime.now(),
      items: items,
      shippingLabel: shipping.label,
      shippingFee: shipping.fee,
      subtotal: subtotal,
      tax: tax,
      total: total,
    );

    return record;
  }
}
