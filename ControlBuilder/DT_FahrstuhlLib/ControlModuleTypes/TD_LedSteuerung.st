(*
  Control Module Type DT_FahrstuhlLib.TD_LedSteuerung   (UNVOLLSTAENDIG - siehe unten)
  Leitet aus der Zielliste ab, welche Taster-LEDs leuchten:
  i1..i6 = Innentaster, aH1..aH5 = Aussen Hoch, aR2..aR6 = Aussen Runter.

  Parameters (FD Port = yes)
  TargetList   ArrayObject  in
  TargetCount  dint         in

  LUECKE: Die Variablen-Tabelle und die ersten Codezeilen sind nicht auf den Screenshots.
  Im Code werden i1..i6, aR2..aR6, aH1..aH5 (bool), k (int), curTarget (Target),
  curDir (bool), curLev (dint) und vStatus (dint) benutzt. Im Diagramm DT_Gondel hat der Baustein
  nur die Eingaenge TargetList und TargetCount sichtbar - wie die LED-Variablen nach aussen
  kommen (External Variables / Zuordnung zur Visualisierung) ist nicht zu sehen.
*)

i1 := false;
i2 := false;
i3 := false;
i4 := false;
i5 := false;
i6 := false;
aR2 := false;
aR3 := false;
aR4 := false;
aR5 := false;
aR6 := false;
aH1 := false;
aH2 := false;
aH3 := false;
aH4 := false;
aH5 := false;



if TargetCount > 0 then
   for k := 1 to TargetCount do
      getArray( Array := TargetList,
                Index := k,
                ArrayElement => curTarget,
                Status => vStatus );
      curDir := curTarget.direction;
      curLev := curTarget.level;
      if curDir then
         if curLev = 1 then
            i1 := true;
            aH1 := true;
         elsif curLev = 2 then
            i2 := true;
            aH2 := true;
         elsif curLev = 3 then
            i3 := true;
            aH3 := true;
         elsif curLev = 4 then
            i4 := true;
            aH4 := true;
         elsif curLev = 5 then
            i5 := true;
            aH5 := true;
         else
            i6:=true;
         end_if;
      else
         if curLev = 1 then
            i1 := true;
         elsif curLev = 2 then
            i2 := true;
            aR2 := true;
         elsif curLev = 3 then
            i3 := true;
            aR3 := true;
         elsif curLev = 4 then
            i4 := true;
            aR4 := true;
         elsif curLev = 5 then
            i5 := true;
            aR5 := true;
         else
            i6 := true;
            aR6 := true;
         end_if;
      end_if;

   end_for;
end_if;
