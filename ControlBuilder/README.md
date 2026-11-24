# Fahrstuhl-Simulator: Structured Text (ABB Control Builder M)

Abschrift des Projekts `Til_Projekt` (ABB University System, Control Builder M Professional) aus Screenshots vom 16.11.2026. Die C++-Vorlage liegt in [`../cpp-prototyp/`](../cpp-prototyp/) (aktueller Stand `main.cc`, frühere Fassungen in `versionen/`).

## Projektstruktur (aus dem Projektbaum)

- Library `DT_FahrstuhlLib 1.0-0`
  - Datentyp: [`Target`](DT_FahrstuhlLib/Target.st)
  - Function Block Types: [`AddTargetToList`](DT_FahrstuhlLib/FunctionBlockTypes/AddTargetToList.st), [`InsertBetweenLimits`](DT_FahrstuhlLib/FunctionBlockTypes/InsertBetweenLimits.st), [`SortBetweenLimits`](DT_FahrstuhlLib/FunctionBlockTypes/SortBetweenLimits.st), [`TD_RemoveAtIndex`](DT_FahrstuhlLib/FunctionBlockTypes/TD_RemoveAtIndex.st)
  - Control Module Types: [`DT_Door`](DT_FahrstuhlLib/ControlModuleTypes/DT_Door.st), [`TD_Door_Pos`](DT_FahrstuhlLib/ControlModuleTypes/TD_Door_Pos.st), [`TD_Gondel`](DT_FahrstuhlLib/ControlModuleTypes/TD_Gondel.st), [`TD_LedSteuerung`](DT_FahrstuhlLib/ControlModuleTypes/TD_LedSteuerung.st), [`TD_MotorController`](DT_FahrstuhlLib/ControlModuleTypes/TD_MotorController.st), [`TD_ResetTaster`](DT_FahrstuhlLib/ControlModuleTypes/TD_ResetTaster.st), [`TD_Shaftdoor_Pos`](DT_FahrstuhlLib/ControlModuleTypes/TD_Shaftdoor_Pos.st)
- Application `TD_Appl` (Controller_TD.Normal) mit den Diagrammen `DT_Door` und `DT_Gondel`: [TD_Appl/Diagrams.md](TD_Appl/Diagrams.md)
- Controller `Controller_TD` (172.16.4.1:20), BasicHwLib 6.1-1, Soft Controller, Tasks Fast / Normal / Slow
- Weitere Libraries: System, BasicLib 1.9-5, IconLib 1.6-2

Die Visualisierung (`TD_Fahrstuhl:Fahrstuhl Schacht`) zeigt den Schacht mit Stockwerken 0 bis 5, die Aussentaster EG bis OG 5 (A = hoch, V = runter), das Kabinen-Bedienfeld (0 bis 5, A, `>|<`, `<|>`), die Tuer und die Lichtschranke.

## Hinweise zur Abschrift

Die `.st`-Dateien sind **Vorlagen zum Nachlesen**, keine importierbaren Dateien. Control Builder M nimmt Parameter und Variablen nur ueber seine Tabellen; ins Code-Fenster kommt nur der Code. Deshalb steht pro Datei zuerst ein Kommentar mit den Tabellen, danach der Code, so wie er im Code-Fenster steht. Der Code wurde Zeichen fuer Zeichen von den Screenshots uebernommen; Tippfehler im Original (z. B. `TuerZuREquest`, `TD_MotorControll_`) sind bewusst erhalten.

## Offene Punkte (auf den Screenshots nicht vorhanden oder auffaellig)

Fehlende Teile, bitte nachliefern (Scrollen im Code-Fenster, Reiter "Variables" / "Function Blocks"):

- `TD_Gondel`: Code nur bis zum Befuellen von `vAnfragenAussenHoch` sichtbar. Es fehlen Runter-Taster, Erkennen neuer Rufe, Aufruf von `AddTargetToList` und `TD_RemoveAtIndex`, `HatZiel`, `ZielStock`, `TargetListOut`, `TargetCountOut`. Reiter "Function Blocks" nicht gesehen.
- `TD_LedSteuerung`: Variablen-Tabelle und Anfang des Codes fehlen.
- `InsertBetweenLimits`, `AddTargetToList`: Reiter "Function Blocks" (Instanzen) fehlt; `AddTargetToList` benutzt `MaxTargets` und `ExecuteOld`, die in der Variablen-Tabelle nicht stehen. Beide Bausteine (und `TD_Gondel`) haben im Projektbaum ein Warndreieck.
- `TD_RemoveAtIndex`: Der Code nutzt `vStatus`, die Tabelle enthaelt `SS`; Zeile 1 der Parameter (vermutlich `inArray`) war nicht sichtbar.

Moegliche Abweichungen von `main2.cc` (bitte pruefen, nichts davon wurde geaendert):

- `AddTargetToList`, zweiter Richtungswechsel: Fuer "gleiche Richtung, nicht erreichbar" (Abschnitt `rWechsel2..nTargets`) und "gleiche Richtung, erreichbar" (`1..rWechsel1`) steht auf dem Screenshot `Dir := NOT startDirection`. In `main2.cc` ist es bei beiden `aufsteigend`, also `startDirection`.
- `AddTargetToList`: `IF Execute` wird nicht mit `ExecuteOld` zu einer steigenden Flanke verknuepft, obwohl die Beschreibung "steigende Flanke" sagt.
- `InsertBetweenLimits` ruft `SortBetweenLimits` nur mit `LowerLimit`, `UpperLimit` und `Dir` auf; `TargetListIn`/`TargetCountIn` werden nicht uebergeben (in `AddTargetToList` schon).
- `Target`: Der Name der ersten Komponente war im Screenshot nur als `S` (Zelle in Bearbeitung) zu sehen und wurde als `level` angenommen.
- `DT_Door`: Kommentare vertauscht ("Tuer Auf Knopfes" steht ueber der Tuer-Zu-LED-Logik und umgekehrt).
