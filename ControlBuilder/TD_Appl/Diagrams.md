# Diagramme der Application TD_Appl

Aus den Screenshots abgelesene Verschaltung (FBD) der beiden Diagramme. Gesamtstruktur siehe [../README.md](../README.md).

## Diagram `DT_Door`

**Variablen**

| Name | Datentyp | Attribute |
|---|---|---|
| vEndlageAufFB | bool | retain, nosort |
| vEndlageZuFB | bool | retain, nosort (Description: auto) |
| vTuerAufTaster | bool | |
| vTuerZuTaster | bool | |
| vLichtschranke | bool | |
| Schachttuer | dint | |
| TuerZuSchacht | bool | |
| TuerAufSchacht | bool | |
| AußenEndlageAuf | bool | retain, nosort |
| AußenEndlageZu | bool | retain, nosort |

**Communication Variables**

| Name | Datentyp | Direction |
|---|---|---|
| S (leere/angefangene Zeile) | bool | in |
| TD_Gondel_1_TuerAufCMD | bool | in |
| DT_Door_1_EnableGondel | bool | out |
| TD_MotorControll_1_GondelPosExpo | dint (retain) | in |

**Bausteine und Verbindungen**

- `move:1`: EN = `vEndlageZuFB`, IN1 = `false`, Ausgang -> `vTuerZuTaster`
- `move:5`: EN = `vEndlageAufFB`, IN1 = `false`, Ausgang -> `vTuerAufTaster`
- `move:6`: EN = `vEndlageAufFB`, IN1 = `false`, Ausgang -> `vLichtschranke`
- `DT_Door_1:2` (Typ `DT_Door`)
  - Eingaenge: TuerZuTaster = `vTuerZuTaster`, TuerAufTaster = `vTuerAufTaster`, Lichtschranke = `vLichtschranke`, TuerZuRequest = `false`, TuerAufRequest = `TD_Gondel_1_TuerAufCMD`, InnenEndlageAuf = `vEndlageAufFB`, InnenEndlageZu = `vEndlageZuFB`, AußenEndlageAuf/Zu = die gleichnamigen Variablen, EnableTuer = `TD_MotorController_1_Done`, EnTimer = `true`, TimerTuerZu (in_out) unverbunden
  - Ausgaenge: TuerAufCmd -> `TD_Door_Pos_1:3.MotorAufCmd`; TuerZuCmd -> `TD_Door_Pos_1:3.MotorZuCmd`; EnableGondel -> `DT_Door_1_EnableGondel`; TuerAufSchacht -> `TD_Shaftdoor_Pos_1:4.MotorAufCmd`; TuerZuSchacht -> `TD_Shaftdoor_Pos_1:4.MotorZuCmd`
- `TD_Door_Pos_1:3` (Typ `TD_Door_Pos`): TuerBreite = `280`; EndlageAufFB -> `vEndlageAufFB`, EndlageZuFB -> `vEndlageZuFB`
- `TD_Shaftdoor_Pos_1:4` (Typ `TD_Shaftdoor_Pos`): SelectedTuer = `TD_MotorControll_1_GondelPosExpo`, TuerBreite = `120`; CurrentEndlageAufFB -> `AußenEndlageAuf`, CurrentEndlageZuFB -> `AußenEndlageZu`

## Diagram `DT_Gondel`

**Variablen**

| Name | Datentyp | Attribute |
|---|---|---|
| GondelPosition | dint | |
| iTaster1 .. iTaster6 | bool | |
| aTasterH1 .. aTasterH5 | bool | |
| aTasterR2 .. aTasterR6 | bool | |
| Done | bool | |
| test | dint | |
| TargetList | ArrayObject | |
| vMotorEnable | bool | nosort |
| vZielStock | dint | nosort |
| TargetListOut | ArrayObject | |
| TargetCountOut | dint | |

**Communication Variables**

| Name | Datentyp | Direction |
|---|---|---|
| DT_Door_1_Freigabe_Fuer_Gondel | bool | in |
| TD_Gondel_1_TuerAufCMD | bool | out |
| DT_Door_1_EnableGondel | bool | in |
| TD_MotorController_1_Done | bool | out |
| TD_MotorControll_1_GondelPosExpo | dint (retain) | out |

**Bausteine und Verbindungen**

- `TD_ResetTaster_2:1` (Typ `TD_ResetTaster`): in_out-Taster = `iTaster1..6`, `aTasterH1..5`, `aTasterR2..6` (laufen direkt weiter an `TD_Gondel_1:2`); ResetTaster = Ausgang `ResetTaster` von `TD_Gondel_1:2`
- `TD_Gondel_1:2` (Typ `TD_Gondel`): GondelPos = `GondelPosition`; TasterInnen/AussenHoch/AussenRunter wie oben; RemoveFirstEntry = `TD_MotorController_1_Done`; Ausgaenge: HatZiel -> `and:4.IN2`, ZielStock -> `vZielStock`, TuerAufCMD -> `TD_Gondel_1_TuerAufCMD`, ResetTaster -> `TD_ResetTaster_2:1`, TargetListOut -> `TD_LedSteuerung_1:3.TargetList`, TargetCountOut -> `TD_LedSteuerung_1:3.TargetCount`
- `and:4`: IN1 = `DT_Door_1_EnableGondel`, IN2 = `HatZiel`, Ausgang -> `vMotorEnable`
- `TD_MotorController_1:5` (Typ `TD_MotorController`): Enable = `vMotorEnable`, ZielStockwerk = `vZielStock`; GondelPos -> `GondelPosition`, Done -> `TD_MotorController_1_Done`, GondelPosExpo -> `TD_MotorControll_1_GondelPosExpo`

Hinweis: Die Communication Variable heisst `TD_MotorControll_1_GondelPosExpo` (zwei l), `TD_MotorController_1_Done` dagegen mit `Controller` - so steht es in den Screenshots.
