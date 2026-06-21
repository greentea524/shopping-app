import 'package:flutter_shop/models/product.dart';
import 'package:flutter_shop/models/shipping_option.dart';

class CartService {
  int itemCountByName(Map<String, int> cart) {
    return cart.values.fold(0, (sum, qty) => sum + qty);
  }

  int itemCount(Map<Product, int> cart) {
    return cart.values.fold(0, (sum, qty) => sum + qty);
  }

  void addToNamedCart(Map<String, int> cart, Product product) {
    cart.update(product.name, (value) => value + 1, ifAbsent: () => 1);
  }

  void increaseNamedQty(Map<String, int> cart, Product product) {
    cart.update(product.name, (qty) => qty + 1, ifAbsent: () => 1);
  }

  void decreaseNamedQty(Map<String, int> cart, Product product) {
    final currentQty = cart[product.name] ?? 0;
    final nextQty = currentQty - 1;
    if (nextQty <= 0) {
      cart.remove(product.name);
      return;
    }
    cart[product.name] = nextQty;
  }

  void removeFromNamedCart(Map<String, int> cart, Product product) {
    cart.remove(product.name);
  }

  Map<Product, int> asProductCart(
    Map<String, int> cartByName,
    List<Product> catalog,
  ) {
    return {
      for (final entry in cartByName.entries)
        catalog.firstWhere((product) => product.name == entry.key): entry.value,
    };
  }

  void increaseProductQty(Map<Product, int> cart, Product product) {
    cart.update(product, (qty) => qty + 1, ifAbsent: () => 1);
  }

  void decreaseProductQty(Map<Product, int> cart, Product product) {
    final currentQty = cart[product] ?? 0;
    final nextQty = currentQty - 1;
    if (nextQty <= 0) {
      cart.remove(product);
      return;
    }
    cart[product] = nextQty;
  }

  void removeFromProductCart(Map<Product, int> cart, Product product) {
    cart.remove(product);
  }

  double subtotal(Map<Product, int> cart) {
    double value = 0;
    for (final entry in cart.entries) {
      value += entry.key.price * entry.value;
    }
    return value;
  }

  double taxFromSubtotal(double subtotal) {
    return subtotal * 0.08;
  }

  double total(Map<Product, int> cart, ShippingOption shipping) {
    final subtotalValue = subtotal(cart);
    return subtotalValue + taxFromSubtotal(subtotalValue) + shipping.fee;
  }

  double itemSubtotal(Product product, int quantity) {
    return product.price * quantity;
  }
}
