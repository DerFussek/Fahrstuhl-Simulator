// Vorlage fuer den Praxisbericht, nachgebaut nach dem
// T1000-Musterbericht (Projektarbeit I, ABB Mannheim / DHBW Mannheim).
// Vorher: "Studienarbeitsvorlage" des Studiengangs Elektrotechnik (Stand bis 19.11.2026).
//
// Formatwerte aus dem Musterbericht:
//   Arial 12 pt, 1,5-zeilig, Blocksatz mit Silbentrennung, ca. 6 pt Absatzabstand
//   Raender links/rechts 2,5 cm; Kopfzeile mit Linie (Name links, Art der Arbeit rechts)
//   Seitenzahl unten rechts; Titelblatt zaehlt als Seite I ohne Nummer,
//   Vorspann roemisch ab II, Hauptteil arabisch ab 1
//   Ueberschriften Arial fett 14 pt (Kapitel) bzw. 12 pt, Nummern mit Schlusspunkt ("1.1.")
//   Beschriftungen "Abbildung 1: Text [Quelle]" unter Bildern und Tabellen
//   Vorspann: Titelblatt, Sperrvermerk, Erklaerung, Ueberblick der Taetigkeiten,
//   Inhaltsverzeichnis, Abbildungs-, Tabellen-, Abkuerzungsverzeichnis, Vorwort
//   Literaturverzeichnis ohne Kapitelnummer
// Abweichend vom Muster: A4 statt US Letter, Anhaenge und KI-Anmerkung (Leitlinie 2025).

// ---------------------------------------------------------------------------
// Hilfsfunktionen fuer den Text
// ---------------------------------------------------------------------------

// Steuert, ob Platzhalter (#todo) im PDF sichtbar sind.
// In main.typ auf false setzen, bevor du abgibst.
#let entwurf = state("entwurf", true)

// Grauer Platzhalter fuer Stichpunkte, die noch ausformuliert werden muessen.
#let todo(body) = context {
  if entwurf.get() {
    block(
      width: 100%,
      inset: 8pt,
      radius: 3pt,
      stroke: (left: 2pt + luma(150)),
      fill: luma(240),
      text(size: 10pt, fill: luma(80), style: "italic", body),
    )
  }
}

// Quellcode aus einer Datei als Abbildung.
// Pfad relativ zu dieser Datei; Dateien ausserhalb von Praxisbericht/
// brauchen beim Kompilieren --root . im Repo-Wurzelordner (siehe README).
#let code-abbildung(pfad, caption, sprache: none, zeilen: none) = {
  let inhalt = read(pfad).replace("\r", "")
  if zeilen != none {
    inhalt = inhalt.split("\n").slice(zeilen.at(0) - 1, zeilen.at(1)).join("\n")
  }
  // Lange Dateien muessen ueber Seiten umbrechen duerfen,
  // sonst laufen sie ueber den unteren Rand.
  show figure: set block(breakable: true)
  figure(
    raw(inhalt, block: true, lang: sprache),
    kind: image,
    caption: caption,
  )
}

// Platzhalter fuer eine Abbildung, die es noch nicht gibt.
#let abbildung-folgt(beschreibung, caption, hoehe: 5cm) = figure(
  rect(width: 100%, height: hoehe, stroke: (dash: "dashed", paint: luma(150)))[
    #align(center + horizon, text(fill: luma(110))[Abbildung folgt: #beschreibung])
  ],
  caption: caption,
)

