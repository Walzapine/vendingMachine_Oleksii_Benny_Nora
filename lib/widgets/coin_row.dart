import 'package:flutter/material.dart';
import '../models/coin.dart';
import '../services/vending_machine_service.dart';

/// Einzelne Münz-Reihe mit ID, Wert, Bestand, +/- Buttons.
///
/// Wird ausschließlich vom AdminScreen verwendet, ist aber eigenständig genug
/// (kein Zugriff auf umgebenden Zustand außer den übergebenen Parametern),
/// um in einer eigenen Datei zu stehen statt den AdminScreen unnötig lang zu
/// machen.
class CoinRow extends StatelessWidget {
  const CoinRow({super.key, required this.coin, required this.service});

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
            Expanded(flex: 1, child: Text(coin.id.toString())),
            // Wert (in Euro formatiert)
            Expanded(flex: 2, child: Text('${coin.valueInCents.toStringAsFixed(2)}€')),
            // Bestand (Anzahl)
            Expanded(flex: 2, child: Text(coin.quantity.toString())),
            // +/- Buttons - flex 2 statt 1, damit auf schmalen Bildschirmen
            // genug Platz für beide Buttons zusammen bleibt (siehe
            // Kommentar in der Kopfzeile in admin_screen.dart).
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: OutlinedButton(
                      onPressed: () => service.decreaseCoinQuantity(coin.id),
                      style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('-'),
                    ),
                  ),
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