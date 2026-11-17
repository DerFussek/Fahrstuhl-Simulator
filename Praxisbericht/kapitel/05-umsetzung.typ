#import "../vorlage.typ": todo, code-abbildung, abbildung-folgt

// Richtwert: ca. 3 Seiten. Nur zwei Bausteine ausfuehrlich (AddTargetToList,
// DT_Door), je mit kurzem Code-Auszug; alle anderen in eine Tabelle.
// Vollstaendiger Code steht in Anhang A.
= Umsetzung <kap:umsetzung>

== Vorgehen und Arbeitsteilung <kap:vorgehen>
#todo[
  - Erster Versuch: Einsortieren direkt in Structured Text in der ganzen Gruppe;
    nach rund einer Woche noch keine funktionierende Lösung
  - Wechsel des Vorgehens auf Anregung des Betreuers: drei Untergruppen, Logik in
    der jeweils vertrauten Sprache, gegenseitiges Testen, Übertragung des besten
    Algorithmus nach Structured Text mit einem KI-Werkzeug (@kap:ki)
  - Danach Integration und Visualisierung wieder in der ganzen Gruppe
]

== C++-Prototyp der Zielliste
#todo[
  Funktionen `SortBetweenLimits` und `AddTargetToList` (Code in @anh:cpp). Welche
  Konventionen die spätere Übertragung leicht machten (Richtung als BOOL, kein
  vorzeitiges RETURN).
]

== Übertragung nach Structured Text
#todo[
  Die Unterschiede, die aufgehalten haben:
  - `std::vector` → `ArrayObject` mit `GetArray`/`PutArray`/`InsertArray`, weil CBM
    keinen Zugriff mit `[ ]` kennt
  - Indizes 1-basiert statt 0-basiert, „kein Wechsel“ = 0 statt −1
  - IN_OUT-Parameter brauchen lokale Kopien
  - Datentypen und Variablen in Tabellen statt als Text
]

== Bausteine in Control Builder M
#todo[
  Projektstruktur in ein bis zwei Sätzen (Library `DT_FahrstuhlLib`, Application
  `TD_Appl`, Tasks Fast/Normal/Slow). Dann `AddTargetToList` (Aufgabe, Ein- und
  Ausgänge, interessanter Ausschnitt) und `DT_Door` (Selbsthaltung, Vorrang von
  Lichtschranke und Tür-auf-Taste, automatisches Schließen nach 5~s mit dem
  CBM-Datentyp `Timer`). Zeilenbereich unten anpassen (zeilen: (von, bis)).
]

// Beispiel: Ausschnitt aus der Datei im Repo. Zeilen anpassen.
#code-abbildung(
  "../ControlBuilder/DT_FahrstuhlLib/FunctionBlockTypes/AddTargetToList.st",
  [Ausschnitt aus dem Funktionsbaustein AddTargetToList, eigene Darstellung],
  zeilen: (1, 25),
) <abb:addtarget-code>

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

== Visualisierung
#todo[
  Grafikbild „Fahrstuhl Schacht“: Schacht mit Stockwerken 0 bis 5, Außentaster,
  Bedienfeld der Kabine, Tür und Lichtschranke; dynamische Anzeige von
  Gondelposition, Türen und LEDs.
]

#abbildung-folgt(
  [Screenshot des Grafikbilds „Fahrstuhl Schacht“],
  [Visualisierung der Aufzugssteuerung, eigene Darstellung],
) <abb:visualisierung>
