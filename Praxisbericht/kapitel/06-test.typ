#import "../vorlage.typ": todo

// Richtwert: ca. 1,5 Seiten. Ausfuehrliche Protokolle mit Screenshots in Anhang C.
= Test und Ergebnisse <kap:test>

== Test des Prototyps
#todo[
  Mehrere Testdurchgänge am C++-Prototyp, unter anderem mit dem interaktiven
  Testprogramm (@anh:cpp); die anderen Untergruppen suchten gezielt nach Fehlern.
  Gefundene und behobene Fehler kurz beschreiben.
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

== Bewertung der Ergebnisse
#todo[
  Welche Anforderungen aus @tab:anforderungen erfüllt sind und welche nicht.
]
