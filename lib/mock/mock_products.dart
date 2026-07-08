import '../models/product.dart';

/// Statische Beispieldaten für die Entwicklung des Frontends.
///
/// Diese Liste simuliert Produkte, die später aus einer Datenbank, JSON-Datei
/// oder API geladen werden. Sie gehört nicht zum endgültigen Backend. Jede
/// Fachnummer ist eindeutig und die Reihenfolge entspricht dem Raster von links
/// nach rechts und oben nach unten.
///
/// Wichtige Testfälle in den Daten:
///
/// * normale Produkte mit unterschiedlichem Preis und Bestand,
/// * zwölf Produkte für ein Raster aus drei Reihen und vier Spalten,
/// * Cola mit Bestand `0`, damit das Frontend „Ausverkauft“ anzeigen kann.
const mockProducts = <Product>[
  Product(id: 1, name: 'Chips', price: 180, stock: 8, emoji: '🥔'),
  Product(id: 2, name: 'Schokolade', price: 150, stock: 5, emoji: '🍫'),
  Product(id: 3, name: 'Cracker', price: 130, stock: 6, emoji: '🍘'),
  Product(id: 4, name: 'Nüsse', price: 160, stock: 4, emoji: '🥜'),
  Product(id: 5, name: 'Keks', price: 110, stock: 9, emoji: '🍪'),
  Product(id: 6, name: 'Bonbons', price: 100, stock: 7, emoji: '🍬'),
  Product(id: 7, name: 'Apfel', price: 90, stock: 5, emoji: '🍎'),
  Product(id: 8, name: 'Riegel', price: 140, stock: 3, emoji: '🍫'),
  Product(id: 9, name: 'Wasser', price: 120, stock: 10, emoji: '💧'),
  Product(id: 10, name: 'Cola', price: 200, stock: 0, emoji: '🥤'),
  Product(id: 11, name: 'Saft', price: 170, stock: 5, emoji: '🧃'),
  Product(id: 12, name: 'Eistee', price: 180, stock: 6, emoji: '🧋'),
];
