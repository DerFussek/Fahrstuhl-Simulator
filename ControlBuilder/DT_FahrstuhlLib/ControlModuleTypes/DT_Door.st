(*
  Control Module Type DT_FahrstuhlLib.DT_Door
  Steuerung der Kabinen- und Schachttuer (Selbsthaltung Oeffnen/Schliessen, Offen-Zeit).

  Parameters
  Name            Data Type  Direction  FD Port  Initial Value
  --------------  ---------  ---------  -------  -------------
  TuerZuTaster    bool       in         yes
  TuerAufTaster   bool       in         yes
  Lichtschranke   bool       in         yes
  TuerZuRequest   bool       in         yes
  TuerAufRequest  bool       in         yes
  TuerAufCmd      bool       out        yes
  TuerZuCmd       bool       out        yes
  InnenEndlageAuf bool       in         yes
  InnenEndlageZu  bool       in         yes
  AussenEndlageAuf bool      in         yes      (im Editor: "AußenEndlageAuf")
  AussenEndlageZu bool       in         yes      (im Editor: "AußenEndlageZu")
  EnableTuer      bool       in         yes
  EnableGondel    bool       out        yes
  TuerAufSchacht  bool       out        yes
  TuerZuSchacht   bool       out        yes
  TimerTuerZu     time       in_out     yes      T#5s
  EnTimer         bool       in         yes      true

  Variables
  Name                Data Type  Start Attribute
  ------------------  ---------  ---------------
  EndlageAuf          bool       retain
  EndlageZu           bool       retain
  Angekommen          bool
  EnableTuerAlt       bool
  NeuerAufRequest     bool
  TuerAufRequestAlt   bool
  Schliessen          bool
  Oeffnen             bool
  OffenTimer          Timer      retain
  OffenTimerEnable    bool      retain
  OffenZeitAbgelaufen bool       retain
  TuerAufLED          bool
  TuerZuLED           bool

  Hinweis: Im Code steht einmal "TuerZuREquest" (Gross-/Kleinschreibung egal in ST).
  Der Code nutzt "AußenEndlageAuf/Zu" mit ß wie im Editor - hier als Namen mit ss in der Tabelle,
  im Code unveraendert uebernommen.
*)

(* Endlagen Zusammenfassen *)
EndlageAuf := InnenEndlageAuf and AußenEndlageAuf;
EndlageZu  := InnenEndlageZu and AußenEndlageZu;



(* Flanken erkennen *)
Angekommen      := EnableTuer and not EnableTuerAlt;
EnableTuerAlt   := EnableTuer;
NeuerAufRequest := TuerAufRequest and not TuerAufRequestAlt;
TuerAufRequestAlt := TuerAufRequest;



(* Oeffnen (Selbsterhaltung) *)
if Angekommen or NeuerAufRequest
   or (TuerAufTaster and (EnableTuer or not EndlageZu))
   or (Lichtschranke and not EndlageZu) then
      Oeffnen := true;
      Schliessen := false;
end_if;
if EndlageAuf then
   Oeffnen := false;
end_if;



(* Offen-Zeit*)
OffenTimerEnable := EnTimer and EndlageAuf and not TuerAufTaster and not Lichtschranke;
Timer(OffenTimer, OffenTimerEnable, false);
OffenZeitAbgelaufen := OffenTimerEnable and TimerElapsed(OffenTimer) >= TimerTuerZu;



(* Schliessen (Selbsterhaltung) *)
if not Oeffnen and not EndlageZu and not Lichtschranke and not TuerAufTaster
   and (TuerZuTaster or TuerZuREquest or OffenZeitAbgelaufen) then
      Schliessen := true;
end_if;
if EndlageZu or Oeffnen then
   Schliessen := false;
end_if;


(*Ausgänge setzen*)
TuerAufCmd    := Oeffnen and not InnenEndlageAuf;
TuerZuCmd     := Schliessen and not InnenEndlageZu;
TuerAufSchacht := Oeffnen and not AußenEndlageAuf;
TuerZuSchacht  := Schliessen and not AußenEndlageZu;
EnableGondel  := EndlageZu and not Oeffnen;

(*Die Beleuchtung des Tuer Auf Knopfes regeln*)
if TuerZuTaster then
   TuerZuLED := True;
end_if;
if EndlageZu then
   TuerZuLED := False;
end_if;

(*Die Beleuchtung des Tuer Zu Knopfes regeln*)
if TuerAufTaster then
   TuerAufLED := True;
end_if;
if EndlageAuf or TuerAufCmd = False then
   TuerAufLED := False;
end_if;
