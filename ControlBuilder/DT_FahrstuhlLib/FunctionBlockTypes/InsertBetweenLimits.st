(*
  Function Block Type DT_FahrstuhlLib.InsertBetweenLimits
  Fuegt NewTarget hinter UpperLimit ein und sortiert den Abschnitt
  [LowerLimit..UpperLimit+1] mit SortBetweenLimits.
  Vorlage in C++: InsertBetweenLimits() in main2.cc

  Parameters
  Name           Data Type    Direction  FD Port
  -------------  -----------  ---------  -------
  NewTarget      Target       in         yes
  LowerLimit     dint         in         yes
  UpperLimit     dint         in         yes
  Dir            bool         in         yes
  TargetCount    dint         out        yes
  TargetList     ArrayObject  out        yes
  TargetCountIn  dint         in         yes
  TargetListIn   ArrayObject  in         yes

  Variables
  Name        Data Type  Start Attribute  Initial Value
  ----------  ---------  ---------------  -------------
  n           dint       retain
  lo          dint       retain
  hi          dint       retain
  element     Target
  sortDone    bool       retain
  status      dint       retain
  MaxTargets  dint       retain           10

  Function Blocks: SortBetweenLimits (Instanz, im Screenshot nicht sichtbar)
*)

TargetCount := TargetCountIn;
TargetList := TargetListIn;

n  := TargetCount;
lo := LowerLimit;
hi := UpperLimit;

(* Schutz vor Ueberlauf: InsertArray wuerde das letzte Element sonst verlieren.
   Im C++ waechst der Vektor einfach weiter. *)
IF n < MaxTargets THEN

    (* Grenzen absichern *)
    IF lo < 1 THEN
        lo := 1;
    END_IF;
    IF lo > n + 1 THEN
        lo := n + 1;
    END_IF;
    IF hi > n THEN
        hi := n;
    END_IF;
    IF hi < lo - 1 THEN
        hi := lo - 1;             (* leerer Abschnitt *)
    END_IF;

    (* TargetList.insert(begin() + upperLimit + 1, NewTarget):
       neues Element auf Position hi+1, alle folgenden rutschen eins nach hinten *)
    element := NewTarget;
    InsertArray(TargetList, hi + 1, element, status);
    TargetCount := n + 1;
    hi := hi + 1;

    (* Am Ende sortieren *)
    SortBetweenLimits(LowerLimit := lo,
                      UpperLimit := hi,
                      Dir        := Dir);

END_IF;
