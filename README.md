# Fahrstuhl-Simulator

Steuerung eines Aufzugs mit sechs Stockwerken in Structured Text für ABB 800xA
(Control Builder M, AC 800M Soft Controller). Projekt während der Praxisphase bei der
ABB AG (Ausbildung DHBW Mannheim). Die Logik der Zielliste wurde zuerst als C++-Prototyp
entwickelt und getestet und dann nach Structured Text übertragen.

## Aufbau des Repositorys

| Ordner | Inhalt |
|---|---|
| [`ControlBuilder/`](ControlBuilder/) | Aktueller Arbeitsstand der Steuerung in Structured Text: Library `DT_FahrstuhlLib` (Datentyp `Target`, Function Blocks, Control Modules) und Application `TD_Appl`. Abschrift aus Control Builder M, Details in [`ControlBuilder/README.md`](ControlBuilder/README.md) |
| [`cpp-prototyp/`](cpp-prototyp/) | C++-Prototyp der Zielliste (`main.cc`), interaktives Testprogramm, automatische Tests mit Protokoll und frühere Fassungen. Details in [`cpp-prototyp/README.md`](cpp-prototyp/README.md) |
| [`Praxisbericht/`](Praxisbericht/) | Quelltext des Praxisberichts (Typst) |
| [`docs/`](docs/) | Hintergrundnotizen, z. B. Vorgaben der DHBW für schriftliche Arbeiten |

```
Fahrstuhl-Simulator/
├── ControlBuilder/
│   ├── DT_FahrstuhlLib/
│   │   ├── Target.st
│   │   ├── FunctionBlockTypes/   AddTargetToList, InsertBetweenLimits, SortBetweenLimits, TD_RemoveAtIndex
│   │   └── ControlModuleTypes/   DT_Door, TD_Gondel, TD_MotorController, TD_LedSteuerung, ...
│   └── TD_Appl/Diagrams.md
├── cpp-prototyp/
│   ├── main.cc                   aktueller Stand
│   ├── test_interaktiv.cc
│   ├── ABLAUF.md                 Ablauf von AddTargetToList in Worten
│   ├── tests/                    test_gruppe.cc, szenarien.cc, build.bat, ergebnisse/
│   └── versionen/                v1_main.cc, v2_main2.cc
├── Praxisbericht/
└── docs/
```

## Schnellstart

C++-Prototyp ausprobieren (g++ oder MSVC):

```bash
cd cpp-prototyp
g++ -std=c++17 test_interaktiv.cc -o test_interaktiv
./test_interaktiv
```

Der Structured-Text-Code in `ControlBuilder/` ist eine Abschrift zum Nachlesen; er lässt
sich nicht direkt in Control Builder M importieren (siehe Hinweise in
[`ControlBuilder/README.md`](ControlBuilder/README.md)).
