import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/product_screen.dart';
import 'services/vending_machine_service.dart';
import 'services/vending_machine_service_impl.dart';
import 'database/database_helper.dart';
import 'repositories/product_repository.dart';
import 'repositories/coin_repository.dart';

/// Einstiegspunkt der Flutter-Anwendung mit SQLite-Persistanz.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔴 FFI ZUERST für Windows Desktop!
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Initialisiere DB + Service
  final databaseHelper = DatabaseHelper();
  final productRepository = ProductRepository(databaseHelper);
  final coinRepository = CoinRepository(databaseHelper);

  final service = VendingMachineServiceImpl(
    productRepository: productRepository,
    coinRepository: coinRepository,
    databaseHelper: databaseHelper,
  );

  await service.initialize();

  runApp(SnackautomatApp(vendingService: service));
}

/// Oberstes Widget der Anwendung.
class SnackautomatApp extends StatelessWidget {
  const SnackautomatApp({super.key, required this.vendingService});

  final VendingMachineService vendingService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snackautomat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB3261E)),
        scaffoldBackgroundColor: const Color(0xFFF1F1F1),
        useMaterial3: true,
      ),
      home: ProductScreen(vendingService: vendingService),
    );
  }
}
