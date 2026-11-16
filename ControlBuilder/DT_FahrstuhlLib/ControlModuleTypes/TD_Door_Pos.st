(*
  Control Module Type DT_FahrstuhlLib.TD_Door_Pos
  Simuliert die Position der Kabinentuer (Zaehler 0 .. TuerBreite, 28 pro Zyklus).

  Parameters
  Name          Data Type  Direction  FD Port  Initial Value
  ------------  ---------  ---------  -------  -------------
  MotorAufCmd   bool       in         yes
  MotorZuCmd    bool       in         yes
  EndlageAufFB  bool       out        yes
  EndlageZuFB   bool       out        yes
  TuerBreite    int        in         yes      280

  Variables
  vCounter  int  retain
*)

IF MotorZuCmd = true AND vCounter < TuerBreite THEN
      vCounter := vCounter + 28;
END_IF;

IF MotorAufCmd = true AND vCounter > 0 THEN
      vCounter := vCounter - 28;
END_IF;


IF vCounter = 0 THEN
      EndlageAufFB := true;
ELSIF vCounter = TuerBreite THEN
   EndlageZuFB := true;
ELSE
   EndlageAufFB := false;
   EndlageZuFB := false;
END_IF;
