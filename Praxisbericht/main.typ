// Praxisbericht Fahrstuhl-Steuerung
// Form nach dem T1000-Musterbericht (Projektarbeit I, ABB Mannheim), seit 19.11.2026.
// Kompilieren aus dem Repo-Wurzelordner (damit der Anhang den Code einlesen kann):
//   typst watch --root . Praxisbericht/main.typ

#import "vorlage.typ": *

#show: praxisbericht.with(
  titel: [Entwicklung einer Aufzugssteuerung in Structured Text mit ABB Control Builder M],
  art: [Praxisbericht],
  studiengang: [Elektrotechnik],
  studienrichtung: [Automation],
  autor: [Til Dussel],
  ort: [Mannheim],
  abgabedatum: [20.11.2026],           // TODO: Abgabetermin bei der ABB erfragen; steht bei Sperrvermerk und Erklaerung
  bearbeitungszeitraum: [3 Wochen],   // TODO
  matrikelnummer: [Matrikelnummer],    // TODO
  kurs: [TEIT26A],                        // TODO
  abteilung: none,                     // TODO: Abteilung bei der ABB, z. B. [Abteilungskürzel]
  firma: [ABB AG, Mannheim],                 // TODO: genaue Firmierung und Standort
  betreuer-firma: [Patrick Boldt],  // TODO
  gutachter-hochschule: none,          // Uebung der ABB: kein Gutachter der DHBW

  // Reihenfolge im PDF wie im Muster: Sperrvermerk, Erklaerung, Taetigkeiten,
  // Verzeichnisse, Abkuerzungen, Vorwort
  sperrvermerk: include "vorspann/sperrvermerk.typ",
  erklaerung-ki: include "vorspann/erklaerung-ki.typ",
  taetigkeiten: include "vorspann/taetigkeiten.typ",
  abkuerzungen: include "vorspann/abkuerzungen.typ",
  vorwort: include "vorspann/vorwort.typ",

  // Im Muster gibt es keine Kurzzusammenfassung. Falls der Betreuer eine will:
  // kurzfassung: include "vorspann/kurzfassung.typ",

  // Vor der Abgabe auf false setzen: blendet alle grauen Platzhalter aus
  zeige-entwurf: true,
)

// Hauptteil: Richtwert 10-15 Seiten reiner Text
#include "kapitel/01-einleitung.typ"
#include "kapitel/02-grundlagen.typ"
#include "kapitel/03-anforderungen.typ"
#include "kapitel/04-loesungsentwurf.typ"
#include "kapitel/05-umsetzung.typ"
#include "kapitel/06-test.typ"
#include "kapitel/07-zusammenfassung.typ"

// Literaturverzeichnis wie im Muster ohne Kapitelnummer, Stil IEEE
#kapitel-ohne-nummer[Literaturverzeichnis] <kap:literatur>
#bibliography("literatur.bib", style: "ieee", title: none, full: false)

#include "kapitel/08-ki-anmerkung.typ"

#show: anhang
#include "anhang/a-st-code.typ"
#include "anhang/b-cpp-prototyp.typ"
#include "anhang/c-testprotokolle.typ"
#include "anhang/d-skizzen.typ"
