import 'package:flutter/material.dart';
import '../services/vending_machine_service.dart';
import 'desktop_machine.dart';
import 'mobile_machine.dart';

/// Ab dieser Breite (in logischen Pixeln) wird das Desktop-Layout
/// ([DesktopMachine]) mit der festen, skalierten Automatenfläche verwendet.
/// Darunter (z. B. Smartphone im Hochformat) greift stattdessen das
/// gestapelte Mobile-Layout ([MobileMachine]). Die zweite, feinere Stufe
/// innerhalb des Mobile-Bereichs (`compactMobileBreakpoint`) steckt in
/// `mobile_machine.dart`, weil sie nur dort relevant ist.
const double mobileBreakpoint = 700;

/// Hauptscreen für den normalen Kundenbetrieb des Snackautomaten.
///
/// Der Screen selbst enthält keine Darstellungslogik mehr - er entscheidet
/// nur anhand der verfügbaren Breite, welches der beiden Layouts gebaut wird:
///
/// * [DesktopMachine] - feste Automatenfläche, per FittedBox skaliert
/// * [MobileMachine] - gestapeltes, scrollbares Layout für schmale Screens
///
/// Der Screen kennt keine konkrete Datenbank und enthält keine
/// Kaufberechnung. Alle Aktionen werden an [vendingService] delegiert.
class ProductScreen extends StatelessWidget {
  /// Erstellt den Screen mit einer injizierten Automatenlogik.
  const ProductScreen({super.key, required this.vendingService});

  /// Abstrakte Verbindung zur Geschäftslogik.
  ///
  /// Der konkrete Typ kann Mock, lokale Datenbank oder API-Backend sein.
  final VendingMachineService vendingService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // LayoutBuilder gibt uns die tatsächlich verfügbare Breite. Damit
        // entscheiden wir, welches der beiden Layouts gebaut wird - das ist
        // der eigentliche "Layoutwechsel" (zusätzlich zur Skalierung, die
        // weiterhin innerhalb des Desktop-Zweigs passiert).
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < mobileBreakpoint;

            if (isMobile) {
              // Mobile: KEIN FittedBox, KEINE feste Pixelgröße. Die Bereiche
              // ordnen sich natürlich untereinander an, die Seite scrollt bei
              // Bedarf. Das verhindert, dass auf schmalen Bildschirmen alles
              // nur winzig klein skaliert würde.
              //
              // Die tatsächliche Breite wird durchgereicht, damit
              // MobileMachine selbst zwischen "normal" und "sehr schmal"
              // unterscheiden und sich fein abgestuft anpassen kann (statt
              // eines einzigen harten Schnitts bei mobileBreakpoint).
              return AnimatedBuilder(
                animation: vendingService,
                builder: (context, _) => MobileMachine(
                  state: vendingService.state,
                  service: vendingService,
                  width: constraints.maxWidth,
                ),
              );
            }

            // Desktop: wie bisher - feste Automatenfläche, die per FittedBox
            // proportional auf die verfügbare Fenstergröße skaliert wird.
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: 940,
                    height: 630,
                    child: AnimatedBuilder(
                      animation: vendingService,
                      builder: (context, _) => DesktopMachine(
                        state: vendingService.state,
                        service: vendingService,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}