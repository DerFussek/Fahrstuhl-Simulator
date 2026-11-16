#import "../vorlage.typ": todo

// Richtwert: ca. 1,5 Seiten. Die Vorlage teilt den Hauptteil in
// Anforderungsdefinition, Anforderungsanalyse, Loesungsgenerierung,
// Loesungsbewertung und Umsetzung; dieses Kapitel deckt die ersten beiden ab.
= Anforderungsdefinition und -analyse <kap:anforderungen>

== Anforderungsdefinition
#todo[
  Einleitender Satz: Woher kommen die Anforderungen (Betreuer, eigene Festlegung)?
  Jede Anforderung hat eine Nummer, auf die sich die Testfälle in @kap:test beziehen.
]

#figure(
  table(
    columns: (auto, 1fr, auto),
    align: (center, left, left),
    table.header([*Nr.*], [*Anforderung*], [*Umgesetzt in*]),
    [A1], [Sechs Stockwerke, Innentaster für jedes Stockwerk], [`TD_Gondel`],
    [A2], [Außentaster: hoch in Stock 1--5, runter in Stock 2--6], [`TD_Gondel`],
    [A3], [Rufe werden nach dem Richtungsprinzip abgearbeitet], [`AddTargetToList`],
    [A4], [Doppelte Rufe werden ignoriert, höchstens 10 Ziele], [`AddTargetToList`],
    [A5], [Ruf im aktuellen Stockwerk in Fahrtrichtung öffnet nur die Tür], [`AddTargetToList`],
    [A6], [Fahren nur bei geschlossener Tür], [`TD_MotorController`, `DT_Door`],
    [A7], [Lichtschranke und Tür-auf-Taste haben Vorrang vor dem Schließen], [`DT_Door`],
    [A8], [Tür schließt nach 5~s Offen-Zeit automatisch], [`DT_Door`],
    [A9], [Taster-LEDs zeigen offene Rufe, Reset nach Bedienung], [`TD_LedSteuerung`, `TD_ResetTaster`],
  ),
  caption: [Anforderungen an die Aufzugssteuerung],
) <tab:anforderungen>

== Anforderungsanalyse
#todo[
  Was folgt aus @tab:anforderungen für den Entwurf? Welche Anforderungen sind
  sicherheitsrelevant (A6--A8)? Welche hängen zusammen (A3 und A5)? Welche Daten
  braucht die Steuerung dafür (eine Zielliste aus Stockwerk und Richtung)?
]
