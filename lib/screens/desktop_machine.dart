import 'package:flutter/material.dart';
import 'package:snackautomat/models/machine_state.dart';
import '../services/vending_machine_service.dart';
import '../widgets/machine_header.dart';
import 'desktop_product_area.dart';
import 'desktop_control_panel.dart';

/// Zusammensetzung des sichtbaren Automatenrahmens für Desktop-Breiten.
///
/// Wird ausschließlich von [ProductScreen] verwendet (in dessen
/// Desktop-Zweig, gewrappt in `FittedBox` + feste `SizedBox`-Größe). Andere
/// Dateien sollten diese Klasse nicht direkt verwenden.
///
/// Setzt sich aus [ProductArea] (links, `desktop_product_area.dart`) und
/// [ControlPanel] (rechts, `desktop_control_panel.dart`) zusammen.
class DesktopMachine extends StatelessWidget {
  const DesktopMachine({super.key, required this.state, required this.service});

  final MachineState state;
  final VendingMachineService service;

  @override
  Widget build(BuildContext context) {
    return Card(
      // Clip verhindert, dass die farbige Kopfzeile über die abgerundeten
      // Außenkanten der Card hinausragt.
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          MachineHeader(service: service, height: 64, horizontalPadding: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    // Verhältnis 3:1: Produktbereich erhält drei Viertel der
                    // verfügbaren Breite, das Bedienfeld ein Viertel.
                    flex: 3,
                    child: ProductArea(state: state, service: service),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ControlPanel(state: state, service: service),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}