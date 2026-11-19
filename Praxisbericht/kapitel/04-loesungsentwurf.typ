#import "../vorlage.typ": todo, abbildung-folgt

// Richtwert: ca. 3,5 Seiten. Das wichtigste Kapitel: warum die Steuerung so
// gebaut ist. Mit dem Schreiben hier anfangen.
= Lösungsgenerierung und -bewertung <kap:loesungsentwurf>

== Systemaufbau und Schnittstellen der Bausteine

#figure(
  image("../bilder/systemaufbau.svg", width: 100%),
  caption: [Systemaufbau der Aufzugssteuerung, eigene Darstellung],
) <abb:systemaufbau>

Die Aufzugssteuerung besteht aus neun Bausteinen, die sich in die Ruf- und Zielverwaltung, die Motor- und Türsteuerung sowie die Anzeige der Taster aufteilen. @abb:systemaufbau zeigt ihre Aufgaben und die wesentlichen Signale. In der Application `TD_Appl` sind sie auf die Diagramme `DT_Gondel` (Fahrlogik) und `DT_Door` (Türsteuerung) verteilt, die ihre Daten über Communication-Variablen austauschen.

Zentraler Baustein ist das Control Module `TD_Gondel`. Es erfasst die sechs Innen- und zehn Außentaster und verwaltet die Zielliste mit höchstens zehn Einträgen aus Stockwerk und Richtung. Neue Ziele sortiert der Funktionsbaustein `AddTargetToList` ein, erreichte Ziele löscht `TD_RemoveAtIndex` (@kap:zielliste). Das erste Ziel geht als `ZielStock` an `TD_MotorController`, der die Gondelposition `GondelPos` und beim Erreichen des Ziels das Signal `Done` zurückmeldet.

Die Türsteuerung `DT_Door` bewegt Kabinen- und Schachttür über `TD_Door_Pos` und `TD_Shaftdoor_Pos` und meldet über `EnableGondel`, dass alle Türen geschlossen sind. Im Diagramm `DT_Gondel` wird dieses Signal mit `HatZiel` UND-verknüpft; erst das Ergebnis `Enable` gibt den Motor frei. `TD_LedSteuerung` beleuchtet anhand der Zielliste die Taster der offenen Rufe.

== Ablauf einer Fahrt

#figure(
  image("../bilder/ablauf-gesamt.svg", width: 100%),
  caption: [Ablauf vom Ruf bis zur Fahrt, eigene Darstellung],
) <abb:ablauf>

@abb:ablauf zeigt den Ablauf vom Ruf bis zur Fahrt. Rufbearbeitung sowie Fahrt- und Türablauf arbeiten parallel, sodass neue Rufe auch während einer Fahrt oder Türbewegung verarbeitet werden und das momentane Fahrtziel ändern können. Die Zustände im Diagramm dienen nur der Veranschaulichung und existieren nicht als Variablen.

*Ruf aufnehmen.* \
`TD_Gondel` macht aus jedem Tastendruck ein Ziel aus Stockwerk und Richtung und übergibt es an `AddTargetToList` (@kap:zielliste). Ein Ruf im aktuellen Stockwerk öffnet unter Umständen nur die Tür (A5, @tab:anforderungen).

*Tür schließen und Fahrt freigeben.* \
Sobald die Liste ein Ziel enthält, setzt `TD_Gondel` das Signal `HatZiel`. Eine offene Tür schließt nach fünf Sekunden Offenhaltezeit oder sofort mit dem Tür-zu-Taster (A8); ein neuer Ruf verkürzt die Zeit nicht. Lichtschranke und Tür-auf-Taster haben Vorrang: Sie halten den Timer an und öffnen eine schließende Tür wieder (A7). Erst wenn alle Türen geschlossen sind, wird `Enable` aktiv und die Gondel fährt (A6).

*Ziel erreichen.* \
Am Ziel stoppt `TD_MotorController` und setzt `Done`. Daraufhin öffnet `DT_Door` mit der steigenden Flanke an `EnableTuer` die Kabinentür und die über `GondelPosExpo` bestimmte Schachttür, und `TD_Gondel` löscht das Ziel aus der Liste. Danach beginnt der Ablauf mit dem nächsten Ziel von vorn; ist die Liste leer, bleibt die Gondel mit geschlossener Tür stehen.

== Lösungsvarianten für die Rufverwaltung <kap:varianten>

