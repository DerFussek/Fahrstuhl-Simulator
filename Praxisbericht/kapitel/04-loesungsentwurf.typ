#import "../vorlage.typ": todo, abbildung-folgt

// Richtwert: ca. 3,5 Seiten. Das wichtigste Kapitel: warum die Steuerung so
// gebaut ist. Mit dem Schreiben hier anfangen.
= Lösungsgenerierung und -bewertung <kap:loesungsentwurf>

== Systemaufbau und Schnittstellen der Bausteine

#figure(
  image("../bilder/systemaufbau.svg", width: 100%),
  caption: [Systemaufbau der Aufzugssteuerung],
) <abb:systemaufbau>


Die Steuerung besteht aus neun Bausteinen, die in @abb:systemaufbau dargestellt
sind. Zentrales Element ist das Control Module `TD_Gondel`. Es liest die Signale
aller Taster ein, verwaltet die Zielliste und gibt an die übrigen Bausteine
weiter, wohin die Gondel fahren soll und wann die Tür öffnen muss. Die Taster
selbst sind Teil der Visualisierung. Das sind die Innentaster für die
Stockwerke 1 bis 6, die Außentaster „hoch“ für die Stockwerke 1 bis 5 und die
Außentaster „runter“ für die Stockwerke 2 bis 6.

`TD_Gondel` fasst die Taster zunächst in drei Feldern zusammen. Neue Rufe
sortiert der Funktionsbaustein `AddTargetToList` in die Zielliste ein, die bis
zu zehn Ziele aus Stockwerk und Richtung aufnimmt (@kap:zielliste). Erreichte
Ziele entfernt `TD_RemoveAtIndex` wieder aus der Liste. Sobald die Liste
mindestens einen Eintrag hat, setzt `TD_Gondel` den Ausgang `HatZiel` und gibt
das erste Ziel als `ZielStock` aus. Nach der Bedienung eines Rufs sendet es
`ResetTaster` an `TD_ResetTaster`, das die betätigten Taster zurücksetzt.

Den Antrieb übernimmt `TD_MotorController`. Er bekommt den `ZielStock` und fährt
die Gondel, solange `Enable` gesetzt ist. Die aktuelle Position meldet er als
`GondelPos` zurück an `TD_Gondel`, damit die Zielliste relativ zur Kabine
sortiert werden kann. Erreicht die Gondel das Ziel, setzt er `Done`. Dieses
Signal geht an `TD_Gondel` (`RemoveFirstEntry`) und an `DT_Door`
(`EnableTuer`). Zusätzlich liefert er die Position als `GondelPosExpo` an
`TD_Shaftdoor_Pos`, damit sich die Schachttür im richtigen Stockwerk bewegt.

`DT_Door` steuert die Kabinentür und die Schachttür und wertet dafür die
Endlagen, die Lichtschranke und die Taster „Tür auf“ und „Tür zu“ aus. Das
Signal `EnableGondel` meldet, dass die Tür geschlossen ist. `TD_Gondel`
verknüpft es mit `HatZiel` durch ein UND-Glied und führt das Ergebnis dem
Eingang `Enable` des Motors zu. Den Befehl `TuerAufCMD` gibt `TD_Gondel`
direkt an `DT_Door` weiter. Die Türen selbst bewegen die Control Modules
`TD_Door_Pos` für die Kabinentür und `TD_Shaftdoor_Pos` für die Schachttür.
Sie bekommen von `DT_Door` die Befehle zum Öffnen und Schließen und melden
die Endlagen zurück.

Zuletzt wertet `TD_LedSteuerung` die Zielliste (`TargetList`, `TargetCount`)
aus und beleuchtet die Taster, deren Ruf noch offen ist.

Die Bausteine sind überwiegend Control Modules, nur die Listenoperationen
sind Funktionsbausteine, die innerhalb von `TD_Gondel` aufgerufen werden. Der
Datenaustausch zwischen den Diagrammen `DT_Gondel` und `DT_Door` läuft über
Communication Variables. Die Anwendung `TD_Appl` ist damit in zwei Diagramme
gegliedert. Das eine enthält die Fahrlogik, das andere die Tür.

== Ablauf einer Fahrt

#figure(
  image("../bilder/ablauf-gesamt.svg", width: 100%),
  caption: [Ablauf vom Ruf bis zur Fahrt],
) <abb:ablauf>

Eine Fahrt läuft in sechs Schritten ab: Ruf aufnehmen, einsortieren, Tür
schließen, fahren, halten und Tür öffnen, Ruf löschen. Die Steuerung hat dafür
keine ausdrückliche Zustandsvariable. Der Ablauf ergibt sich aus dem
Zusammenspiel von Zielliste, Tür und Motor, und die Zustände im
rechten Teil von @abb:ablauf sind aus deren Signalen abgeleitet.
@tab:zustaende fasst sie mit ihren Erkennungsmerkmalen und Übergängen zusammen.

*Ruf aufnehmen und einsortieren.* Betätigt jemand einen Innen- oder
Außentaster, übernimmt `TD_Gondel` das Signal und gibt es als Ziel aus
Stockwerk und Richtung an `AddTargetToList`. Der Baustein ignoriert doppelte
Rufe und nimmt bei zehn Einträgen keine weiteren auf. Ist die Gondel bereits
im gewünschten Stockwerk, öffnet nur die Tür (`TuerAufCMD`), und der Ruf
kommt nicht in die Liste (A5 in @tab:anforderungen). Steht schon ein Ziel in
der Liste, gilt das nur für einen Ruf in Fahrtrichtung. Alle anderen Rufe
sortiert der Baustein nach dem Richtungsprinzip ein (@kap:zielliste). Sie
werden auch während einer Fahrt einsortiert und können das erste Ziel
verändern. Der linke Teil von @abb:ablauf zeigt diese Rufbearbeitung.

