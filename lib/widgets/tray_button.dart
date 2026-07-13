import 'package:flutter/material.dart';

/// Ein einzelnes, antippbares Fach (Produkt- oder Rückgeld-Fach).
///
/// Beide Fächer (Ausgabefach, Rückgeld-Fach) sehen gleich aus und verhalten
/// sich gleich (gefüllt = bunt und antippbar, leer = grau und nicht
/// antippbar), unterscheiden sich nur in Inhalt und Aktion. Deshalb dieses
/// eine gemeinsame Widget statt Duplikat - wird sowohl von [DesktopMachine]
/// als auch von [MobileMachine] verwendet.
class TrayButton extends StatelessWidget {
  const TrayButton({
    super.key,
    required this.isFilled,
    required this.filledColor,
    required this.emptyColor,
    required this.label,
    required this.onTap,
  });

  /// Ob gerade etwas im Fach liegt (Produkt bzw. abholbares Guthaben).
  final bool isFilled;

  /// Hintergrundfarbe, wenn das Fach gefüllt ist.
  final Color filledColor;

  /// Hintergrundfarbe, wenn das Fach leer ist.
  final Color emptyColor;

  /// Anzuzeigender Text.
  final String label;

  /// Aktion bei Klick. `null`, wenn das Fach leer ist - dadurch reagiert
  /// InkWell gar nicht erst auf Taps und braucht keine eigene Prüfung.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Material(
        color: isFilled ? filledColor : emptyColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}