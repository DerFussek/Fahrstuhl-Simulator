#import "../vorlage.typ": kapitel-ohne-nummer

// Pflicht nach der Leitlinie Technik (10.11.2025); fehlt im T1000-Musterbericht (2019).
// Wie das Literaturverzeichnis ohne Kapitelnummer. Verweis im Text: #link(<kap:ki>)[KI-Anmerkung]
#kapitel-ohne-nummer[Anmerkung zur Nutzung von Künstlicher Intelligenz] <kap:ki>

#figure(
  table(
    columns: (auto, 1fr, auto),
    table.header([*KI-Werkzeug*], [*Wofür eingesetzt*], [*Kapitel*]),
    [Claude (Anthropic)], [Portierung der Ziellisten-Logik von C++ nach Structured Text], [6],
    [Claude (Anthropic)], [Gliederung und Struktur des Berichts], [--],
    [Claude (Anthropic)], [Prüfung von `AddTargetToList` mit Testszenarien und Zufallsläufen], [7],
  ),
  caption: [Einsatz von KI-Werkzeugen],
) <tab:ki>
