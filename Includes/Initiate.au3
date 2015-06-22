#include-once

#Region Init
logThis($LogFile, "GUI initialized.")
setStatus($Status, "GUI initialiued.")

;~	is there an osu window?
If WinWait("osu!", "", 5) = 0 Then
	DisplayError("Osu!-window not found!")
	SetError(1)
	Exit
EndIf
Global $OsuTitle = WinGetTitle("osu!")

logThis($LogFile, "Window found")
setStatus($Status, "Window found")

;Osu prozess öffnen
Global Const $OsuID = ProcessExists("osu!.exe")
Global Const $OsuProcess = _MemoryOpen($OsuID)
If @error Then
	DisplayError("Failed to open Process. Errorcode: " & @error)
	SetError(2)
	Exit
EndIf

logThis($LogFile, "Process opened.")
setStatus($Status, "Process opened.")

Local Const $aob = "B4 17 00 00 14 13 00 00 B8 17 00 00 14 13 00 00" ;Pattern + Scan form an online guy


;~ Local Const $aob = "DB 5D F4 8B 45 F4 A3" ;Pattern + Scan

Local Const $scan = _AOBScan($OsuProcess, $aob)

If @error Or $scan = 0 Then ;Pattern gefunden?
	DisplayError("Pattern not Found! Errorcode: " & @error & " $Scan: " & $scan)
	SetError(3)
	_Exit($LogFile, $OsuProcess)
EndIf

logThis($LogFile, "Pattern {" & $aob & "} found.")
setStatus($Status, "Pattern found.")

;~ Global Const $TimeAdress = _MemoryRead($scan + 0x7, $OsuProcess, "byte[4]")	;Activate if the other one doesn't work anymore
Global Const $TimeAdress = $scan + 0xA20

;~ If @error Or $TimeAdress = 0 Then ;Zeit gefunden?
;~ 	DisplayError("Time-adress not found! Errorcode: " & @error)
;~ 	SetError(4)
;~ 	_Exit($LogFile, $OsuProcess)
;~ EndIf

logThis($LogFile, "Timeadress found.")
setStatus($Status, "Timeadress found.")

;OsuVerzeichnis herausfinden
Global $Directory = IniRead($Inifile, $IniSectionGeneral, $IniKeyDirectory, StringTrimRight(_ProcessGetLocation($OsuID), 8))
If @error Or $Directory = "" Then
	DisplayError("Unable to find game directory. Please make sure you have set the right path in your settings. Errorcode: " & @error)
	SetError(5)
	_Exit($LogFile, $OsuProcess)
EndIf

;Directory invalid
If StringLen($Directory) <= 2 Then
	DisplayError("Directory not Found! ")
	SetError(6)
	_Exit($LogFile, $OsuProcess)
Else ;if valid add "Songs\"
	Local Const $SongsDir = "Songs\"
	If StringRight($Directory, StringLen($SongsDir)) <> $SongsDir Then
		$Directory &= $SongsDir
	EndIf

	If $FileNotProtected = 1 then IniWrite($Inifile, $IniSectionGeneral, $IniKeyDirectory, $Directory)
EndIf

logThis($LogFile, "Song folder found: " & $Directory)
setStatus($Status, "Song folder found.")

ConsoleWriteError("[Warning] Map directory modified!" & @CRLF)

Global Const $MapList = FolderList($Directory)
If @error Then
	DisplayError("Error loading Beatmaplist. Errorcode: " & @error)
	_Exit($LogFile, $OsuProcess)
EndIf

;Playing?	Gobal
Global $Playing = 0
Global $BeatmapLoaded = 0

Global $HitList
Global $Bpms
Global $SliderMultiplier

Global $Diffs
Global $Song = ""
Global $SelectedSong = ""
Global $Diff = ""

logThis($LogFile, "Bot successfully started!")
setStatus($Status, "Bot successfully started!")

#EndRegion Init