Die Rufverwaltung legt fest, in welcher Reihenfolge die Gondel die gedrückten Taster bedient. Alle Ansätze müssen das Richtungsprinzip (A3, @kap:sammelsteuerung) einhalten. In der Gruppe wurden vier Ansätze diskutiert, die sich vor allem darin unterscheiden, ob und wie die Rufe in einer Liste gespeichert werden.

*I. Rufspeicher ohne Zielliste.* \
Die Rufe werden in drei Arrays mit einem Eintrag pro Stockwerk gespeichert, je eines für Innenrufe, Außenrufe hoch und Außenrufe runter. Die Gondel prüft in jedem Stockwerk, ob dort ein Ruf in Fahrtrichtung ansteht, und hält oder fährt weiter. Sie wechselt die Richtung erst, wenn in Fahrtrichtung keine Rufe mehr offen sind (Flussdiagramme in @anh:skizzen).

*II. Feste Umkehrpunkte.* \
Kommt während einer Aufwärtsfahrt ein Ruf nach unten, wird am höchsten Ziel ein Umkehrpunkt gesetzt. Rufe, die danach weiter oben eingehen, werden erst bei der nächsten Aufwärtsfahrt bedient, abwärts gilt dasselbe. In hohen Gebäuden verhindert das, dass Fahrgäste mit Rufen in Gegenrichtung lange warten.

*III. Einsortieren in eine sortierte Liste.* \
Jeder neue Ruf wird an die passende Stelle der bestehenden Zielliste einsortiert. Da die Liste nur so entsteht, ist sie immer sortiert, und die vorhandenen Ziele müssen nicht neu geordnet werden. Zwei Marken teilen die Liste an den Richtungswechseln in drei Abschnitte (@kap:zielliste).

*IV. Liste bei jedem Ruf neu sortieren.* \
Bei jedem neuen Ruf wird die Liste aus allen bisherigen Zielen und dem neuen Ruf komplett neu aufgebaut. Die Reihenfolge hängt dann nur von Gondelposition und Fahrtrichtung ab, auch falls die alte Liste einmal unsortiert gewesen sein sollte.

== Bewertung und Auswahl

@tab:varianten bewertet die Ansätze nach dem Richtungsprinzip, dem Fahrverhalten, der Komplexität und dem Rechenaufwand pro Ruf.

#figure(
  table(
    columns: (1fr, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    table.header(
      [*Variante*], [*Richtungs-\ prinzip (A3)*], [*Fahr-\ verhalten*], [*Geringe\ Komplexität*], [*Geringer\ Rechenaufwand*],
    ),
    [Rufspeicher ohne Zielliste], [+], [--], [+], [+],
    [Feste Umkehrpunkte], [o], [+], [--], [o],
    [Einsortieren in eine sortierte Liste], [+], [+], [o], [+],
    [Liste bei jedem Ruf neu sortieren], [+], [+], [o], [--],
  ),
  caption: [Bewertung der Lösungsvarianten für die Rufverwaltung (+ gut, o mittel, -- schlecht)],
) <tab:varianten>

Der Rufspeicher ohne Zielliste wurde verworfen, weil die Gondel in jedem Stockwerk anhalten müsste, um über die Weiterfahrt zu entscheiden, und dadurch ruckartig fahren würde. Feste Umkehrpunkte bringen bei sechs Stockwerken kaum Nutzen, erhöhen aber die Komplexität deutlich. Die vollständige Neusortierung kostet nur zusätzlichen Rechenaufwand, da beim Einsortieren und beim Löschen des ersten Eintrags gar keine unsortierte Liste entstehen kann.

Die Wahl fiel deshalb auf das Einsortieren in eine sortierte Liste. Es erfüllt alle Anforderungen aus @tab:anforderungen mit geringem Rechenaufwand und war bereits teilweise umgesetzt, was bei noch etwa zwei verbleibenden Wochen den Ausschlag gab.

== Algorithmus der Zielliste <kap:zielliste>

#figure(
  image("../bilder/add-target.svg", width: 100%),
  caption: [Einsortieren eines Rufs mit `AddTargetToList`, eigene Darstellung],
) <abb:addtarget>

Neue Rufe sortiert der Funktionsbaustein `AddTargetToList` in die Zielliste ein. Er erhält die Zielliste, den neuen Ruf `NewElement` aus Stockwerk und Richtung und die aktuelle Gondelposition. Den Ablauf zeigt die linke Seite von @abb:addtarget.

