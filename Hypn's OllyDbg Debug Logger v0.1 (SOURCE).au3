;http://www.edgeofnowhere.cc/viewtopic.php?t=346148

Func _MemRead($i_hProcess, $i_lpBaseAddress, $i_nSize, $v_lpNumberOfBytesRead = '')
	Local $v_Struct = DllStructCreate ('byte[' & $i_nSize & ']')
	DllCall('kernel32.dll', 'int', 'ReadProcessMemory', 'int', $i_hProcess, 'int', $i_lpBaseAddress, 'int', DllStructGetPtr ($v_Struct, 1), 'int', $i_nSize, 'int', $v_lpNumberOfBytesRead)
	Local $v_Return = DllStructGetData ($v_Struct, 1)
	$v_Struct=0
	Return $v_Return
EndFunc ;==> _MemRead()

Func _MemWrite($i_hProcess, $i_lpBaseAddress, $v_Inject, $i_nSize, $v_lpNumberOfBytesRead = '')
	Local $v_Struct = DllStructCreate ('byte[' & $i_nSize & ']')
	DllStructSetData ($v_Struct, 1, $v_Inject)
	$i_Call = DllCall('kernel32.dll', 'int', 'WriteProcessMemory', 'int', $i_hProcess, 'int', $i_lpBaseAddress, 'int', DllStructGetPtr ($v_Struct, 1), 'int', $i_nSize, 'int', $v_lpNumberOfBytesRead)
	$v_Struct=0
	Return $i_Call[0]
EndFunc ;==> _MemWrite()

Func _MemOpen($i_dwDesiredAccess, $i_bInheritHandle, $i_dwProcessId)
	$ai_Handle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', $i_dwDesiredAccess, 'int', $i_bInheritHandle, 'int', $i_dwProcessId)
	If @error Then
		SetError(1)
		Return 0
	EndIf
	Return $ai_Handle[0]
EndFunc ;==> _MemOpen()

Func _MemClose($i_hProcess)
	$av_CloseHandle = DllCall('kernel32.dll', 'int', 'CloseHandle', 'int', $i_hProcess)
	Return $av_CloseHandle[0]
EndFunc ;==> _MemClose() 

Func ReadString($OpenProcess, $Address)
	$i = 0
	$end = false
	$string = ''
	Do
		$v_Read = _MemRead($OpenProcess, $Address, 1)
		$char = chr($v_Read)
		$i = $i + 1
		$Address = $Address + 1	
		If hex($v_Read, 8) == "00" Then
			$end = true
		Else
			$string = $string & $char
		EndIf
	until $end
	Return $string
EndFunc

Func ReadByte($OpenProcess, $Address)
	$v_Read = _MemRead($OpenProcess, $Address, 1)
	Return $v_Read
EndFunc





$loop = false
$just_started = true
$Process = 'OLLYDBG.EXE'
$line1_addr = 0x004CE860
$line2_addr = 0x004CE760
;$line3addr = 0x004CE660 ; not sure if we need these yet
;$line4addr = 0x004CE560 ; not sure if we need these yet
$running_addr = 0x004D56FC

$PID = ProcessExists($Process) ; get OllyDbg's process id
$OpenProcess = _MemOpen(0x38, False, $PID) ; open OllyDbg process
AutoItSetOption ("WinTitleMatchMode", "2") ; change option to make it easier to find OllyDbg window

$StopOn = InputBox ( "String to stop on?", "Please enter the string to stop looping on (be as specific as possible)")

If $StopOn > "" Then
	$loop = True
	$file = FileOpen ("log.txt", 2)
	While $loop
		$paused = ReadByte($OpenProcess, $running_addr)
		If $paused == "0x01" Then
			$string = ""
			
			; read both lines of text
			$line1 = ReadString($OpenProcess, $line1_addr)
			$line2 = ReadString($OpenProcess, $line2_addr)
			
			; get the text (might be both, or only 1 line of text)
			if $line2 > "" then
				if $line1 > "" then
					$string = $line1 & @CRLF & $line2
				Else
					$string = $line2
				EndIf
			EndIf
			
			; check if we've found our string match, and if so stop our loop, otherwise continue looping
			If (StringInStr($string, $StopOn) AND $just_started == false) Then
				$loop = False ; stop looping
			Else
				$just_started = false ; we can unset this, so our script will break when necessary
				;WinWaitActive ("OllyDbg") ; send F9 (continue) to OllyDbg
				;Send ("{F9}") ; tell OllyDbg to continue
				ControlSend ("OllyDbg", "", "ACPUASM1", "{F9}")
			EndIf
			
			If $just_started == false Then
				FileWrite($file, $string & @CRLF) ; write the text to "log.txt"
			EndIf
			sleep(100) ; put a little pause in
		Else
			sleep(1000) ; put a little pause in
		EndIf
	WEnd
	FileClose($file)
EndIf
