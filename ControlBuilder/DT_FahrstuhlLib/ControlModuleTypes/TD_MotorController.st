(*
  Control Module Type DT_FahrstuhlLib.TD_MotorController
  Faehrt die Gondel (Y-Position in Pixeln) in 10er-Schritten zum Zielstockwerk.

  Parameters
  Name           Data Type  Direction  FD Port
  -------------  ---------  ---------  -------
  Enable         bool       in         yes
  ZielStockwerk  dint       in         yes
  GondelPos      dint       out        yes
  Done           bool       out        yes
  GondelPosExpo  dint       out        yes

  Variables
  Name                Data Type  Start Attribute  Initial Value
  ------------------  ---------  ---------------  -------------
  vCount0 .. vCount5  int                         120
  vGondelPosY         dint                        0
  vZielPosition       dint       retain
  vDirection          bool       retain
  vDiff               dint       retain
*)

(* Überblick
 0: 1036 -- 0
 1: 856  -- 180
 2: 676  -- 360
 3: 496  -- 540
 4: 316  -- 720
 5: 136  -- 900
*)

GondelPos := (vGondelPosY + 90) / 180 + 1;
GondelPosExpo := GondelPos;

vZielPosition := ZielStockwerk * 180 - 180;

vDiff := vZielPosition - vGondelPosY;

if Enable and vDiff > 0 then
   if vDiff > 10 then
      vGondelPosY := vGondelPosY + 10;
   else
      vGondelPosY := vZielPosition;
   end_if;
elsif Enable and vDiff < 0 then
   if vDiff < -10 then
      vGondelPosY := vGondelPosY - 10;
   else
      vGondelPosY := vZielPosition;
   end_if;
end_if;

Done := vGondelPosY = vZielPosition;
