# Snackautomat

Flutter-Projekt eines Snackautomaten. Der normale Kundenbereich ist als einfacher
Frontend-Prototyp vorhanden. Der Adminbereich ist noch nicht implementiert; das
sichtbare Adminsymbol zeigt derzeit nur einen Arbeitshinweis.

## Projekt starten

```powershell
flutter pub get
flutter run
```

Für Chrome:

```powershell
flutter run -d chrome
```

Das Projekt ist kein npm-Projekt. Deshalb wird kein `npm start` verwendet.

## Qualität prüfen

```powershell
flutter analyze
flutter test
```

## Entwicklerdokumentation

Die ausführliche Architektur-, Datei- und Integrationsbeschreibung steht in
[docs/DEVELOPER_GUIDE.md](docs/DEVELOPER_GUIDE.md).

Die konkrete Aufgabenverteilung und Schritt-für-Schritt-Anleitung für Nora und
Oleksii steht in
[docs/BACKEND_ARBEITSANLEITUNG.md](docs/BACKEND_ARBEITSANLEITUNG.md).

Alle wichtigen Projektänderungen und die Vorlage für neue Einträge stehen in
[docs/CHANGELOG.md](docs/CHANGELOG.md).
