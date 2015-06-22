#include-once

#Region GUI
logThis($Logfile, "Creating GUI")

;~ Fenstertitel festlegen
Local Const $WindowTitle = IniRead($Inifile, $IniSectionGeneral, $IniKeyWindowtitle, "ChangeMe")

;~ Gui initialisieren
#Region ### START Koda GUI section ### Form=
Global $MainWindow = GUICreate($WindowTitle, 741, 338, 1505, 181)
Global $Options = GUICtrlCreateMenu("Options")
$OpenOptions = GUICtrlCreateMenuItem("Open Options", $Options)
Global $StatusBox = GUICtrlCreateGroup("StatusBox", 96, 200, 617, 113)
Global $Status = GUICtrlCreateLabel("Window found.", 112, 224, 586, 17)
Global $TimeLabel = GUICtrlCreateLabel("Time: ", 112, 288, 589, 17)
Global $LoadedBeatmap = GUICtrlCreateLabel("Beatmap: ", 112, 256, 594, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $RelaxBox = GUICtrlCreateCheckbox("RelaxBox", 8, 208, 9, 25)
GUICtrlSetState(-1, $GUI_CHECKED)
Global $SongSearch = GUICtrlCreateInput("", 96, 32, 337, 21)
Global Const $RelaxEnabled = GUICtrlCreateLabel("Relax", 24, 216, 31, 17)
Global $Songlist = GUICtrlCreateList("", 96, 64, 337, 110)
Global $DiffList = GUICtrlCreateList("", 448, 32, 281, 97)
Global $LoadDiff = GUICtrlCreateButton("LoadDiff", 448, 136, 281, 41)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

#EndRegion GUI