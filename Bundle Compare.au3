#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Timboli (aka TheSaint)

 Script Function:  Extract game titles from Itch.io bundle JSON file listings
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <Misc.au3>
#include <File.au3>
#include <String.au3>
#include <Array.au3>

_Singleton("bundle-compare-thsaint")

Global $ans, $attrib, $bundle, $c, $check, $cnt, $created, $dir, $downfile, $drv, $entries, $entry, $fext, $fname, $games
Global $inifile, $itchfile, $itchlist, $num, $palestine, $path, $racial, $read, $sect, $sects, $split, $status, $titfile
Global $title, $titles, $ukraine, $version

$downfile = @ScriptDir & "\Downloaded.ini"
$inifile = @ScriptDir & "\Settings.ini"
$itchfile = @ScriptDir & "\Itch Bundles.tsv"
$itchlist = @ScriptDir & "\Itch Bundles.ini"
$titfile = @ScriptDir & "\Titles.tsv"

$created = "March 2022"
$version = "v1.3"

$racial = @ScriptDir & "\520_games.json"
$palestine = @ScriptDir & "\902_games.json"
$ukraine = @ScriptDir & "\1316_games.json"

$ans = MsgBox(262177 + 256, "Process Query", "OK = Extract." & @LF & "CANCEL = View Options.", 0)
If $ans = 1 Then
	SplashTextOn("", "Extracting!", 100, 80, Default, Default, 33)
	If FileExists($itchlist) Then FileMove($itchlist, $itchlist & ".bak", 1)
	If FileExists($itchfile) Then FileMove($itchfile, $itchfile & ".bak", 1)
	If FileExists($titfile) Then FileMove($titfile, $titfile & ".bak", 1)
	$games = 0
	While 1
		$path = $racial
		If FileExists($path) Then
			AddToThelist()
		Else
			MsgBox(262192, "Path Error", "The required '520_games.json' file not found.", 0)
			ExitLoop
		EndIf
		$path = $palestine
		If FileExists($path) Then
			AddToThelist()
		Else
			MsgBox(262192, "Path Error", "The required '902_games.json' file not found.", 0)
			ExitLoop
		EndIf
		$path = $ukraine
		If FileExists($path) Then
			AddToThelist()
		Else
			MsgBox(262192, "Path Error", "The required '1316_games.json' file not found.", 0)
			ExitLoop
		EndIf
		ExitLoop
	WEnd
	SplashOff()
	MsgBox(262192, "Game Titles", "Found = " & $games, 0)
Else
	If FileExists($itchfile) Then
		ViewerOptions()
	ElseIf FileExists($itchlist) Then
		SplashTextOn("", "Converting!", 100, 80, Default, Default, 33)
		$entries = ""
		$read = FileRead($itchlist)
		If $read <> "" Then
			$split = StringSplit($read, '[', 1)
			$cnt = $split[0]
			MsgBox(262192, "Games Count", $cnt - 1 & @LF & @LF & "(auto close)", 3)
			For $c = 3 To $cnt
				$sect = $split[$c]
				If $sect <> "" Then
					$entry = StringSplit($sect, ']', 1)
					If $entry[0] > 1 Then
						$entry = $entry[1]
						If $entry <> "" Then
							$title = IniRead($itchlist, $entry, "title", "")
							If $title <> "" Then
								$racial = IniRead($itchlist, $entry, "1", "na")
								$palestine = IniRead($itchlist, $entry, "2", "na")
								$ukraine = IniRead($itchlist, $entry, "3", "na")
								$status = IniRead($itchlist, $title, "downloaded", "na")
								$entry = $title & @TAB & $racial & @TAB & $palestine & @TAB & $ukraine & @TAB & $status
								If $entries = "" Then
									$entries = $entry
								Else
									$entries = $entries & @CRLF & $entry
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next
		EndIf
		FileWrite($itchfile, $entries)
		;
		SplashTextOn("", "Loading!", 100, 80, Default, Default, 33)
		If FileExists($itchfile) Then
			_FileReadToArray($itchfile, $entries, 1, @TAB)
			$ans = MsgBox(262177, "Sort Choice", "OK = Title." & @LF & "CANCEL = No Sort.", 0)
			If $ans = 1 Then
				_ArraySort($entries, 0, 1, 0, 0)
			EndIf
			SplashOff()
			_ArrayDisplay($entries, "Itch Bundles", "", 0, @TAB, "Titles|Racial Justice|Palestinian Aid|Ukraine Assist|Have", 350, $COLOR_SKYBLUE)
		Else
			SplashOff()
			MsgBox(262192, "Convert Error", "No resulting 'Itch Bundles.tsv' file found.", 0)
		EndIf
	Else
		MsgBox(262192, "File Error", "No files (using Extract) have been created yet.", 0)
	EndIf
