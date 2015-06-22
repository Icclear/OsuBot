#include-once

FileDelete($Logfile)
logThis($LogFile, "Program started.")

logThis($LogFile, "Initiating .ini file.")

Local $tmp = IniRead($Inifile, $IniSectionGeneral, $IniKeyWindowtitle, "changeme")
Global Const $FileNotProtected = IniWrite($Inifile, $IniSectionGeneral, $IniKeyWindowtitle, $tmp)

If $FileNotProtected = 0 Then
	showError($LogFile, 0, "Couldn't save Ini. File is readonly.")
Else
	$tmp = IniRead($Inifile, $IniSectionKeys, $IniKeyStopkey, "s")
	IniWrite($Inifile, $IniSectionKeys, $IniKeyStopkey, $tmp)

	$tmp = IniRead($Inifile, $IniSectionKeys, $IniKeyButton1, "x")
	IniWrite($Inifile, $IniSectionKeys, $IniKeyButton1, $tmp)

	$tmp = IniRead($Inifile, $IniSectionKeys, $IniKeyButton2, "z")
	IniWrite($Inifile, $IniSectionKeys, $IniKeyButton2, $tmp)


	$tmp = IniRead($Inifile, $IniSectionPlaying, $IniKeyPreKlick, "25")
	IniWrite($Inifile, $IniSectionPlaying, $IniKeyPreKlick, $tmp)

	$tmp = IniRead($Inifile, $IniSectionPlaying, $IniKeyExtraHoldTime, "40")
	IniWrite($Inifile, $IniSectionPlaying, $IniKeyExtraHoldTime, $tmp)
EndIf


