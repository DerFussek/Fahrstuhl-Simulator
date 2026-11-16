#import "../vorlage.typ": code-abbildung

// Der Code wird direkt aus ControlBuilder/ eingelesen und bleibt damit
// automatisch aktuell. Braucht beim Kompilieren --root . im Repo-Wurzelordner.
= Structured-Text-Code <anh:st>

== Datentyp Target
#code-abbildung("../ControlBuilder/DT_FahrstuhlLib/Target.st", [Datentyp Target])

== Function Blocks
#code-abbildung("../ControlBuilder/DT_FahrstuhlLib/FunctionBlockTypes/AddTargetToList.st", [Function Block AddTargetToList])
#code-abbildung("../ControlBuilder/DT_FahrstuhlLib/FunctionBlockTypes/InsertBetweenLimits.st", [Function Block InsertBetweenLimits])
#code-abbildung("../ControlBuilder/DT_FahrstuhlLib/FunctionBlockTypes/SortBetweenLimits.st", [Function Block SortBetweenLimits])
#code-abbildung("../ControlBuilder/DT_FahrstuhlLib/FunctionBlockTypes/TD_RemoveAtIndex.st", [Function Block TD_RemoveAtIndex])

== Control Modules
#code-abbildung("../ControlBuilder/DT_FahrstuhlLib/ControlModuleTypes/TD_Gondel.st", [Control Module TD_Gondel])
#code-abbildung("../ControlBuilder/DT_FahrstuhlLib/ControlModuleTypes/TD_MotorController.st", [Control Module TD_MotorController])
#code-abbildung("../ControlBuilder/DT_FahrstuhlLib/ControlModuleTypes/DT_Door.st", [Control Module DT_Door])
#code-abbildung("../ControlBuilder/DT_FahrstuhlLib/ControlModuleTypes/TD_Door_Pos.st", [Control Module TD_Door_Pos])
#code-abbildung("../ControlBuilder/DT_FahrstuhlLib/ControlModuleTypes/TD_Shaftdoor_Pos.st", [Control Module TD_Shaftdoor_Pos])
#code-abbildung("../ControlBuilder/DT_FahrstuhlLib/ControlModuleTypes/TD_LedSteuerung.st", [Control Module TD_LedSteuerung])
#code-abbildung("../ControlBuilder/DT_FahrstuhlLib/ControlModuleTypes/TD_ResetTaster.st", [Control Module TD_ResetTaster])
