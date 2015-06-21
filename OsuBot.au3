#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#Region Includes
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <FileConstants.au3>

#include "Includes\NomadMemory.au3"
#include "Includes\exported stuff.au3"
#include "Includes\HelpFunctions.au3"

#EndRegion Includes

#Region Init


;Data folder
Global Const $DataFolder = "Data"
DirCreate("Data")

;Inidatei
Global Const $Inifile = $DataFolder & "/Settings.ini"
Global Const $LogFile = $DataFolder & "/log.log"

logThis($LogFile, "Program started.")

;~	Überprüfe, ob ein Osufenster vorhanden ist
If WinWait("osu!", "", 5) = 0 Then
	showError($LogFile, 0, "Osu!-window not found!")
	SetError(1)
	Exit
EndIf
Global $OsuTitle = WinGetTitle("osu!")

logThis($LogFile, "Window found")


;~ Fenstertitel festlegen
Local Const $WindowTitle = IniRead($Inifile, "General", "WindowTitle", "ChangeMe")
If IniWrite($Inifile, "General", "WindowTitle", $WindowTitle) = 0 Then
	showError($LogFile, 0, "Couldn't save windowtitle. File is readonly.")
EndIf



;~ Gui initialisieren
#Region ### START Koda GUI section ### Form=
Global $MainWindow = GUICreate($WindowTitle, 741, 534, 197, 152)
Global $StatusBox = GUICtrlCreateGroup("StatusBox", 408, 312, 305, 193)
Global $Status = GUICtrlCreateLabel("Window found.", 424, 336, 258, 17)
Global $TimeLabel = GUICtrlCreateLabel("Time: ", 424, 368, 269, 17)
Global $TitleLabel = GUICtrlCreateLabel("Title: " & $OsuTitle, 424, 408, 274, 17)
Global $DirectoryLabel = GUICtrlCreateLabel("Directory: ", 92, 287, 500, 20)
Global $PlayingLabel = GUICtrlCreateLabel("Playing: ", 424, 440, 272, 17)
Global $KlickingLabel = GUICtrlCreateLabel("Key: ", 424, 472, 273, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $RelaxBox = GUICtrlCreateCheckbox("", 56, 344, 9, 25)
GUICtrlSetState(-1, $GUI_CHECKED)
Local $Songpath = GUICtrlCreateInput("Songpath", 104, 64, 337, 21) ;TODO: Rename -------
Global Const $RelaxActivated = GUICtrlCreateLabel("RelaxActivated", 80, 352, 76, 17)
Global $Songnames = GUICtrlCreateList("", 104, 104, 337, 162)
Local $LoadList = GUICtrlCreateButton("LoadList", 456, 48, 105, 65)
Local $LoadSelected = GUICtrlCreateButton("LoadSelected", 456, 128, 105, 65)
Global $DiffList = GUICtrlCreateList("", 464, 208, 265, 58)
Local $LoadDiff = GUICtrlCreateButton("LoadDiff", 616, 152, 73, 41)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

logThis($LogFile, "GUI initialized.")
setStatus($Status, "GUI initialiued.")

;Osu prozess öffnen
Local Const $OsuID = ProcessExists("osu!.exe")
Global Const $OsuProcess = _MemoryOpen($OsuID)
If @error Then
	DisplayError("Failed to open Process. Errorcode: " & @error)
	SetError(2)
	Exit
EndIf

logThis($LogFile, "Process opened.")
setStatus($Status, "Process opened.")

; B4 17 00 00 14 13 00 00 B8 17 00 00 14 13 00 00
Local Const $aob = "B4 17 00 00 14 13 00 00 B8 17 00 00 14 13 00 00" ;Pattern + Scan form an online guy
; address = (IntPtr)((Int32)addre + (Int32)((IntPtr)0xA20));


;~ Local Const $aob = "DB 5D F4 8B 45 F4 A3" ;Pattern + Scan

Local Const $scan = _AOBScan($OsuProcess, $aob)

If @error Or $scan = 0 Then ;Pattern gefunden?
	DisplayError("Pattern not Found! Errorcode: " & @error & " $Scan: " & $scan)
	SetError(3)
	_Exit($LogFile, $OsuProcess)
EndIf

logThis($LogFile, "Pattern {" & $aob & "} found.")
setStatus($Status, "Pattern found.")

;$scan += 0x7 ;Anpassen der Adresse
;~ Global Const $TimeAdress = _MemoryRead($scan + 0x7, $OsuProcess, "byte[4]")
Global Const $TimeAdress = $scan + 0xA20

;~ If @error Or $TimeAdress = 0 Then ;Zeit gefunden?
;~ 	DisplayError("Time-adress not found! Errorcode: " & @error)
;~ 	SetError(4)
;~ 	_Exit($LogFile, $OsuProcess)
;~ EndIf

logThis($LogFile, "Timeadress found.")
setStatus($Status, "Timeadress found.")

;OsuVerzeichnis herausfinden
Global $Directory = IniRead($Inifile, "General", "Directory", StringTrimRight(_ProcessGetLocation($OsuID), 8))
If @error Or $Directory = "" Then
	DisplayError("Unable to find game directory. Please make sure you have set the right path in your settings. Errorcode: " & @error)
	SetError(5)
	_Exit($LogFile, $OsuProcess)
EndIf

;Verzeichnis ungültig
If StringLen($Directory) <= 2 Then
	GUICtrlSetData($DirectoryLabel, "Directory: Error")
	DisplayError("Directory not Found! ")
	SetError(6)
	_Exit($LogFile, $OsuProcess)
Else ;Wenn gültig, evtl "Songs\" ergänzen und speichern
	Local Const $SongsDir = "Songs\"
	If StringRight($Directory, StringLen($SongsDir)) <> $SongsDir Then
		$Directory &= $SongsDir
	EndIf

	If IniWrite($Inifile, "General", "Directory", $Directory) = 0 Then
		DisplayError("Couldn't save directory File is readonly.")
	EndIf

	GUICtrlSetData($DirectoryLabel, "Directory: " & $Directory)
EndIf

logThis($LogFile, "Song folder found: " & $Directory)
setStatus($Status, "Song folder found.")

Local $Map = "" ;TODO: Make a proper song selection--------------------------------
GUICtrlSetData($Songpath, $Map)
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

#Region Running

Local $Playing = 0
Local $Time = 0
setTime($TimeLabel, $Time) ;Zeit eintragen

While 1 ;Main window loop
	$OsuTitle = WinGetTitle("osu!")
	If $OsuTitle = "" Then
		DisplayError("Osu Window not found. Bot will now exit.")
		_Exit($LogFile, $OsuProcess)
	EndIf

	setTitle($TitleLabel, $OsuTitle) ;Titel auslesen

	If $OsuTitle <> "osu!" And $BeatmapLoaded = 1 Then
		Play()
	ElseIf $BeatmapLoaded = 1 Then
		setStatus($Status, "Waiting for Song: " & $SelectedSong)
	Else
		setStatus($Status, "Need to load Beatmap First!")
	EndIf

	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_Exit($LogFile, $OsuProcess)

		Case $LoadList
			updateList()

		Case $LoadSelected
			LoadSelectedBeatmap()

		Case $LoadDiff
			LoadSelectedDiff()
	EndSwitch
	Sleep(5)
WEnd

_Exit($LogFile, $OsuProcess)

#EndRegion Running

#Region Playing
; #FUNCTION# ====================================================================================================================
; Name ..........: Play
; Description ...: Function the playing takes place in. It initializes the playing and the beatmap and plays.
; Syntax ........: Play()
; Parameters ....:
; Return values .: None
; Author ........: Icclear
; Modified ......:
; Remarks .......: Disables interaction with the main menu.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func Play()
	#Region PlayingInit

	If $BeatmapLoaded = 0 Then ;notBeatmap exit
		setStatus($Status, "No Beatmap loaded.")
		Return
	EndIf

	$Playing = 1
	Local $Finished = 0
	Local Const $RelaxActive = _isChecked($RelaxBox)

	Local $FoundNextHit = 0
	Local $Klicked = 0
	Global $NextHitTime = 0
	Global $NextHitType = 0
	Global $Duration = 0
	Global $Time = 0
	Local $BPMCount = 0
	Local $CurrentBPM = $Bpms[$BPMCount][1] ;bpm
	Local $i = 0 ;Count var

	Global $LastButtonPressed = 1
	Global $BT1Pressed = 0
	Global $BT1ReleaseAt = 0
	Global $BT2Pressed = 0
	Global $BT2ReleaseAt = 0

	Local $PreKlick = 25
	Global $ExtraPressTime = 40
	Global $BeginKlick = 0
	Global $EndKlick = 0

	Local $StopButton = "s"
	Global $Button1 = "-"
	Global $Button2 = "."

	HotKeySet("{" & $StopButton & "}", "StopPlaying") ;Hotkey to stop bot

	ResetButtons()

	#EndRegion PlayingInit


	;Some songs start with negative time that is calculated as extremely high value in autoit. Thus wait till the time is below 10 and the map starts.
	While readTime($LogFile, $TimeAdress, $OsuProcess) > 10 Or readTime($LogFile, $TimeAdress, $OsuProcess) < 0
		Sleep(1)
	WEnd

	While $Playing = 1;WinGetTitle("osu!") = $OsuTitle

		$Time = readTime($LogFile, $TimeAdress, $OsuProcess) ;Zeit auslesen
		setTime($TimeLabel, $Time)


		If $BPMCount < UBound($Bpms) - 1 Then ;Change to next bpm
			If $Time > $Bpms[$BPMCount + 1][0] Then
				$BPMCount += 1
				If $Bpms[$BPMCount][1] < 0 Then
					$CurrentBPM = -1 * $Bpms[$BPMCount][1] / 100 * $CurrentBPM
				Else
					$CurrentBPM = $Bpms[$BPMCount][1]
				EndIf
			EndIf
		EndIf


		If $FoundNextHit = 0 Then

			Do ;Find the next hit
				If $i >= UBound($HitList) Then ;Endoffile
					If $BT1Pressed = 1 Or $BT2Pressed = 1 Then
						$Finished = 1
						ExitLoop
					EndIf

					setStatus($Status, "Finished playing map.")
					logThis($LogFile, "Stopped Playing")
					ResetButtons()
					HotKeySet("{s}")
					Return
				EndIf
				$NextHitTime = StringSplit($HitList[$i], ",")[3] ;Time
				If $Time < $NextHitTime Then $FoundNextHit = 1
				$i += 1
			Until $FoundNextHit = 1

			If $Finished = 0 Then
				$NextHitType = StringSplit($HitList[$i - 1], ",")[4] ;Type

				$BeginKlick = $NextHitTime - $PreKlick


				;Which type of hit
				If $NextHitType = 1 Or $NextHitType = 5 Or $NextHitType = 16 Then ;Circle
					$EndKlick = $BeginKlick + $ExtraPressTime

;~ 				ElseIf $NextHitType = 2 Or $NextHitType = 6 Or $NextHitType = 21 Or $NextHitType = 22 Then ;Slider
					;Moved to else since there were too many possibilities


				ElseIf $NextHitType = 12 Or $NextHitType = 8 Then ;Spin
					$EndKlick = StringSplit($HitList[$i - 1], ",")[6] + $ExtraPressTime ;You can read the duration there

					;if pressed till before the next hitobject
					If $i <= UBound($HitList) - 1 And $EndKlick > StringSplit($HitList[$i], ",")[3] Then $EndKlick = StringSplit($HitList[$i], ",")[3] - ($ExtraPressTime * 2)

				Else ;Slider
					Local $Repetition = StringSplit($HitList[$i - 1], ",")[7]
					Local $Length = StringSplit($HitList[$i - 1], ",")[8]
					$EndKlick = $BeginKlick + $CurrentBPM * $Repetition * $Length / $SliderMultiplier / 100
				EndIf



				setStatus($Status, "Next Klick: " & $NextHitTime)
			EndIf

		EndIf

		If $Finished = 0 Then
			If $RelaxActive And $Time > $BeginKlick And $Time < $EndKlick And $Klicked = 0 Then
				setStatus($Status, "Klicking")
				$Klicked = 1
				Klick()

			ElseIf $RelaxActive And $Time >= $BeginKlick + $ExtraPressTime Then
				$FoundNextHit = 0
				$Klicked = 0
			EndIf
		EndIf

		If $RelaxActive Then ReleaseButtons()

	WEnd ;End of the while loop the playing takes place in
	setStatus($Status, "Finished playing map.")
	logThis($LogFile, "Stopped Playing")
	ResetButtons()
	HotKeySet("{s}")

EndFunc   ;==>Play



; #FUNCTION# ====================================================================================================================
; Name ..........: Klick
; Description ...: Selects which button to klick next and calls it's funcion.
; Syntax ........: Klick()
; Parameters ....:
; Return values .: None
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func Klick()
	If $LastButtonPressed = 2 Then
		BT1Klick()
	Else
		BT2Klick()
	EndIf
EndFunc   ;==>Klick



; #FUNCTION# ====================================================================================================================
; Name ..........: BT1Klick
; Description ...: Tries to klick with button 1. If button 1 is pressed tries to press with bt2 instead. If that doesn't work it
;					shows an error.
; Syntax ........: BT1Klick()
; Parameters ....:
; Return values .: None
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func BT1Klick()

	If $BT1Pressed = 0 Then
		Send("{" & $Button1 & " down}")
		$BT1Pressed = 1
		$BT1ReleaseAt = $EndKlick
	ElseIf $BT2Pressed = 0 Then
		Send("{" & $Button2 & " down}")
		$BT2Pressed = 0
		$BT2ReleaseAt = $EndKlick
	Else
		$Klicked = 0 ;Not klicked + forcerelease
		Send("{" & $Button2 & " up}")
		$BT2Pressed = 0
		Return
	EndIf
	$LastButtonPressed = 1
EndFunc   ;==>BT1Klick



; #FUNCTION# ====================================================================================================================
; Name ..........: BT2Klick
; Description ...: Tries to klick with button 2. If button 2 is pressed tries to press with bt1 instead. If that doesn't work it
;					shows an error.
; Syntax ........: BT2Klick()
; Parameters ....:
; Return values .: None
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func BT2Klick()

	If $BT2Pressed = 0 Then
		Send("{" & $Button2 & " down}")
		$BT2Pressed = 1
		$BT2ReleaseAt = $EndKlick
	ElseIf $BT1Pressed = 0 Then
		Send("{" & $Button1 & " down}")
		$BT1Pressed = 0
		$BT1ReleaseAt = $EndKlick
	Else
		$Klicked = 0 ;Not klicked + forcerelease
		Send("{" & $Button2 & " up}")
		$BT2Pressed = 0
		Return
	EndIf
	$LastButtonPressed = 2
EndFunc   ;==>BT2Klick



; #FUNCTION# ====================================================================================================================
; Name ..........: ReleaseButtons
; Description ...: Releases a button that is used to play if $time > pointoftimethebuttonhastobepressedto
; Syntax ........: ReleaseButtons()
; Parameters ....:
; Return values .: None
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func ReleaseButtons()
	If $BT1Pressed = 1 And $Time >= $BT1ReleaseAt Then
		Send("{" & $Button1 & " up}")
		$BT1Pressed = 0
	EndIf

	If $BT2Pressed = 1 And $Time >= $BT2ReleaseAt Then
		Send("{" & $Button2 & " up}")
		$BT2Pressed = 0
	EndIf
EndFunc   ;==>ReleaseButtons



; #FUNCTION# ====================================================================================================================
; Name ..........: ResetButtons
; Description ...: Releases both buttons and resets klick variables.
; Syntax ........: ResetButtons()
; Parameters ....:
; Return values .: None
; Author ........: Icclears
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func ResetButtons()
	Send("{" & $Button1 & " up}")
	$BT1Pressed = 0
	$BT1PressedAt = 0

	Send("{" & $Button2 & " up}")
	$BT2Pressed = 0
	$BT2PressedAt = 0
EndFunc   ;==>ResetButtons



; #FUNCTION# ====================================================================================================================
; Name ..........: StopPlaying
; Description ...: Sets $Playing to 0 in order to stop playing the current song. Used in order to be  able to interrupt a play.
; Syntax ........: StopPlaying()
; Parameters ....:
; Return values .: None
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func StopPlaying()
	$Playing = 0
EndFunc   ;==>StopPlaying

#EndRegion Playing

#Region LoadingBeatmaps

; #FUNCTION# ====================================================================================================================
; Name ..........: updateList
; Description ...: Displays all Songs in $Songnames that include the string entered in $Songpath
; Syntax ........: updateList()
; Parameters ....:
; Return values .: None
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func updateList()
	setStatus($Status, "Searching beatmaps...")
	logThis($LogFile, "Searching beatmaps...")

	GUICtrlSetData($Songnames, "")
	Local $Mask = GUICtrlRead($Songpath)
	For $i = 0 To UBound($MapList) - 1 Step 1
		If StringInStr($MapList[$i], $Mask) > 0 Then GUICtrlSetData($Songnames, $MapList[$i] & "|")
	Next

	setStatus($Status, "Search finished.")
	logThis($LogFile, "Search finished.")
EndFunc   ;==>updateList



; #FUNCTION# ====================================================================================================================
; Name ..........: LoadSelectedBeatmap
; Description ...: Displays all difficultys of the Beatmap that's selected in $Songnames
; Syntax ........: LoadSelectedBeatmap()
; Parameters ....:
; Return values .: None
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func LoadSelectedBeatmap()
	setStatus($Status, "Loading difficulties...")
	logThis($LogFile, "Loading difficulties...")

	GUICtrlSetData($DiffList, "")

	Local $tmpSong = GUICtrlRead($Songnames)
	If $tmpSong <> "" And $tmpSong <> 0 Then
		$Song = $tmpSong

		$Diffs = _FileListToArray($Directory & $Song, "*", $FLTA_FILES)
		For $i = 0 To UBound($Diffs) - 1 Step 1
			If StringInStr($Diffs[$i], ".osu") > 0 Then
				GUICtrlSetData($DiffList, StringSplit(StringSplit($Diffs[$i], "[")[2], "]")[1])
			EndIf
		Next
	EndIf

	setStatus($Status, "Finished loading difficulties.")
	logThis($LogFile, "Finished loading difficulties.")
EndFunc   ;==>LoadSelectedBeatmap



; #FUNCTION# ====================================================================================================================
; Name ..........: LoadSelectedDiff
; Description ...: Loads the beatmap's currently in $Difflist selected difficulty
; Syntax ........: LoadSelectedDiff()
; Parameters ....:
; Return values .: None
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func LoadSelectedDiff()
	For $i = 0 To UBound($Diffs) - 1 Step 1
		If StringInStr($Diffs[$i], GUICtrlRead($DiffList)) > 0 Then $Diff = $Diffs[$i]
	Next

	setStatus($Status, "Loading Beatmap")
	logThis($LogFile, "Loading Beatmap")

	LoadBeatmap($Directory & $Song & "\" & $Diff)
	If @error Or Not IsArray($HitList) Then
		$BeatmapLoaded = 0
		DisplayError("Couldn't load Beatmap. Errorcode: " & @error)
		SetError(0) ;Reset Error
		Return
	EndIf

	setStatus($Status, "Beatmap loaded.")
	logThis($LogFile, "Beatmap loaded.")
EndFunc   ;==>LoadSelectedDiff



; #FUNCTION# ====================================================================================================================
; Name ..........: LoadBeatmap
; Description ...: Loads the needed variables of a beatmap including all hitobjects
; Syntax ........: LoadBeatmap($FilePath)
; Parameters ....: $FilePath            - Path to the beatmap that should be loaded
; Return values .: None
; Author ........: Icclear
; Modified ......:
; Remarks .......: Sets $BeatmapLoaded to 1 if a beatmap was successfully loaded
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func LoadBeatmap($FilePath)
	$BeatmapLoaded = 0

	Local $Beatmap = FileReadToArray($FilePath)

	FileClose($FilePath)
	If @error Or Not IsArray($Beatmap) Or Not StringInStr($Beatmap[0], "osu file format v") Then
		DisplayError("Beatmap couldn't be loaded. Errorcode: " & @error)
		Return
	EndIf

	ConsoleWrite("Erste Zeile der Beatmap: " & $Beatmap[0] & @CRLF)

	$HitList = LoadHitObjects($Beatmap)
	If @error Or Not IsArray($HitList) Then
		DisplayError("Error loading hitobjects Errorcode: " & @error)
		Return
	EndIf

	$Bpms = LoadBpms($Beatmap)
	If @error Or Not IsArray($Bpms) Then
		DisplayError("Error loading TimingPoints. Errorcode: " & @error)
		Return
	EndIf

	$SliderMultiplier = LoadFromBeatMap($Beatmap, "SliderMultiplier")
	If @error Then
		DisplayError("Error loading SliderMultiplier from Beatmap.")
		Return
	EndIf

	$SelectedSong = $Song
	$BeatmapLoaded = 1
EndFunc   ;==>LoadBeatmap

#EndRegion LoadingBeatmaps


; #FUNCTION# ====================================================================================================================
; Name ..........: DisplayError
; Description ...: Shortcut to use showError() with less parameters
; Syntax ........: DisplayError($Errortext)
; Parameters ....: $Errortext           - Errortext that will be displayed
; Return values .: None
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func DisplayError($Errortext)
	showError($LogFile, $Status, $Errortext)
EndFunc   ;==>DisplayError
