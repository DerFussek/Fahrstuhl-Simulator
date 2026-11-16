#import "../vorlage.typ": todo

// Richtwert: ca. 3,5 Seiten. Das wichtigste Kapitel: warum die Steuerung so
// gebaut ist. Mit dem Schreiben hier anfangen.
= Lösungsgenerierung und -bewertung <kap:loesungsentwurf>

== Systemaufbau und Schnittstellen der Bausteine
#todo[
  Die Bausteine und welche Signale zwischen ihnen laufen. Abbildung beschreiben:
  `TD_Gondel` sammelt die Rufe und gibt Zielstock, Rufliste und Tür-auf-Befehl an
  Motor, LEDs und Tür; `DT_Door` gibt die Fahrt über `EnableGondel` frei.
  Signalnamen vorher mit den Diagrammen in `TD_Appl` abgleichen.
]

#figure(
  image("../bilder/systemaufbau.svg", width: 100%),
  caption: [Systemaufbau der Aufzugssteuerung, eigene Darstellung],
) <abb:systemaufbau>

== Ablauf einer Fahrt
#todo[
  Ruf → einsortieren → Tür zu → fahren → halten → Tür auf → Ruf löschen.
  Als Zustandsdiagramm zeichnen, mit den Zuständen, die die Steuerung wirklich hat.
]

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
