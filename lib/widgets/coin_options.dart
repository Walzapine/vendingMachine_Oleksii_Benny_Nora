/// Verfügbare Münzwerte für die "Geld einwerfen"-Buttons.
///
/// Zentral hier definiert (statt lokal in einem Widget), damit
/// [DesktopMachine] (genauer: dessen `ControlPanel`) und [MobileMachine]
/// dieselbe Liste verwenden und sie nicht zweimal gepflegt werden muss.
/// Schlüssel sind die sichtbaren Beschriftungen, Werte die an den Service
/// übergebenen Centbeträge. Neue Münzen können hier zentral ergänzt werden.
const coinButtons = {
  '2 €': 200,
  '1 €': 100,
  '50 ct': 50,
  '20 ct': 20,
  '10 ct': 10,
  '5 ct': 5,
};