import 'package:flutter/material.dart';
import 'package:flutter_shop/views/shop_shell_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop Play',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C6B58)),
        useMaterial3: true,
      ),
      home: const ShopShellView(),
    );
  }
}
