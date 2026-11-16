(*
  Function Block Type DT_FahrstuhlLib.TD_RemoveAtIndex
  Kopiert inArray nach outArray und laesst dabei das Element index_delete weg
  (Elemente dahinter rutschen eins nach vorn). Fest auf 10 Elemente ausgelegt.

  Parameters
  Name          Data Type    Direction  FD Port
  ------------  -----------  ---------  -------
  inArray       ArrayObject  in         yes     (Zeile 1 im Screenshot nicht sichtbar, aus dem Code abgeleitet)
  index_delete  int          in         yes
  ArrayElement  Target       in         yes
  outArray      ArrayObject  out        yes

  Variables (laut Screenshot, Start Attribute retain)
  SS dint, vGet Target, i int

  ACHTUNG: Der Code verwendet vStatus, in der Variablen-Tabelle steht aber "SS"
  (Titelleiste im Screenshot zeigt * = ungespeicherte Aenderung). Vermutlich ist
  "SS" ein Tippfehler fuer "vStatus" - bitte in Control Builder M pruefen.
*)

CreateArray( Array        => outArray,
             FirstIndex   := 1,
             LastIndex    := 10,
             ArrayElement := ArrayElement,
             Status       => vStatus );

for i := 1 to index_delete - 1 do
    GetArray( Array        := inArray,
              Index        := i,
              ArrayElement => vGet,
              Status       => vStatus );
    PutArray( Array        := outArray,
              Index        := i,
              ArrayElement := vGet,
              Status       => vStatus );
end_for;

for i := index_delete to 9 do
    GetArray( Array        := inArray,
              Index        := i + 1,
              ArrayElement => vGet,
              Status       => vStatus );
    PutArray( Array        := outArray,
              Index        := i,
              ArrayElement := vGet,
              Status       => vStatus );
end_for;
