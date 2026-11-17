#import "../vorlage.typ": todo

// Richtwert: ca. 2 Seiten. Nur so viel Theorie, wie Kapitel 4 und 5 brauchen:
// ein bis zwei Absaetze pro Unterkapitel. Hier stehen die meisten Quellenangaben.
= Grundlagen <kap:grundlagen>

== Speicherprogrammierbare Steuerungen nach IEC 61131-3
#todo[
  Zyklische Abarbeitung (Eingänge lesen, Programm, Ausgänge schreiben), Tasks mit
  verschiedenen Zykluszeiten (hier Fast, Normal, Slow). Sprachen der Norm
  @iec61131-3, Programmorganisationseinheiten (Funktion, Funktionsbaustein, Programm),
  Structured Text.
  Stichpunkte aus dem ABB-Seminar (Vault: 30 Wissen/800xA, "AC 800M Tasks und
  Speicher"): Zyklus = Input Copy, Code, Output Copy; Task = Intervall, Priorität
  und Offset; Standard-Tasks 50/250/1000 ms; Funktion ohne Gedächtnis, ein Ergebnis,
  Funktionsbaustein mit Zustand.
]

== ABB AC 800M und Control Builder M
#todo[
  Projektstruktur (Library, Application, Controller), Control Modules vs. Function
  Blocks, Soft Controller zur Simulation. Quelle: ABB-Handbücher (in literatur.bib
  eintragen).
  Stichpunkte aus dem ABB-Seminar (Vault: 30 Wissen/800xA, "AC 800M Projektrahmen",
  "AC 800M Diagramme"): Control Network > Control Project > Libraries, Applications,
  Controllers; Typ vs. Instanz in Bibliotheken; Code-Container Diagram, Program,
  Control Module (CM: Reihenfolge sortiert das System, effizienter als FB); Diagramme
  tauschen Daten über Communication Variables; Test Mode vs. SoftController (nur
  SoftController zeigt Werte in der Visualisierung); einordnen in System 800xA
  (Leitebene über Connectivity Server, Aspect Objects) nur kurz.
  Zitieren: die Seminarunterlagen sind nicht zur Weitergabe gedacht, besser die
  öffentlichen ABB-Handbücher (z. B. AC 800M Planning, Configuration) mit Nummer
  und Version aus dem PDF.
]

== Sammelsteuerung von Aufzügen
#todo[
  Einzelsteuerung vs. Sammelsteuerung, Richtungsprinzip (erst alle Rufe in
  Fahrtrichtung, dann umkehren), Sicherheitsfunktionen der Tür. Eventuell
  DIN EN 81-20 @din-en-81-20 als Beleg für Türanforderungen.
]
