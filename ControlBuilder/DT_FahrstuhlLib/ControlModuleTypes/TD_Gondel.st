(*
  Control Module Type DT_FahrstuhlLib.TD_Gondel   (UNVOLLSTAENDIG - siehe unten)
  Sammelt die Rufe aller Taster in ArrayObjects und verwaltet die Zielliste.

  Parameters (alle FD Port = yes)
  Name                  Data Type    Direction
  --------------------  -----------  ---------
  GondelPos             dint         in
  TasterInnen1 .. 6     bool         in
  TasterAussenHoch1 .. 5     bool    in
  TasterAussenRunter2 .. 6   bool    in
  HatZiel               bool         out
  RemoveFirstEntry      bool         in
  ZielStock             dint         out
  TuerAufCMD            bool         out
  ResetTaster           bool         out
  TargetListOut         ArrayObject  out
  TargetCountOut        dint         out

  Variables
  Name                 Data Type    Initial Value  Description
  -------------------  -----------  -------------  ------------------------------------------------
  vFirstScan           bool         true
  vAnfragenInnen       ArrayObject
  vArrayElement        bool                        legt den Datentyp des Array fest. als Bool
  vAnfragenAussenHoch  ArrayObject
  vAnfragenAussenRunter ArrayObject
  vStatus              dint                        Ueberall eingesetzt, weil uns der status nicht interessiert
  vTargets             ArrayObject
  vTargetElement       Target
  i                    int                         fuer die for Schleifen
  vNewTarget           Target
  vGetElement          bool
  TargetList           ArrayObject
  vStatusHoch          dint
  vStatusInnen         dint
  vStatusRunter        dint
  vStatusListe         dint
  vStatusAdd           dint
  vS1, vS2, vS3        dint
  TargetCount          dint         0
  vAddDone             bool
  vTuerAufAdd          bool

  LUECKE: Die Screenshots zeigen den Code bis zum Befuellen von vAnfragenAussenHoch und
  (seit 19.11.2026) den Teil ab der for-Schleife bis zur Uebergabe an die LED-Steuerung.
  Weiterhin fehlen: das Befuellen von vAnfragenAussenRunter (vermutlich analog zu
  vAnfragenAussenHoch mit TasterAussenRunter2 .. 6, Index 2 .. 6), das Auslesen des
  ersten Listeneintrags in vTargetElement und die Zuweisung von ZielStock sowie der
  Reiter "Function Blocks" (Instanzen).
  Im Code steht "Status := VS2" bzw. "Status := vS1" mit ":=" statt "=>" bei CreateArray, wie im Screenshot.
*)

ResetTaster := false;
vGetElement := false;
TuerAufCMD := false;
(*Arrays beim erstmaligen ausfuehren erstellen*)
if vFirstScan then

   vFirstScan := false;
   CreateArray( Array => vAnfragenInnen,
                         FirstIndex := 1,
                         LastIndex := 6,
                         ArrayElement := vArrayElement,
                         Status := vS1);

   CreateArray( Array => vAnfragenAussenHoch,
                         FirstIndex := 1,
                         LastIndex := 5,
                         ArrayElement := vArrayElement,
                         Status := VS2);


   CreateArray( Array => vAnfragenAussenRunter,
                         FirstIndex := 2,
                         LastIndex := 6,
                         ArrayElement := vArrayElement,
                         Status := vS3);

   CreateArray( Array => TargetList,
                         FirstIndex := 1,
                         LastIndex := 10,
                         ArrayElement := vNewTarget,
                         Status := vStatusListe);
end_if;



(*Array AnfragenInnen befuellen*)
PutArray( Array := vAnfragenInnen,
          Index := 1,
          ArrayElement := TasterInnen1,
          Status => vStatusInnen );

PutArray( Array := vAnfragenInnen,
          Index := 2,
          ArrayElement := TasterInnen2,
          Status => vStatusInnen );

PutArray( Array := vAnfragenInnen,
          Index := 3,
          ArrayElement := TasterInnen3,
          Status => vStatusInnen );

PutArray( Array := vAnfragenInnen,
          Index := 4,
          ArrayElement := TasterInnen4,
          Status => vStatusInnen );

PutArray( Array := vAnfragenInnen,
          Index := 5,
          ArrayElement := TasterInnen5,
          Status => vStatusInnen );

PutArray( Array := vAnfragenInnen,
          Index := 6,
          ArrayElement := TasterInnen6,
          Status => vStatusInnen );



