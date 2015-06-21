#include "NomadMemory.au3"
#include <File.au3>

#include-once
#Region HelpFunctions

; #FUNCTION# ====================================================================================================================
; Name ..........: setStatus
; Description ...: sets the status field's text
; Syntax ........: setStatus($Status, $toSet)
; Parameters ....: $Status              - Handle of the status label
;                  $toSet               - String the text should be set to
; Return values .: None
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func setStatus($Status, $toSet)
	if IsString($toSet) then
		GUICtrlSetData($Status, "Status: " & $toSet)
	Else
		GUICtrlSetData($Status, "Status: Error setting Status. Argument not a string.")
	EndIf
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: setTime
; Description ...: updates the time in the time label
; Syntax ........: setTime($TimeField, $Time)
; Parameters ....: $TimeField           - handle of the time label
;                  $Time                - current time
; Return values .: None
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func setTime($TimeField, $Time)
	if IsNumber($Time) then
		GUICtrlSetData($TimeField, "Time: " & $Time)
	Else
		GUICtrlSetData($TimeField, "Time: Error setting Time. Argument is not a number.")
	EndIf
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: showError
; Description ...: Displays an Error
; Syntax ........: showError($LogFile, $Status, $Error)
; Parameters ....: $LogFile             - String containing the path of the logfile
;                  $Status              - Handle of the status label
;                  $Error               - Errortext
; Return values .: None
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func showError($LogFile, $Status, $Error)
	ConsoleWriteError($Error & @CRLF)
	if not $status = 0 then setStatus($Status, $Error)
	MsgBox(8192, "Error", $Error)
	LogThis($LogFile, "[Error] " & $Error)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: readTime
; Description ...: Reads the current time
; Syntax ........: readTime($LogFile, $TimeAdress, $OsuProcess)
; Parameters ....: $LogFile             - String containing the path of the logfile
;                  $TimeAdress          - The adress of the time value
;                  $OsuProcess          - The handle of the process
; Return values .: current time
; Author ........: Icclear
; Modified ......:
; Remarks .......: Inefficient. Rework------------------------------
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func readTime($LogFile, $TimeAdress, $OsuProcess)	;Make more efficient	(MemoryRead with new bytes etc)
	Local $Time = _MemoryRead($TimeAdress, $OsuProcess)
	if not @error then return $Time

	showError($LogFile, 0, "Time couldn't be read.")
	_Exit($LogFile, $OsuProcess)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _Exit
; Description ...: Exists the program proberly
; Syntax ........: _Exit($LogFile, $Process)
; Parameters ....: $LogFile             - String containing the logpath
;                  $Process             - Handle of the osuprocess
; Return values .: None
; Author ........: Icclear
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Exit($LogFile, $Process)
	_MemoryClose($Process)
	LogThis($LogFile, "Program exits with Errorcode: " & @error & @CRLF)
	Exit
EndFunc	;==>_Exit


; #FUNCTION# ====================================================================================================================
; Name ..........: LogThis
; Description ...: Logs text
; Syntax ........: LogThis($LogFile, $toLog)
; Parameters ....: $LogFile             - String containing the logfilepath
;                  $toLog               - String of what to log
; Return values .: None
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func LogThis($LogFile, $toLog)
	ConsoleWrite($toLog & @CRLF)
	_FileWriteLog($LogFile, $toLog)
EndFunc

#EndRegion