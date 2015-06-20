Global Const $GUI_EVENT_CLOSE = -3
Global Const $GUI_CHECKED = 1
Global Const $UBOUND_DIMENSIONS = 0
Global Const $UBOUND_ROWS = 1
Global Const $UBOUND_COLUMNS = 2
Func _ArrayDelete(ByRef $avArray, $vRange)
If Not IsArray($avArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($avArray, $UBOUND_ROWS) - 1
If IsArray($vRange) Then
If UBound($vRange, $UBOUND_DIMENSIONS) <> 1 Or UBound($vRange, $UBOUND_ROWS) < 2 Then Return SetError(4, 0, -1)
Else
Local $iNumber, $aSplit_1, $aSplit_2
$vRange = StringStripWS($vRange, 8)
$aSplit_1 = StringSplit($vRange, ";")
$vRange = ""
For $i = 1 To $aSplit_1[0]
If Not StringRegExp($aSplit_1[$i], "^\d+(-\d+)?$") Then Return SetError(3, 0, -1)
$aSplit_2 = StringSplit($aSplit_1[$i], "-")
Switch $aSplit_2[0]
Case 1
$vRange &= $aSplit_2[1] & ";"
Case 2
If Number($aSplit_2[2]) >= Number($aSplit_2[1]) Then
$iNumber = $aSplit_2[1] - 1
Do
$iNumber += 1
$vRange &= $iNumber & ";"
Until $iNumber = $aSplit_2[2]
EndIf
EndSwitch
Next
$vRange = StringSplit(StringTrimRight($vRange, 1), ";")
EndIf
If $vRange[1] < 0 Or $vRange[$vRange[0]] > $iDim_1 Then Return SetError(5, 0, -1)
Local $iCopyTo_Index = 0
Switch UBound($avArray, $UBOUND_DIMENSIONS)
Case 1
For $i = 1 To $vRange[0]
$avArray[$vRange[$i]] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $avArray[$iReadFrom_Index] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
$avArray[$iCopyTo_Index] = $avArray[$iReadFrom_Index]
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $avArray[$iDim_1 - $vRange[0] + 1]
Case 2
Local $iDim_2 = UBound($avArray, $UBOUND_COLUMNS) - 1
For $i = 1 To $vRange[0]
$avArray[$vRange[$i]][0] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $avArray[$iReadFrom_Index][0] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
For $j = 0 To $iDim_2
$avArray[$iCopyTo_Index][$j] = $avArray[$iReadFrom_Index][$j]
Next
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $avArray[$iDim_1 - $vRange[0] + 1][$iDim_2 + 1]
Case Else
Return SetError(2, 0, False)
EndSwitch
Return UBound($avArray, $UBOUND_ROWS)
EndFunc
Global Const $FO_APPEND = 1
Global Const $FO_OVERWRITE = 2
Global Const $FLTA_FILES = 1
Global Const $FLTA_FOLDERS = 2
Func _FileListToArray($sFilePath, $sFilter = "*", $iFlag = 0, $bReturnPath = False)
Local $sDelimiter = "|", $sFileList = "", $sFileName = "", $sFullPath = ""
$sFilePath = StringRegExpReplace($sFilePath, "[\\/]+$", "") & "\"
If $iFlag = Default Then $iFlag = 0
If $bReturnPath Then $sFullPath = $sFilePath
If $sFilter = Default Then $sFilter = "*"
If Not FileExists($sFilePath) Then Return SetError(1, 0, 0)
If StringRegExp($sFilter, "[\\/:><\|]|(?s)^\s*$") Then Return SetError(2, 0, 0)
If Not($iFlag = 0 Or $iFlag = 1 Or $iFlag = 2) Then Return SetError(3, 0, 0)
Local $hSearch = FileFindFirstFile($sFilePath & $sFilter)
If @error Then Return SetError(4, 0, 0)
While 1
$sFileName = FileFindNextFile($hSearch)
If @error Then ExitLoop
If($iFlag + @extended = 2) Then ContinueLoop
$sFileList &= $sDelimiter & $sFullPath & $sFileName
WEnd
FileClose($hSearch)
If $sFileList = "" Then Return SetError(4, 0, 0)
Return StringSplit(StringTrimLeft($sFileList, 1), $sDelimiter)
EndFunc
Func _FileWriteLog($sLogPath, $sLogMsg, $iFlag = -1)
Local $iOpenMode = $FO_APPEND
Local $sDateNow = @YEAR & "-" & @MON & "-" & @MDAY
Local $sTimeNow = @HOUR & ":" & @MIN & ":" & @SEC
Local $sMsg = $sDateNow & " " & $sTimeNow & " : " & $sLogMsg
If $iFlag = Default Then $iFlag = -1
If $iFlag <> -1 Then
$iOpenMode = $FO_OVERWRITE
$sMsg &= @CRLF & FileRead($sLogPath)
EndIf
Local $hFileOpen = $sLogPath
If IsString($sLogPath) Then
$hFileOpen = FileOpen($sLogPath, $iOpenMode)
EndIf
If $hFileOpen = -1 Then Return SetError(1, 0, 0)
Local $iReturn = FileWriteLine($hFileOpen, $sMsg)
If IsString($sLogPath) Then $iReturn = FileClose($hFileOpen)
If $iReturn <= 0 Then Return SetError(2, $iReturn, 0)
Return $iReturn
EndFunc
Func _MemoryOpen($iv_Pid, $iv_DesiredAccess = 0x1F0FFF, $iv_InheritHandle = 1)
If Not ProcessExists($iv_Pid) Then
SetError(1)
Return 0
EndIf
Local $ah_Handle[2] = [DllOpen('kernel32.dll')]
If @Error Then
SetError(2)
Return 0
EndIf
Local $av_OpenProcess = DllCall($ah_Handle[0], 'int', 'OpenProcess', 'int', $iv_DesiredAccess, 'int', $iv_InheritHandle, 'int', $iv_Pid)
If @Error Then
DllClose($ah_Handle[0])
SetError(3)
Return 0
EndIf
$ah_Handle[1] = $av_OpenProcess[0]
Return $ah_Handle
EndFunc
Func _MemoryRead($iv_Address, $ah_Handle, $sv_Type = 'dword')
If Not IsArray($ah_Handle) Then
SetError(1)
Return 0
EndIf
Local $v_Buffer = DllStructCreate($sv_Type)
If @Error Then
SetError(@Error + 1)
Return 0
EndIf
DllCall($ah_Handle[0], 'int', 'ReadProcessMemory', 'int', $ah_Handle[1], 'int', $iv_Address, 'ptr', DllStructGetPtr($v_Buffer), 'int', DllStructGetSize($v_Buffer), 'int', '')
If Not @Error Then
Local $v_Value = DllStructGetData($v_Buffer, 1)
Return $v_Value
Else
SetError(6)
Return 0
EndIf
EndFunc
Func _MemoryClose($ah_Handle)
If Not IsArray($ah_Handle) Then
SetError(1)
Return 0
EndIf
DllCall($ah_Handle[0], 'int', 'CloseHandle', 'int', $ah_Handle[1])
If Not @Error Then
DllClose($ah_Handle[0])
Return 1
Else
DllClose($ah_Handle[0])
SetError(2)
Return 0
EndIf
EndFunc
Const $TOKEN_ADJUST_PRIVILEGES = 0x0020
Const $TOKEN_QUERY = 0x0008
Const $SE_PRIVILEGE_ENABLED = 0x0002
Func setStatus($Status, $toSet)
if IsString($toSet) then
GUICtrlSetData($Status, "Status: " & $toSet)
Else
GUICtrlSetData($Status, "Status: Error setting Status. Argument not a string.")
EndIf
EndFunc
Func setTitle($TitleLabel, $Title)
if IsString($Title) then
GUICtrlSetData($TitleLabel, "Title: " & $Title)
Else
GUICtrlSetData($TitleLabel, "Title: Error setting Title. Argument not a string.")
EndIf
EndFunc
Func setTime($TimeField, $Time)
if IsNumber($Time) then
GUICtrlSetData($TimeField, "Time: " & $Time)
Else
GUICtrlSetData($TimeField, "Time: Error setting Time. Argument is not a number.")
EndIf
EndFunc
Func showError($LogFile, $Status, $Error)
ConsoleWriteError($Error & @CRLF)
if not $status = 0 then setStatus($Status, $Error)
MsgBox(8192, "Error", $Error)
LogThis($LogFile, "[Error] " & $Error)
EndFunc
Func readTime($LogFile, $TimeAdress, $OsuProcess)
Local $Time = _MemoryRead($TimeAdress, $OsuProcess)
if not @error then return $Time
showError($LogFile, 0, "Time couldn't be read.")
_Exit($LogFile, $OsuProcess)
EndFunc
Func _Exit($LogFile, $Process)
_MemoryClose($Process)
LogThis($LogFile, "Program exits with Errorcode: " & @error & @CRLF)
Exit
EndFunc
Func LogThis($LogFile, $toLog)
ConsoleWrite($toLog & @CRLF)
_FileWriteLog($LogFile, $toLog)
EndFunc
Func _ProcessGetLocation($iPID)
Local $aProc = DllCall('kernel32.dll', 'hwnd', 'OpenProcess', 'int', BitOR(0x0400, 0x0010), 'int', 0, 'int', $iPID)
If $aProc[0] = 0 Then Return SetError(1, 0, '')
Local $vStruct = DllStructCreate('int[1024]')
DllCall('psapi.dll', 'int', 'EnumProcessModules', 'hwnd', $aProc[0], 'ptr', DllStructGetPtr($vStruct), 'int', DllStructGetSize($vStruct), 'int_ptr', 0)
Local $aReturn = DllCall('psapi.dll', 'int', 'GetModuleFileNameEx', 'hwnd', $aProc[0], 'int', DllStructGetData($vStruct, 1), 'str', '', 'int', 2048)
If StringLen($aReturn[3]) = 0 Then Return SetError(2, 0, '')
Return $aReturn[3]
EndFunc
Func _AOBScan($handle, $sig)
Local $Mult = 1600
$sig = StringRegExpReplace($sig, "[^0123456789ABCDEFabcdef?.]", "")
$sig = StringRegExpReplace($sig, "[?]", ".")
Local $bytes = StringLen($sig) / 2
Local $start_addr = 0x00000000
Local $end_Addr = 0x7FFFFFFF
For $addr = $start_addr To $end_Addr Step $bytes *($Mult - 1)
Local $string = _MemoryRead($addr, $handle, "byte[" & $bytes * $Mult & "]")
StringRegExp($string, $sig, 1, 2)
If @error = 0 Then
Return StringFormat("0x%.8X", $addr +((@extended - StringLen($sig) - 2) / 2))
EndIf
Next
Return 0
EndFunc
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
EndFunc
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
Func _IsChecked($idControlID)
Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc
Func FolderList($Folder)
return  _FileListToArray($Folder, "*", $FLTA_FOLDERS)
EndFunc
DirCreate("Data")
Global Const $Inifile = "Data/Settings.ini"
Global Const $LogFile = "Data/log.log"
logThis($LogFile, "Program started.")
If WinWait("osu!", "", 5) = 0 Then
showError($LogFile, 0, "Osu!-window not found!")
SetError(1)
Exit
EndIf
Global $OsuTitle = WinGetTitle("osu!")
logThis($LogFile, "Window found")
Local Const $WindowTitle = IniRead($Inifile, "General", "WindowTitle", "ChangeMe")
If IniWrite($Inifile, "General", "WindowTitle", $WindowTitle) = 0 Then
showError($LogFile, 0, "Couldn't save windowtitle. File is readonly.")
EndIf
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
Local $Songpath = GUICtrlCreateInput("Songpath", 104, 64, 337, 21)
Global Const $RelaxActivated = GUICtrlCreateLabel("RelaxActivated", 80, 352, 76, 17)
Global $Songnames = GUICtrlCreateList("", 104, 104, 337, 162)
Local $LoadList = GUICtrlCreateButton("LoadList", 456, 48, 105, 65)
Local $LoadSelected = GUICtrlCreateButton("LoadSelected", 456, 128, 105, 65)
Global $DiffList = GUICtrlCreateList("", 464, 208, 265, 58)
Local $LoadDiff = GUICtrlCreateButton("LoadDiff", 616, 152, 73, 41)
GUISetState(@SW_SHOW)
logThis($LogFile, "GUI initialized.")
setStatus($Status, "GUI initialiued.")
Local Const $OsuID = ProcessExists("osu!.exe")
Global Const $OsuProcess = _MemoryOpen($OsuID)
If @error Then
DisplayError("Failed to open Process. Errorcode: " & @error)
SetError(2)
Exit
EndIf
logThis($LogFile, "Process opened.")
setStatus($Status, "Process opened.")
Local Const $aob = "DB 5D F4 8B 45 F4 A3"
Local Const $scan = _AOBScan($OsuProcess, $aob)
If @error Or $scan = 0 Then
DisplayError("Pattern not Found! Errorcode: " & @error & " $Scan: " & $scan)
SetError(3)
_Exit($LogFile, $OsuProcess)
EndIf
logThis($LogFile, "Pattern {" & $aob & "} found.")
setStatus($Status, "Pattern found.")
Global Const $TimeAdress = _MemoryRead($scan + 0x7, $OsuProcess, "byte[4]")
If @error Or $TimeAdress = 0 Then
DisplayError("Time-adress not found! Errorcode: " & @error)
SetError(4)
_Exit($LogFile, $OsuProcess)
EndIf
logThis($LogFile, "Timeadress found.")
setStatus($Status, "Timeadress found.")
Global $Directory = IniRead($Inifile, "General", "Directory", StringTrimRight(_ProcessGetLocation($OsuID), 8))
If @error Or $Directory = "" Then
DisplayError("Unable to find game directory. Please make sure you have set the right path in your settings. Errorcode: " & @error)
SetError(5)
_Exit($LogFile, $OsuProcess)
EndIf
If StringLen($Directory) <= 2 Then
GUICtrlSetData($DirectoryLabel, "Directory: Error")
DisplayError("Directory not Found! ")
SetError(6)
_Exit($LogFile, $OsuProcess)
Else
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
Local $Map = ""
GUICtrlSetData($Songpath, $Map)
ConsoleWriteError("[Warning] Map directory modified!" & @CRLF)
Global Const $MapList = FolderList($Directory)
If @error Then
DisplayError("Error loading Beatmaplist. Errorcode: " & @error)
_Exit($LogFile, $OsuProcess)
EndIf
Global $Playing = 0
Global $BeatmapLoaded = 0
Global $HitList
Global $SliderMultiplier
Global $Diffs
Global $Song = ""
Global $Diff = ""
logThis($LogFile, "Bot successfully started!")
setStatus($Status, "Bot successfully started!")
Local $Playing = 0
Local $Time = 0
While 1
setTime($TimeLabel, $Time)
$OsuTitle = WinGetTitle("osu!")
If $OsuTitle = "" Then
DisplayError("Osu Window not found. Bot will now exit.")
_Exit($LogFile, $OsuProcess)
EndIf
setTitle($TitleLabel, $OsuTitle)
If $OsuTitle <> "osu!" And $BeatmapLoaded = 1 Then
Play()
ElseIf $BeatmapLoaded = 1 Then
setStatus($Status, "Waiting for Song!")
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
Sleep(100)
WEnd
_Exit($LogFile, $OsuProcess)
Func Play()
HotKeySet("{s}", "StopPlaying")
$Playing = 1
Local Const $RelaxActive = _isChecked($RelaxBox)
Local $FoundNextHit = 0
Local $Klicked = 0
Global $NextHitTime = 0
Global $NextHitType = 0
Global $Time = 0
Local $i = 0
Global $LastButtonPressed = 2
Global $BT1Pressed = 0
Global $BT1ReleaseAt = 0
Global $BT2Pressed = 0
Global $BT2ReleaseAt = 0
Local $PreKlick = 30
Global $ExtraPressTime = 50
Global $BeginKlick = 0
Global $EndKlick = 0
ResetButtons()
While readTime($LogFile, $TimeAdress, $OsuProcess) > 10
Sleep(1)
WEnd
While $Playing = 1
$Time = readTime($LogFile, $TimeAdress, $OsuProcess)
setTime($TimeLabel, $Time)
If $FoundNextHit = 0 Then
Do
$NextHitTime = StringSplit($HitList[$i], ",")[3]
$i += 1
If $Time < $NextHitTime Then $FoundNextHit = 1
If $i >= UBound($HitList) - 1 Then
setStatus($Status, "Finished playing map.")
Return
EndIf
Until $FoundNextHit = 1
$NextHitType = StringSplit($HitList[$i - 1], ",")[4]
$BeginKlick = $NextHitTime - $PreKlick
If $NextHitType = 1 Or $NextHitType = 5 Then
$EndKlick = $BeginKlick + $ExtraPressTime
ElseIf $NextHitType = 2 Or $NextHitType = 6 Then
Local $Repetition = StringSplit($HitList[$i - 1], ",")[7]
Local $Length = StringSplit($HitList[$i - 1], ",")[8]
$EndKlick = $BeginKlick + $Repetition * $Length * $SliderMultiplier + $ExtraPressTime
ElseIf $NextHitType = 16 Then
$Klicked = 1
Else
$EndKlick = StringSplit($HitList[$i - 1], ",")[6] + $ExtraPressTime
EndIf
setStatus($Status, "Next Klick: " & $NextHitTime)
EndIf
If $RelaxActive And $Time > $BeginKlick And $Time < $EndKlick And $Klicked = 0 Then
setStatus($Status, "Klicking")
Klick()
$Klicked = 1
ElseIf $RelaxActive And $Time >= $EndKlick Then
$FoundNextHit = 0
$Klicked = 0
EndIf
If $RelaxActive Then ReleaseButtons()
WEnd
logThis($LogFile, "Stopped Playing")
ResetButtons()
HotKeySet("{s}")
EndFunc
Func Klick()
If $LastButtonPressed = 2 Then
BT1Klick()
Else
BT2Klick()
EndIf
EndFunc
Func BT1Klick()
If $BT1Pressed = 0 Then
Send("{- down}")
$BT1Pressed = 1
$BT1ReleaseAt = $EndKlick
ElseIf $BT2Pressed = 0 Then
Send("{. down}")
$BT2Pressed = 0
$BT2ReleaseAt = $EndKlick
EndIf
$LastButtonPressed = 1
EndFunc
Func BT2Klick()
If $BT2Pressed = 0 Then
Send("{. down}")
$BT2Pressed = 1
$BT2ReleaseAt = $EndKlick
ElseIf $BT1Pressed = 0 Then
Send("{- down}")
$BT1Pressed = 0
$BT1ReleaseAt = $EndKlick
EndIf
$LastButtonPressed = 2
EndFunc
Func ReleaseButtons()
If $BT1Pressed = 1 And $Time >= $BT1ReleaseAt Then
Send("{- up}")
$BT1Pressed = 0
EndIf
If $BT2Pressed = 1 And $Time >= $BT2ReleaseAt Then
Send("{. up}")
$BT2Pressed = 0
EndIf
EndFunc
Func ResetButtons()
Send("{- up}")
$BT1Pressed = 0
$BT1PressedAt = 0
Send("{. up}")
$BT2Pressed = 0
$BT2PressedAt = 0
EndFunc
Func StopPlaying()
$Playing = 0
EndFunc
Func updateList()
GUICtrlSetData($Songnames, "")
Local $Mask = GUICtrlRead($Songpath)
ConsoleWrite("Function started" & @CRLF)
For $i = 0 To UBound($MapList) - 1 Step 1
If StringInStr($MapList[$i], $Mask) > 0 Then GUICtrlSetData($Songnames, $MapList[$i] & "|")
Next
ConsoleWrite("Function finished" & @CRLF)
EndFunc
Func LoadSelectedBeatmap()
GUICtrlSetData($DiffList, "")
$Song = GUICtrlRead($Songnames)
$Diffs = _FileListToArray($Directory & $Song, "*", $FLTA_FILES)
For $i = 0 To UBound($Diffs) - 1 Step 1
If StringInStr($Diffs[$i], ".osu") > 0 Then
GUICtrlSetData($DiffList, StringSplit(StringSplit($Diffs[$i], "[")[2], "]")[1])
EndIf
Next
EndFunc
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
ConsoleWrite("Größe: " & UBound($HitList) & @CRLF)
SetError(0)
Return
EndIf
setStatus($Status, "Beatmap loaded.")
logThis($LogFile, "Beatmap loaded.")
EndFunc
Func LoadBeatmap($FilePath)
$BeatmapLoaded = 0
Local $Beatmap = FileReadToArray($FilePath)
If @error Then
DisplayError("Beatmap couldn't be loaded. Errorcode: " & @error)
Return 0
EndIf
FileClose($FilePath)
$HitList = LoadHitObjects($Beatmap)
If @error Then
DisplayError("Beatmap couldn't be loaded. Errorcode: " & @error)
Return 0
EndIf
$SliderMultiplier = LoadFromBeatMap($Beatmap, "SliderMultiplier")
If @error Then
DisplayError("Error loading SliderMultiplier from Beatmap.")
SetError(0)
Return 0
EndIf
$BeatmapLoaded = 1
EndFunc
Func DisplayError($Errortext)
showError($LogFile, $Status, $Errortext)
EndFunc