// Ort, Datum und Unterschrift wie im Musterbericht:
// "Mannheim, der 19.12.2019   ________   Unterschrift (Name)"
#let unterschrift-zeile(ort, datum, name) = {
  set par(justify: false)
  v(1.5cm)
  grid(
    columns: (1fr, 1.3fr),
    column-gutter: 1.5em,
    align: (left + bottom, center + bottom),
    [#ort, der #datum],
    stack(
      dir: ttb,
      spacing: 6pt,
      line(length: 100%, stroke: 0.5pt),
      text(size: 11pt)[Unterschrift (#name)],
    ),
  )
}

// ---------------------------------------------------------------------------
// Hauptvorlage
// ---------------------------------------------------------------------------

#let praxisbericht(
  titel: [Titel der Arbeit],
  art: [Praxisbericht],
  studiengang: [Elektrotechnik],
  studienrichtung: none,
  hochschule: [Dualen Hochschule Baden-Württemberg Mannheim],
  autor: [Vorname Nachname],
  ort: [Mannheim],
  abgabedatum: [TT.MM.JJJJ],
  bearbeitungszeitraum: [xx Wochen],
  matrikelnummer: [Matrikelnummer],
  kurs: [Kurs],
  abteilung: none,
  firma: [Firmenname, Stadt],
  betreuer-firma: [Titel Vorname Nachname],
  gutachter-hochschule: none,
  logo-links: "bilder/logo-abb.png",
  logo-rechts: "bilder/logo-dhbw-mannheim.png",
  sperrvermerk: none,
  erklaerung-ki: none,
  taetigkeiten: none,
  kurzfassung: none,
  abkuerzungen: none,
  vorwort: none,
  zeige-entwurf: true,
  body,
) = {
  entwurf.update(zeige-entwurf)

  set document(title: titel, author: if type(autor) == str { autor } else { () })

  // -- Grundformat ----------------------------------------------------------
  set text(
    font: ("Arial", "Liberation Sans"),
    size: 12pt,
    lang: "de",
    region: "de",
    hyphenate: true,
  )
  // 1,5-zeilig wie in Word (Arial 12 pt: 20,7 pt Zeilenabstand), ca. 6 pt zwischen Absaetzen
  set par(justify: true, leading: 1.0em, spacing: 1.0em + 6pt, first-line-indent: 0pt)

  // -- Ueberschriften -------------------------------------------------------
  // Nummern mit Schlusspunkt wie im Muster ("1.", "1.1.", "2.3.1.")
  set heading(numbering: "1.1.")
  show heading: set text(size: 12pt, weight: "bold")
  show heading.where(level: 1): set text(size: 14pt)
  show heading: it => {
    if it.numbering == none { it } else {
      // etwas Abstand zwischen Nummer und Titel wie in Word
      block(grid(columns: (auto, 1fr), column-gutter: 0.8em,
        counter(heading).display(it.numbering), it.body))
    }
  }
  show heading.where(level: 1): set block(above: 0pt, below: 18pt)
  show heading.where(level: 2): set block(above: 18pt, below: 10pt)
  show heading.where(level: 3): set block(above: 14pt, below: 8pt)

  // Verweise im Text ohne Schlusspunkt: "Abschnitt 4.3" statt "Abschnitt 4.3."
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading and el.numbering == "1.1." {
      let nr = numbering("1.1", ..counter(heading).at(el.location()))
      let wort = if el.level == 1 [Kapitel] else [Abschnitt]
      link(el.location(), [#wort~#nr])
    } else if el != none and el.func() == heading and type(el.numbering) == function {
      // Anhaenge: "Anhang A" bzw. "Anhang A.1"
      let nr = numbering("A.1", ..counter(heading).at(el.location()))
      link(el.location(), [Anhang~#nr])
    } else { it }
  }

  // -- Abbildungen, Tabellen, Code -----------------------------------------
  // "Abbildung 1: Text", Beschriftung wie im Muster immer unter dem Objekt
  set figure.caption(separator: [: ])
  show figure.caption: set text(size: 11pt)
  show figure.caption: set align(left)
  show figure: set block(breakable: false)
  set table(stroke: 0.5pt + black, inset: 6pt)
  show table: set par(justify: false, leading: 0.65em)
  show table: set text(size: 11pt)

  show raw: set text(weight: "regular")
  show raw.where(block: true): set text(font: ("Consolas", "Courier New", "Liberation Mono"), size: 9pt)
  show raw.where(block: true): set par(justify: false, leading: 0.5em)
  show raw.where(block: true): it => block(
    width: 100%,
    inset: (x: 8pt, y: 8pt),
    radius: 2pt,
    fill: luma(246),
    stroke: 0.5pt + luma(200),
    {
      show raw.line: l => {
        box(width: 2.2em, align(right, text(fill: luma(130))[#l.number]))
        h(1em)
        l.body
      }
      align(left, it)
    },
  )
  show raw.where(block: false): set text(font: ("Consolas", "Courier New", "Liberation Mono"), size: 0.92em, style: "normal")

  // -- Titelblatt (zaehlt als Seite I, ohne Nummer und Kopfzeile) ------------
  set page(
    paper: "a4",
    margin: (left: 2.5cm, right: 2.5cm, top: 2cm, bottom: 2.5cm),
    numbering: none,
    header: none,
    footer: none,
  )
  {
    set par(justify: false)
    set text(hyphenate: false)
    grid(
      columns: (1fr, 1fr),
      align: (left + horizon, right + horizon),
      if logo-links != none { image(logo-links, height: 1.3cm) },
      if logo-rechts != none { image(logo-rechts, height: 2.8cm) },
    )
    v(2.5cm)
    align(center)[
      #text(size: 14pt, weight: "bold", titel)
      #v(2.5cm)
      #text(weight: "bold", art)
      #v(2cm)
      des Studiengangs #studiengang#if studienrichtung != none [ -- #studienrichtung]
      \ an der #hochschule
      #v(1cm)
      von
      #v(0.3cm)
      #autor
    ]
    v(1fr)
    let zeile(k, w) = (k, w)
    let firmenzeile = if abteilung != none [#abteilung, #firma] else [#firma]
    grid(
      columns: (auto, 1fr),
      column-gutter: 2em,
      row-gutter: 0.8em,
      ..zeile[Bearbeitungszeitraum][#bearbeitungszeitraum],
      ..zeile[Matrikelnummer, Kurs][#matrikelnummer, #kurs],
      ..zeile[Abteilung/Ausbildungsfirma][#firmenzeile],
      ..zeile[Betreuer der Ausbildungsfirma][#betreuer-firma],
      ..(if gutachter-hochschule != none { zeile[Gutachter der Dualen Hochschule][#gutachter-hochschule] } else { () }),
    )
    v(1.5cm)
    grid(
      columns: (auto, 1fr),
      column-gutter: 2em,
      align: (left + bottom, left + bottom),
      [Unterschrift Betreuer], line(length: 80%, stroke: 0.5pt),
    )
    v(1cm)
  }

  // -- Kopf- und Fusszeile ab Seite II --------------------------------------
  let kopfzeile = {
    set text(size: 11pt)
    grid(columns: (1fr, 1fr), align: (left, right), autor, art)
    v(-6pt)
    line(length: 100%, stroke: 0.5pt)
  }

  // -- Vorspann (roemische Seitenzahlen ab II) ------------------------------
  // Alle Vorspann-Ueberschriften ohne Nummer, aber im Inhaltsverzeichnis
  // (wie im Muster: Sperrvermerk ... II, Erklaerung ... III, ...).
  let vorspann-titel(t) = heading(numbering: none, outlined: true, t)

  set page(
    margin: (left: 2.5cm, right: 2.5cm, top: 3cm, bottom: 2.5cm),
    numbering: "I",
    header: kopfzeile,
    footer: context align(right, counter(page).display("I")),
  )
  // Seitenzaehler laeuft weiter: Titelblatt = I, naechste Seite = II

  if sperrvermerk != none {
    pagebreak(weak: true)
    vorspann-titel[Sperrvermerk]
    sperrvermerk
    unterschrift-zeile(ort, abgabedatum, autor)
  }

  pagebreak(weak: true)
  vorspann-titel[Erklärung]
  [
    Ich, #autor, versichere hiermit, dass ich meinen #art mit dem Thema:
    „#titel“ selbstständig verfasst und keine anderen als die angegebenen
    Quellen und Hilfsmittel benutzt habe.

    Ich versichere zudem, dass die eingereichte elektronische Fassung mit der
    gedruckten Fassung übereinstimmt.
  ]
  if erklaerung-ki != none { erklaerung-ki }
  unterschrift-zeile(ort, abgabedatum, autor)

  if taetigkeiten != none {
    pagebreak(weak: true)
    vorspann-titel[Überblick der Tätigkeiten in der Praxisphase]
    taetigkeiten
  }

  if kurzfassung != none {
    pagebreak(weak: true)
    vorspann-titel[Kurzzusammenfassung]
    kurzfassung
  }

  // Verzeichnisse wie im Muster hintereinander, ohne eigene Seite je Verzeichnis
  pagebreak(weak: true)
  vorspann-titel[Inhaltsverzeichnis]
  {
    set par(leading: 0.65em)
    show outline.entry.where(level: 1): set block(above: 1.1em)
    outline(title: none, indent: auto)
  }

pagebreak()

  v(1.5em)
  vorspann-titel[Abbildungsverzeichnis]
  outline(title: none, target: figure.where(kind: image))

  v(1.5em)
  vorspann-titel[Tabellenverzeichnis]
  outline(title: none, target: figure.where(kind: table))

  if abkuerzungen != none {
    pagebreak(weak: true)
    vorspann-titel[Abkürzungsverzeichnis]
    abkuerzungen
  }

  if vorwort != none {
    pagebreak(weak: true)
    vorspann-titel[Vorwort]
    vorwort
  }

  // -- Hauptteil (arabische Seitenzahlen ab 1) ------------------------------
  set page(
    numbering: "1",
    footer: context align(right, counter(page).display("1")),
  )
  pagebreak(weak: true)
  counter(page).update(1)
  counter(heading).update(0)

  // Jedes Hauptkapitel beginnt auf einer neuen Seite
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
  }

  body
}

// Kapitel ohne Nummer, aber im Inhaltsverzeichnis (Literaturverzeichnis,
// KI-Anmerkung). Verweis darauf mit #link(<label>)[Text], nicht mit @label.
#let kapitel-ohne-nummer(t) = heading(numbering: none, t)

// Anhaenge: "Anhang A Titel", Unterkapitel A.1, A.2, ...
// Verweise im Text: "Anhang A" bzw. "Anhang A.1" (statt "Abschnitt ...").
#let anhang(body) = {
  counter(heading).update(0)
  set heading(numbering: (..n) => {
    let p = n.pos()
    if p.len() == 1 { "Anhang " + numbering("A", ..p) + ":" } else { numbering("A.1.", ..p) }
  }, supplement: [Anhang])
  // Die Nummer der Hauptueberschrift enthaelt "Anhang" schon selbst.
  show heading.where(level: 1): set heading(supplement: none)
  body
}