(*Array AnfragenAussenHoch befuellen*)
PutArray( Array := vAnfragenAussenHoch,
          Index := 1,
          ArrayElement := TasterAussenHoch1,
          Status => vStatusHoch );

PutArray( Array := vAnfragenAussenHoch,
          Index := 2,
          ArrayElement := TasterAussenHoch2,
          Status => vStatusHoch );

PutArray( Array := vAnfragenAussenHoch,
          Index := 3,
          ArrayElement := TasterAussenHoch3,
          Status => vStatusHoch );

PutArray( Array := vAnfragenAussenHoch,
          Index := 4,
          ArrayElement := TasterAussenHoch4,
          Status => vStatusHoch );

PutArray( Array := vAnfragenAussenHoch,
          Index := 5,
          ArrayElement := TasterAussenHoch5,
          Status => vStatusHoch );

(* ... Befuellen von vAnfragenAussenRunter fehlt in den Screenshots ... *)



(*Taster Innen auf Tastendruck abfragen und entsprechende TargetVar. erstellen*)
for i := 1 to 6 do
   vGetElement := false;
   GetArray( Array := vAnfragenInnen,
             Index := i,
             ArrayElement => vGetElement,
             Status => vStatus );

   (* Innen *)
   if vGetElement then
       if i - GondelPos > 0 then
          vNewTarget.Direction := true;
       else
          vNewTarget.Direction := false;
       end_if;

       vNewTarget.Level := i;

       (*TargetVar.in Liste einsortieren*)
       AddTargetToList( Execute := true,
                        NewElement := vNewTarget,
                        GondelPosition := GondelPos,
                        Done => vAddDone,
                        TargetListIN := TargetList,
                        TargetList => TargetList,
                        TargetCountIN := TargetCount,
                        TargetCount => TargetCount,
                        TuerAufCmd => vTuerAufAdd);
       TuerAufCMD := TuerAufCMD or vTuerAufAdd;
       ResetTaster := true;
   end_if;

   (*Anfragen Hoch Erstellen*)
   if i <= 5 then
      vGetElement := false;
      GetArray( Array := vAnfragenAussenHoch,
                Index := i,
                ArrayElement => vGetElement,
                Status => vStatusAdd );

      if vGetElement = true then
         vNewTarget.Direction := true;
         vNewTarget.Level := i;
         (*TargetVar.in Liste einsortieren*)
         AddTargetToList( Execute := true,
                          NewElement := vNewTarget,
                          GondelPosition := GondelPos,
                          Done => vAddDone,
                          TargetListIN := TargetList,
                          TargetList => TargetList,
                          TargetCountIN := TargetCount,
                          TargetCount => TargetCount,
                          TuerAufCmd => vTuerAufAdd);
         TuerAufCMD := TuerAufCMD or vTuerAufAdd;
         ResetTaster := true;
      end_if;
   end_if;

   (*Anfragen Runter Erstellen*)
   if i >= 2 then
      vGetElement := false;
      GetArray( Array := vAnfragenAussenRunter,
                Index := i,
                ArrayElement => vGetElement,
                Status => vStatusAdd );

      if vGetElement = true then
         vNewTarget.Direction := false;
         vNewTarget.Level := i;
         (*TargetVar.in Liste einsortieren*)
         AddTargetToList( Execute := true,
                          NewElement := vNewTarget,
                          GondelPosition := GondelPos,
                          Done => vAddDone,
                          TargetListIN := TargetList,
                          TargetList => TargetList,
                          TargetCountIN := TargetCount,
                          TargetCount => TargetCount,
                          TuerAufCmd => vTuerAufAdd);
         TuerAufCMD := TuerAufCMD or vTuerAufAdd;
         ResetTaster := true;
      end_if;
   end_if;
end_for;

(* ... Auslesen des ersten Listeneintrags (vTargetElement) und ZielStock fehlen in den Screenshots ... *)

(*Wenn Angekommen ersten Eintrag loeschen*)
if RemoveFirstEntry and (GondelPos = vTargetElement.level) and TargetCount > 0 then
   TuerAufCMD := true;
   RemoveAtIndex( inArray := TargetList,
                  index_delete := 1,
                  ArrayElement := vTargetElement,
                  outArray => TargetList );
   TargetCount := TargetCount - 1;
end_if;


(* Motor darf nur fahren, wenn es Ziele gibt*)
HatZiel := TargetCount > 0;


(*Uebergabe an LED-Steuerung*)
TargetListOut:= TargetList;
TargetCountOut := TargetCount;
