import 'package:flutter/material.dart';
import 'package:snackautomat/models/machine_state.dart';
import '../services/vending_machine_service.dart';
import '../widgets/product_card.dart';
import '../widgets/tray_button.dart';
import '../widgets/machine_header.dart';
import '../widgets/mobile_control_panel.dart';
import '../widgets/purchase_actions.dart';

/// Zweite Stufe innerhalb des Mobile-Layouts: Unterhalb dieser Breite gilt
/// ein Bildschirm als "sehr schmal" (z. B. iPhone SE, kleine Android-Handys).
/// Dort werden Spaltenzahl, Abstände und Schriftgrößen nochmal verkleinert,
/// statt bei jeder Breite unterhalb des Mobile-Breakpoints (siehe
/// `product_screen.dart`) gleich auszusehen.
const double compactMobileBreakpoint = 420;

/// Layout für schmale Bildschirme (z. B. Smartphone im Hochformat).
///
/// Anders als `DesktopMachine` hat dieses Layout KEINE feste Pixelgröße
/// und wird nicht per FittedBox skaliert. Stattdessen:
///
/// * ordnen sich Produktraster, Fächer und Bedienfeld UNTEREINANDER an,
/// * scrollt die ganze Seite bei Bedarf (`SingleChildScrollView`),
/// * steckt Guthaben/Münzen/Auswahl in [MobileControlPanel] (statt in dieser
///   Datei), damit der `build()` hier überschaubar bleibt.
///
/// Enthält bewusst eigenen Produktraster-Code statt `ProductArea`
/// (`desktop_machine.dart`) wiederzuverwenden: Diese setzt intern `Expanded`
/// ein, was einen begrenzten Elternhöhen-Kontext braucht - innerhalb eines
/// `SingleChildScrollView` ist die Höhe aber unbegrenzt.
class MobileMachine extends StatelessWidget {
  const MobileMachine({
    super.key,
    required this.state,
    required this.service,
    required this.width,
  });

  final MachineState state;
  final VendingMachineService service;

  /// Tatsächlich verfügbare Breite, vom LayoutBuilder in `product_screen.dart`
  /// durchgereicht. Steuert die feineren Anpassungen innerhalb des
  /// Mobile-Layouts (Spaltenzahl, Abstände, Schriftgröße).
  final double width;

  @override
  Widget build(BuildContext context) {
    final isCompact = width < compactMobileBreakpoint;
    final crossAxisCount = isCompact ? 2 : 3;
    final outerPadding = isCompact ? 12.0 : 16.0;
    final sectionSpacing = isCompact ? 12.0 : 16.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(outerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MachineHeader(
            service: service,
            horizontalPadding: isCompact ? 12 : 16,
            verticalPadding: isCompact ? 10 : 12,
            titleFontSize: isCompact ? 16 : 18,
            roundedCorners: true,
          ),
          SizedBox(height: sectionSpacing),

          // Produktraster: shrinkWrap + NeverScrollableScrollPhysics, weil
          // die ganze Seite bereits über das äußere SingleChildScrollView
          // scrollt - ein zweites, geschachteltes Scrollen würde zu Konflikten
          // führen ("Scroll-in-Scroll"-Problem).
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: isCompact ? 6 : 8,
              mainAxisSpacing: isCompact ? 6 : 8,
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
          SizedBox(height: isCompact ? 8 : 12),

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
          SizedBox(height: isCompact ? 8 : 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(state.statusMessage),
          ),
          SizedBox(height: sectionSpacing),

          MobileControlPanel(state: state, service: service, isCompact: isCompact),
          SizedBox(height: sectionSpacing),

          FilledButton(
            onPressed: () => performPurchase(context, service),
            child: const Text('KAUFEN'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => performReturnMoney(context, service),
            child: const Text('RÜCKGABE'),
          ),
        ],
      ),
    );
  }
}