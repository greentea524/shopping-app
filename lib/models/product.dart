import 'package:flutter/material.dart';

class Product {
  const Product({
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
  });

  final String name;
  final String description;
  final double price;
  final IconData icon;
}

const List<Product> demoCatalog = [
  Product(
    name: 'Classic Tee',
    description: 'Soft cotton shirt for everyday wear.',
    price: 24.99,
    icon: Icons.checkroom_outlined,
  ),
  Product(
    name: 'Smart Bottle',
    description: 'Insulated bottle that keeps drinks cold.',
    price: 18.50,
    icon: Icons.local_drink_outlined,
  ),
  Product(
    name: 'Travel Backpack',
    description: 'Compact backpack with laptop sleeve.',
    price: 49.00,
    icon: Icons.backpack_outlined,
  ),
];