*Tür schließen.* Sobald die Liste einen Eintrag hat, setzt `TD_Gondel` den
Ausgang `HatZiel`. Gefahren wird aber erst, wenn auch `EnableGondel` von
`DT_Door` anliegt, also bei vollständig geschlossener Tür (A6). Ist die Tür
noch offen, schließt `DT_Door` sie nach der Offen-Zeit von 5~s (A8). Dabei
haben Lichtschranke und Tür-auf-Taste Vorrang: Solange eine von beiden aktiv
ist, läuft die Zeit nicht, und eine laufende Schließbewegung wird durch sie
wieder in eine Öffnung umgekehrt (A7).

*Fahren.* Mit `EnableGondel` und `HatZiel` liegt `Enable` am
`TD_MotorController` an. Er liest das erste Listenelement als `ZielStock` und
bewegt die Gondel pro Zyklus um zehn Pixel Richtung Zielposition. Ein
Stockwerk entspricht 180 Pixeln. Die aktuelle Position meldet er als
`GondelPos` zurück.

*Halten und Tür öffnen.* Ist die Zielposition erreicht, setzt der Motor `Done`
und hält an. `DT_Door` erkennt `Done` als steigende Flanke an `EnableTuer` und
gibt den Öffnen-Befehl an `TD_Door_Pos` (Kabinentür) und `TD_Shaftdoor_Pos`
(Schachttür). Welche Schachttür dabei fährt, bestimmt `GondelPosExpo`. Nach dem Erreichen der Endlage beginnt die Offen-Zeit von
5~s.

*Ruf löschen.* Mit `Done` löscht `TD_Gondel` über `RemoveFirstEntry` den ersten
Eintrag der Zielliste. `TD_RemoveAtIndex` lässt ihn weg, die übrigen Ziele
rücken nach vorn. `TD_LedSteuerung` setzt in jedem Zyklus alle LEDs zurück und
leuchtet nur die Taster der noch offenen Rufe, die LED des bedienten Rufs
erlischt also von selbst. Stehen noch weitere Ziele in der Liste, schließt die
Tür, und die nächste Fahrt beginnt.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    align: (left, left, left),
    table.header([*Zustand*], [*Erkennbar an*], [*Übergang*]),
    [Leerlauf], [`HatZiel` = false, Tür geschlossen],
      [Neuer Ruf in anderem Stockwerk: Fahren. Ruf im aktuellen Stockwerk: Tür öffnet],
    [Fahren], [`EnableGondel` und `HatZiel`, Gondel nicht am Ziel],
      [`Done`: Tür öffnet],
    [Tür öffnet], [`Oeffnen` in `DT_Door`],
      [Endlage Auf erreicht: Tür offen],
    [Tür offen], [Endlage Auf, Offen-Timer läuft],
      [5~s ohne Lichtschranke und Tür-auf-Taste, oder Tür-zu-Taste: Tür schließt],
    [Tür schließt], [`Schliessen` in `DT_Door`],
      [Endlage Zu erreicht: Fahren (mit Ziel) oder Leerlauf. Lichtschranke oder Tür-auf-Taste: Tür öffnet],
  ),
  caption: [Zustände der Aufzugssteuerung],
) <tab:zustaende>

== Lösungsvarianten für die Rufverwaltung <kap:varianten>
#todo[
  Die vier Ansätze aus der Entwurfsphase, je zwei bis drei Sätze:
  - Einfügen mit Fallunterscheidung: Liste durchlaufen, Nachbarn vergleichen,
    je nach Fall einfügen (erster Versuch direkt in Structured Text)
  - Dummy-Eintrag in Gegenrichtung für nicht mehr erreichbare Ziele
  - Drei getrennte Listen (auf dem Weg, Gegenrichtung, nicht mehr auf dem Weg)
  - Eine Liste mit zwei Markern für die Richtungswechsel
]

== Bewertung und Auswahl
#todo[
  Einleitender Satz zu den Kriterien, dann @tab:varianten füllen und die Auswahl
  in zwei bis drei Sätzen begründen.
]

#figure(
  table(
    columns: (1fr, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    table.header(
      [*Variante*], [*Korrektheit*], [*Übersicht-\ lichkeit*], [*Rechen-\ aufwand*], [*Umsetzbar-\ keit in CBM*],
    ),
    [Einfügen mit Fallunterscheidung], [], [], [], [],
    [Dummy-Eintrag], [], [], [], [],
    [Drei getrennte Listen], [], [], [], [],
    [Eine Liste mit zwei Markern], [], [], [], [],
  ),
  caption: [Bewertung der Lösungsvarianten für die Rufverwaltung],
) <tab:varianten>

== Algorithmus der Zielliste <kap:zielliste>
#todo[
  - Aufbau der Liste: bis zu drei Abschnitte (Fahrtrichtung vor der Kabine,
    Gegenrichtung, wieder Startrichtung)
  - Marker `rWechsel1` und `rWechsel2` für die Richtungswechsel
  - Einsortieren an einem Beispiel durchspielen: Kabine in Stock 2 aufwärts,
    nacheinander Innenrufe in 4, 1 und 3 -- die Liste nach jedem Schritt als
    kleine Tabelle
  - Sonderfälle: leere Liste, doppelter Ruf, volle Liste, Ruf im aktuellen Stockwerk
]
