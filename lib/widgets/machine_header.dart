import 'package:flutter/material.dart';
import '../services/vending_machine_service.dart';
import '../screens/admin_screen.dart';

/// Kopfzeile mit Titel "SNACKAUTOMAT" und Admin-Icon.
///
/// Wird von [DesktopMachine] und [MobileMachine] gemeinsam verwendet - vorher
/// gab es diesen Block (samt Navigation zum AdminScreen) fast identisch an
/// zwei Stellen. Die Unterschiede zwischen Desktop und Mobile (feste Höhe vs.
/// natürliche Höhe, Innenabstand, Schriftgröße) werden über Parameter
/// gesteuert statt über Code-Duplizierung.
class MachineHeader extends StatelessWidget {
  const MachineHeader({
    super.key,
    required this.service,
    this.height,
    this.horizontalPadding = 16,
    this.verticalPadding = 12,
    this.titleFontSize,
    this.roundedCorners = false,
  });

  /// Service, der an den AdminScreen weitergereicht wird, damit dieser auf
  /// denselben Zustand zugreift wie der Verkaufsbildschirm.
  final VendingMachineService service;

  /// Feste Höhe (Desktop-Variante mit `940x630`-Fläche). `null` bedeutet:
  /// Höhe ergibt sich natürlich aus Innenabstand + Inhalt (Mobile-Variante).
  final double? height;

  final double horizontalPadding;

  /// Wird nur verwendet, wenn [height] `null` ist (siehe oben).
  final double verticalPadding;

  /// `null` verwendet die Standardgröße von `titleLarge`. Wird für die
  /// Mobile-Variante auf einen kleineren, festen Wert gesetzt.
  final double? titleFontSize;

  /// Abgerundete Ecken nur sinnvoll, wenn der Header NICHT direkt in einer
  /// [Card] mit `clipBehavior: Clip.antiAlias` sitzt (Desktop schneidet die
  /// Card selbst ab, Mobile braucht die Rundung selbst).
  final bool roundedCorners;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Text(
          'SNACKAUTOMAT',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: titleFontSize,
          ),
        ),
        const Spacer(),
        IconButton(
          // Öffnet den fertigen AdminScreen zur Verwaltung des Münzbestands.
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminScreen(vendingService: service),
              ),
            );
          },
          tooltip: 'Adminbereich',
          color: Theme.of(context).colorScheme.onPrimary,
          icon: const Icon(Icons.admin_panel_settings_outlined),
        ),
      ],
    );

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: height == null ? verticalPadding : 0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: roundedCorners ? BorderRadius.circular(8) : null,
      ),
      child: content,
    );
  }
}