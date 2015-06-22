#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Compile_Both=y
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
#include <Array.au3>
#include <FileConstants.au3>

#include "Includes\NomadMemory.au3"
#include "Includes\exported stuff.au3"
#include "Includes\HelpFunctions.au3"
#include "Includes\GlobalConsts.au3"


;Begin Program
#include "Includes\GUI.au3"
#include "Includes\Initiate.au3"

#EndRegion Includes


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

	If $OsuTitle <> "osu!" And $BeatmapLoaded = 1 Then
		Play()
	ElseIf $BeatmapLoaded = 1 Then
		setStatus($Status, "Waiting for Song! ")
	Else
		setStatus($Status, "Need to load Beatmap First!")
	EndIf

	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_Exit($LogFile, $OsuProcess)

		Case $SongSearch ;$LoadList
			updateList()

		Case $Songlist ;$LoadSelected
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


	Local $StopButton = IniRead($Inifile, $IniSectionKeys, $IniKeyStopkey, "s")
	Global $Button1 = IniRead($Inifile, $IniSectionKeys, $IniKeyButton1, "x")
	Global $Button2 = IniRead($Inifile, $IniSectionKeys, $IniKeyButton2, "z")

	IniWrite($Inifile, $IniSectionKeys, $IniKeyStopkey, $StopButton)
	IniWrite($Inifile, $IniSectionKeys, $IniKeyButton1, $Button1)
	IniWrite($Inifile, $IniSectionKeys, $IniKeyButton2, $Button2)

	;Save settings


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
				$NextHitComplete = StringSplit($HitList[$i], ",")
				$NextHitTime = $NextHitComplete[3] ;Time
				If $Time < $NextHitTime Then
					$FoundNextHit = 1
					$Klicked = 0
				EndIf
				$i += 1
			Until $FoundNextHit = 1

			If $Finished = 0 Then

				$NextHitType = StringSplit($HitList[$i - 1], ",")[4] ;Type

				$BeginKlick = $NextHitTime - $PreKlick


				;Which type of hit
				If $NextHitType = 1 Or $NextHitType = 5 Or $NextHitType = 16 Or $NextHitType = 37 Or $NextHitType = 21 Then ;Circle
					$EndKlick = $BeginKlick + $ExtraPressTime

;~ 				ElseIf $NextHitType = 2 Or $NextHitType = 6 Or $NextHitType = 21 Or $NextHitType = 22 Then ;Slider
					;Moved to else since there were too many possibilities


				ElseIf $NextHitType = 12 Or $NextHitType = 8 Then ;Spin
					$EndKlick = $NextHitComplete[6] + $ExtraPressTime ;You can read the duration there

					;if pressed till after the next hitobject
					If $i <= UBound($HitList) - 1 And $EndKlick > StringSplit($HitList[$i], ",")[3] Then $EndKlick = StringSplit($HitList[$i], ",")[3] - ($ExtraPressTime * 2)

				Else ;Slider
					Local $Repetition = $NextHitComplete[7]
					Local $Length = $NextHitComplete[8]
					$EndKlick = $BeginKlick + $CurrentBPM * $Repetition * $Length / $SliderMultiplier / 100 + $ExtraPressTime

					;if pressed till after the next hitobject
					If $i <= UBound($HitList) - 1 And $EndKlick > StringSplit($HitList[$i], ",")[3] Then $EndKlick = StringSplit($HitList[$i], ",")[3] - ($ExtraPressTime * 2)
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
; Description ...: Displays all Songs in $Songlist that include the string entered in $SongSearch
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

	GUICtrlSetData($Songlist, "")
	Local $Mask = GUICtrlRead($SongSearch)
	For $i = 0 To UBound($MapList) - 1 Step 1
		If StringInStr($MapList[$i], $Mask) > 0 Then GUICtrlSetData($Songlist, $MapList[$i])
	Next

	setStatus($Status, "Search finished.")
	logThis($LogFile, "Search finished.")
EndFunc   ;==>updateList



; #FUNCTION# ====================================================================================================================
; Name ..........: LoadSelectedBeatmap
; Description ...: Displays all difficultys of the Beatmap that's selected in $Songlist
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

	Local $tmpSong = GUICtrlRead($Songlist)
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
	Local $SelectedDiff = GUICtrlRead($DiffList)
	For $i = 0 To UBound($Diffs) - 1 Step 1
		If StringInStr($Diffs[$i], $SelectedDiff) > 0 Then $Diff = $Diffs[$i]
	Next

	setStatus($Status, "Loading Beatmap")
	logThis($LogFile, "Loading Beatmap")

	LoadBeatmap($Directory & $Song & "\" & $Diff)
	$SelectedSong = $Song & " [" & $SelectedDiff & "]"
	If @error Or Not IsArray($HitList) Then
		$BeatmapLoaded = 0
		DisplayError("Couldn't load Beatmap. Errorcode: " & @error)
		SetError(0) ;Reset Error
		Return
	EndIf

	If $BeatmapLoaded = 1 Then
		GUICtrlSetData($LoadedBeatmap, "Loaded beatmap: " & $SelectedSong)
		setStatus($Status, "Beatmap loaded.")
		logThis($LogFile, "Beatmap loaded.")
	Else
		GUICtrlSetData($LoadedBeatmap, "Loaded beatmap: Error")
		setStatus($Status, "Error loading Beatmap.")
		logThis($LogFile, "Error laoding Beatmap.")
	EndIf
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
	setStatus($Status, "Reading Beatmap")
	logThis($LogFile, "Reading Beatmap: " & $FilePath)
	Local $Beatmap = FileReadToArray($FilePath)

	FileClose($FilePath)
	If @error Or Not IsArray($Beatmap) Or Not StringInStr($Beatmap[0], "osu file format v") Then
		If IsArray($Beatmap) Then ConsoleWrite("First line: " & $Beatmap[0] & @CRLF) ;Debug Line

		DisplayError("Error reading Beatmap. Errorcode: " & @error)
		SetError(1)
		Return
	EndIf

	ConsoleWrite("First line: " & $Beatmap[0] & @CRLF)

	setStatus($Status, "Validating mode.")
	logThis($LogFile, "Validating mode.")
	Local $Mode = LoadFromBeatMap($Beatmap, "Mode")
	If $Mode <> " 0" And Not @error Then ;Not in old maps
		DisplayError("Wrong gamemode.")
		Return
	EndIf
	If @error Then SetError(0) ;reset Error

	setStatus($Status, "Loading HitObjects.")
	logThis($LogFile, "Loading Hitobjects.")

	$HitList = LoadHitObjects($Beatmap)
	If @error Or Not IsArray($HitList) Then
		DisplayError("Error loading hitobjects Errorcode: " & @error)
		SetError(2)
		Return
	EndIf

	setStatus($Status, "Loading timepoints.")
	logThis($LogFile, "Loading timepoints.")
	$Bpms = LoadBpms($Beatmap)
	If @error Or Not IsArray($Bpms) Then
		DisplayError("Error loading TimingPoints. Errorcode: " & @error)
		SetError(3)
		Return
	EndIf

	setStatus($Status, "Loading SliderMultiplier")
	logThis($LogFile, "Loading SliderMultiplier")
	$SliderMultiplier = LoadFromBeatMap($Beatmap, "SliderMultiplier")
	If @error Then
		DisplayError("Error loading SliderMultiplier from Beatmap.")
		SetError(4)
		Return
	EndIf

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
