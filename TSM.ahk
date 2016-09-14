#InstallKeybdHook
#Persistent
#SingleInstance, Ignore
#NoTrayIcon

;--------------------------------------------------------------------------
; WO moderation
;--------------------------------------------------------------------------
IfExist, data.ini
	IniRead, last_path, data.ini, Data, last_path
else
{
	RegRead, last_path, HKEY_CURRENT_USER\SOFTWARE\Team17SoftwareLTD\WormsArmageddon, PATH
	last_path = %last_path%\WA.exe
}

	WIDTH := 300
	Gui, 1: New
	Gui, Font, s10, Verdana
	Gui, Add, Text,, Moderator name:
	Gui, Add, Edit, vM w%WIDTH%, MOD``
	Gui, Add, Text,, Tournament name:
	Gui, Add, Edit, vT w%WIDTH%
	Gui, Add, Text,, Signups time (in GMT):
	Gui, Add, DateTime, vDT Choose%A_NowUTC% w%WIDTH%, HH:mm
	Gui, Add, Text,, Link to tournament:
	Gui, Add, Edit, vL w%WIDTH%, http://wormolympics.com/
	Gui, Add, Text,, Link to tournament brackets:
	Gui, Add, Edit, vB w%WIDTH%,
	Gui, Add, Text,, Channel:
	Gui, Add, Edit, vC w%WIDTH%, `#RopersHeaven
	Gui, Add, Text, h1
	Gui, Add, Text, w640 h1 0x4
	Gui, Add, Text, y8 x348, At signups time:
	Gui, Add, Text, w%WIDTH% h1 0x4
	Gui, Add, Checkbox, vNotifyMsgBox, Notify by showing a message box
	Gui, Add, Checkbox, vOpenTourney, Open the tournament link
	Gui, Add, Checkbox, vOpenBrackets, Open the tournament brackets link
	Gui, Add, Checkbox, vRunExternal, Run external program: 
	Gui, Add, Edit, vExtPath w290, %last_path%
	Gui, Add, Button,, Browse
	Gui, Add, Text, w%WIDTH% h1 0x4
	Gui, Add, Button, Default w300 h40 x175, Ready
	Gui 1: Show, , Tournament signups manager
	
	WIDTH2 := 360
	Gui, 2: New
	Gui, Font, s8, Verdana
	Gui, Add, Text, w%WIDTH2%, List of players (0)
	Gui, Add, ListView, -LV0x10 -Multi -ReadOnly Grid AltSubmit r26 w%WIDTH2% vLoP gListOfPlayers, Nickname|Clan|Country|Host
	Gui, Add, Button, w%WIDTH2% h40, Export
	Gui, Add, Text, y8, Nickname:
	Gui, Add, Edit, vNick w%WIDTH2%
	Gui, Add, Text,, Clan:
	Gui, Add, Edit, vClan w%WIDTH2%
	Gui, Add, Text,, Country:
	Gui, Add, Edit, vCountry w%WIDTH2%
	Gui, Add, Text,, Hostability (* if can't host, blank otherwise):
	Gui, Add, Edit, vHost w%WIDTH2%
	Gui, Add, Button, Default w%WIDTH2% h40, Add
	Gui, Add, Text,, `t*Left click on a field to delete it.
	Gui, Add, Text, h4
	Gui, Font, s8, Verdana
	Gui, Add, Text,, Ctrl+F1: Post a welcome message.
	Gui, Add, Text,, Ctrl+F2: Post an invitation message.
	Gui, Add, Text,, Ctrl+F3: Post the list of players.
	Gui, Add, Text,, Ctrl+F4: Post a reminder to upload replays.
	Gui, Add, Text,, Ctrl+F5: Post a reminder to report wins to moderator.
	Gui, Add, Text,, Ctrl+F6: Post a link to tournament brackets.
	Gui, Add, Text,, Ctrl+F11: Post a "Signups are open" message.
	Gui, Add, Text,, Ctrl+F12: Post a "Signups are closed" message.
	Gui, Add, Text, w%WIDTH2% h1 0x4
	Gui, Add, Text,, `t*put a cursor into any input field before using
	
	LV_ModifyCol(1, 120)
	LV_ModifyCol(2, 45)
	LV_ModifyCol(3, 120)
	LV_ModifyCol(4, 45)
return

notify:
	diff := DT
	diff -= %A_NowUTC%, Seconds
	if (diff <= 0)
	{
		if (NotifyMsgBox = 1)
		{	
			MsgBox, 0x40, TSM, Signups time for %T% in %C%!
		}
		if (OpenTourney = 1)
		{
			Run, %L%
		}
		if (OpenBrackets = 1)
		{
			Run, %B%
		}
		if (RunExternal = 1)
		{
			if (ExtPath)
			{
				Run, %ExtPath%
			}
		}
		SetTimer, notify, Off
	}
return

ButtonBrowse:
	FileSelectFile, cur_path
	if !ErrorLevel
		GuiControl, 1:, ExtPath, %cur_path%
	IniWrite, %cur_path%, data.ini, Data, last_path
return

ButtonReady:
	
	Gui, 1: Submit
	Gui, 2: Show, , Tournament signups manager - %T% - %M% - %C%
	SetTimer, notify, 1000
	GuiControl, 2: Focus, Nick
	
return

2ButtonAdd:
	Gui, 2: Submit, NoHide
	LV_Add("", Nick, Clan, Country, Host)
	GuiControl,, Nick,
	GuiControl,, Clan,
	GuiControl,, Country,
	GuiControl,, Host,
	GuiControl, Focus, Nick
	
	list :=
	count := LV_GetCount()
	GuiControl,, Static1, List of players (%count%) 
	Loop % count
	{
		LV_GetText(nick, A_Index)
		LV_GetText(host, A_Index, 4)
		if (host = "*")
		{
			nick = %nick%*
		}
		list = %list% %nick%
		clipboard := list
	}
return

2ButtonExport:
	FileDelete, %T%.txt
	count := LV_GetCount()
	Loop % count
	{
		LV_GetText(nick, A_Index, 1)
		LV_GetText(clan, A_Index, 2)
		LV_GetText(country, A_Index, 3)
		LV_GetText(host, A_Index, 4)
		FileAppend, %nick%`t%clan%`t%country%`t%host%`r`n, %T%.txt
	}
	
