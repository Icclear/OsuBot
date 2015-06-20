#include "NomadMemory.au3"
#include <Array.au3>
#include <FileConstants.au3>
#include "HelpFunctions.au3"

#include-once
#Region ExStuff

; #FUNCTION# ====================================================================================================================
; Name ..........: _ProcessGetLocation
; Description ...: Find the directory of a process
; Syntax ........: _ProcessGetLocation($iPID)
; Parameters ....: $iPID                - The handle of the process
; Return values .: path of the process
; Author ........: Unknown
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ProcessGetLocation($iPID)
    Local $aProc = DllCall('kernel32.dll', 'hwnd', 'OpenProcess', 'int', BitOR(0x0400, 0x0010), 'int', 0, 'int', $iPID)
    If $aProc[0] = 0 Then Return SetError(1, 0, '')
    Local $vStruct = DllStructCreate('int[1024]')
    DllCall('psapi.dll', 'int', 'EnumProcessModules', 'hwnd', $aProc[0], 'ptr', DllStructGetPtr($vStruct), 'int', DllStructGetSize($vStruct), 'int_ptr', 0)
    Local $aReturn = DllCall('psapi.dll', 'int', 'GetModuleFileNameEx', 'hwnd', $aProc[0], 'int', DllStructGetData($vStruct, 1), 'str', '', 'int', 2048)
    If StringLen($aReturn[3]) = 0 Then Return SetError(2, 0, '')
    Return $aReturn[3]
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _AOBScan
; Description ...: Finds a pattern in a process
; Syntax ........: _AOBScan($handle, $sig)
; Parameters ....: $handle              - Handle of the process the pattern should be find in.
;                  $sig                 - The pattern/signature to be found.
; Return values .: - adress	Adress of the begin of the pattern.
;				   - 0		There was an error
; Author ........: Unknown
; Modified ......: by Icclear
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _AOBScan($handle, $sig)
	Local $Mult = 1600
	$sig = StringRegExpReplace($sig, "[^0123456789ABCDEFabcdef?.]", "")
	$sig = StringRegExpReplace($sig, "[?]", ".")
	Local $bytes = StringLen($sig) / 2

;~ 	Local $start_addr = 0x00400000
;~ 	Local $end_Addr = 0x0FFFFFFF
	Local $start_addr = 0x00000000
	Local $end_Addr = 0x7FFFFFFF

	For $addr = $start_addr To $end_Addr Step $bytes * ($Mult - 1)
		Local $string = _MemoryRead($addr, $handle, "byte[" & $bytes * $Mult & "]")

		StringRegExp($string, $sig, 1, 2)
		If @error = 0 Then
			Return StringFormat("0x%.8X", $addr + ((@extended - StringLen($sig) - 2) / 2))
		EndIf
	Next
	Return 0
EndFunc   ;==>_AOBScan



; #FUNCTION# ====================================================================================================================
; Name ..........: LoadHitObjects
; Description ...: Loads all hitobjects
; Syntax ........: LoadHitObjects($Lines)
; Parameters ....: $Lines               - a string list containing all the lines of a beatmap
; Return values .: a stringlist containing all the hitobjects of the map
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func LoadHitObjects($Lines)

	If not IsArray($Lines) Then
		SetError(2)
		Return 0
	EndIf

	ConsoleWrite("Erste Zeile der Beatmap: " & $Lines[0] & @CRLF)

	Local $FoundStart = 0

	do
		if $Lines[0] = "[HitObjects]" Then
			_ArrayDelete($Lines, 0)
			$FoundStart = 1
		Else
			_ArrayDelete($Lines, 0)
		EndIf
	Until $FoundStart = 1 Or 0 = UBound($Lines)

	If $FoundStart = 0 Then
		SetError(1)
		Return 0
	Else
		return $Lines
	EndIf

EndFunc   ;==>LoadBeatmap


; #FUNCTION# ====================================================================================================================
; Name ..........: LoadFromBeatmap
; Description ...: Loads the value of a specific key
; Syntax ........: LoadFromBeatmap($Beatmap, $toFind)
; Parameters ....: $Beatmap             - arraylist that contains the full beatmap
;                  $toFind              - a key as a string
; Return values .: the value of the key
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func LoadFromBeatmap($Beatmap, $toFind)
	Local $i = 0
	do
		if StringInStr($Beatmap[$i], $toFind) > 0 then
			return StringSplit($Beatmap[$i], ":")[2]
		EndIf

		$i += 1
	Until $i >= UBound($Beatmap) - 1
	SetError(1)
	Return 0
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _IsChecked
; Description ...: Checks if a checkbox is checked.
; Syntax ........: _IsChecked($idControlID)
; Parameters ....: $idControlID         - The ID of the Checkbox that should be checked
; Return values .: true or false, depending on whether the checkbox is checked
; Author ........: Unknown
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _IsChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked


; #FUNCTION# ====================================================================================================================
; Name ..........: FolderList
; Description ...: Lists all directories in  a folder
; Syntax ........: FolderList($Folder)
; Parameters ....: $Folder              - String containing the folder
; Return values .: Array containing all directories
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func FolderList($Folder)
	return  _FileListToArray ( $Folder, "*", $FLTA_FOLDERS)
EndFunc

#EndRegion