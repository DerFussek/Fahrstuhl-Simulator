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

  LUECKE: Auf den Screenshots ist nur der Anfang des Codes zu sehen (ab "ResetTaster := false;"
  bis zum Befuellen von vAnfragenAussenHoch). Es fehlen: die Zeilen davor (falls vorhanden),
  das Befuellen von vAnfragenAussenRunter, das Erkennen neuer Rufe, die Aufrufe von
  AddTargetToList / TD_RemoveAtIndex, HatZiel, ZielStock, TargetListOut, TargetCountOut.
  Ausserdem fehlt der Reiter "Function Blocks" (Instanzen).
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

(* ... Rest des Codes fehlt in den Screenshots ... *)
