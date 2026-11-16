(*
  Control Module Type DT_FahrstuhlLib.TD_ResetTaster
  Setzt alle Taster zurueck, wenn ResetTaster = true.

  Parameters (alle bool, FD Port = yes)
  TasterInnen1 .. TasterInnen6          in_out
  TasterAussenHoch1 .. TasterAussenHoch5   in_out
  TasterAussenRunter2 .. TasterAussenRunter6  in_out
  ResetTaster                           in

  Variables: keine
*)

if ResetTaster = true then

    TasterInnen1 := false;
    TasterInnen2 := false;
    TasterInnen3 := false;
    TasterInnen4 := false;
    TasterInnen5 := false;
    TasterInnen6 := false;

    TasterAussenHoch1 := false;
    TasterAussenHoch2 := false;
    TasterAussenHoch3 := false;
    TasterAussenHoch4 := false;
    TasterAussenHoch5 := false;

    TasterAussenRunter2 := false;
    TasterAussenRunter3 := false;
    TasterAussenRunter4 := false;
    TasterAussenRunter5 := false;
    TasterAussenRunter6 := false;

end_if;
