#import "../vorlage.typ": todo, code-abbildung, abbildung-folgt

// Richtwert: ca. 3 Seiten. Nur zwei Bausteine ausfuehrlich (AddTargetToList,
// DT_Door), je mit kurzem Code-Auszug; alle anderen in eine Tabelle.
// Vollstaendiger Code steht in Anhang A.
= Umsetzung <kap:umsetzung>

== Vorgehen und Arbeitsteilung <kap:vorgehen>
Die Gruppe aus sechs Personen arbeitete drei Wochen (26.10. bis 13.11.2026) an dem Projekt. Da die Aufgabe offen gestellt war, dienten die ersten drei bis vier Tage dazu, die Anforderungen festzulegen. Dazu sammelte zunächst jedes Gruppenmitglied für sich Ideen, danach skizzierte die Gruppe die Anlage, sammelte die Regeln der Rufabarbeitung und zeichnete die Abläufe als Diagramme (@anh:skizzen). Daraus entstanden die Anforderungen und der Aufbau des simulierten Aufzugs (@kap:anforderungen). Anschließend wurde auf Vorgabe des Betreuers zuerst die Türsteuerung `DT_Door` gemeinsam umgesetzt, damit die Gruppe den Control Builder und die Sprache Structured Text kennenlernte. Ab Woche 2 plante die Gruppe eigenständig und hielt dabei den Ist- und Soll-Stand sowie die jeweiligen Aufgaben des Tages fest.

In der zweiten Woche wurde die Logik für den Sortieralgorithmus der Zielliste konzipiert. Der gemeinsame Versuch, diesen direkt in Structured Text zu entwickeln, scheiterte jedoch. Auf Rat des Betreuers teilte sich die Gruppe in drei Untergruppen auf, die jeweils eine eigene Lösung für den Sortieralgorithmus in einer Programmiersprache ihrer Wahl umsetzten und dafür Testfälle schrieben. Anschließend testete die Gruppe die Lösungen gegenseitig und wählte die beste Lösung aus. Diese wurde daraufhin mit einem KI-Werkzeug nach Structured Text migriert (#link(<kap:ki>)[KI-Anmerkung], @kap:uebertragung).

Die letzte Woche wurde dazu verwendet, die übrigen Bausteine zu realisieren. Der Algorithmus wurde als Baustein eingebunden, die Taster wurden angeschlossen und sowohl die LED-Steuerung als auch die Schachttüren wurden umgesetzt. Zudem wurden passende Grafikbilder erstellt (@kap:visualisierung). Sie machten erstmals sichtbar, ob die Steuerung wie gewünscht arbeitete, was im Editor zuvor kaum zu kontrollieren war.

== C++-Prototyp der Zielliste <kap:prototyp>
Die Untergruppe, dessen Algorithmus am ende umgesetzt wurden, entwickelte diesen zunächst in C++, da sie diese Sprache am besten kannten.
So konnte die Logik der Zielliste unabhängig von den Fähigkeiten in ControlBuilderM entwickelt und getestet werden.
Dabei hat der Prototyp bereits dieselben Funktionen `SortBetweenLimits`, `InsertBetweenLimits` und `AddTargetToList` wie die finale Implementierung (@kap:zielliste). Der Gesamte Code ist in @anh:cpp zu sehen.

Wie der Prototyp getestet wurde und welche Fehler dabei auffielen, beschreibt @kap:test-prototyp.

Da der Prototyp nur aus einfachen Schleifen und Listenzugriffen bestand, erleichterte dies die Übertragung nach Structured Text.
@kap:uebertragung beschreibt die Anpassungen die trotzdem nötigwaren, damit der Algorithmus fehlerfrei im Structured Text funktionierte.

== Übertragung nach Structured Text <kap:uebertragung>

Für die Übertragung wurde der C++-Code an das KI-Werkzeug Claude übergeben (#link(<kap:ki>)[KI-Anmerkung]), das ihn in Structured Text umwandelte; jede C++-Funktion entspricht dabei einem Function Block. Die erste Version griff noch mit eckigen Klammern wie `TargetList[i]` auf Listen zu, was Control Builder M nicht kennt. Mit Screenshots der Dokumentation zu `GetArray`, `PutArray` und `InsertArray` entstand eine zweite Version, die der Betreuer in die virtuelle Maschine kopierte. Dort fielen drei weitere Fehler auf: Die Indizes begannen wie in C++ bei 0 statt bei 1, der Zähler `TargetCount` wurde zwischen den Bausteinen nicht richtig weitergegeben, und `InsertArray` verlor bei voller Liste das letzte Element, weil ein `ArrayObject` anders als ein `std::vector` nicht mitwächst. @tab:uebertragung fasst zusammen, wie diese Unterschiede gelöst wurden.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    table.header([*Merkmal*], [*C++-Prototyp*], [*Structured Text*]),
    [Liste], [`std::vector<Target>`], [`ArrayObject` mit `TargetCount` als Zähler],
    [Zugriff], [`TargetList[i]`, `insert()`], [`GetArray`, `PutArray`, `InsertArray`],
    [Erster Index], [0, „kein Wechsel“ = −1], [1, „kein Wechsel“ = 0],
    [Richtung], [`enum Direction`], [`bool` (true = rauf)],
    [Liste als Parameter], [Referenz (`&`)], [Getrennte Ein- und Ausgänge (`TargetListIn`, `TargetList`)],
    [Bausteinart], [Funktionen], [Function Blocks],
    [Volle Liste], [`std::vector` wächst mit], [Abfrage vor `InsertArray`],
  ),
  caption: [Unterschiede zwischen C++-Prototyp und Structured Text],
) <tab:uebertragung>