EndIf

Exit

Func ViewerOptions()
	Local $Button_info, $Button_no, $Button_view, $Button_yes, $Checkbox_save, $Checkbox_view, $Combo_limit, $Combo_sort, $Combo_titles
	Local $Group_bundles, $Group_down, $Group_limit, $Group_sort, $Group_titles, $Input_down, $Label_palestine, $Label_racial, $Label_ukraine
	Local $array, $change, $choice, $choices, $game, $GUI_main, $items, $other, $save, $savfile, $tmpfile, $url, $val, $view, $viewfile, $views
	;
	; Script generated by GUIBuilder Prototype 0.9
	Const $style = BitOR($WS_OVERLAPPED, $WS_CAPTION, $WS_SYSMENU, $WS_VISIBLE, $WS_CLIPSIBLINGS, $WS_MINIMIZEBOX)
	$GUI_main = GuiCreate("View Options - Bundle Compare", 410, 220, -1, -1, $style, $WS_EX_TOPMOST)
	; CONTROLS
	$Group_sort = GuiCtrlCreateGroup("Sorting", 10, 10, 120, 55)
	$Combo_sort = GuiCtrlCreateCombo("", 20, 30, 100, 21)
	GUICtrlSetTip($Combo_sort, "Sort by selected for Viewing!")
	;
	$Group_limit = GuiCtrlCreateGroup("Limiting", 140, 10, 120, 55)
	$Combo_limit = GuiCtrlCreateCombo("", 150, 30, 100, 21)
	GUICtrlSetTip($Combo_limit, "Limit by selected for Viewing!")
	;
	$Button_info = GuiCtrlCreateButton("Info", 270, 15, 50, 50)
	GUICtrlSetFont($Button_info, 9, 600)
	GUICtrlSetTip($Button_info, "Program Information!")
	;
	$Button_view = GuiCtrlCreateButton("VIEW", 330, 15, 70, 50)
	GUICtrlSetFont($Button_view, 9, 600)
	GUICtrlSetTip($Button_view, "View using the Sort and Limit options!")
	;
	$Checkbox_save = GUICtrlCreateCheckbox("Save any sorted or limited results to file", 15, 72, 200, 20)
	GUICtrlSetTip($Checkbox_save, "Save any sorted or limited results to file!")
	;
	$Checkbox_view = GUICtrlCreateCheckbox("View with another TAB program", 230, 72, 170, 20)
	GUICtrlSetTip($Checkbox_view, "View results with another (default) TAB program!")
	;
	$Group_titles = GuiCtrlCreateGroup("Titles", 10, 100, 390, 55)
	$Combo_titles = GuiCtrlCreateCombo("", 20, 120, 370, 21, $GUI_SS_DEFAULT_COMBO + $CBS_SORT)
	GUICtrlSetTip($Combo_titles, "List of game titles!")
	;
	$Group_bundles = GuiCtrlCreateGroup("Bundles", 10, 160, 270, 52)
	$Label_racial = GUICtrlCreateLabel("", 20, 180, 80, 20, $SS_CENTER + $SS_CENTERIMAGE + $SS_NOTIFY + $SS_SUNKEN)
	GUICtrlSetTip($Label_racial, "Click to go to bundle web page for game!")
	$Label_palestine = GUICtrlCreateLabel("", 105, 180, 80, 20, $SS_CENTER + $SS_CENTERIMAGE + $SS_NOTIFY + $SS_SUNKEN)
	GUICtrlSetTip($Label_palestine, "Click to go to bundle web page for game!")
	$Label_ukraine = GUICtrlCreateLabel("", 190, 180, 80, 20, $SS_CENTER + $SS_CENTERIMAGE + $SS_NOTIFY + $SS_SUNKEN)
	GUICtrlSetTip($Label_ukraine, "Click to go to bundle web page for game!")
	;
	$Group_down = GuiCtrlCreateGroup("Downloaded", 290, 160, 110, 52)
	$Input_down = GUICtrlCreateInput("", 300, 180, 32, 20, $ES_CENTER)
	GUICtrlSetTip($Input_down, "Status of download for selected game!")
	$Button_yes = GuiCtrlCreateButton("Y", 337, 180, 24, 20)
	GUICtrlSetFont($Button_yes, 7, 600, 0 , "Small Fonts")
	GUICtrlSetTip($Button_yes, "Set downloaded as YES for selected game!")
	$Button_no = GuiCtrlCreateButton("N", 366, 180, 24, 20)
	GUICtrlSetFont($Button_no, 7, 600, 0 , "Small Fonts")
	GUICtrlSetTip($Button_no, "Remove the YES for selected game!")
	;
	; SETTINGS
	$choices = "none|Titles|Racial Justice|Palestinian Aid|Ukraine Assist"
	GUICtrlSetData($Combo_sort, $choices, "Titles")
	;
	$views = "ALL|Racial Justice|Palestinian Aid|Ukraine Assist|Downloaded"
	GUICtrlSetData($Combo_limit, $views, "all")
	;
	$save = IniRead($inifile, "Sorted Or Limited", "save", "")
	If $save = "" Then
		$save = 4
		IniWrite($inifile, "Sorted Or Limited", "save", $save)
	EndIf
	GUICtrlSetState($Checkbox_save, $save)
	;
	$other = IniRead($inifile, "Another Program", "view", "")
	If $other = "" Then
		$other = 4
		IniWrite($inifile, "Another Program", "view", $other)
	EndIf
	GUICtrlSetState($Checkbox_view, $other)
	;
	$entries = "|"
	$games = 0
	_FileReadToArray($itchfile, $array, 1)
	If IsArray($array) Then
		$cnt = $array[0]
		For $c = 1 To $cnt
			$sect = $array[$c]
			If $sect <> "" Then
				$entry = StringSplit($sect, @TAB, 1)
				If $entry[0] > 1 Then
					$entry = $entry[1]
					If $entry <> "" Then
						$games = $games + 1
						$entries = $entries & "|" & $entry
					EndIf
				EndIf
			EndIf
		Next
		GUICtrlSetData($Group_titles, "Titles (" & $games & ")")
		GUICtrlSetData($Combo_titles, $entries, "")
	EndIf


	GuiSetState(@SW_SHOWNORMAL)
	Do
		Switch GuiGetMsg()
			Case $GUI_EVENT_CLOSE
				GUIDelete($GUI_main)
				ExitLoop
			Case $Button_yes
				; Set downloaded as YES for selected game
				$title = GUICtrlRead($Combo_titles)
				If $title <> "" Then
					$status = GUICtrlRead($Input_down)
					If $status = "" Then
						$status = "YES"
						IniWrite($itchlist, $title, "downloaded", $status)
						IniWrite($downfile, $title, "downloaded", $status)
						GUICtrlSetData($Input_down, $status)
						$racial = IniRead($itchlist, $title, "1", "na")
						$palestine = IniRead($itchlist, $title, "2", "na")
						$ukraine = IniRead($itchlist, $title, "3", "na")
						$entry = $title & @TAB & $racial & @TAB & $palestine & @TAB & $ukraine & @TAB & "na"
						$change = $title & @TAB & $racial & @TAB & $palestine & @TAB & $ukraine & @TAB & $status
						SplashTextOn("", "Updating!", 100, 80, Default, Default, 33)
						For $c = 1 To $array[0]
							$sect = $array[$c]
							If $sect = $entry Then
								MsgBox(262192, "Entry", "Found.", 1, $GUI_main)
								_ArrayDelete($array, $c)
								_ArrayInsert($array, $c, $change)
								_FileWriteFromArray($itchfile, $array, 1)
								ExitLoop
							EndIf
						Next
						SplashOff()
					EndIf
				EndIf
			Case $Button_view
				; View using the Sort and Limit options
				GUISetState(@SW_MINIMIZE, $GUI_main)
				SplashTextOn("", "Loading!", 100, 80, Default, Default, 33)
				If Not FileExists($titfile) Then
					FileCopy($itchfile, $titfile, 1)
				EndIf
				$choice = GUICtrlRead($Combo_sort)
				$view = GUICtrlRead($Combo_limit)
				If $choice <> "none" Or $view <> "ALL" Then
					If $view = "ALL" Then
						$viewfile = $itchfile
						$savfile = $titfile
						$savfile = StringReplace($savfile, "Titles.tsv", "Titles_saved.tsv")
					ElseIf $view = "Racial Justice" Then
						$racial = @ScriptDir & "\Racial Justice.tsv"
						$viewfile = $racial
						FileDelete($viewfile)
						$items = ""
						_FileReadToArray($itchfile, $entries, 1)
						For $c = 1 To $entries[0]
							$entry = $entries[$c]
							If StringInStr($entry, "Racial Justice") > 0 And (StringInStr($entry, "Palestinian Aid") < 1 And StringInStr($entry, "Ukraine Assist") < 1) Then
								If $items = "" Then
									$items = $entry
								Else
									$items = $items & @CRLF & $entry
								EndIf
							EndIf
						Next
						FileWrite($viewfile, $items)
						$savfile = $racial
						$savfile = StringReplace($savfile, "Racial Justice.tsv", "Racial Justice_saved.tsv")
					ElseIf $view = "Palestinian Aid" Then
						$palestine = @ScriptDir & "\Palestinian Aid.tsv"
						$viewfile = $palestine
						FileDelete($viewfile)
						$items = ""
						_FileReadToArray($itchfile, $entries, 1)
						For $c = 1 To $entries[0]
							$entry = $entries[$c]
							If StringInStr($entry, "Palestinian Aid") > 0 And (StringInStr($entry, "Racial Justice") < 1 And StringInStr($entry, "Ukraine Assist") < 1) Then
								If $items = "" Then
									$items = $entry
								Else
									$items = $items & @CRLF & $entry
								EndIf
							EndIf
						Next
						FileWrite($viewfile, $items)
						$savfile = $palestine
						$savfile = StringReplace($savfile, "Palestinian Aid.tsv", "Palestinian Aid_saved.tsv")
					ElseIf $view = "Ukraine Assist" Then
						$ukraine = @ScriptDir & "\Ukraine Assist.tsv"
						$viewfile = $ukraine
						FileDelete($viewfile)
						$items = ""
						_FileReadToArray($itchfile, $entries, 1)
						For $c = 1 To $entries[0]
							$entry = $entries[$c]
							If StringInStr($entry, "Ukraine Assist") > 0 And (StringInStr($entry, "Palestinian Aid") < 1 And StringInStr($entry, "Racial Justice") < 1) Then
								If $items = "" Then
									$items = $entry
								Else
									$items = $items & @CRLF & $entry
								EndIf
							EndIf
						Next
						FileWrite($viewfile, $items)
						$savfile = $ukraine
						$savfile = StringReplace($savfile, "Ukraine Assist.tsv", "Ukraine Assist_saved.tsv")
					ElseIf $view = "Downloaded" Then
						$have = @ScriptDir & "\Downloaded.tsv"
						$viewfile = $have
						FileDelete($viewfile)
						$items = ""
						_FileReadToArray($itchfile, $entries, 1)
						For $c = 1 To $entries[0]
							$entry = $entries[$c]
							If StringRight($entry, 3) = "YES" > 0 Then
								If $items = "" Then
									$items = $entry
								Else
									$items = $items & @CRLF & $entry
								EndIf
							EndIf
						Next
						FileWrite($viewfile, $items)
						$savfile = $have
						$savfile = StringReplace($savfile, "Downloaded.tsv", "Downloaded_saved.tsv")
					EndIf
					_FileReadToArray($viewfile, $entries, 1, @TAB)
					SplashTextOn("", "Sorting!", 100, 80, Default, Default, 33)
					If $choice = "Titles" Then
						_ArraySort($entries, 0, 1, 0, 0)
					ElseIf $choice = "Racial Justice" Then
						_ArraySort($entries, 0, 1, 0, 1)
					ElseIf $choice = "Palestinian Aid" Then
						_ArraySort($entries, 0, 1, 0, 2)
					ElseIf $choice = "Ukraine Assist" Then
						_ArraySort($entries, 0, 1, 0, 3)
					EndIf
					If $save = 1 Then
						_FileWriteFromArray($savfile, $entries, 1, Default, @TAB)
					EndIf
				Else
					_FileReadToArray($itchfile, $entries, 1, @TAB)
					$savfile = $titfile
				EndIf
				SplashOff()
				If $other = 4 Then
					_ArrayDisplay($entries, "Itch Bundles", "", 0, @TAB, "Titles|Racial Justice|Palestinian Aid|Ukraine Assist|Have", 350, $COLOR_SKYBLUE)
					GUISetState(@SW_RESTORE, $GUI_main)
				ElseIf $other = 1 Then
					If $save = 4 And ($choice <> "none" Or $view <> "ALL") Then
						; Create a temp save file
						$tmpfile = @ScriptDir & "\Temp_saved.tsv"
						_FileWriteFromArray($tmpfile, $entries, 1, Default, @TAB)
						$savfile = $tmpfile
					EndIf
					ShellExecute($savfile)
				EndIf
			Case $Button_no
				; Remove the YES for selected game
				$title = GUICtrlRead($Combo_titles)
				If $title <> "" Then
					$status = GUICtrlRead($Input_down)
					If $status = "YES" Then
						$status = ""
						IniWrite($itchlist, $title, "downloaded", "na")
						IniDelete($downfile, $title)
						GUICtrlSetData($Input_down, $status)
						$racial = IniRead($itchlist, $title, "1", "na")
						$palestine = IniRead($itchlist, $title, "2", "na")
						$ukraine = IniRead($itchlist, $title, "3", "na")
						$entry = $title & @TAB & $racial & @TAB & $palestine & @TAB & $ukraine & @TAB & "YES"
						$change = $title & @TAB & $racial & @TAB & $palestine & @TAB & $ukraine & @TAB & "na"
						SplashTextOn("", "Updating!", 100, 80, Default, Default, 33)
						For $c = 1 To $array[0]
							$sect = $array[$c]
							If $sect = $entry Then
								MsgBox(262192, "Entry", "Found.", 1, $GUI_main)
								_ArrayDelete($array, $c)
								_ArrayInsert($array, $c, $change)
								_FileWriteFromArray($itchfile, $array, 1)
								ExitLoop
							EndIf
						Next
						SplashOff()
					EndIf
				EndIf
			Case $Button_info
				; Program Information
				MsgBox(262208, "Program Information - Bundle Compare", _
					"This program Extracts game titles from Itch.io bundle JSON file listings." & @LF & @LF & _
					"Initially an INI file is created (Itch Bundles.ini), and from that a TAB" & @LF & _
					"separated file is then created (Itch Bundles.tsv), and then other TAB" & @LF & _
					"separated files (Titles.tsv etc) are created for Sort and View options." & @LF & @LF & _
					"To open a TAB delimited file with another program, you may need to" & @LF & _
					"associate the 'tsv' extension with it (i.e. Microsoft Works Spreadsheet)." & @LF & @LF & _
					"The 'Bundles' input fields are clickable labels, that will take you to the" & @LF & _
					"unique bundle web page for the selected game. On first use of each," & @LF & _
					"you will be prompted to provide the download URL for that bundle." & @LF & @LF & _
					"© " & $created & " created by Timboli. " & $version & " update.", 0, $GUI_main)
			Case $Checkbox_view
				; View results with another (default) TAB program
				If GUICtrlRead($Checkbox_view) = $GUI_CHECKED Then
					$other = 1
				Else
					$other = 4
				EndIf
				IniWrite($inifile, "Another Program", "view", $other)
			Case $Checkbox_save
				; Save any sorted or limited results to file
				If GUICtrlRead($Checkbox_save) = $GUI_CHECKED Then
					$save = 1
				Else
					$save = 4
				EndIf
				IniWrite($inifile, "Sorted Or Limited", "save", $save)
			Case $Combo_titles
				; List of game titles
				$title = GUICtrlRead($Combo_titles)
				$racial = IniRead($itchlist, $title, "1", "na")
				GUICtrlSetData($Label_racial, $racial)
				$palestine = IniRead($itchlist, $title, "2", "na")
				GUICtrlSetData($Label_palestine, $palestine)
				$ukraine = IniRead($itchlist, $title, "3", "na")
				GUICtrlSetData($Label_ukraine, $ukraine)
				$status = IniRead($downfile, $title, "downloaded", "")
				GUICtrlSetData($Input_down, $status)
			Case $Label_ukraine
				; Go to bundle web page for game
				$bundle = GUICtrlRead($Label_ukraine)
				If $bundle = "Ukraine Assist" Then
					$title = GUICtrlRead($Combo_titles)
					If $title <> "" Then
						$url = IniRead($inifile, "Ukraine Assist", "base_url", "")
						If $url = "" Then
							$val = InputBox("Ukraine Assist Bundle", "Please provide your unique account web link to the Ukraine bundle page." _
								& @LF & @LF & "i.e. https://itch.io/bundle/download/....etc", "", "", 470, 160, Default, Default, 0, $GUI_main)
							If @error = 0 And StringLeft($val, 32) = "https://itch.io/bundle/download/" Then
								$url = $val
								IniWrite($inifile, "Ukraine Assist", "base_url", $url)
							Else
								MsgBox(262192, "Link Error", "URL must start with - https://itch.io/bundle/download/", 0, $GUI_main)
								ContinueLoop
							EndIf
						EndIf
						$game = StringReplace($title, "#", "%23")
						ShellExecute($url & "?search=" & $game)
					EndIf
				EndIf
			Case $Label_racial
				; Go to bundle web page for game
				$bundle = GUICtrlRead($Label_racial)
				If $bundle = "Racial Justice" Then
					$title = GUICtrlRead($Combo_titles)
					If $title <> "" Then
						$url = IniRead($inifile, "Racial Justice", "base_url", "")
						If $url = "" Then
							$val = InputBox("Racial Justice Bundle", "Please provide your unique account web link to the Racial Justice bundle page." _
								& @LF & @LF & "i.e. https://itch.io/bundle/download/....etc", "", "", 470, 160, Default, Default, 0, $GUI_main)
							If @error = 0 And StringLeft($val, 32) = "https://itch.io/bundle/download/" Then
								$url = $val
								IniWrite($inifile, "Racial Justice", "base_url", $url)
							Else
								MsgBox(262192, "Link Error", "URL must start with - https://itch.io/bundle/download/", 0, $GUI_main)
								ContinueLoop
							EndIf
						EndIf
						$game = StringReplace($title, "#", "%23")
						ShellExecute($url & "?search=" & $game)
					EndIf
				EndIf
			Case $Label_palestine
				; Go to bundle web page for game
				$bundle = GUICtrlRead($Label_palestine)
				If $bundle = "Palestinian Aid" Then
					$title = GUICtrlRead($Combo_titles)
					If $title <> "" Then
						$url = IniRead($inifile, "Palestinian Aid", "base_url", "")
						If $url = "" Then
							$val = InputBox("Palestinian Aid Bundle", "Please provide your unique account web link to the Palestinian Aid bundle page." _
								& @LF & @LF & "i.e. https://itch.io/bundle/download/....etc", "", "", 470, 160, Default, Default, 0, $GUI_main)
							If @error = 0 And StringLeft($val, 32) = "https://itch.io/bundle/download/" Then
								$url = $val
								IniWrite($inifile, "Palestinian Aid", "base_url", $url)
							Else
								MsgBox(262192, "Link Error", "URL must start with - https://itch.io/bundle/download/", 0, $GUI_main)
								ContinueLoop
							EndIf
						EndIf
						$game = StringReplace($title, "#", "%23")
						ShellExecute($url & "?search=" & $game)
					EndIf
				EndIf
			Case Else
				;
		EndSwitch
	Until False
