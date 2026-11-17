#import "../vorlage.typ": todo, abbildung-folgt

// Richtwert: ca. 3,5 Seiten. Das wichtigste Kapitel: warum die Steuerung so
// gebaut ist. Mit dem Schreiben hier anfangen.
= Lösungsgenerierung und -bewertung <kap:loesungsentwurf>

== Systemaufbau und Schnittstellen der Bausteine

#figure(
  image("../bilder/systemaufbau.svg", width: 100%),
  caption: [Systemaufbau der Aufzugssteuerung],
) <abb:systemaufbau>

Die Aufzugssteuerung besteht aus insgesamt neun Bausteinen. @abb:systemaufbau zeigt deren Aufgabenverteilung sowie die wesentlichen Signalverbindungen. Die Steuerung teilt sich in die Ruf- und Zielverwaltung, die Motor- und Türsteuerung sowie die Ansteuerung der Tasteranzeigen auf.

Als zentrale Schnittstelle zwischen den Bedienereingaben und der Fahrsteuerung dient das Control Module `TD_Gondel`. Es erfasst die sechs Innentaster sowie die zehn Außentaster, die sich jeweils in fünf Taster für die Aufwärts- und Abwärtsfahrt aufteilen. Die Taster sind in das Grafikbild integriert und werden innerhalb von `TD_Gondel` in drei Arrays zusammengefasst.

Zur Verwaltung der Fahrtziele nutzt `TD_Gondel` eine Zielliste mit maximal zehn Einträgen, wobei jeder Eintrag das angeforderte Stockwerk und die dazugehörige Richtung enthält. Das Einfügen und Sortieren neuer Ziele übernimmt der Funktionsbaustein `AddTargetToList`, während `TD_RemoveAtIndex` Einträge aus der Liste löscht (das Sortierverfahren wird in @kap:zielliste genauer erläutert). Das Zurücksetzen der Taster übernimmt der Baustein `TD_ResetTaster`, den `TD_Gondel` direkt ansteuert.

Der Gondelmotor wird von `TD_MotorController` gesteuert. `TD_Gondel` stellt ihm hierfür das erste Ziel der Zielliste als `ZielStock` sowie die Fahrtfreigabe `Enable` zur Verfügung. Als Rückmeldungen liefert der Motorcontroller die aktuelle Gondelposition (`GondelPos`) und das Signal `Done` beim Erreichen der Zielposition, welches von `TD_Gondel` genutzt wird, um neue Ziele relativ zur aktuellen Position einzusortieren.

Die Türsteuerung `DT_Door` wertet die Türendlagen, die Lichtschranke sowie die Taster „Tür auf“ und „Tür zu“ aus. Sie steuert sowohl die Kabinentür über `TD_Door_Pos` als auch die Schachttürren des jeweiligen Stockwerks über `TD_Shaftdoor_Pos`, wobei die Position `GondelPosExpo` fest legt, welche Schachttür sich öffnnet. Über `TuerAufCMD` kann `TD_Gondel` eine Türöffnung anfordern; die Ankunft am Ziel wird der Türsteuerung über die Rückmeldung `Done` signalisiert.

Das Signal `EnableGondel` zeigt an, dass alle Türen geschlossen sind und eine Fahrt freigegeben werden kann. Im Diagramm `DT_Gondel` wird dises über eine UND-Verknüpfung mit `HatZiel` verschaltet. Das daraus entstehende Signal `Enable` gibt den Motorcontroller nur dann frei, wenn ein Fahrtziel vorliegt und die Türsteuerung die Fahrt freigibt.

Die Anzeige offener Rufe übernimmt der Baustein `TD_LedSteuerung`. Dieser erhält die Zielliste über `TargetList` und deren Größe über `TargetCount`, woraufhin er die entsprechenden Taster beleuchtet.

Innerhalb der Anwendung `TD_Appl` ist die Steuerung auf die beiden Diagramme `DT_Gondel` (Fahrlogik) und `DT_Door` (Türsteuerung) aufgeteilt, wobei der Datenaustausch zwischen ihnen über Communication-Variablen erfolgt. Mit Ausnahme der beiden Listenoperationen sind alle Bausteine Control Modules; `AddTargetToList` und `TD_RemoveAtIndex` werden als Funktionsbausteine direkt innerhalb von `TD_Gondel` verwendet.

