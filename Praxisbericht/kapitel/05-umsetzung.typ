#import "../vorlage.typ": todo, code-abbildung

// Richtwert: ca. 3 Seiten. Nur zwei Bausteine ausfuehrlich (AddTargetToList,
// DT_Door), je mit kurzem Code-Auszug; alle anderen in eine Tabelle.
// Vollstaendiger Code steht in Anhang A.
= Umsetzung in Control Builder M <kap:umsetzung>

== Projektstruktur
#todo[
  Library `DT_FahrstuhlLib`, Application `TD_Appl`, Tasks Fast/Normal/Slow.
  Screenshot des Projektbaums als Abbildung.
]

== Portierung von C++ nach Structured Text
#todo[
  Die Unterschiede, die aufgehalten haben:
  - `std::vector` → `ArrayObject` mit `GetArray`/`PutArray`/`InsertArray`, weil CBM
    keinen Zugriff mit `[ ]` kennt
  - Indizes 1-basiert statt 0-basiert, „kein Wechsel“ = 0 statt −1
  - IN_OUT-Parameter brauchen lokale Kopien
  - Datentypen und Variablen in Tabellen statt als Text
]

== Funktionsbaustein AddTargetToList
#todo[
  Aufgabe, Ein- und Ausgänge, dann den interessanten Ausschnitt zeigen und im Text
  erklären. Zeilenbereich unten anpassen (zeilen: (von, bis)).
]

// Beispiel: Ausschnitt aus der Datei im Repo. Zeilen anpassen.
#code-abbildung(
  "../ControlBuilder/DT_FahrstuhlLib/FunctionBlockTypes/AddTargetToList.st",
  [Ausschnitt aus dem Funktionsbaustein AddTargetToList],
  zeilen: (1, 25),
) <abb:addtarget>

== Control Module DT_Door
#todo[
  Öffnen und Schließen mit Selbsthaltung, Vorrang von Lichtschranke und Tür-auf-Taste,
  automatisches Schließen nach 5~s mit dem CBM-Datentyp `Timer`. Code-Ausschnitt wie oben.
]

== Übersicht der weiteren Bausteine
#figure(
  table(
    columns: (auto, 1fr),
    table.header([*Baustein*], [*Aufgabe*]),
    [`TD_Gondel`], [Sammelt Innen- und Außenrufe, liefert Zielstock, `HatZiel` und Rufliste],
    [`TD_MotorController`], [Fährt die Gondel in 10er-Pixelschritten zum Zielstock, nur bei geschlossener Tür],
    [`InsertBetweenLimits`, `SortBetweenLimits`], [Fügen ein Ziel sortiert in einen Abschnitt der Zielliste ein],
    [`TD_RemoveAtIndex`], [Löscht ein erreichtes Ziel aus der Liste],
    [`TD_Door_Pos`, `TD_Shaftdoor_Pos`], [Bewegen Kabinen- und Schachttüren in der Visualisierung],
    [`TD_LedSteuerung`], [Schaltet die Taster-LEDs für offene Rufe],
    [`TD_ResetTaster`], [Setzt alle Taster zurück],
  ),
  caption: [Weitere Bausteine der Steuerung],
) <tab:bausteine>
