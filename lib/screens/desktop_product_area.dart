import 'package:flutter/material.dart';
import 'package:snackautomat/models/machine_state.dart';
import '../services/vending_machine_service.dart';
import '../widgets/product_card.dart';
import '../widgets/tray_button.dart';

/// Linker Automatenbereich mit Produkten, Ausgabe und Statuszeile (Desktop).
///
/// Nur für Desktop-Breiten gedacht (nutzt `Expanded` und setzt damit einen
/// begrenzten Elternhöhen-Kontext voraus). Für schmale Bildschirme siehe
/// stattdessen `MobileMachine` in `mobile_machine.dart`.
class ProductArea extends StatelessWidget {
  const ProductArea({super.key, required this.state, required this.service});

  final MachineState state;
  final VendingMachineService service;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              final product = state.products[index];
              return ProductCard(
                product: product,
                slotCode: product.id.toString(),
                onTap: () => service.selectProduct(product.id),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TrayButton(
                isFilled: state.trayHasProduct,
                filledColor: Colors.green.shade100,
                emptyColor: Colors.grey.shade300,
                label: state.trayHasProduct
                    ? '${state.dispensedProduct?.emoji ?? ''} '
                          '${state.dispensedProduct?.name ?? ''}'
                          ' – antippen'
                    : 'AUSGABEFACH',
                onTap: state.trayHasProduct
                    ? () => service.collectProduct()
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TrayButton(
                isFilled: state.hasChangeToCollect,
                filledColor: Colors.amber.shade100,
                emptyColor: Colors.grey.shade300,
                label: state.hasChangeToCollect
                    ? '🪙 ${state.formattedCredit} – antippen'
                    : 'RÜCKGELD',
                onTap: state.hasChangeToCollect
                    ? () => service.returnMoney()
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 44,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: Colors.grey.shade200,
          child: Text(state.statusMessage),
        ),
      ],
    );
  }
}