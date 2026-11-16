(*
  Control Module Type DT_FahrstuhlLib.TD_Shaftdoor_Pos
  Simuliert die sechs Schachttueren (je Stockwerk ein Zaehler, 12 pro Zyklus);
  bewegt wird nur die Tuer des gerade ausgewaehlten Stockwerks (SelectedTuer 1..6).

  Parameters
  Name                 Data Type  Direction  FD Port  Initial Value
  -------------------  ---------  ---------  -------  -------------
  MotorAufCmd          bool       in         yes
  MotorZuCmd           bool       in         yes
  SelectedTuer         dint       in         yes
  TuerBreite           dint       in         yes      120
  CurrentEndlageAufFB  bool       out        yes
  CurrentEndlageZuFB   bool       out        yes

  Variables
  Name                              Data Type  Attributes  Initial Value
  --------------------------------  ---------  ----------  -------------
  vCount1 .. vCount6                dint                   120
  EndlageAufFB1, EndlageZuFB1 ..    bool       nosort
  EndlageAufFB6, EndlageZuFB6       bool       nosort
  vCount                            dint       nosort
*)

if SelectedTuer = 1 then
   vCount := vCount1;
elsif SelectedTuer = 2 then
   vCount := vCount2;
elsif SelectedTuer = 3 then
   vCount := vCount3;
elsif SelectedTuer = 4 then
   vCount := vCount4;
elsif SelectedTuer = 5 then
   vCount := vCount5;
elsif SelectedTuer = 6 then
   vCount := vCount6;
end_if;

if SelectedTuer >= 1 and SelectedTuer <= 6 then
   if MotorAufCmd then
      vCount := vCount - 12;
   elsif MotorZuCmd then
      vCount := vCount + 12;
   end_if;

   if vCount < 0 then
      vCount := 0;
   end_if;
   if vCount > TuerBreite then
      vCount := TuerBreite;
   end_if;

   CurrentEndlageAufFB := vCount <= 0;
   CurrentEndlageZuFB  := vCount >= TuerBreite;
else
   CurrentEndlageAufFB := false;
   CurrentEndlageZuFB  := false;
end_if;

if SelectedTuer = 1 then
   vCount1 := vCount;
elsif SelectedTuer = 2 then
   vCount2 := vCount;
elsif SelectedTuer = 3 then
   vCount3 := vCount;
elsif SelectedTuer = 4 then
   vCount4 := vCount;
elsif SelectedTuer = 5 then
   vCount5 := vCount;
elsif SelectedTuer = 6 then
   vCount6 := vCount;
end_if;



EndlageAufFB1 := vCount1 <= 0;
EndlageZuFB1  := vCount1 >= TuerBreite;
EndlageAufFB2 := vCount2 <= 0;
EndlageZuFB2  := vCount2 >= TuerBreite;
EndlageAufFB3 := vCount3 <= 0;
EndlageZuFB3  := vCount3 >= TuerBreite;
EndlageAufFB4 := vCount4 <= 0;
EndlageZuFB4  := vCount4 >= TuerBreite;
EndlageAufFB5 := vCount5 <= 0;
EndlageZuFB5  := vCount5 >= TuerBreite;
EndlageAufFB6 := vCount6 <= 0;
EndlageZuFB6  := vCount6 >= TuerBreite;
