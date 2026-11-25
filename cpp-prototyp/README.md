# C++-Prototyp der Zielliste

Bevor die Steuerung in Structured Text (Control Builder M) geschrieben wurde, hat die
Untergruppe die Logik der Zielliste in C++ entwickelt und getestet. Der Prototyp enthält
dieselben Funktionen wie die spätere ST-Umsetzung in
[`../ControlBuilder/DT_FahrstuhlLib/FunctionBlockTypes/`](../ControlBuilder/DT_FahrstuhlLib/FunctionBlockTypes/):

| Funktion | Aufgabe |
|---|---|
| `SortBetweenLimits` | sortiert einen Abschnitt der Liste nach Etage (auf- oder absteigend) |
| `InsertBetweenLimits` | hängt einen Ruf an einen Abschnitt an und sortiert ihn neu |
| `AddTargetToList` | entscheidet, in welchen Abschnitt ein neuer Ruf gehört |

Wie `AddTargetToList` Schritt für Schritt arbeitet, steht in [`ABLAUF.md`](ABLAUF.md).

## Dateien

| Pfad | Inhalt |
|---|---|
| [`main.cc`](main.cc) | **Aktueller Stand** des Prototyps (Vorlage für die ST-Bausteine) |
| [`test_interaktiv.cc`](test_interaktiv.cc) | Interaktives Testprogramm: Rufe von Hand eingeben, Liste nach jedem Schritt ansehen |
| [`tests/test_gruppe.cc`](tests/test_gruppe.cc) | 20 Testfälle der Gruppe (Soll/Ist-Vergleich) |
| [`tests/szenarien.cc`](tests/szenarien.cc) | 241 Szenarien für alle Gondelpositionen und 5 Zufallsläufe mit je 100.000 Listen |
| [`tests/ergebnisse/szenarien_log.txt`](tests/ergebnisse/szenarien_log.txt) | Protokoll eines Laufs von `szenarien.cc` |
| [`tests/build.bat`](tests/build.bat) | Baut und startet beide Tests mit MSVC |
| [`versionen/v1_main.cc`](versionen/v1_main.cc) | Erste Fassung (Fahrtrichtung noch aus dem Pfeil des ersten Rufs) |
| [`versionen/v2_main2.cc`](versionen/v2_main2.cc) | Aufgeräumte erste Fassung, gleiche Logik wie v1 |

Unterschied `main.cc` zu den älteren Fassungen: Die Fahrtrichtung ergibt sich aus
Gondelposition und erstem Ziel, ein Ruf in der aktuellen Etage öffnet die Tür
(`TuerAufCmd`), statt in die Liste zu kommen, und die Liste ist auf 10 Einträge begrenzt
(so viele Plätze hat das Array in 800xA).

## Bauen und ausführen

Mit g++ (aus diesem Ordner):

```bash
g++ -std=c++17 test_interaktiv.cc -o test_interaktiv && ./test_interaktiv
cd tests
g++ -std=c++17 test_gruppe.cc -o test_gruppe && ./test_gruppe
g++ -std=c++17 szenarien.cc  -o szenarien  && ./szenarien
```

Mit MSVC: `cl /EHsc /std:c++17 test_interaktiv.cc`, für die Tests `tests\build.bat`.

Die Testprogramme binden `main.cc` per `#include` ein. Eine andere Fassung lässt sich mit
`-DFUNKTION='"versionen/v1_main.cc"'` (bzw. `"../versionen/v1_main.cc"` in `tests/`) prüfen.

## Ergebnis der Tests (Stand `main.cc`)

- `test_gruppe.cc`: 20 von 20 bestanden.
- `szenarien.cc`: In allen Zufallsläufen gehen keine Rufe verloren, die Liste wird nie
  länger als 10 und kein erreichbarer Ruf in Fahrtrichtung wird verpasst. Die 51 als
  „Fehler“ gezählten Szenarien sind alle von der Art „Ruf/Ziel in aktueller Etage“: Die
  Referenz im Test sortiert solche Rufe ein, `main.cc` öffnet stattdessen die Tür. Das ist
  so gewollt.