EndFunc ;=> ViewerOptions

Func AddToThelist()
	$attrib = FileGetAttrib($path)
	If StringInStr($attrib, "D") < 1 Then
		_PathSplit($path, $drv, $dir, $fname, $fext)
		If $fext = ".json" Then
			$read = FileRead($path)
			If $read <> "" Then
				$split = StringSplit($read, '"title":"', 1)
				$cnt = $split[0]
				MsgBox(262192, "Games Count", $cnt - 1 & @LF & @LF & "(auto close)", 3)
				$games = IniRead($itchlist, "Games", "total", "")
				If $games = "" Then
					$games = 0
					IniWrite($itchlist, "Games", "total", $games)
				EndIf
				If FileExists($downfile) Then
					$check = 1
				Else
					$check = ""
				EndIf
				$titles = ""
				For $c = 2 To $cnt
					$sect = $split[$c]
					$title = StringSplit($sect, '","', 1)
					If $title[0] > 1 Then
						$title = $title[1]
						$title = StringReplace($title, "&amp;", "&")
						$title = StringReplace($title, "[", "(")
						$title = StringReplace($title, "]", ")")
						$title = StringReplace($title, "\/", "/")
						$title = StringReplace($title, "|", "/")
						;Dominique Pamplemousse
						$title = StringReplace($title, '\"', "'")
						;$title = StringReplace($title, '??', '')
						While StringLeft($title, 1) = "?"
							$title = StringTrimLeft($title, 1)
							$title = StringStripWS($title, 1)
						WEnd
						$title = StringSplit($title, '"', 1)
						$title = $title[1]
						$title = StringStripWS($title, 3)
						If $title <> "" Then
							IniWrite($itchlist, $title, "title", $title)
							$games = $games + 1
							;IniWrite($itchlist, $title, "count", $games)
							IniWrite($itchlist, "Games", "total", $games)
							If $fname = "520_games" Then
								$bundle = "Racial Justice"
								$num = 1
							ElseIf $fname = "902_games" Then
								$bundle = "Palestinian Aid"
								$num = 2
							ElseIf $fname = "1316_games" Then
								$bundle = "Ukraine Assist"
								$num = 3
							EndIf
							IniWrite($itchlist, $title, $num, $bundle)
							If $check = 1 Then
								$status = IniRead($downfile, $title, "downloaded", "na")
								IniWrite($itchlist, $title, "downloaded", $status)
							EndIf
						EndIf
						;?? Potato Thriller (Classic)	Racial Justice	na	na
						;If $titles = "" Then
						;	$titles = $title
						;Else
						;	$titles = $titles & " | " & $title
						;EndIf
					EndIf
				Next
				;MsgBox(262192, "Game Titles", "Found = " & $games & @LF & @LF & $titles, 0)
			EndIf
		Else
			MsgBox(262192, "Format Error", "File does not appear to be a json file.", 0)
		EndIf
	Else
		MsgBox(262192, "Usage Error", "Needs to be a json file not a folder.", 0)
	EndIf
EndFunc ;=> AddToThelist