== Ablauf einer Fahrt

#figure(
  image("../bilder/ablauf-gesamt.svg", width: 100%),
  caption: [Ablauf vom Ruf bis zur Fahrt],
) <abb:ablauf>

Der Ablauf einer Fahrt ergibt sich aus dem Zusammenspiel von Rufverwaltung, Motor- und Türsteuerung. @abb:ablauf unterteilt die Rufbearbeitung und den Ablauf von Fahrt- und Türbewegungen in zwei Bereiche, die parallel arbeiten: Neue Rufe lassen sich somit auch während einer laufenden Fahrt oder einer Türbewegung verarbeiten. Die Zustände im Ablaufdiagramm existieren nicht als Zustandsvariablen, sondern dienen nur zur Veranschaulichung.

*I. Ruf aufnehmen und einordnen* \ 
Wird ein Innen- oder Außentaster betätigt, verarbeitet `TD_Gondel` die Anforderung als Ziel bestehend aus Stockwerk und Richtung. Bereits hinterlegte Rufe werden nicht erneut aufgenommen und sobald alle zehn Listenplätze belegt sind, werden keine weiteren Rufe mehr in die Zielliste einsortiert.

Befindet sich die Gondel bereits auf dem angeforderten Stockwerk, wird der Ruf direkt durch ein Öffnen der Tür über `TuerAufCMD` bedient, ohne dafür einen neuen Listeneintrag anzulegen (A5,  @tab:anforderungen). Bei einer nicht leeren Zielliste gilt dies allerdings nur für Rufe in der aktuellen Fahrtrichtung; ein Ruf in Gegenrichtung wird stattdessen normal in die Zielliste einsortiert.

Alle übrigen Rufe werden nach dem Richtungsprinzip eingeordnet, welches in @kap:zielliste näher beschrieben wird. Da die Rufbearbeitung während des gesamten Betriebs aktiv bleibt, können neue Rufe auch während einer Fahrt die Reihenfolge der Ziele und damit das momentane Fahrtziel verändern.

*II. Türen schließen und Fahrt freigeben* \
Sobald die Zielliste mindestens einen Eintrag enthält, aktiviert `TD_Gondel` das Signal `HatZiel` und stellt das erste Listenelement als `ZielStock` für die Motorsteuerung bereit. Die Fahrt beginnt jedoch erst, wenn auch die Türfreigabe `EnableGondel` vorliegt (A6).

Ist die Tür noch geöffnet, bleibt sie für die Offenhaltezeit von fünf Sekunden geöffnet, bevor `DT_Door` den Schließvorgang auslöst (A8). Mit dem "Tür zu" Taster lässt sich das Schließen vorher auslösen. Ein neuer Ruf verkürzt die Offenhaltezeit nicht.

Die Lichtschranke sowie der Taster „Tür auf“ werden vor dem Schließvorgang priorisiert. Solange eines dieser Signale aktiv ist, wird der Offenhalte-Timer angehalten. Erfolgt die Betätigung während eines bereits laufenden Schließvorgangs, öffnen sich die Türen wieder (A7). Erst wenn die Türen vollständig geschlossen sind und weiterhin ein Ziel ansteht, wird `Enable` aktiviert.

*III. Zum Ziel fahren* \
Bei Fahrtfreigabe verfährt `TD_MotorController` die Gondel zum entsprechenden `ZielStock`. Während der Fahrt stellt dieser die aktuelle Position als Rückmeldung bereit, welche sowohl für die fortlaufende Zielverwaltung als auch für die Zuordnung der jeweiligen Schachttür benutzt wird.

*IV. Ziel erreichen und Ruf abschließen* \
Beim Erreichen der Zielposition stoppt der Motorcontroller die Gondel und aktiviert das Signal `Done`. Dies löst zwei Vorgänge aus, die parallel verlaufen. Die Türsteuerung leitet die Türöffnung ein und `TD_Gondel` entfernt das erreichte Ziel aus der Zielliste.

