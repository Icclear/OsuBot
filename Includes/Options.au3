#include-once
#Region Options

Func Options()
	#Region ### START Koda GUI section ### Form=D:\Projects\OsuBot\Options.kxf
	Local $Options = GUICreate("Options", 485, 437, 199, 130)
	Local $WindowTitle = GUICtrlCreateInput(IniRead($Inifile, $IniSectionGeneral, $IniKeyWindowtitle, "changeme"), 104, 56, 305, 21)
	Local Const $General = GUICtrlCreateLabel("General:", 32, 16, 44, 17)
	Local $OsuDirectory = GUICtrlCreateInput(IniRead($Inifile, $IniSectionGeneral, $IniKeyDirectory, ""), 104, 88, 305, 21)
	Local Const $OsuDirectoryLabel = GUICtrlCreateLabel("OsuDirectory:", 32, 88, 68, 17)
	Local $StopKey = GUICtrlCreateInput(IniRead($Inifile, $IniSectionKeys, $IniKeyStopkey, "s"), 104, 192, 81, 21)
	Local Const $StopKeyLabel = GUICtrlCreateLabel("StopKey:", 56, 192, 47, 17)
	Local Const $WindowTitleLabel = GUICtrlCreateLabel("WindowTitle:", 32, 56, 66, 17)
	Local Const $Keys = GUICtrlCreateLabel("Keys:", 40, 152, 30, 17)
	Local $Button1 = GUICtrlCreateInput(IniRead($Inifile, $IniSectionKeys, $IniKeyButton1, "x"), 104, 224, 81, 21)
	Local Const $Button1Label = GUICtrlCreateLabel("Button 1:", 56, 224, 47, 17)
	Local $Button2 = GUICtrlCreateInput(IniRead($Inifile, $IniSectionKeys, $IniKeyButton2, "z"), 104, 256, 81, 21)
	Local Const $Button2Label = GUICtrlCreateLabel("Button 2:", 56, 256, 47, 17)
	Local $Preklick = GUICtrlCreateInput(IniRead($Inifile, $IniSectionPlaying, $IniKeyPreKlick, "25"), 104, 328, 81, 21)
	Local Const $PreklickLabel = GUICtrlCreateLabel("Preklick:", 56, 328, 45, 17)
	Local Const $Playing = GUICtrlCreateLabel("Playing:", 40, 288, 41, 17)
	Local $Extraholdtime = GUICtrlCreateInput(IniRead($Inifile, $IniSectionPlaying, $IniKeyExtraHoldTime, "49"), 104, 360, 81, 21)
	Local Const $ExtraholdtimeLabel = GUICtrlCreateLabel("Extraholdtime:", 32, 360, 70, 17)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###

	GUISetState(@SW_HIDE, $MainWindow)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				if 0 = IniWrite($Inifile, $IniSectionGeneral, $IniKeyWindowtitle, GUICtrlRead($WindowTitle)) then
					DisplayError("Couldn't save Ini. File is readonly.")
				else
					IniWrite($Inifile, $IniSectionGeneral, $IniKeyDirectory, GUICtrlRead($OsuDirectory))

					IniWrite($Inifile, $IniSectionKeys, $IniKeyStopkey, GUICtrlRead($StopKey))

					IniWrite($Inifile, $IniSectionKeys, $IniKeyButton1, GUICtrlRead($Button1))

					IniWrite($Inifile, $IniSectionKeys, $IniKeyButton2, GUICtrlRead($Button2))


					IniWrite($Inifile, $IniSectionPlaying, $IniKeyPreKlick, GUICtrlRead($Preklick))

					IniWrite($Inifile, $IniSectionPlaying, $IniKeyExtraHoldTime, GUICtrlRead($Extraholdtime))
				EndIf
				GUIDelete($Options)
				GUISetState(@SW_SHOW, $MainWindow)
				Return

		EndSwitch
	WEnd

	Return
EndFunc

#EndRegion