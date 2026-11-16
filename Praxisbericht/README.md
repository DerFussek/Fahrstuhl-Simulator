# Praxisbericht Fahrstuhl-Steuerung (Typst)

Bericht zur Aufzugssteuerung in Structured Text, Übung der ABB im Stil von
Praxisprojekt I. Form nach der *Studienarbeitsvorlage* des Studiengangs
Elektrotechnik, DHBW Mannheim; Zitierstil IEEE; Richtwert 10–15 Seiten reiner Text.

## Kompilieren

Typst installieren (eine der Möglichkeiten):

```bash
winget install --id Typst.Typst
```

Oder in VS Code die Erweiterung **Tinymist Typst** installieren (Vorschau beim Tippen).

Dann **aus dem Repo-Wurzelordner** kompilieren. `--root .` ist nötig, weil der
Anhang den Code aus `ControlBuilder/` und `main.cc` direkt einliest:

```bash
typst watch --root . Praxisbericht/main.typ
```

Das PDF landet als `Praxisbericht/main.pdf`.

## Aufbau

| Datei / Ordner | Inhalt |
|---|---|
| `main.typ` | Titelblatt-Daten, Reihenfolge der Kapitel; `zeige-entwurf: false` blendet alle Platzhalter aus |
| `vorlage.typ` | Format der Word-Vorlage: Calibri Light 12 pt, 1,5-zeilig, Blocksatz, Ränder, Seitenzahlen, Beschriftungen, Code mit Zeilennummern |
| `vorspann/` | Erklärung (KI-Zusatz), Kurzzusammenfassung, Vorwort, Abkürzungen, Sperrvermerk (optional) |
| `kapitel/` | Kapitel 1–7 mit Stichpunkten aus dem Gliederungsentwurf, dazu die KI-Anmerkung |
| `anhang/` | A: ST-Code, B: C++-Prototyp, C: Testprotokolle |
| `literatur.bib` | Quellen (BibTeX), im Text mit `@schluessel` zitieren |
| `bilder/` | Screenshots und Abbildungen |

## Hilfsfunktionen aus `vorlage.typ`

- `#todo[...]`: grauer Platzhalter, verschwindet mit `zeige-entwurf: false`
- `#code-abbildung("pfad", [Beschriftung], zeilen: (von, bis))`: Code aus einer Datei als Abbildung
- `#abbildung-folgt([was], [Beschriftung])`: Rahmen für eine Abbildung, die noch fehlt

Gliederungsentwurf mit Begründungen: https://claude.ai/artifact/1a8oE6F3xzUZAsxRGiE7FN
