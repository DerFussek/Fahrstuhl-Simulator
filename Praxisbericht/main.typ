// Praxisbericht Fahrstuhl-Steuerung
// Kompilieren aus dem Repo-Wurzelordner (damit der Anhang den Code einlesen kann):
//   typst watch --root . Praxisbericht/main.typ

#import "vorlage.typ": *

#show: praxisbericht.with(
  titel: [Entwicklung einer Aufzugssteuerung in Structured Text mit ABB Control Builder M],
  art: [Praxisbericht],
  studiengang: [Elektrotechnik],
  studienrichtung: [Automation],
  autor: [Til Dussel],
  abgabedatum: [TT.MM.JJJJ],           // TODO: Abgabetermin bei der ABB erfragen
  bearbeitungszeitraum: [xx Wochen],   // TODO
  matrikelnummer: [Matrikelnummer],    // TODO
  kurs: [Kurs],                        // TODO
  firma: [ABB, Stadt],                 // TODO: genaue Firmierung und Standort
  betreuer-firma: [Titel Vorname Nachname],  // TODO
  gutachter-hochschule: none,          // Uebung der ABB: kein Gutachter der DHBW

  // Nur einkommentieren, wenn die ABB einen Sperrvermerk verlangt:
  // sperrvermerk: include "vorspann/sperrvermerk.typ",

  erklaerung-ki: include "vorspann/erklaerung-ki.typ",
  kurzfassung: include "vorspann/kurzfassung.typ",
  vorwort: include "vorspann/vorwort.typ",   // optional, sonst none
  abkuerzungen: include "vorspann/abkuerzungen.typ",

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

// Literaturverzeichnis als eigenes nummeriertes Kapitel, Stil IEEE
= Literaturverzeichnis <kap:literatur>
#bibliography("literatur.bib", style: "ieee", title: none, full: false)

#include "kapitel/08-ki-anmerkung.typ"

#show: anhang
#include "anhang/a-st-code.typ"
#include "anhang/b-cpp-prototyp.typ"
#include "anhang/c-testprotokolle.typ"
#include "anhang/d-skizzen.typ"