Die Türsteuerung erkennt die Ankunft anhand der steigenden Flanke am Eingang `EnableTuer` und steuert das Öffnen der Kabinentür sowie der über `GondelPosExpo` ermittelten Schachttür an. Sobald die geöffnete Endlage erreicht ist, startet erneut die Offenhaltezeit von fünf Sekunden.

Durch das Löschen des erreichten Ziels rücken die verbleibenden Listeneinträge auf. Die Tasterbeleuchtung wird entsprechend der aktualisierten Zielliste angepasst, sodass nur weiterhin offene Rufe angezeigt werden.

*V. Weitere Ziele bearbeiten oder in den Leerlauf wechseln* \
Sind noch weitere Ziele hinterlegt, wird das nächste Listenelement als neues Fahrtziel benutzt, woraufhin nach dem Schließen der Türen und erneuter Fahrtfreigabe die nächste Fahrt beginnt. Ist die Zielliste hingegen leer, bleibt die Gondel nach dem Schließen der Türen im Leerlauf, bis ein neuer Ruf eingeht.


== Lösungsvarianten für die Rufverwaltung <kap:varianten>

Die Rufverwaltung legt fest, in welcher Reihenfolge die Gondel die gedrückten
Taster bedient. Alle Ansätze müssen dabei das Richtungsprinzip (A3) einhalten:
Rufe in Fahrtrichtung werden auf dem Weg mitgenommen, Rufe in Gegenrichtung erst
nach dem Richtungswechsel. In der Gruppe wurden dafür vier Ansätze diskutiert,
die sich vor allem darin unterscheiden, ob und wie die Rufe in einer Liste
gespeichert werden.

*Rufspeicher ohne Zielliste.* \ Der erste Ansatz kommt ganz ohne Liste aus. Die
Rufe werden nur in drei Arrays mit einem Eintrag pro Stockwerk gespeichert: eines
für die Innentaster und je eines für die Außentaster aufwärts und abwärts. Die
Gondel fährt immer ein Stockwerk weiter und prüft dort, ob für diese Etage ein
Innenruf oder ein Außenruf in Fahrtrichtung vorliegt. Je nachdem hält sie an oder
fährt weiter, die Reihenfolge der Ziele ergibt sich also erst während der Fahrt.
Die Richtung behält die Gondel bei, solange in Fahrtrichtung noch Rufe
gespeichert sind. Erst wenn dort keine mehr vorliegen, hält sie auch für einen
Ruf in Gegenrichtung und wechselt die Richtung; ohne weitere Rufe bleibt sie
stehen. Diesen Ablauf beschreiben drei Flussdiagramme aus der Entwurfsphase
(@anh:skizzen).

*Feste Umkehrpunkte.* \ Der zweite Ansatz begrenzt, wie weit die Gondel in eine
Richtung fährt. Kommt während einer Aufwärtsfahrt ein Ruf abwärts, wird am zu
diesem Zeitpunkt höchsten Ziel ein Umkehrpunkt gesetzt. Dort wechselt die Gondel
die Richtung und fährt nicht mehr höher, auch wenn danach noch Rufe weiter oben
in Fahrtrichtung eingehen; diese werden erst bei der nächsten Aufwärtsfahrt
bedient. So soll etwa in einem Gebäude mit 100 Stockwerken verhindert werden,
dass die Gondel erst ganz hinauf- und dann ganz hinunterfährt, während Fahrgäste
in Gegenrichtung lange warten.

*Einsortieren in eine sortierte Liste.* \ Im dritten Ansatz, der am Ende
umgesetzt wurde, wird jeder neue Ruf direkt an der passenden Stelle in die
bestehende Zielliste eingefügt. Da die Liste nur durch dieses Einsortieren
aufgebaut wird und beim Abarbeiten immer nur das erste Ziel entfällt, wird
angenommen, dass sie stets richtig sortiert ist. Die übrigen Ziele müssen deshalb
nicht neu geordnet werden. Die erste Umsetzung direkt in Structured Text
verglich dazu den neuen Ruf mit den benachbarten Einträgen und scheiterte an
Zielen hinter einem Richtungswechsel. Die endgültige Lösung aus dem C++-Prototyp
teilt die Liste deshalb mit zwei Markern in bis zu drei Abschnitte und sortiert
den Ruf nur in den passenden Abschnitt ein (@kap:zielliste).

