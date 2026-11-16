#import "../vorlage.typ": todo, abbildung-folgt

// Richtwert: ca. 4 Seiten. Das wichtigste Kapitel: warum die Steuerung so
// gebaut ist. Mit dem Schreiben hier anfangen.
= Lösungsentwurf und Bewertung <kap:loesungsentwurf>

== Systemaufbau
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

== Algorithmus der Zielliste <kap:zielliste>
#todo[
  - Aufbau der Liste: bis zu drei Abschnitte (Fahrtrichtung vor der Kabine,
    Gegenrichtung, wieder Startrichtung)
  - Marker `rWechsel1` und `rWechsel2` für die Richtungswechsel
  - Einsortieren an einem Beispiel durchspielen: Kabine in Stock 2 aufwärts,
    nacheinander Innenrufe in 4, 1 und 3 -- die Liste nach jedem Schritt als
    kleine Tabelle
  - Sonderfälle: doppelter Ruf, volle Liste, Ruf im aktuellen Stockwerk
]

== Entwicklung mit C++-Prototyp
#todo[
  Warum die Logik zuerst in C++ entstand (schnell testbar, ohne Controller) und
  welche Konventionen die spätere Portierung leicht machten (Richtung als BOOL,
  kein vorzeitiges RETURN).
]

== Lösungsvarianten und Bewertung
#todo[
  Höchstens eine halbe Seite. Nur Varianten, die du wirklich erwogen hast, z. B.:
  - Zielliste mit Sortierung vs. ein einfaches Ruf-Bit pro Stockwerk und Richtung
  - Logik erst in C++ entwickeln vs. direkt in Structured Text
  - Control Modules vs. Function Blocks für die einzelnen Bausteine
  Bewertung als Tabelle mit Kriterien wie Aufwand, Testbarkeit, Umsetzbarkeit in CBM.
]
