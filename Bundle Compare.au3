#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Timboli (aka TheSaint)

 Script Function:  Extract game titles from Itch.io bundle JSON file listings
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; FUNCTIONS
; ReadTheBundleFile()

#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <ColorConstants.au3>
#include <Misc.au3>
#include <File.au3>
#include <String.au3>
#include <Array.au3>

_Singleton("bundle-compare-thsaint")

Global $ans, $attrib, $bundle, $c, $check, $cnt, $created, $dir, $downfile, $drv, $entries, $entry, $fext, $fname, $games
Global $GUI_main, $inifile, $itchfile, $itchlist, $num, $palestine, $path, $racial, $read, $sect, $sects, $split, $status
Global $titfile, $title, $titles, $ukraine, $updated, $version

Global $520, $902, $1316

$downfile = @ScriptDir & "\Downloaded.ini"
$inifile = @ScriptDir & "\Settings.ini"
$itchfile = @ScriptDir & "\Itch Bundles.tsv"
$itchlist = @ScriptDir & "\Itch Bundles.ini"
$titfile = @ScriptDir & "\Titles.tsv"

$created = "March 2022"
$updated = "July 2022"
$version = "v1.5"

$racial = @ScriptDir & "\520_games.json"
$520 = $racial
$palestine = @ScriptDir & "\902_games.json"
$902 = $palestine
$ukraine = @ScriptDir & "\1316_games.json"
$1316 = $ukraine

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
	Local $Button_cover, $Button_exit, $Button_fold, $Button_info, $Button_no, $Button_view, $Button_web, $Button_yes, $Checkbox_save
	Local $Checkbox_view, $Combo_limit, $Combo_sort, $Combo_titles, $Group_bundles, $Group_down, $Group_limit, $Group_sort, $Group_titles
	Local $Input_down, $Label_palestine, $Label_racial, $Label_ukraine
	Local $array, $change, $choice, $choices, $cover, $detail, $game, $items, $other, $platforms, $save, $savfile, $tmpfile, $url, $val
	Local $view, $viewfile, $views
	;
	; Script generated by GUIBuilder Prototype 0.9
	Const $style = BitOR($WS_OVERLAPPED, $WS_CAPTION, $WS_SYSMENU, $WS_VISIBLE, $WS_CLIPSIBLINGS, $WS_MINIMIZEBOX)
	$GUI_main = GuiCreate("View Options - Bundle Compare", 480, 220, -1, -1, $style, $WS_EX_TOPMOST)
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
	$Button_view = GuiCtrlCreateButton("VIEW", 330, 15, 60, 50)
	GUICtrlSetFont($Button_view, 9, 600)
	GUICtrlSetTip($Button_view, "View using the Sort and Limit options!")
	;
	$Button_detail = GuiCtrlCreateButton("GAME" & @LF & "DETAIL", 400, 15, 70, 50, $BS_MULTILINE)
	GUICtrlSetFont($Button_detail, 7, 600, 0 , "Small Fonts")
	GUICtrlSetTip($Button_detail, "Detail about the game!")
	;
	$Checkbox_save = GUICtrlCreateCheckbox("Save sorted or limited results to file", 10, 72, 180, 20)
	GUICtrlSetTip($Checkbox_save, "Save any sorted or limited results to file!")
	;
	$Checkbox_view = GUICtrlCreateCheckbox("View with another TAB program", 200, 72, 170, 20)
	GUICtrlSetTip($Checkbox_view, "View results with another (default) TAB program!")
	;
	$Button_fold = GuiCtrlCreateButton("", 375, 72, 25, 24, $BS_ICON)
	GUICtrlSetTip($Button_fold, "Open the program folder!")
	;
	$Button_cover = GuiCtrlCreateButton("COVER", 410, 72, 60, 24)
	GUICtrlSetFont($Button_cover, 7, 600, 0 , "Small Fonts")
	GUICtrlSetTip($Button_cover, "Download the cover image for the game!")
	;
	$Group_titles = GuiCtrlCreateGroup("Titles", 10, 100, 460, 55)
	$Combo_titles = GuiCtrlCreateCombo("", 20, 120, 390, 21, $GUI_SS_DEFAULT_COMBO + $CBS_SORT)
	GUICtrlSetTip($Combo_titles, "List of game titles!")
	$Button_web = GuiCtrlCreateButton("WEB", 415, 120, 45, 21)
	GUICtrlSetFont($Button_web, 7, 600, 0 , "Small Fonts")
	GUICtrlSetTip($Button_web, "Go to the web page for the game!")
	;
	$Group_bundles = GuiCtrlCreateGroup("Bundles && Clickable Labels (web page links)", 10, 160, 270, 52)
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
	$Button_exit = GuiCtrlCreateButton("EXIT", 410, 165, 60, 47)
	GUICtrlSetFont($Button_exit, 9, 600)
	GUICtrlSetTip($Button_exit, "Close, Quit, Exit the program!")
	;
	; SETTINGS
	GUICtrlSetImage($Button_fold, @SystemDir & "\shell32.dll", -4, 0)
	;
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
			Case $GUI_EVENT_CLOSE, $Button_exit
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
			Case $Button_web
				; Go to the web page for the game
				$title = GUICtrlRead($Combo_titles)
				If $title <> "" Then
					ReadTheBundleFile()
					If $read <> "" Then
						$url = StringSplit($read, '"title":"' & $title & '",', 1)
						If $url[0] > 1 Then
							$url = $url[1]
							$url = StringSplit($url, '"title":', 1)
							If $url[0] > 1 Then
								$url = $url[$url[0]]
							Else
								$url = $url[1]
							EndIf
							$url = StringSplit($url, ',"url":"', 1)
							If $url[0] > 1 Then
								$url = $url[2]
								$url = StringSplit($url, '",', 1)
								$url = $url[1]
								$url = StringReplace($url, "\/", "/")
								If StringLeft($url, 6) <> "https:" Then
									$url = ""
									MsgBox(262192, "Extraction Issue", "Game web page URL could not be discovered!", 2, $GUI_main)
								Else
									ShellExecute($url)
								EndIf
								;MsgBox(262208, "Game Web Page", "URL = " & $url, 0, $GUI_main)
							Else
								MsgBox(262192, "Read Error", "Game web page URL could not be found!", 2, $GUI_main)
							EndIf
						Else
							MsgBox(262192, "Read Error", "Game title could not be found!", 2, $GUI_main)
						EndIf
					EndIf
				Else
					MsgBox(262192, "Process Error", "No game is selected!", 0, $GUI_main)
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
					"© " & $created & " created by Timboli.  (" & $version & " update " & $updated & ")", 0, $GUI_main)
			Case $Button_fold
				; Open the program folder
				ShellExecute(@ScriptDir)
			Case $Button_detail
				; Detail about the game
				$title = GUICtrlRead($Combo_titles)
				If $title <> "" Then
					ReadTheBundleFile()
					If $read <> "" Then
						$detail = StringSplit($read, '"title":"' & $title & '",', 1)
						If $detail[0] > 1 Then
							$platforms = $detail[1]
							$detail = $detail[2]
							$detail = StringSplit($detail, '"title":', 1)
							$detail = $detail[1]
							$detail = StringSplit($detail, '"short_text":"', 1)
							If $detail[0] > 1 Then
								$detail = $detail[2]
								$detail = StringSplit($detail, '","', 1)
								$detail = $detail[1]
								$detail = $detail & "."
								$detail = StringReplace($detail, "..", ".")
								$platforms = StringSplit($platforms, '"title":', 1)
								If $platforms[0] > 1 Then
									$platforms = $platforms[$platforms[0]]
								Else
									$platforms = $platforms[1]
								EndIf
								;MsgBox(262192, "$platforms 0", $platforms, 0, $GUI_main)
								$platforms = StringSplit($platforms, '"platforms":', 1)
								If $platforms[0] > 1 Then
									$platforms = $platforms[2]
									;MsgBox(262192, "$platforms", $platforms, 0, $GUI_main)
									$platforms = StringSplit($platforms, ',"user":', 1)
									$platforms = $platforms[1]
									;MsgBox(262192, "$platforms 2", $platforms, 0, $GUI_main)
									$platforms = StringSplit($platforms, ']', 1)
									$platforms = $platforms[1]
									;MsgBox(262192, "$platforms 3", $platforms, 0, $GUI_main)
									$platforms = StringReplace($platforms, "[", "")
									$platforms = StringReplace($platforms, "]", "")
									$platforms = StringReplace($platforms, ",", ", ")
									$platforms = StringReplace($platforms, '"', '')
								Else
									$platforms = "none found"
								EndIf
								MsgBox(262208, "Game Detail", "Title = " & $title & @LF & @LF & $detail & @LF & @LF & "Platforms = " & $platforms, 0, $GUI_main)
							Else
								MsgBox(262192, "Read Error", "Game blurb could not be found!", 2, $GUI_main)
							EndIf
						Else
							MsgBox(262192, "Read Error", "Game title could not be found!", 2, $GUI_main)
						EndIf
					EndIf
				Else
					MsgBox(262192, "Process Error", "No game is selected!", 2, $GUI_main)
				EndIf
			Case $Button_cover
				; Download the cover image for the game
				$title = GUICtrlRead($Combo_titles)
				If $title <> "" Then
					ReadTheBundleFile()
					If $read <> "" Then
						$cover = StringSplit($read, '"title":"' & $title & '",', 1)
						If $cover[0] > 1 Then
							$cover = $cover[2]
							$cover = StringSplit($cover, '"title":', 1)
							$cover = $cover[1]
							$cover = StringSplit($cover, '"cover":"', 1)
							If $cover[0] > 1 Then
								$cover = $cover[2]
								$cover = StringSplit($cover, '",', 1)
								$cover = $cover[1]
								$cover = StringReplace($cover, "\/", "/")
								If StringLeft($cover, 6) <> "https:" Then
									$cover = ""
									MsgBox(262192, "Extraction Issue", "Game cover image URL could not be discovered!", 2, $GUI_main)
								Else
									ShellExecute($cover)
								EndIf
								;MsgBox(262208, "Cover Image", "URL = " & $cover, 0, $GUI_main)
							Else
								MsgBox(262192, "Read Error", "Cover URL could not be found!", 2, $GUI_main)
							EndIf
						Else
							MsgBox(262192, "Read Error", "Game title could not be found!", 2, $GUI_main)
						EndIf
					EndIf
				Else
					MsgBox(262192, "Process Error", "No game is selected!", 0, $GUI_main)
				EndIf
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
				If $title = "" Then
					$racial = ""
					$palestine = ""
					$ukraine = ""
					GUICtrlSetBkColor($Label_racial, $CLR_DEFAULT)
					GUICtrlSetBkColor($Label_palestine, $CLR_DEFAULT)
					GUICtrlSetBkColor($Label_ukraine, $CLR_DEFAULT)
				Else
					$racial = IniRead($itchlist, $title, "1", "na")
					If $racial = "na" Then
						GUICtrlSetBkColor($Label_racial, $COLOR_RED)
					Else
						GUICtrlSetBkColor($Label_racial, $COLOR_LIME)
					EndIf
					$palestine = IniRead($itchlist, $title, "2", "na")
					If $palestine = "na" Then
						GUICtrlSetBkColor($Label_palestine, $COLOR_RED)
					Else
						GUICtrlSetBkColor($Label_palestine, $COLOR_LIME)
					EndIf
					$ukraine = IniRead($itchlist, $title, "3", "na")
					If $ukraine = "na" Then
						GUICtrlSetBkColor($Label_ukraine, $COLOR_RED)
					Else
						GUICtrlSetBkColor($Label_ukraine, $COLOR_LIME)
					EndIf
				EndIf
				GUICtrlSetData($Label_racial, $racial)
				GUICtrlSetData($Label_palestine, $palestine)
				GUICtrlSetData($Label_ukraine, $ukraine)
				$status = IniRead($downfile, $title, "downloaded", "")
				If $status = "YES" Then
					GUICtrlSetBkColor($Input_down, $COLOR_YELLOW)
				Else
					GUICtrlSetBkColor($Input_down, $CLR_DEFAULT)
				EndIf
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

Func ReadTheBundleFile()
	$racial = IniRead($itchlist, $title, "1", "na")
	If $racial = "na" Then
		$palestine = IniRead($itchlist, $title, "2", "na")
		If $palestine = "na" Then
			$ukraine = IniRead($itchlist, $title, "3", "na")
			If $ukraine = "na" Then
				MsgBox(262192, "Retrieve Error", "Game not found in any bundle!", 2, $GUI_main)
			Else
				$read = FileRead($1316)
				If $read = "" Then
					MsgBox(262192, "Read Error", "Ukraine Assist Bundle could not be read!", 2, $GUI_main)
				EndIf
			EndIf
		Else
			$read = FileRead($902)
			If $read = "" Then
				MsgBox(262192, "Read Error", "Palestinian Aid Bundle could not be read!", 2, $GUI_main)
			EndIf
		EndIf
	Else
		$read = FileRead($520)
		If $read = "" Then
			MsgBox(262192, "Read Error", "Racial Justice Bundle could not be read!", 2, $GUI_main)
		EndIf
	EndIf
EndFunc ;=> ReadTheBundleFile
