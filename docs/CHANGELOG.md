# Changelog

In dieser Datei werden wichtige Änderungen am Snackautomaten dokumentiert. Neue
Einträge werden immer direkt unter „Aktuelle Änderungen“ eingefügt. Texte und
Commit-Nachrichten werden für dieses Projekt auf Deutsch geschrieben.

## Regeln für neue Einträge

- Datum im Format `JJJJ-MM-TT` angeben.
- Namen der verantwortlichen Person eintragen.
- Einen kurzen deutschen Commit-Titel verwenden.
- In der Beschreibung erklären, was geändert wurde und warum.
- Betroffene Bereiche oder Dateien nennen.
- Durchgeführte Prüfungen dokumentieren.
- Keine Zugangsdaten, Passwörter oder persönlichen Daten eintragen.

## Vorlage

Die folgende Vorlage kopieren und unter „Aktuelle Änderungen“ einfügen:

```markdown
### JJJJ-MM-TT – Kurzer Titel der Änderung

- **Verantwortlich:** Name
- **Commit-Titel:** `Kurzer deutscher Commit-Titel`
- **Beschreibung:** Ausführliche Beschreibung der Änderung und ihres Zwecks.
- **Betroffene Bereiche:** `lib/...`, `test/...`, `docs/...`
- **Prüfung:** `flutter analyze` und `flutter test`
- **Ergebnis:** Kurze Angabe, ob alle Prüfungen erfolgreich waren.
```

## Aktuelle Änderungen

### 2026-07-02 – Flutter-Grundprojekt und Kundenautomat vorbereitet

- **Verantwortlich:** Benni und Projektteam
- **Commit-Titel:** `Flutter-Snackautomaten und Entwicklerdokumentation hinzufügen`
- **Beschreibung:** Das Flutter-Projekt wurde vollständig angelegt. Der normale
  Snackautomat besitzt eine einfache Produktraster-Ansicht, Münzeinwurf,
  Produktauswahl, Kauf, Rückgabe, Guthabenanzeige, Ausgabefach und Statuszeile.
  Eine austauschbare Demo-Logik ermöglicht die Frontend-Entwicklung, ohne bereits
  eine Datenbank vorauszusetzen. Das sichtbare Adminsymbol zeigt vorerst nur den
  Hinweis, dass dieser Bereich noch in Arbeit ist.
- **Betroffene Bereiche:** `lib/`, `test/`, `docs/`, Flutter-Plattformordner,
  `pubspec.yaml`, `README.md`
- **Prüfung:** `flutter analyze` und `flutter test`
- **Ergebnis:** Analyse ohne Befunde; alle vorhandenen Tests erfolgreich.

### 2026-07-02 – Zusammenarbeit und Backend-Übergabe dokumentiert

- **Verantwortlich:** Benni und Projektteam
- **Commit-Titel:** `Deutsche Entwickleranleitungen für das Team ergänzen`
- **Beschreibung:** Alle eigenen Dart-Dateien wurden ausführlich auf Deutsch
  dokumentiert. Zusätzlich wurden ein Architekturleitfaden und eine getrennte
  Arbeitsanleitung für Noras Geschäftslogik und Oleksiis Datenhaltung erstellt.
- **Betroffene Bereiche:** `lib/`, `test/`, `docs/DEVELOPER_GUIDE.md`,
  `docs/BACKEND_ARBEITSANLEITUNG.md`, `README.md`
- **Prüfung:** `flutter analyze` und `flutter test`
- **Ergebnis:** Dokumentation ergänzt; Anwendung und Tests weiterhin fehlerfrei.

## Commit-Nachrichten

Für Commits wird dieses einfache deutsche Format empfohlen:

```text
Kurzer Titel im Imperativ

Beschreibung:
- Was wurde geändert?
- Warum wurde es geändert?
- Welche wichtigen Auswirkungen gibt es?

Prüfung:
- flutter analyze
- flutter test
```

Beispiel:

```text
Kaufprüfung für unzureichendes Guthaben ergänzen

Beschreibung:
- Kauf wird abgebrochen, wenn das Guthaben nicht ausreicht.
- Bestand und Guthaben bleiben bei einem fehlgeschlagenen Kauf unverändert.
- Passender Servicetest wurde ergänzt.

Prüfung:
- flutter analyze
- flutter test
```

## Branch-Arbeitsweise

- `main` enthält den gemeinsam geprüften, stabilen Projektstand.
- `dev` ist der Hauptbranch für die laufende gemeinsame Entwicklung.
- Neue Arbeiten werden normalerweise von `dev` aus begonnen und zuerst wieder
  in `dev` zusammengeführt.
- Erst nach erfolgreicher Analyse, erfolgreichen Tests und gemeinsamer Prüfung
  wird `dev` in `main` übernommen.
