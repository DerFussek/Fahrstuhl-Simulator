# Praxisbericht Fahrstuhl-Steuerung (Typst)

Bericht zur Aufzugssteuerung in Structured Text, Übung der ABB im Stil von
Praxisprojekt I. Form seit 19.11.2026 nach dem *T1000-Musterbericht* (Projektarbeit I,
ABB Mannheim), vorher nach der *Studienarbeitsvorlage* des Studiengangs Elektrotechnik;
Zitierstil IEEE; Richtwert 10–15 Seiten reiner Text.

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
| `vorlage.typ` | Format des T1000-Musterberichts: Arial 12 pt, 1,5-zeilig, Blocksatz, Kopfzeile mit Name und Art, Titelblatt mit Logos, Nummern „1.1.“, Beschriftungen „Abbildung 1: …“, Code mit Zeilennummern |
| `vorspann/` | Sperrvermerk, Erklärung (KI-Zusatz), Überblick der Tätigkeiten, Abkürzungen, Vorwort; Kurzzusammenfassung (im Muster nicht vorgesehen, in `main.typ` auskommentiert) |
| `kapitel/` | Kapitel 1–7 (Kapitel 7 mit Reflexion wie im Muster), dazu die KI-Anmerkung ohne Kapitelnummer |
| `anhang/` | A: ST-Code, B: C++-Prototyp und Testprogramm, C: Testprotokolle, D: Skizzen aus der Entwurfsphase |
| `literatur.bib` | Quellen (BibTeX), im Text mit `@schluessel` zitieren |
| `bilder/` | Screenshots, Abbildungen und die Logos für das Titelblatt (`logo-abb.png`, `logo-dhbw-mannheim.png`) |

## Hilfsfunktionen aus `vorlage.typ`

- `#todo[...]`: grauer Platzhalter, verschwindet mit `zeige-entwurf: false`
- `#code-abbildung("pfad", [Beschriftung], zeilen: (von, bis))`: Code aus einer Datei als Abbildung
- `#abbildung-folgt([was], [Beschriftung])`: Rahmen für eine Abbildung, die noch fehlt
- `#kapitel-ohne-nummer[Titel]`: Kapitel ohne Nummer im Inhaltsverzeichnis (Literatur, KI-Anmerkung); Verweis mit `#link(<label>)[Text]` statt `@label`

Gliederungsentwurf mit Begründungen: https://claude.ai/artifact/1a8oE6F3xzUZAsxRGiE7FN
