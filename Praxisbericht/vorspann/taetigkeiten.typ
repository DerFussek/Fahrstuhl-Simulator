#import "../vorlage.typ": todo

// Ueberblick der Taetigkeiten wie im T1000-Musterbericht:
// Tabelle Nr. | Taetigkeit | Projekt | Bearbeitungszeitraum
#figure(
  table(
    columns: (auto, 1fr, auto, auto),
    align: (left, left, left, left),
    table.header([], [*Tätigkeit*], [*Projekt*], [*Bearbeitungszeitraum*]),
    [1], [Einarbeitung in die Service-Abteilung, Schulungen zu Cybersecurity und Arbeitssicherheit, Programmieren von EPROMs im Prüffeld], [--], [05.10.–13.10.2026],
    [2], [Erstellen einer Lagerliste für eine Mitarbeiterin], [--], [14.10.–16.10.2026],
    [3], [Einführungsseminar Prozessleittechnik, ABB University Heidelberg], [--], [19.10.–23.10.2026],
    [4], [Entwicklung einer Aufzugssteuerung in Structured Text mit Control Builder M (Gruppenprojekt)], [Fahrstuhl-Simulator], [26.10.–13.11.2026],
    [5], [Projekttag mit Hackathon im ABB-Forschungszentrum], [--], [04.11.2026],
    [6], [Cyberday, Fachvorträge, Townhalls, AZB-Module zum wissenschaftlichen Arbeiten], [--], [begleitend],
  ),
  caption: [Tätigkeiten in der Praxisphase],
) <tab:taetigkeiten>

#todo[Daten nach Tils Angaben vom 19.11.: Lagerliste Mi–Fr vor dem Seminar, Projekttag Mittwoch der zweiten Projektwoche. Beschrieben werden die Tätigkeiten in @kap:praxisphase.]
