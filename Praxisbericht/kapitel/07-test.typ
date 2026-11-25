#import "../vorlage.typ": todo

// Richtwert: ca. 1,5 Seiten. Ausfuehrliche Protokolle mit Screenshots in Anhang C.
= Test und Ergebnisse <kap:test>

== Test des Prototyps <kap:test-prototyp>
Der Prototyp wurde mit Testfällen getestet, die die Zielliste vor und nach dem fertigen Sortiereingang eines neuen Rufs ausgeben.
Dabei decken die Tests Listen ohne, mit einem und mit zwei Richtungswechseln ab. Anschließend wurde `AddTargetToList` mit einem KI-Werkzeug (#link(<kap:ki>)[KI-Anmerkung]) deutlich gründlicher geprüft: Mit 241 Szenarien für alle Gondelpositionen, den 20 Testfällen der Gruppe und mittels fünf Zufallsläufen die je 100.000 zufällige Listen aufgebaut und getestet haben. Dabei hat das Werkzeug geprüft, ob Rufe verloren gehen, die Liste mehr als zehn Einträge erhält oder die Gondel einen Ruf in Fahrtrichtung, der noch erreichbar ist, nicht mitnimmt.
Dabei deckten die Tests drei Fehler auf. Einmal wurde die Fahrrichtung aus der Richtung des ersten Rufs statt aus der Gondelposition und dem ersten Ziel abgeleitet, nicht mehr erreichbare Rufe wurden deshalb teilweise nur angehängt statt einsortiert zu werden und eine volle Liste wurde erst gar nicht abgefragt. Nach der Korrektur dieser Fehler hat der Algorithmus alle Testfälle der Gruppe bestanden.

#todo[
  Ggf. ergänzen: interaktives Testprogramm (@anh:cpp) und gegenseitiges Testen der
  Untergruppen (Ablauf siehe @kap:vorgehen, hier nur das Ergebnis).
]

== Test in der Simulation
#todo[
  Soft Controller und Visualisierung „Fahrstuhl Schacht“. Die Spalte Ergebnis in
  @tab:testfaelle beim Testen füllen.
]

#figure(
  table(
    columns: (auto, 1fr, auto, 1fr, auto),
    align: (center, left, center, left, center),
    table.header([*Nr.*], [*Testfall*], [*Prüft*], [*Erwartet*], [*Ergebnis*]),
    [T1], [Kabine in Stock 2 aufwärts, Innenrufe in 4, 1, 3], [A3], [Reihenfolge 3, 4, 1], [],
    [T2], [Gleicher Ruf zweimal], [A4], [Liste unverändert], [],
    [T3], [11 verschiedene Rufe], [A4], [11. Ruf wird ignoriert], [],
    [T4], [Ruf im aktuellen Stock in Fahrtrichtung], [A5], [Tür öffnet, kein neues Ziel], [],
    [T5], [Ruf im aktuellen Stock in Gegenrichtung], [A5], [Ruf wird einsortiert], [],
    [T6], [Ziel wählen, während die Tür offen ist], [A6], [Gondel fährt erst nach Tür zu], [],
    [T7], [Lichtschranke beim Schließen unterbrechen], [A7], [Tür öffnet wieder], [],
    [T8], [Tür offen, keine Bedienung], [A8], [Tür schließt nach 5~s], [],
  ),
  caption: [Testfälle und Ergebnisse],
) <tab:testfaelle>

== Bewertung der Ergebnisse <kap:bewertung>
#todo[
  Die Details zur Erfüllung der Anforderungen stehen nur hier; 8.1 fasst sie in einem
  Satz zusammen.
  Welche Anforderungen aus @tab:anforderungen erfüllt sind und welche nicht.
]
