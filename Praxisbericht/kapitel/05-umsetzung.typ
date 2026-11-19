#import "../vorlage.typ": todo, code-abbildung, abbildung-folgt

// Richtwert: ca. 3 Seiten. Nur zwei Bausteine ausfuehrlich (AddTargetToList,
// DT_Door), je mit kurzem Code-Auszug; alle anderen in eine Tabelle.
// Vollstaendiger Code steht in Anhang A.
= Umsetzung <kap:umsetzung>

== Vorgehen und Arbeitsteilung <kap:vorgehen>
In der ersten Woche stellte die Gruppe die Anforderungen auf. Dazu notierte sich jedes Gruppenmitglied für sich, wie ein Aufzug grundlegend aufgebaut ist und welche Funktionen er erfüllen soll. Die Listen wurden anschließend zusammengetragen und in der Gruppe diskutiert, woraus die Ziele und Anforderungen (@kap:anforderungen) entstanden. Danach wurde der Aufzug ausgelegt; es wurde also festgelegt, welche Sensoren und Aktoren benötigt werden, zum Beispiel Endlagensensoren für die Türen oder ein Positionssensor für die Gondelposition. Anschließend wurde auf Vorgabe des Betreuers zuerst die Türsteuerung `DT_Door` gemeinsam umgesetzt, damit die Gruppe den Control Builder und die Sprache Structured Text kennenlernte. Ab Woche 2 plante die Gruppe eigenständig und hielt dabei den Ist- und Soll-Stand sowie die jeweiligen Aufgaben des Tages fest.

