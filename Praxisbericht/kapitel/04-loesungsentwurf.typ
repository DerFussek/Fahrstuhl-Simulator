#import "../vorlage.typ": todo, abbildung-folgt

// Richtwert: ca. 3,5 Seiten. Das wichtigste Kapitel: warum die Steuerung so
// gebaut ist. Mit dem Schreiben hier anfangen.
= Lösungsgenerierung und -bewertung <kap:loesungsentwurf>

== Systemaufbau und Schnittstellen der Bausteine

#figure(
  image("../bilder/systemaufbau.svg", width: 100%),
  caption: [Systemaufbau der Aufzugssteuerung, eigene Darstellung],
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
  caption: [Ablauf vom Ruf bis zur Fahrt, eigene Darstellung],
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
Taster bedient. Alle Ansätze müssen dabei das Richtungsprinzip (A3, @tab:anforderungen) einhalten:
Rufe in Fahrtrichtung werden auf dem Weg mitgenommen, Rufe in Gegenrichtung erst
nach dem Richtungswechsel. In unserer Gruppe wurden dafür vier Ansätze diskutiert,
die sich vor allem darin unterscheiden, ob und wie die Rufe in einer Liste
gespeichert und einsortiert werden.

*I. Rufspeicher ohne Zielliste.* \ 
Der Erste Ansatz funktioniert ohne Liste. Die Rufe werden in drei Arrays mit einem Eintrag pro 
Stockwerk gespeichert. Dabei gibt es ein Arrays für Innenrufe und jeweils ein Array für die 
Außentaster hoch und runter.\
Die Gondel fährt immer ein Stockwerk weiter und prüft, ob dort ein Innen- oder Außenruf in Fahrtrichtung ansteht.
Je nachdem hält sie an oder fährt in das nächste Stockwerk weiter. Die Reihenfolge der Ziele ergibt sich während der Fahrt,
dabei behält die Gondel die Richtung bei, solange in Fahrtrichtung noch Rufe offen sind. Ist dies nicht mehr der Fall und alle
Rufe in Fahrtrichtung wurden abgearbeitet, hält die Gondel auch für Rufe in Gegenrichtung und wechselt die Fahrtrichtung;
sind keine Rufe gespeichert, bleibt die Gondel stehen. Der beschriebene Ablauf wird auch durch die drei Flussdiagramme im @anh:skizzen
veranschaulicht.

*II. Feste Umkehrpunkte.* \ 
Der Zweite Ansatzt begrenzt, wie weit die Gondel in eine Richtung fahren kann. Gibt es zum Beispiel, während
einer Aufwärtsfahrt ein Ruf nach unten, wird am höchsten Ziel ein Umkehrpunkt gesetzt. Sobald die Gondel diesen
Umkehrpunkt erreicht hat fährt diese nicht mehr häher, auch wenn danach noch Rufe weiter oben in Fahrtrichtung eingehen.
Diese Rufe werden erst bei der nächsten Fahrt nach oben bearbeitet. Das gleiche Prinzip gilt auch für Abwärtsfahrten.
So wird in einem Gebäude mit beispielsweise 100 Etagen verhindert, dass die Gondel erst ganz hinauf und dann ganz hinunter fährt
und so Fahrgäste mit Rufen in Gegenrichtung lange warten müssen.

*III. Einsortieren in eine sortierte Liste.* \ 
Im dritten Ansatz, der auch umgesetzt wurde, wird jeder neue Ruf an die passende Stelle in eine bereits existierende Zielliste einsortiert.
Da die Liste nur durch Einsortieren neuer Rufe entsteht und aufgebaut wird, nehmen wir an, dass diese immer richtig sortiert ist.
Die bestehenden Ziele in der Liste müssen also nicht neu sortiert werden. Um die neuen Rufe in die Liste einzusortieren, wird
diese in drei Abschnitte mittels zwei Marken, die die Richtungswechsel markieren, aufgeteilt und die Rufe werden entsprechend in den passenden
Abschnitt einsortiert (@kap:zielliste).


*IV. Liste bei jedem Ruf neu sortieren.* \ 
Der vierte Ansatzt enstand nach Ansatz 3 und aus der Frage, was passiert, wenn die Zielliste doch einmal unsortiert ist.
Dazu wird bei jedem neuen Ruf eine neue Liste aufgebaut, in die alle Ziele der alten Liste und der neue Ruf nacheinander
nach dem Richtungsprinzip (A3, @tab:anforderungen) einsortiert werden. Danach ersetzt diese die alte Liste. Die Reihenfolge der Ziele hängt so nur 
von der aktuellen Gondelposition und deren Fahrtrichtung ab und berücksichtigt nicht mehr, wie die alte Liste ausgesehen hat.


== Bewertung und Auswahl
Die Ansätze wurden danach bewertet, ob diese das Richtungsprinzip (A3, @tab:anforderungen) erfüllen,
wie flüssig die Gondel damit fährt, wie komplet die Umsetzung ist und wie viel Rechenaufwand pro Ruf benötigt wird
um diesen in die Liste einzusortieren. @tab:varianten veranschaulicht die Bewertung und fasst diese zusammen.

Den Rufspeicher ohne Zielliste verwarf unsere Gruppe, da wir vermuteten, dass die Gondel
dadurch ruckartig fährt, weil diese bei jedem Stockwerk anhalten müsste, um über eine Weiterfahrt zu entscheiden.
Den Ansatzt mit Umkehrpunkten verwarfen wir auch, da diese für eine Simulation mit sechs Stockwerken keinen größeren Nutzen bringt und 
die Komplexität nochmal deutlich erhöhen würde.\
Die vollständige Neusortierung der Liste würde zwar auch eine falsch bzw. unsortierte Liste wieder ordnen, da die Zielliste beim
Einsortieren aber von Anfang an sortiert wird und beim entfernen eines Zieles nur die erste Stelle gelöscht wird, kann eine unsortierte Liste gar nicht
erst entstehen. Damit bedeutet dieser Ansatzt nur zusätzlichen Rechenaufwand.

Deshalb fiel die Wahl auf das Einsortieren in eine sortierte Liste. Es erfüllt alle Anforderungen in @tab:anforderungen und benötigt dabei nur geringen
Rechenaufwand. Zudem war dieser Ansatz bereits teilweise umgesetzt und es verblieben noch etwa zwei Wochen Zeit für das gesamte Projekt, was die Wahl noch mal bekräftigte. 


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
  caption: [Einsortieren eines Rufs mit `AddTargetToList`, eigene Darstellung],
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
