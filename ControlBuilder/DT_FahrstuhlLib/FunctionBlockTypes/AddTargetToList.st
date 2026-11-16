(*
  Function Block Type DT_FahrstuhlLib.AddTargetToList
  Sortiert einen neuen Ruf (NewElement) in die Zielliste ein.
  Vorlage in C++: AddTargetToList() in main2.cc

  Parameters
  Name           Data Type    Direction  FD Port  Description
  -------------  -----------  ---------  -------  ------------------------------------
  Execute        bool         in         yes      steigende Flanke --> eimmal ausfuehren
  NewElement     Target       in         yes
  GondelPosition dint         in         yes
  Done           bool         out        yes
  TargetListIN   ArrayObject  in         yes
  TargetList     ArrayObject  out        yes
  TargetCountIN  dint         in         yes
  TargetCount    dint         out        yes
  TuerAufCmd     bool         out        yes

  Variables (alle Start Attribute = retain)
  S bool (Tippfehler/Rest, wird nicht benutzt), i dint, nTargets dint,
  rWechsel1 dint, rWechsel2 dint, startDirection bool, abschnitt1Leer bool,
  wechsel1 bool, isReachable bool, isDuplicate bool, suchen bool, insertPos dint,
  sortDone bool, newLocal Target, erstes Target, elemI Target, elemPrev Target,
  status dint

  Function Blocks: InsertBetweenLimits, SortBetweenLimits (Instanzen im Screenshot nicht sichtbar)

  LUECKEN (im Screenshot nicht zu sehen, vermutlich Grund fuer das Warndreieck im Projektbaum):
  - MaxTargets wird benutzt, steht aber nicht in der Variablen-Tabelle (evtl. External Variables)
  - ExecuteOld wird am Ende zugewiesen, steht nicht in der Variablen-Tabelle
  - Die Flankenerkennung ist nicht aktiv: es wird "IF Execute" geprueft, nicht "Execute AND NOT ExecuteOld"
  - Zeile 1 im Screenshot beginnt mit "STargetList" - das "S" ist vermutlich ein versehentlich
    getipptes Zeichen und hier entfernt
*)

TargetList := TargetListIN;
TargetCount := TargetCountIN;
Done := FALSE;
TuerAufCmd := false;