*Liste bei jedem Ruf neu sortieren.* \ Der vierte Ansatz entstand erst danach,
aus der Frage, was passiert, wenn die Zielliste doch einmal unsortiert ist. Dazu
wird bei jedem neuen Ruf eine neue Liste aufgebaut, in die alle Ziele der alten
Liste und der neue Ruf nacheinander nach dem Richtungsprinzip einsortiert werden.
Anschließend ersetzt sie die alte Liste. Die Reihenfolge hängt damit nur von der
aktuellen Position und Fahrtrichtung der Gondel ab und nicht davon, wie die alte
Liste aussah.

== Bewertung und Auswahl

Die Ansätze wurden danach bewertet, ob sie das Richtungsprinzip (A3) erfüllen,
wie gleichmäßig die Gondel damit fährt, wie komplex die Umsetzung ist und wie
viel die Steuerung bei jedem Ruf rechnen muss. @tab:varianten fasst die Bewertung
zusammen.

Den Rufspeicher ohne Zielliste verwarf die Gruppe, weil sie vermutete, dass die
Gondel damit ruckartig fährt: Sie müsste an jedem Stockwerk anhalten und prüfen,
ob sie weiterfahren soll. Feste Umkehrpunkte lohnen sich vor allem in hohen
Gebäuden. In der Simulation mit sechs Stockwerken bringen sie kaum einen Vorteil,
machen die Steuerung aber deutlich komplexer. Das vollständige Neusortieren
würde zwar auch eine unsortierte Liste wieder ordnen. Da die Zielliste beim
Einsortieren aber von Anfang an sortiert aufgebaut wird und beim Abarbeiten nur
das erste Ziel entfällt, kann eine unsortierte Liste gar nicht entstehen. Alle
Ziele bei jedem Tastendruck neu zu sortieren, wäre damit nur zusätzlicher
Rechenaufwand.

Die Wahl fiel deshalb auf das Einsortieren in eine sortierte Liste. Es erfüllt
das Richtungsprinzip, die Gondel fährt jedes Ziel ohne Zwischenhalt an, und bei
einem neuen Ruf muss nur dieser eine Eintrag eingeordnet werden.

#todo[
  Bewertung in @tab:varianten ist ein Vorschlag, bitte prüfen. Die Kriterien
  sind an eure Gründe angepasst (vorher: Korrektheit, Übersichtlichkeit,
  Rechenaufwand, Umsetzbarkeit in CBM).
]

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

== Algorithmus der Zielliste <kap:zielliste>

#figure(
  image("../bilder/add-target.svg", width: 100%),
  caption: [Einsortieren eines Rufs mit `AddTargetToList`],
) <abb:addtarget>

#todo[
  - Aufbau der Liste: bis zu drei Abschnitte (Fahrtrichtung vor der Kabine,
    Gegenrichtung, wieder Startrichtung)
  - Marker `rWechsel1` und `rWechsel2` für die Richtungswechsel
  - Optional: Zwischenschritte bis zur Marker-Lösung -- Einfügen mit
    Fallunterscheidung der Nachbarn `i` und `i+1` (erster ST-Versuch, scheiterte
    am „Sprung“, z. B. gehört in 2↑ 3↑ 4↑ 1↑ ein neuer Ruf 3↓ vor 1↑),
    Dummy-Eintrag in Gegenrichtung (Ziel, das niemand angefordert hat) und drei
    getrennte Listen (Grundgedanke der drei Abschnitte)
  - Einsortieren an einem Beispiel durchspielen: Kabine in Stock 2 aufwärts,
    nacheinander Innenrufe in 4, 1 und 3 -- die Liste nach jedem Schritt als
    kleine Tabelle
  - Sonderfälle: leere Liste, doppelter Ruf, volle Liste, Ruf im aktuellen Stockwerk
]
