import 'package:flutter/material.dart';

import 'mock/mock_vending_machine_service.dart';
import 'screens/product_screen.dart';
import 'services/vending_machine_service.dart';

/// Einstiegspunkt der Flutter-Anwendung.
///
/// Hier wird aktuell bewusst die Demo-Implementierung
/// [MockVendingMachineService] erzeugt. Sobald das echte Backend fertig ist,
/// muss nur diese konkrete Instanz ausgetauscht werden. Das Frontend arbeitet
/// ausschließlich mit dem abstrakten Vertrag [VendingMachineService] und muss
/// deshalb bei einem Backendwechsel nicht umgebaut werden.
void main() {
  final service = MockVendingMachineService();
  runApp(SnackautomatApp(vendingService: service));
}

/// Oberstes Widget der Anwendung.
///
/// Aufgaben dieser Klasse:
///
/// * globales Material-Design konfigurieren,
/// * den Namen der App festlegen,
/// * Abhängigkeiten an den ersten Screen weiterreichen.
///
/// Die Automatenlogik wird über den Konstruktor injiziert. Dieses Vorgehen
/// heißt Dependency Injection und erleichtert sowohl Tests als auch den späteren
/// Austausch der Demo durch eine Datenbank- oder API-Implementierung.
class SnackautomatApp extends StatelessWidget {
  /// Erstellt die App mit einer beliebigen Implementierung der Automatenlogik.
  const SnackautomatApp({super.key, required this.vendingService});

  /// Liefert Zustand und Aktionen des Automaten an das Frontend.
  final VendingMachineService vendingService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Das Debug-Banner wird ausgeblendet, weil es nicht zur Benutzeroberfläche
      // des Snackautomaten gehört.
      debugShowCheckedModeBanner: false,
      title: 'Snackautomat',
      theme: ThemeData(
        // Aus einer einzigen Grundfarbe erzeugt Flutter passende Farben für
        // Buttons, Hinweise und andere Material-Komponenten.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB3261E)),
        scaffoldBackgroundColor: const Color(0xFFF1F1F1),
        useMaterial3: true,
      ),
      // ProductScreen kennt nur die abstrakte Schnittstelle, nicht die konkrete
      // Mock-Klasse. Dadurch bleibt die UI unabhängig vom Backend.
      home: ProductScreen(vendingService: vendingService),
    );
  }
}
