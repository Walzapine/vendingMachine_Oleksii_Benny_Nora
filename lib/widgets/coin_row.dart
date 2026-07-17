import 'package:flutter/material.dart';
import '../models/coin.dart';
import '../services/vending_machine_service.dart';

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
            // Wert (formatiert)
            Expanded(flex: 2, child: Text(coin.formattedValue)),
            // Bestand
            Expanded(flex: 2, child: Text(coin.quantity.toString())),
            // +/- Buttons
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