In der zweiten Woche wurde die Logik für den Sortieralgorithmus der Zielliste konzipiert. Der gemeinsame Versuch, diesen direkt in Structured Text zu entwickeln, scheiterte jedoch. Auf Rat des Betreuers teilte sich die Gruppe in drei Untergruppen auf, die jeweils eine eigene Lösung für den Sortieralgorithmus in einer Programmiersprache ihrer Wahl umsetzten und dafür Testfälle schrieben. Anschließend testete die Gruppe die Lösungen gegenseitig und wählte die beste Lösung aus. Diese wurde daraufhin mit einem KI-Werkzeug nach Structured Text migriert (#link(<kap:ki>)[KI-Anmerkung], @kap:uebertragung).

Die letzte Woche wurde dazu verwendet, die übrigen Bausteine zu realisieren. Der Algorithmus wurde als Baustein eingebunden, die Taster wurden angeschlossen und sowohl die LED-Steuerung als auch die Schachttüren wurden umgesetzt. Zudem wurden passende Grafikbilder erstellt (@kap:visualisierung). Diese machten sichtbar, ob die Steuerung wie gewünscht arbeitete, und stellten somit eine große Hilfe dar, da die Programme zuvor im Editor kaum kontrollierbar waren.

== C++-Prototyp der Zielliste <kap:prototyp>
Die Untergruppe, dessen Algorithmus am ende umgesetzt wurden, entwickelte diesen zunächst in C++, da sie diese Sprache am besten kannten.
So konnte die Logik der Zielliste unabhängig von den Fähigkeiten in ControlBuilderM entwickelt und getestet werden.
Dabei hat der Prototyp bereits die selben Funktion wie die finale Implementierung. `SortBetweenLimits` sortiert einen Abschnitt in der Liste und `InsertBetweenLimits` fügt einen Ruf in einen Abschnitt ein und `AddTargetToList` bestimmt den passenden Abschnitt (@kap:zielliste). Der Gesamte Code ist in @anh:cpp zu sehen.

Der Prototyp wurde mit Testfällen getestet, die die Zielliste vor und nach dem fertigen Sortiereingang eines neuen Rufs ausgeben.
Dabei decken die Tests Listen ohne, mit einem und mit zwei Richtungswechseln ab. Anschließend wurde `AddTargetToList` mit einem KI-Werkzeug (#link(<kap:ki>)[KI-Anmerkung]) deutlich gründlicher geprüft: Mit 241 Szenarien für alle Gondelposition, den 20 Testfällen der Gruppe und mittels fünf Zufallsläufen die je 100.000 zufällige Listen aufgebaut und getestet haben. Dabei hat das Werkzeug geprüft, ob Rufe verloren gehen, die Liste mehr als zehn Einträge erhält oder die Gondel einen Ruf in Fahrtrichtung, der noch erreichbar ist, nicht mitnimmt.
Dabei deckten die Test drei Fehler auf. Einmal wurde die Fahrrichtung aus der Richtung des ersten Rufs statt aus der Gondelposition und dem ersten Ziel abgeleitet, nicht mehr erreichbare Rufe wurden deshalb teilweise nur angehängt statt einsortiert zu werden und eine volle Liste wurde erst gar nicht abgefragt. Nach der Korrektur dieser Fehler hat der Algorithmus alle Testfälle der Gruppe bestanden.

Da der Prototyp nur aus einfachen Schleifen und Listenzugriffen bestand, erleichterte dies die Übertragung nach Structured Text.
@kap:uebertragung beschreibt die Anpassungen die trotzdem nötigwaren, damit der Algorithmus fehlerfrei im Structured Text funktionierte.

== Übertragung nach Structured Text <kap:uebertragung>
Für die Übertragung wurde der C++-Code für die Listensortierung an das KI-Werkzeug Claude übergeben (#link(<kap:ki>)[KI-Anmerkung]), das diesen in Structured Text umwandelte. Dabei blieben die grundlegenden Funktionen der C++-Version erhalten, sodass jede Funktion in C++ einem eigenen Funktionsbaustein in ControlBuilderM entspricht.\
Die erste Version der ST-Version griff noch mit eckigen Klammern auf Listen zu, zum Beispiel `TargetListe[i]`. In der Structured-Text-Version von ControlBuilderM gibt es diese Zugriffsmethode jedoch nicht und man muss mit den Funktionen `GetArray`, `PutArray` und `InsertArray` auf die Listen zugreifen. Daraufhin gab die Gruppe Claude Screenshots der Dokumentation zu diesen Funktionen, sodass die zweite Version mit diesen arbeitete und anschließend vom Betreuer in die virtuelle Maschine kopiert wurde.
Dadurch fielen aber weitere Fehler auf; die Indizes begannen mit 0, wie es bei C++ üblich ist, während diese in ControlBuilderM mit 1 starten. Aus diesem Grund mussten die Marker für „kein Richtungswechsel“ von -1 auf 0 abgeändert werden.
Zudem wurden die Einträge in `TargetCount` zwischen den verschiedenen Funktionsbausteinen nicht richtig weitergegeben; die Gruppe behob dies, indem sie jeweils die Liste und den Zähler einmal als Eingang (`TargetCountIn`, `TargetListIn`) und einmal als Ausgang (`TargetCount`, `TargetList`) anlegte. Zum Schluss wurde noch ein Schutz gegen eine volle Liste ergänzt, da `ArrayObjects` anders als ein `std::vector` nicht mitwächst und sonst `InsertArray` das letzte Element verliert.
@tab:uebertragung stellt die Änderungen noch einmal übersichtlich dar.

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
  ),
  caption: [Unterschiede zwischen C++-Prototyp und Structured Text],
) <tab:uebertragung>

Die Logik selbst musste bei der Übertragung nicht geändert werden. Die Fehler entstanden ausschließlich aus den Eigenheiten von Control Builder M.

== Projektstruktur und Türsteuerung in Control Builder M <kap:bausteine>
Das Projekt in Control Builder M besteht aus der Bibliothek `DT_FahrstuhlLib`, der Application `TD_Appl` und dem Soft Controller `Controller_TD`. In der Bibliothek liegen die Typen aller Bausteine, also der Datentyp `Target`, die vier Function Blocks der Zielliste und die sieben Control Modules. In `TD_Appl` werden diese Typen instanziiert und in den beiden Diagrammen `DT_Gondel` und `DT_Door` verschaltet (@kap:loesungsentwurf). Die Application läuft in der Task `Normal` des Controllers. @tab:bausteine ordnet die Bausteine ihrem Typ und ihrem Diagramm zu; ihre Aufgaben beschreibt @abb:systemaufbau.

#figure(
  table(
    columns: (1fr, auto, auto),
    align: left,
    table.header([*Baustein*], [*Typ*], [*Instanziiert in*]),
    [`TD_Gondel`, `TD_MotorController`, \ `TD_ResetTaster`, `TD_LedSteuerung`], [Control Module], [Diagramm `DT_Gondel`],
    [`DT_Door`, `TD_Door_Pos`, `TD_Shaftdoor_Pos`], [Control Module], [Diagramm `DT_Door`],
    [`AddTargetToList`, `TD_RemoveAtIndex`], [Function Block], [`TD_Gondel`],
    [`InsertBetweenLimits`, `SortBetweenLimits`], [Function Block], [`AddTargetToList`],
  ),
  caption: [Typ und Einbindung der Bausteine in `TD_Appl`],
) <tab:bausteine>