IF Execute THEN

    newLocal := NewElement;

    IF TargetCount <= 0 THEN
        (* Wenn Liste leer *)
        IF NewElement.level = GondelPosition THEN
            (* Ruf in der aktuellen Etage --> Tuer oeffnen, nicht in die Liste aufnehmen *)
            TuerAufCmd := TRUE;
        ELSE
            TargetCount := 1;
            PutArray(TargetList, 1, newLocal, status);
        END_IF;

    ELSIF TargetCount < MaxTargets THEN
        (* Liste nicht voll (bei >= 10 Eintraegen wird ignoriert) *)

        (* Wenn identischer Aufruf vorhanden --> Ignorieren *)
        isDuplicate := FALSE;
        FOR i := 1 TO TargetCount DO
            GetArray(TargetList, i, elemI, status);
            IF (elemI.direction = NewElement.direction)
               AND (elemI.level = NewElement.level) THEN
                isDuplicate := TRUE;
            END_IF;
        END_FOR;

        IF NOT isDuplicate THEN

            (* Marker erstellen *)
            rWechsel1 := 0;
            rWechsel2 := 0;
            GetArray(TargetList, 1, erstes, status);
            IF GondelPosition < erstes.level THEN
                startDirection := TRUE;                      (* Rauf *)
            ELSIF GondelPosition > erstes.level THEN
                startDirection := FALSE;                     (* Runter *)
            ELSE
                startDirection := erstes.direction;
            END_IF;

            (* Ruf in der aktuellen Etage in Fahrtrichtung --> Tuer oeffnen, nicht einsortieren
               (Ruf in Gegenrichtung wird normal einsortiert) *)
            IF (NewElement.level = GondelPosition)
               AND (NewElement.direction = startDirection) THEN
                TuerAufCmd := TRUE;

            ELSE
                (* Hat das erste Element einen Pfeil gegen die Fahrtrichtung, ist Abschnitt 1 leer
                   (rWechsel1 bleibt dann 0 = "Abschnitt 1 endet vor Index 1") *)
                abschnitt1Leer := (erstes.direction <> startDirection);

                (* Erster Richtungswechsel *)
                IF NOT abschnitt1Leer THEN
                    i      := 2;
                    suchen := TRUE;
                    WHILE suchen AND (i <= TargetCount) DO
                        GetArray(TargetList, i - 1, elemPrev, status);
                        GetArray(TargetList, i,     elemI,    status);
                        IF (elemI.direction <> startDirection)
                           OR (elemI.direction AND (elemPrev.level > elemI.level))
                           OR ((NOT elemI.direction) AND (elemPrev.level < elemI.level)) THEN
                            rWechsel1 := i - 1;
                            suchen    := FALSE;
                        END_IF;
                        i := i + 1;
                    END_WHILE;
                END_IF;

                wechsel1 := (rWechsel1 <> 0) OR abschnitt1Leer;

                (* Zweiter Richtungswechsel *)
                IF wechsel1 THEN
                    i      := rWechsel1 + 1;
                    suchen := TRUE;
                    WHILE suchen AND (i <= TargetCount) DO
                        GetArray(TargetList, i, elemI, status);
                        IF elemI.direction = startDirection THEN
                            rWechsel2 := i;
                            suchen    := FALSE;
                        END_IF;
                        i := i + 1;
                    END_WHILE;
                END_IF;

                (* Anfahrbarkeit *)
                isReachable := ((GondelPosition > NewElement.level) AND (NOT startDirection))
                            OR ((GondelPosition < NewElement.level) AND startDirection);

                nTargets := TargetCount;

                IF (NOT wechsel1) AND (rWechsel2 = 0) THEN
                    (* Keine Richtungswechsel *)
                    TargetCount := TargetCount + 1;
                    PutArray(TargetList, TargetCount, newLocal, status);
                    IF (NewElement.direction = startDirection) AND isReachable THEN
                        SortBetweenLimits( LowerLimit    := 1,
                                           UpperLimit    := TargetCount,
                                           Dir           := startDirection,
                                           TargetCount   => TargetCount,
                                           TargetList    => TargetList,
                                           TargetCountIn := TargetCount,
                                           TargetListIn  := TargetList );
                    END_IF;

                ELSIF wechsel1 AND (rWechsel2 = 0) THEN
                    (* 1. Richtungswechsel *)
                    IF (NewElement.direction = startDirection) AND isReachable THEN
                        InsertBetweenLimits( NewTarget     := NewElement,
                                             LowerLimit    := 1,
                                             UpperLimit    := rWechsel1,
                                             Dir           := startDirection,
                                             TargetCount   => TargetCount,
                                             TargetList    => TargetList,
                                             TargetCountIn := TargetCount,
                                             TargetListIn  := TargetList );
                    ELSIF (NewElement.direction = startDirection) AND (NOT isReachable) THEN
                        TargetCount := TargetCount + 1;
                        PutArray(TargetList, TargetCount, newLocal, status);
                    ELSE
                        InsertBetweenLimits( NewTarget     := NewElement,
                                             LowerLimit    := rWechsel1+1,
                                             UpperLimit    := nTargets,
                                             Dir           := NOT startDirection,
                                             TargetCount   => TargetCount,
                                             TargetList    => TargetList,
                                             TargetCountIn := TargetCount,
                                             TargetListIn  := TargetList );
                    END_IF;

                ELSIF wechsel1 AND (rWechsel2 <> 0) THEN
                    (* 2. Richtungswechsel *)
                    IF (NewElement.direction = startDirection) AND (NOT isReachable) THEN
                        InsertBetweenLimits( NewTarget     := NewElement,
                                             LowerLimit    := rWechsel2,
                                             UpperLimit    := nTargets,
                                             Dir           := NOT startDirection,
                                             TargetCount   => TargetCount,
                                             TargetList    => TargetList,
                                             TargetCountIn := TargetCount,
                                             TargetListIn  := TargetList );
                    ELSIF (NewElement.direction = startDirection) AND isReachable THEN
                        InsertBetweenLimits( NewTarget     := NewElement,
                                             LowerLimit    := 1,
                                             UpperLimit    := rWechsel1,
                                             Dir           := NOT startDirection,
                                             TargetCount   => TargetCount,
                                             TargetList    => TargetList,
                                             TargetCountIn := TargetCount,
                                             TargetListIn  := TargetList );
                    ELSE
                        InsertBetweenLimits( NewTarget     := NewElement,
                                             LowerLimit    := rWechsel1+1,
                                             UpperLimit    := rWechsel2-1,
                                             Dir           := NOT startDirection,
                                             TargetCount   => TargetCount,
                                             TargetList    => TargetList,
                                             TargetCountIn := TargetCount,
                                             TargetListIn  := TargetList );
                    END_IF;
                END_IF;

            END_IF;     (* Tuer-auf-Sonderfall *)
        END_IF;         (* kein Duplikat *)
    END_IF;             (* Liste leer / nicht voll *)

    Done := TRUE;
END_IF;

ExecuteOld := Execute;
