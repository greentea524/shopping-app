import 'package:flutter/material.dart';
import 'package:flutter_shop/app.dart';
import 'package:flutter_shop/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().initialize();
  runApp(const MyApp());
}
