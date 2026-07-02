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
  Product(
    id: '1',
    slotCode: 'A1',
    name: 'Chips',
    priceInCents: 180,
    stock: 8,
    emoji: '🥔',
  ),
  Product(
    id: '2',
    slotCode: 'A2',
    name: 'Schokolade',
    priceInCents: 150,
    stock: 5,
    emoji: '🍫',
  ),
  Product(
    id: '3',
    slotCode: 'A3',
    name: 'Cracker',
    priceInCents: 130,
    stock: 6,
    emoji: '🍘',
  ),
  Product(
    id: '4',
    slotCode: 'A4',
    name: 'Nüsse',
    priceInCents: 160,
    stock: 4,
    emoji: '🥜',
  ),
  Product(
    id: '5',
    slotCode: 'B1',
    name: 'Keks',
    priceInCents: 110,
    stock: 9,
    emoji: '🍪',
  ),
  Product(
    id: '6',
    slotCode: 'B2',
    name: 'Bonbons',
    priceInCents: 100,
    stock: 7,
    emoji: '🍬',
  ),
  Product(
    id: '7',
    slotCode: 'B3',
    name: 'Apfel',
    priceInCents: 90,
    stock: 5,
    emoji: '🍎',
  ),
  Product(
    id: '8',
    slotCode: 'B4',
    name: 'Riegel',
    priceInCents: 140,
    stock: 3,
    emoji: '🍫',
  ),
  Product(
    id: '9',
    slotCode: 'C1',
    name: 'Wasser',
    priceInCents: 120,
    stock: 10,
    emoji: '💧',
  ),
  Product(
    id: '10',
    slotCode: 'C2',
    name: 'Cola',
    priceInCents: 200,
    stock: 0,
    emoji: '🥤',
  ),
  Product(
    id: '11',
    slotCode: 'C3',
    name: 'Saft',
    priceInCents: 170,
    stock: 5,
    emoji: '🧃',
  ),
  Product(
    id: '12',
    slotCode: 'C4',
    name: 'Eistee',
    priceInCents: 180,
    stock: 6,
    emoji: '🧋',
  ),
];
