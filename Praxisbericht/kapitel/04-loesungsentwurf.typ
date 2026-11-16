#import "../vorlage.typ": todo, abbildung-folgt

// Richtwert: ca. 3,5 Seiten. Das wichtigste Kapitel: warum die Steuerung so
// gebaut ist. Mit dem Schreiben hier anfangen.
= Lösungsgenerierung und -bewertung <kap:loesungsentwurf>

== Systemaufbau und Schnittstellen der Bausteine

#figure(
  image("../bilder/systemaufbau.svg", width: 100%),
  caption: [Systemaufbau der Aufzugssteuerung],
) <abb:systemaufbau>


Die gesamte Steuerung besteht aus neun Bausteinen, die in @abb:systemaufbau dargestellt sind. Dabei ist das Control Modul `TD_Gondel` das zentrale Element. Es liest die Signale
aller Taster ein, verwaltet die Zielliste und gibt an die übrigen Bausteine
weiter, wohin die Gondel fahren soll und wann die Türen öffnen muss. Die Taster sind direkt in das Grafikbild integriert und gliedern sich in insgesamt sechs Innentaster sowie zehn Außentaster (aufgeteilt in jeweils fünf Taster für die Aufwärts- und Abwärtsfahrt).

Das Modul `TD_Gondel` fasst die Taster in drei Arrays zusammen. Neue Rufe werden durch
den Funktionsbaustein `AddTargetToList` in die Zielliste einsortiert, die maxiam zehn Ziele,
bestehend aus Stockwerk und Richtung, aufnehmen kann (@kap:zielliste). Erreichte Ziele werden anschließend über TD_RemoveAtIndex wieder aus der Liste entfernt.

Die Motorsteuerung für die Gondel übernimmt der Baustein `TD_MotorController`. Dieser erhält ein `ZielStock` und fährt die Gondel, solange die Freigabe `Enable` aktiv ist, zum entsprechenden Zielstockwerk. Die aktuelle Position der Gondel wird als `GondelPos` an `TD_Gondel` zurückgesendet, um eine relative Sortierung der Zielliste zur Gondelposition umzusetzen.

Der Baustein `DT_Door` übernimmt die Steuerung der Kabinen- und Schachttürren.
Dafür wertet dieser die Endlagen, die Lichtschranke und die Taster "Tür auf" und "Tür zu" aus. Dabei sendet dieser über `EnableGondel` den geschlossen Zustand der Türen zurück.
Im Diagram `DT_Gondel` wird dies über einem Und-Gatter mit `HatZiel` verknüpft und steuert so die Freigabe `Enable` der Motorsteuerung.

Zuletzt wertet `TD_LedSteuerung` die Zielliste (`TargetList`, `TargetCount`)
aus und beleuchtet die Taster, deren Rufe noch offen sind.

Innerhalb der Anwendung `TD_Appl` ist die Steuerung auf zwei Diagramme aufgeteilt. Dabei übernimmt `DT_Gondel` die Fahrlogik, während `DT_Door` die Türsteuerung regelt. Die Kommunikation zwischen den beiden Diagrammen findet über Communication Variablen statt.
Fast alle Bausteine sind als Control Module implementiert, außer die Listenoperationen, die als Funktionsbausteine direkt in `TD_Gondel` benutzt werden.

== Ablauf einer Fahrt

#figure(
  image("../bilder/ablauf-gesamt.svg", width: 100%),
  caption: [Ablauf vom Ruf bis zur Fahrt],
) <abb:ablauf>

Eine Fahrt läuft in sechs verschiedenen Schritten ab: Ruf aufnehmen, einsortieren, Tür schließen, fahren, halten und Tür öffnen sowie Ruf löschen. Diese Schritte exsistieren nicht als Zustandsvariablen, sondern ergeben sich durch das Verhalten aus dem Zusammenspiel von Zielliste, Tür und Motor; die Zustände im rechten Teil von @abb:ablauf werden direkt aus deren Signalen abgeleitet.

*Ruf aufnehmen und einsortieren.* \ Betätigt eine Person einen Innen- oder
Außentaster, übernimmt `TD_Gondel` das Signal und gibt es als Ziel aus
Stockwerk und Richtung an `AddTargetToList` weiter. Die Funktion ignoriert doppelte
Rufe und nimmt bei zehn Einträgen keine weiteren an. Ist die Gondel bereits
im gewünschten Stockwerk, öffnet nur die Tür (`TuerAufCMD`) und der Ruf
wird nicht in die Liste einsortiert (A5 in @tab:anforderungen). Ist schon ein Ziel in
der Liste, gilt dies nur für einen Ruf in Fahrtrichtung. Alle anderen Rufe
sortiert die Funktion nach dem Richtungsprinzip ein (@kap:zielliste). 
Die Einsortierung der Liste erfolgt auch parallel während einer Fahrt und kann somit auch das erste Ziel verändern. Der linke Teil von @abb:ablauf zeigt diese Rufbearbeitung.

*Tür schließen.* \ Sobald mindestens ein Eintrag in der Zielliste ist, 
aktiviert `TD_Gondel` den Ausgang `HatZiel`. Der Motor startet jedoch erst,
wenn auch das Freigabesignal `EnableGondel` von `DT_Door` aktiv ist (A6).
Ist die Tür noch offen, wird nach 5~s Offenhaltezeit die Tür geschlossen (A8).
Die Lichtschranke und der Tür-auf-Taster sind jeodch priorisiert. Solange eines dieser beiden Signale aktiv ist, hält der Timer an und ein aktiver Schließvorgang wird zu einem Öffnen der Tür umgewandelt (A7).

*Fahren.* \ Sobalt `Enable` am `TD_MotorController` anliegt, 
liest dieser das erste Element in der Zielliste als `ZielStock` und
bewegt die Gondel pro Zyklus um zehn Pixel in Richtung Zielposition. Ein
Stockwerk entspricht dabei 180 Pixeln. Die aktuelle Position meldet er als
`GondelPos` und `GondelPosExpo` zurück.

*Halten und Tür öffnen.* \ Ist die Zielposition erreicht, aktiviert die Motorsteuerung `Done`
und hält an. `DT_Door` erkennt `Done` als steigende Flanke an `EnableTuer` und
gibt ein Öffnen-Befehl an `TD_Door_Pos` (Kabinentür) und `TD_Shaftdoor_Pos`
(Schachttür) weiter. Welche Schachttür dabei auf- und zufährt, bestimmt `GondelPosExpo`. Nach dem Erreichen der Endlage beginnt die Offen-Zeit von 5~s.

*Ruf löschen.* \ Mit dem Signal `Done` löscht `TD_Gondel` den ersten
Eintrag in der Zielliste. Dabei rücken die übrigen Ziele nach vorn. 
`TD_LedSteuerung` setzt in jedem Zyklus alle LEDs zurück und
beleuchtet nur die Taster der noch offenen Rufe hat.
Sind noch weitere Ziele in der Liste, schließen die
Türen und die nächste Fahrt wird bearbeitet.


#todo("Tabelle 2 an den veränderten Text in 4.1 und 4.2 anpassen.")
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
