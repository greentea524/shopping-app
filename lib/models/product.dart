import 'package:flutter/material.dart';

class Product {
  const Product({
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.category,
  });

  final String name;
  final String description;
  final double price;
  final IconData icon;
  final String category;
}

const List<Product> demoCatalog = [
  // Apparel & Accessories
  Product(
    name: 'Classic Tee',
    description: 'Soft cotton shirt for everyday wear.',
    price: 24.99,
    icon: Icons.checkroom_outlined,
    category: 'Apparel',
  ),
  Product(
    name: 'Smart Bottle',
    description: 'Insulated bottle that keeps drinks cold.',
    price: 18.50,
    icon: Icons.local_drink_outlined,
    category: 'Apparel',
  ),
  Product(
    name: 'Travel Backpack',
    description: 'Compact backpack with laptop sleeve.',
    price: 49.00,
    icon: Icons.backpack_outlined,
    category: 'Apparel',
  ),

  // TVs
  Product(
    name: '55" 4K Smart TV',
    description: 'Crystal-clear 4K display with built-in streaming apps.',
    price: 499.99,
    icon: Icons.tv_outlined,
    category: 'TVs',
  ),
  Product(
    name: '65" OLED TV',
    description: 'Stunning OLED panel with HDR and 120Hz refresh rate.',
    price: 1299.99,
    icon: Icons.tv_outlined,
    category: 'TVs',
  ),
  Product(
    name: '32" HD Monitor TV',
    description: 'Compact dual-use display for bedroom or office.',
    price: 179.99,
    icon: Icons.tv_outlined,
    category: 'TVs',
  ),

  // Computers
  Product(
    name: 'Ultrabook Laptop',
    description: 'Thin and light laptop with 16GB RAM and 512GB SSD.',
    price: 999.00,
    icon: Icons.laptop_outlined,
    category: 'Computers',
  ),
  Product(
    name: 'Gaming Laptop',
    description: 'High-performance laptop with RTX 4060 GPU.',
    price: 1499.00,
    icon: Icons.laptop_outlined,
    category: 'Computers',
  ),
  Product(
    name: 'Mini Desktop PC',
    description: 'Compact desktop with Intel Core i5 and 8GB RAM.',
    price: 549.00,
    icon: Icons.computer_outlined,
    category: 'Computers',
  ),
  Product(
    name: 'Wireless Keyboard & Mouse',
    description: 'Ergonomic combo with long battery life.',
    price: 59.99,
    icon: Icons.keyboard_outlined,
    category: 'Computers',
  ),

  // PC Parts
  Product(
    name: 'RTX 4070 GPU',
    description: 'High-end graphics card for gaming and content creation.',
    price: 599.99,
    icon: Icons.memory_outlined,
    category: 'PC Parts',
  ),
  Product(
    name: 'AMD Ryzen 7 CPU',
    description: '8-core processor with excellent multi-threaded performance.',
    price: 329.99,
    icon: Icons.developer_board_outlined,
    category: 'PC Parts',
  ),
  Product(
    name: '32GB DDR5 RAM Kit',
    description: 'Dual-channel 6000MHz memory kit for fast performance.',
    price: 129.99,
    icon: Icons.storage_outlined,
    category: 'PC Parts',
  ),
  Product(
    name: '1TB NVMe SSD',
    description: 'PCIe Gen4 drive with blazing-fast read/write speeds.',
    price: 89.99,
    icon: Icons.storage_outlined,
    category: 'PC Parts',
  ),
  Product(
    name: 'ATX Motherboard',
    description: 'Full-size board with PCIe 5.0 and WiFi 6E support.',
    price: 249.99,
    icon: Icons.developer_board_outlined,
    category: 'PC Parts',
  ),
  Product(
    name: '750W PSU',
    description: '80+ Gold certified power supply with modular cables.',
    price: 109.99,
    icon: Icons.power_outlined,
    category: 'PC Parts',
  ),
];
