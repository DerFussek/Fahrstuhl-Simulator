#import "../vorlage.typ": todo, abbildung-folgt

// Richtwert: ca. 2 Seiten. Die Vorlage teilt den Hauptteil in
// Anforderungsdefinition, Anforderungsanalyse, Loesungsgenerierung,
// Loesungsbewertung und Umsetzung; dieses Kapitel deckt die ersten beiden ab.
= Anforderungsdefinition und -analyse <kap:anforderungen>

Die Anforderungen legte die Gruppe in der ersten Projektwoche selbst fest, da die Aufgabe offen gestellt war (@kap:vorgehen). Skizzen aus dieser Phase enthält @anh:skizzen.

== Aufbau des simulierten Aufzugs <kap:aufbau>
#todo[
  Einzige Stelle, an der Sensoren, Aktoren und Bedienelemente aufgezählt werden;
  5.1 und 5.5 verweisen hierher.
  Schacht mit sechs Stockwerken, Kabine, Kabinentür und sechs Schachttüren,
  Endlagen und Lichtschranke, Außentaster auf/ab mit Beleuchtung, Bedienfeld in
  der Kabine. Alles nur simuliert, keine echte Hardware.
]

#abbildung-folgt(
  [Skizze des Aufzugs mit Sensoren, Aktoren und Bedienelementen],
  [Aufbau des simulierten Aufzugs, eigene Darstellung],
) <abb:aufzug>

== Anforderungen an die Steuerung
#todo[
  Einleitender Satz. Jede Anforderung hat eine Nummer, auf die sich die Testfälle
  in @kap:test beziehen.
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

== Analyse der Anforderungen <kap:analyse>
#todo[
  Nur die projektspezifischen Regeln; das Richtungsprinzip allgemein steht in
  @kap:sammelsteuerung.
  - Regeln der Rufabarbeitung hinter A3: Mitnahme in Fahrtrichtung, keine Mitnahme
    in Gegenrichtung, Richtung wird bis zum Umkehrpunkt zu Ende gefahren, der
    Zeitpunkt des Tastendrucks entscheidet über die Reihenfolge
  - Sicherheitsrelevant: A6 bis A8
  - Folge für den Entwurf: eine Zielliste aus Stockwerk und Richtung
  - Bewusst ausgeklammert: Sonderbetrieb (Brand, Störung), Kartenleser,
    Trendbilder und Alarme
]
