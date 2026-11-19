#import "../vorlage.typ": todo

// Ueberblick der Taetigkeiten wie im T1000-Musterbericht:
// Tabelle Nr. | Taetigkeit | Projekt | Bearbeitungszeitraum
#figure(
  table(
    columns: (auto, 1fr, auto, auto),
    align: (left, left, left, left),
    table.header([], [*Tätigkeit*], [*Projekt*], [*Bearbeitungszeitraum*]),
    [1], [Einarbeitung in die Service-Abteilung, Schulungen zu Cybersecurity und Arbeitssicherheit], [--], [05.10.–16.10.2026],
    [2], [Einführungsseminar Prozessleittechnik, ABB University Heidelberg], [--], [TT.MM.2026],
    [3], [Erstellen einer Lagerliste für eine Mitarbeiterin], [--], [TT.MM.2026],
    [4], [Entwicklung einer Aufzugssteuerung in Structured Text mit Control Builder M (Gruppenprojekt)], [Fahrstuhl-Simulator], [26.10.–13.11.2026],
    [5], [Projekttag mit Hackathon im ABB-Forschungszentrum], [--], [TT.MM.2026],
    [6], [Cyberday, Fachvorträge, Townhalls, AZB-Module zum wissenschaftlichen Arbeiten], [--], [begleitend],
  ),
  caption: [Tätigkeiten in der Praxisphase],
) <tab:taetigkeiten>

#todo[Zeiträume TT.MM. ergänzen und prüfen, ob der Einarbeitungszeitraum stimmt. Beschrieben werden die Tätigkeiten in @kap:praxisphase.]
