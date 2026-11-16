// Vorlage fuer den Praxisbericht, nachgebaut nach der
// "Studienarbeitsvorlage" des Studiengangs Elektrotechnik, DHBW Mannheim.
//
// Formatwerte aus der Word-Vorlage:
//   Calibri Light 12 pt, 1,5-zeilig, Blocksatz, 6 pt vor und nach Absaetzen
//   Raender links/rechts 2,5 cm, unten 2 cm,
//   oben 3,5 cm im Vorspann und 2,5 cm im Hauptteil
//   Vorspann roemisch nummeriert, Hauptteil arabisch ab 1
//   Abbildungsbeschriftung unter dem Bild, Tabellenbeschriftung ueber der Tabelle
//   Quellcode als Text mit Zeilennummern, beschriftet als Abbildung

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

// Quellcode aus einer Datei als Abbildung (so verlangt es die Vorlage).
// Pfad relativ zu dieser Datei; Dateien ausserhalb von Praxisbericht/
// brauchen beim Kompilieren --root .. (siehe README).
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
  abgabedatum: [TT.MM.JJJJ],
  bearbeitungszeitraum: [xx Wochen],
  matrikelnummer: [Matrikelnummer],
  kurs: [Kurs],
  firma: [Firmenname, Stadt],
  betreuer-firma: [Titel Vorname Nachname],
  gutachter-hochschule: none,
  sperrvermerk: none,
  erklaerung-ki: none,
  kurzfassung: none,
  vorwort: none,
  abkuerzungen: none,
  zeige-entwurf: true,
  body,
) = {
  entwurf.update(zeige-entwurf)

  set document(title: titel, author: if type(autor) == str { autor } else { () })

  // -- Grundformat ----------------------------------------------------------
  set text(
    // "Calibri Light" heisst in Typst: Familie Calibri, Schnitt light
    font: ("Calibri", "Arial"),
    weight: "light",
    size: 12pt,
    lang: "de",
    region: "de",
    hyphenate: true,
  )
  // 1,5-zeilig wie in Word; 6 pt vor + 6 pt nach = 12 pt zwischen Absaetzen
  set par(justify: true, leading: 1.05em, spacing: 1.05em + 12pt, first-line-indent: 0pt)

  // -- Ueberschriften -------------------------------------------------------
  set heading(numbering: "1.1")
  show heading: set text(weight: "bold")
  show strong: set text(weight: "bold")
  show heading.where(level: 1): set text(size: 16pt)
  show heading.where(level: 2): set text(size: 14pt)
  show heading.where(level: 3): set text(size: 12pt)
  show heading.where(level: 1): set block(above: 0pt, below: 18pt)
  show heading.where(level: 2): set block(above: 18pt, below: 10pt)
  show heading.where(level: 3): set block(above: 14pt, below: 8pt)

  // -- Abbildungen, Tabellen, Code -----------------------------------------
  set figure.caption(separator: [. ])
  show figure.caption: set text(size: 10.5pt)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure: set block(breakable: false)
  set table(stroke: 0.5pt + luma(120), inset: 6pt)
  show table: set par(justify: false, leading: 0.65em)
  show table: set text(size: 11pt)

  show raw: set text(weight: "regular")
  show raw.where(block: true): set text(font: ("Consolas", "Courier New"), size: 9pt)
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
  show raw.where(block: false): set text(font: ("Consolas", "Courier New"), size: 0.92em, style: "normal")

  // -- Titelblatt -----------------------------------------------------------
  set page(
    paper: "a4",
    margin: (left: 2.5cm, right: 2.5cm, top: 3.5cm, bottom: 2cm),
    numbering: none,
  )
  {
    set par(justify: false)
    set text(hyphenate: false)
    align(center)[
      #v(2cm)
      #text(size: 22pt, weight: "bold", titel)
      #v(1.5cm)
      #text(size: 16pt, upper(art))
      #v(1cm)
      des Studienganges #studiengang
      #if studienrichtung != none [ \ Studienrichtung #studienrichtung ]
      \ an der #hochschule
      #v(1cm)
      von
      #v(0.3cm)
      #text(size: 14pt, weight: "bold", autor)
      #v(0.6cm)
      #abgabedatum
    ]
    v(1fr)
    let zeile(k, w) = (text(weight: "bold", k), w)
    grid(
      columns: (auto, 1fr),
      column-gutter: 1.5em,
      row-gutter: 0.8em,
      ..zeile[Bearbeitungszeitraum][#bearbeitungszeitraum],
      ..zeile[Matrikelnummer, Kurs][#matrikelnummer, #kurs],
      ..zeile[Ausbildungsfirma][#firma],
      ..zeile[Betreuer der Ausbildungsfirma][#betreuer-firma],
      ..(if gutachter-hochschule != none { zeile[Gutachter der Dualen Hochschule][#gutachter-hochschule] } else { () }),
    )
  }

  // -- Vorspann (roemische Seitenzahlen) -------------------------------------
  // Ueberschriften im Vorspann: nicht nummeriert. Erklaerung, Kurzfassung,
  // Vorwort und Inhaltsverzeichnis stehen nicht im Inhaltsverzeichnis;
  // die Verzeichnisse schon, mit I., II., ... (wie in der Word-Vorlage).
  let vorspann-titel(t) = heading(numbering: none, outlined: false, t)
  let verzeichnis-titel(t) = heading(numbering: "I.", t)

  set page(numbering: "I", footer: context align(center, counter(page).display("I")))
  counter(page).update(1)

  if sperrvermerk != none {
    pagebreak(weak: true)
    vorspann-titel[Sperrvermerk]
    sperrvermerk
  }

  pagebreak(weak: true)
  vorspann-titel[Erklärung]
  [
    Ich versichere hiermit, dass ich meinen #art mit dem Thema: #emph(titel)
    selbstständig verfasst und keine anderen als die angegebenen Quellen und
    Hilfsmittel benutzt habe.

    Ich versichere zudem, dass die eingereichte elektronische Fassung mit der
    gedruckten Fassung übereinstimmt.#super[\*]
  ]
  if erklaerung-ki != none { erklaerung-ki }
  v(2.5cm)
  {
    set par(justify: false)
    grid(
      columns: (1fr, 1fr, 1.4fr),
      column-gutter: 1.5em,
      row-gutter: 4pt,
      line(length: 100%, stroke: 0.5pt), line(length: 100%, stroke: 0.5pt), line(length: 100%, stroke: 0.5pt),
      text(size: 10pt)[Ort], text(size: 10pt)[Datum], text(size: 10pt)[Unterschrift],
    )
    v(1fr)
    text(size: 10pt)[\* falls beide Fassungen gefordert sind]
  }

  if kurzfassung != none {
    pagebreak(weak: true)
    vorspann-titel[Kurzzusammenfassung]
    kurzfassung
  }

  if vorwort != none {
    pagebreak(weak: true)
    vorspann-titel[Vorwort]
    vorwort
  }

  pagebreak(weak: true)
  vorspann-titel[Inhaltsverzeichnis]
  {
    show outline.entry.where(level: 1): set block(above: 1.1em)
    show outline.entry.where(level: 1): set text(weight: "bold")
    set par(leading: 0.65em)
    outline(title: none, indent: auto)
  }

  if abkuerzungen != none {
    pagebreak(weak: true)
    verzeichnis-titel[Abkürzungsverzeichnis]
    abkuerzungen
  }

  pagebreak(weak: true)
  verzeichnis-titel[Abbildungsverzeichnis]
  outline(title: none, target: figure.where(kind: image))

  pagebreak(weak: true)
  verzeichnis-titel[Tabellenverzeichnis]
  outline(title: none, target: figure.where(kind: table))

  // -- Hauptteil (arabische Seitenzahlen ab 1, oberer Rand 2,5 cm) ----------
  set page(
    margin: (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2cm),
    numbering: "1",
    footer: context align(center, counter(page).display("1")),
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

// Anhaenge: "Anhang A: Titel", Unterkapitel A.1, A.2, ...
#let anhang(body) = {
  counter(heading).update(0)
  set heading(numbering: (..n) => {
    let p = n.pos()
    if p.len() == 1 { "Anhang " + numbering("A:", ..p) } else { numbering("A.1", ..p) }
  })
  body
}
