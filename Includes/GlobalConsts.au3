#include-once
;Data folder
Global Const $DataFolder = "Data"
DirCreate("Data")

;files
Global Const $Inifile = $DataFolder & "/Settings.ini"
Global Const $LogFile = $DataFolder & "/log.log"

;ini
Global Const $IniSectionGeneral = "General"
Global Const $IniKeyWindowtitle = "WindowTitle"
Global Const $IniKeyDirectory = "Directory"

Global Const $IniSectionKeys = "Keys"
Global Const $IniKeyStopkey = "StopKey"
Global Const $IniKeyButton1 = "Button 1"
Global Const $IniKeyButton2 = "Button 2"