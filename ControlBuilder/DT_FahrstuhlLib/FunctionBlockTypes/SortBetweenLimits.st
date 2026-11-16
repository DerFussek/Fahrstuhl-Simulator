(*
  Function Block Type DT_FahrstuhlLib.SortBetweenLimits
  Insertion Sort auf TargetList[LowerLimit..UpperLimit] (beide inklusive, 1-basiert).
  Dir = TRUE -> aufsteigend, FALSE -> absteigend.
  Vorlage in C++: SortBetweenLimits() in main2.cc

  Parameters
  Name                Data Type    Direction  FD Port
  ------------------  -----------  ---------  -------
  LowerLimit          dint         in         yes
  UpperLimit          dint         in         yes
  Dir                 bool         in         yes
  SortBetweenLimits   bool         out        yes
  TargetCount         dint         out        yes
  TargetList          ArrayObject  out        yes
  TargetCountIn       dint         in         yes
  TargetListIn        ArrayObject  in         yes

  Variables (alle Start Attribute = retain)
  lo dint, hi dint, j dint, aktuell Target, elemJ Target,
  verschieben bool, status dint, i dint
*)

TargetCount := TargetCountIn;
TargetList := TargetListIn;

lo := LowerLimit;
hi := UpperLimit;
SortBetweenLimits := FALSE;

(* Grenzen absichern *)
IF lo < 1 THEN
    lo := 1;
END_IF;
IF hi > TargetCount THEN
    hi := TargetCount;
END_IF;

(* lo >= hi: 0 oder 1 Element, nichts zu tun *)
IF lo < hi THEN
    FOR i := lo + 1 TO hi DO
        GetArray(TargetList, i, aktuell, status);
        j := i - 1;

        (* nach rechts schieben, solange das Element davor "falsch" liegt.
           j >= lo wird in der WHILE-Bedingung geprueft, damit nie
           das Element lo-1 gelesen wird. *)
        verschieben := TRUE;
        WHILE verschieben AND (j >= lo) DO
            GetArray(TargetList, j, elemJ, status);
            IF (Dir AND (elemJ.level > aktuell.level))
                OR ((NOT Dir) AND (elemJ.level < aktuell.level)) THEN
                PutArray(TargetList, j + 1, elemJ, status);
                j := j - 1;
            ELSE
                verschieben := FALSE;
            END_IF;
        END_WHILE;

        PutArray(TargetList, j + 1, aktuell, status);
    END_FOR;

    SortBetweenLimits := TRUE;
END_IF;
