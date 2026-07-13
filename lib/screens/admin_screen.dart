import 'package:flutter/material.dart';
import '../models/coin.dart';
import '../services/vending_machine_service.dart';

/// Admin-Bereich zur Verwaltung des Münzbestands.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key, required this.vendingService});

  final VendingMachineService vendingService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin-Bereich'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: vendingService,
          builder: (context, _) => _AdminPanel(
            coins: vendingService.coins,
            service: vendingService,
          ),
        ),
      ),
    );
  }
}
/// Private Admin-Panel mit ListView für alle Münzen.
class _AdminPanel extends StatelessWidget {
  const _AdminPanel({
    required this.coins,
    required this.service,
  });

  final List<Coin> coins;
  final VendingMachineService service;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header: Spalten-Überschrift
        Card(
          color: Colors.grey.shade300,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              // Verhältnis 1:2:2:2 statt 1:2:2:1 - "Aktion" braucht mehr
              // relativen Platz als die anderen, weil hier zwei Buttons
              // nebeneinander stehen (siehe _CoinRow). Bei 1:2:2:1 bekam
              // diese Spalte auf schmalen Bildschirmen (Handy) weniger
              // Breite als die beiden Buttons zusammen brauchen -> Overflow.
              children: const [
                Expanded(flex: 1, child: Text('ID')),
                Expanded(flex: 2, child: Text('Wert')),
                Expanded(flex: 2, child: Text('Bestand')),
                Expanded(flex: 2, child: Text('Aktion')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // ListView: Münzen-Reihen
        Expanded(
          child: ListView.builder(
            itemCount: coins.length,
            itemBuilder: (context, index) {
              final coin = coins[index];
              return _CoinRow(coin: coin, service: service);
            },
          ),
        ),
        const SizedBox(height: 16),
        // Zurück-Button
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Zurück zum Verkauf'),
        ),
      ],
    );
  }
}

/// Einzelne Münz-Reihe mit ID, Wert, Bestand, +/- Buttons.
class _CoinRow extends StatelessWidget {
  const _CoinRow({required this.coin, required this.service});

  final Coin coin;
  final VendingMachineService service;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            // ID
            Expanded(
              flex: 1,
              child: Text(coin.id.toString()),
            ),
            // Wert (in Euro formatiert)
            Expanded(
              flex: 2,
              child: Text('${coin.value.toStringAsFixed(2)}€'),
            ),
            // Bestand (Anzahl)
            Expanded(
              flex: 2,
              child: Text(coin.quantity.toString()),
            ),
            // +/- Buttons - flex erhöht (siehe Kommentar in der Kopfzeile
            // oben) und Buttons leicht verkleinert (32 statt 36), damit auch
            // auf schmalen Bildschirmen genug Platz für beide Buttons bleibt.
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // "-" Button
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: OutlinedButton(
                      onPressed: () => service.decreaseCoinQuantity(coin.id),
                      style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('-'),
                    ),
                  ),
                  // "+" Button
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: OutlinedButton(
                      onPressed: () => service.increaseCoinQuantity(coin.id),
                      style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('+'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}