Die Logik selbst musste nicht geändert werden; alle Fehler entstanden aus den Eigenheiten von Control Builder M.

== Projektstruktur und Türsteuerung in Control Builder M <kap:bausteine>

Das Projekt besteht aus der Bibliothek `DT_FahrstuhlLib` mit den Typen aller Bausteine, der Application `TD_Appl` und dem Soft Controller `Controller_TD`, in dessen Task `Normal` die Application läuft. Die vier Function Blocks der Zielliste werden in `TD_Gondel` bzw. `AddTargetToList` aufgerufen, alle übrigen Bausteine sind Control Modules in den Diagrammen `DT_Gondel` und `DT_Door` (@abb:systemaufbau). Der vollständige Code steht in @anh:st.

*Rufe in `TD_Gondel`.* \
`TD_Gondel` schreibt die Zustände der 16 Taster in jedem Zyklus mit `PutArray` in drei ArrayObjects. Eine `for`-Schleife über die Stockwerke liest sie mit `GetArray` aus, bildet für jeden gedrückten Taster ein `Target` und übergibt es an `AddTargetToList` (@kap:zielliste, @kap:uebertragung). Die Richtung eines Innenrufs ergibt sich aus dem Vergleich von Stockwerk und Gondelposition.

*Türsteuerung `DT_Door`.* \
`DT_Door` erfüllt die sicherheitsrelevanten Anforderungen A6 bis A8; ihr Verhalten beschreibt @abb:ablauf. Weil Taster und Lichtschranke nur kurz aktiv sind, die Tür aber mehrere Zyklen bis zur Endlage braucht, sind `Oeffnen` und `Schliessen` als Merker mit Selbsthaltung umgesetzt: Ein Ereignis setzt den Merker, erst die Endlage setzt ihn zurück. Der folgende Ausschnitt zeigt das Öffnen. Es setzt `Schliessen` sofort zurück und hat damit Vorrang, sodass Lichtschranke oder Tür-auf-Taster einen Schließvorgang abbrechen (A7).

#code-abbildung(
  "../ControlBuilder/DT_FahrstuhlLib/ControlModuleTypes/DT_Door.st",
  [Öffnen mit Selbsthaltung im Control Module DT_Door, eigene Darstellung],
  zeilen: (62, 71),
) <abb:door-code>

Ankunft und Öffnungsanforderung wertet der Baustein nur als steigende Flanke aus (`Angekommen`, `NeuerAufRequest`), damit die Tür nicht in jedem Zyklus neu öffnet. Die Offenhaltezeit von 5~s (A8) misst der Datentyp `Timer` aus Control Builder M; er wird angehalten, solange Lichtschranke oder Tür-auf-Taster aktiv sind. Die Fahrtfreigabe `EnableGondel := EndlageZu and not Oeffnen` ist nur bei geschlossenen Türen ohne anstehendes Öffnen aktiv (A6).

== Visualisierung <kap:visualisierung>
#todo[
  Nur das Grafikbild beschreiben; den Aufbau des Aufzugs nicht erneut aufzählen,
  sondern auf @kap:aufbau verweisen.
  Grafikbild „Fahrstuhl Schacht“: Schacht mit Stockwerken 0 bis 5, Außentaster,
  Bedienfeld der Kabine, Tür und Lichtschranke; dynamische Anzeige von
  Gondelposition, Türen und LEDs.
]

#abbildung-folgt(
  [Screenshot des Grafikbilds „Fahrstuhl Schacht“],
  [Visualisierung der Aufzugssteuerung, eigene Darstellung],
) <abb:visualisierung>