return

ListOfPlayers:
	if A_GuiEvent = RightClick
	{
		LV_Delete(A_EventInfo)
		
		list :=
		count := LV_GetCount()
		GuiControl,, Static1, List of players (%count%) 
		Loop % count
		{
			LV_GetText(nick, A_Index)
			LV_GetText(host, A_Index, 4)
			if (host = "*")
			{
				nick = %nick%*
			}
			list = %list% %nick%
			clipboard := list
		}
	}
return

GuiClose:
2GuiClose:
	ExitApp
return

#IfWinNotActive, Tournament signups manager
^F1::
	SendInput, {Raw}/me ==== Welcome to Worm Olympics %T% tournament! To sign up, send a message to %M% your nickname, clan (or no clan), country and whether you can host. For more information about the tourney, visit %L%
	SendInput, {Enter}
return

^F2::
	SendInput, {Raw}/me ==== Worm Olympics %T% tournament starts now in %C%, join!
	SendInput, {Enter}
return

^F3::
	SendInput, {Raw}/me ==== List of players: %list% (%count%)
	SendInput, {Enter}
return

^F4::
	SendInput, {Raw}/me ==== Don't forget to upload your replays at http://wormolympics.com/upload, even if you lost. Not uploading replays is penalized.
	SendInput, {Enter}
return

^F5::
	SendInput, {Raw}/me ==== Don't forget to report wins to %M%
	SendInput, {Enter}
return

^F6::
	SendInput, {Raw}/me ==== Check the stage of the tournament at %B%
	SendInput, {Enter}
return

^F9::
	InputBox, results, Enter winners, Enter winners
	SendInput, {Raw}/me ==== Results
	SendInput, {Enter}
return

^F10::
	SendInput, {Raw}/me ==== Thank you for playing %T% tournament!
	SendInput, {Enter}
return

^F11::
	SendInput, {Raw}/me ==== Signups are open!
	SendInput, {Enter}
return

^F12::
	SendInput, {Raw}/me ==== Signups are closed!
	SendInput, {Enter}
return