Wie die Zielliste in Structured Text umgesetzt wurde, beschreibt bereits @kap:uebertragung. Im Folgenden wird deshalb nur die Türsteuerung `DT_Door` genauer betrachtet, da sie die sicherheitsrelevanten Anforderungen A6 bis A8 (@tab:anforderungen) erfüllt. Ihr Verhalten wurde in @abb:ablauf beschrieben; hier geht es darum, wie es im Code umgesetzt ist. Der folgende Ausschnitt zeigt den Kern des Bausteins.

#code-abbildung(
  "../ControlBuilder/DT_FahrstuhlLib/ControlModuleTypes/DT_Door.st",
  [Öffnen, Offenhaltezeit und Schließen im Control Module DT_Door, eigene Darstellung],
  zeilen: (62, 89),
) <abb:door-code>

*Flanken.* \
Die Ankunft der Gondel und eine Öffnungsanforderung von `TD_Gondel` liegen als Dauersignal an. Damit die Tür nicht bei jedem Zyklus erneut geöffnet wird, wertet `DT_Door` nur die steigenden Flanken aus. Dazu speichert der Baustein den Wert aus dem letzten Zyklus in `EnableTuerAlt` bzw. `TuerAufRequestAlt` und bildet daraus die Signale `Angekommen` und `NeuerAufRequest`.

*Selbsthaltung.* \
Die Taster und die Lichtschranke sind nur kurz aktiv, die Tür braucht aber mehrere Zyklen, um ihre Endlage zu erreichen. Deshalb werden `Oeffnen` und `Schliessen` als Merker mit Selbsthaltung umgesetzt: Ein Ereignis setzt den Merker, und erst das Erreichen der jeweiligen Endlage setzt ihn wieder zurück. Beim Öffnen wird `Schliessen` gleichzeitig zurückgesetzt, außerdem darf `Schliessen` nur gesetzt werden, solange `Oeffnen` nicht aktiv ist. Dadurch hat das Öffnen immer Vorrang, und ein laufender Schließvorgang wird von der Lichtschranke oder dem Tür-auf-Taster sofort abgebrochen (A7). Die Endlagen von Kabinen- und Schachttür werden vorher mit UND zu `EndlageAuf` und `EndlageZu` zusammengefasst, sodass eine Bewegung erst abgeschlossen ist, wenn beide Türen ihre Endlage erreicht haben.

*Offenhaltezeit.* \
Für die Offenhaltezeit (A8) wird der Datentyp `Timer` aus der Bibliothek von Control Builder M verwendet. Er wird mit der Funktion `Timer` gesteuert, die abgelaufene Zeit liefert `TimerElapsed`. Der Timer läuft nur, solange die Tür offen ist und weder die Lichtschranke noch der Tür-auf-Taster aktiv ist. Ist die eingestellte Zeit `TimerTuerZu` von 5~s erreicht, wird `OffenZeitAbgelaufen` gesetzt und löst das Schließen aus, genau wie der Tür-zu-Taster.

*Ausgänge.* \
Aus den Merkern werden zum Schluss die Motorbefehle `TuerAufCmd`, `TuerZuCmd`, `TuerAufSchacht` und `TuerZuSchacht` für Kabinen- und Schachttür gebildet, die jeweils an der eigenen Endlage abschalten. Die Fahrtfreigabe `EnableGondel := EndlageZu and not Oeffnen` ist nur aktiv, wenn beide Türen geschlossen sind und kein Öffnen ansteht (A6).

== Visualisierung <kap:visualisierung>
#todo[
  Grafikbild „Fahrstuhl Schacht“: Schacht mit Stockwerken 0 bis 5, Außentaster,
  Bedienfeld der Kabine, Tür und Lichtschranke; dynamische Anzeige von
  Gondelposition, Türen und LEDs.
]

#abbildung-folgt(
  [Screenshot des Grafikbilds „Fahrstuhl Schacht“],
  [Visualisierung der Aufzugssteuerung, eigene Darstellung],
) <abb:visualisierung>
