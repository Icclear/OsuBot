#include-once
;Data folder
Global Const $DataFolder = "Data"
DirCreate("Data")

;Inidatei
Global Const $Inifile = $DataFolder & "/Settings.ini"
Global Const $LogFile = $DataFolder & "/log.log"

Global Const $IniSectionGeneral = "General"
Global Const $IniKeyWindowtitle = "WindowTitle"
Global Const $IniKeyDirectory = "Directory"

Global Const $IniSectionKeys = "Keys"
Global Const $IniKeyStopkey = "StopKey"
Global Const $IniKeyButton1 = "Button 1"
Global Const $IniKeyButton2 = "Button 2"