*Vorprüfungen.* \
Ist die Liste voll oder gibt es den Ruf schon, wird er ignoriert (A4, @tab:anforderungen). Steht die Gondel bereits im Stockwerk des Rufs, öffnet sich die Tür über `TuerAufCmd`, ohne dass der Ruf einsortiert wird (A5). Bei einer nicht leeren Liste gilt das nur für einen Ruf in Fahrtrichtung; ein Ruf in Gegenrichtung wird normal einsortiert. In eine leere Liste kommt der Ruf als erstes Ziel.

*Aufbau der Zielliste.* \
Die Liste besteht aus bis zu drei Abschnitten, die die Gondel nacheinander abfährt (rechte Seite von @abb:addtarget). Grundlage ist die Startrichtung: aufwärts, wenn die Gondel unter dem ersten Ziel steht, abwärts, wenn sie darüber steht, und sonst die Richtung des ersten Ziels. Abschnitt 1 enthält die noch erreichbaren Ziele in Startrichtung, Abschnitt 2 alle Ziele in Gegenrichtung und Abschnitt 3 die Ziele in Startrichtung, an denen die Gondel schon vorbei ist. Jeder Abschnitt ist in seiner Fahrtrichtung sortiert.

Die Grenzen speichern die Marker `rWechsel1` (letzte Position von Abschnitt 1) und `rWechsel2` (erste Position von Abschnitt 3); fehlt ein Wechsel, ist der Marker 0. `AddTargetToList` bestimmt sie bei jedem Ruf neu, indem es die Liste durchläuft, bis ein Ziel die Richtung wechselt oder die Sortierung bricht, etwa beim Sprung von 5▲ zu 1▲.

*Einsortieren.* \
Zwei Fragen bestimmen den Abschnitt: Zeigt der Ruf in Startrichtung, und ist er noch erreichbar? Ein Ruf in Gegenrichtung kommt in Abschnitt 2, ein erreichbarer Ruf in Startrichtung in Abschnitt 1 und ein nicht mehr erreichbarer in Abschnitt 3. `InsertBetweenLimits` hängt den Ruf ans Ende des Abschnitts, und `SortBetweenLimits` sortiert den Abschnitt danach auf- oder absteigend. Gibt es weder Abschnitt 2 noch 3, wird der Ruf ans Listenende gehängt und bildet so einen neuen Abschnitt.

*Beispiel.* \
@tab:zielliste-beispiel zeigt, wie die Liste aus @abb:addtarget entsteht. Die Gondel steht in Stock 3, und sechs Außenrufe gehen kurz nacheinander ein. Der zweite Ruf 3▼ kommt zwar aus dem aktuellen Stockwerk, zeigt aber in Gegenrichtung und wird deshalb einsortiert. Im vierten Schritt gibt es Abschnitt 3 schon, sodass 6▼ in die Mitte der Liste gehört und nicht an das Ende.

#figure(
  table(
    columns: (auto, auto, 1fr, auto),
    align: (center, center, left, left),
    table.header([*Nr.*], [*Ruf*], [*Sortierung*], [*Zielliste*]),
    [1], [5▲], [Liste leer --> erstes Ziel], [5▲],
    [2], [3▼], [Gegenrichtung --> Abschnitt 2], [5▲ | 3▼],
    [3], [1▲], [Startrichtung + Nicht Erreichbar --> Abschnitt 3], [5▲ | 3▼ | 1▲],
    [4], [6▼], [Gegenrichtung --> Abschnitt 2], [5▲ | 6▼ 3▼ | 1▲],
    [5], [4▲], [Startrichtung + Erreichbar --> Abschnitt 1], [4▲ 5▲ | 6▼ 3▼ | 1▲],
    [6], [2▲], [Startrichtung + Nicht Erreichbar --> Abschnitt 3], [4▲ 5▲ | 6▼ 3▼ | 1▲ 2▲],
  ),
  caption: [Schrittweiser Aufbau der Beispiel-Zielliste, Gondel in Stock 3 (| trennt die Abschnitte)],
) <tab:zielliste-beispiel>

*Erreichte Ziele löschen.* \
`TD_RemoveAtIndex` löscht den ersten Eintrag, und die übrigen rücken in unveränderter Reihenfolge nach vorn, sodass die Liste sortiert bleibt. Hat die Gondel Abschnitt 1 abgearbeitet und gewendet, wird Abschnitt 2 zum neuen Abschnitt 1 und Abschnitt 3 zum neuen Abschnitt 2.

