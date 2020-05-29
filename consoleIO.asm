.686P; Pentium Pro or later
.MODEL flat, stdcall
.STACK 4096
.data
externdef fileNamePrompt:BYTE
externdef fileNamePromptLen:DWORD
externdef tempoPrompt:BYTE
externdef tempoPromptLen:DWORD
externdef minTempoPrompt:BYTE
externdef minTempoPromptLen:DWORD
externdef maxTempoPrompt:BYTE
externdef maxTempoPromptLen:DWORD
externdef outTempoPrompt:BYTE
externdef outTempoPromptLen:DWORD
externdef measurePrompt:BYTE
externdef measurePromptLen:DWORD
externdef minMeasurePrompt:BYTE
externdef minMeasurePromptLen:DWORD
externdef maxMeasurePrompt:BYTE
externdef maxMeasurePromptLen:DWORD
externdef outMeasurePrompt:BYTE
externdef outMeasurePromptLen:DWORD
externdef errorMsg:BYTE
externdef segmentNumOobErr:BYTE
externdef measureNumOobErr:BYTE
externdef timeOorErr:BYTE
externdef pitchOorErr:BYTE
externdef invalidRange:BYTE
externdef testStr:BYTE
externdef crLfStr:BYTE
externdef consoleOutHandle:DWORD
externdef consoleInHandle:DWORD
externdef bytesRead:DWORD
externdef numStr:BYTE

invalidInputMsg BYTE "You have put in an invalid input. Please try again."; if user entered something that was wrong
fileNamePrompt BYTE "Enter the filename: "; prompts user for file name
fileNamePromptLen DWORD $-fileNamePrompt
tempoPrompt BYTE "Please enter a tempo range. To set a specific tempo, type it in for both the min and the max."; explains prompted input for user
tempoPromptLen DWORD $-tempoPrompt
minTempoPrompt BYTE "Enter the minimum tempo: "; prompts for min bpm
minTempoPromptLen DWORD $-minTempoPrompt
maxTempoPrompt BYTE "Enter the maximum tempo: "; prompts for max bpm
maxTempoPromptLen DWORD $-maxTempoPrompt
outTempoPrompt BYTE "The generated tempo is: "; tells user the limited rng bpm
outTempoPromptLen DWORD $-outTempoPrompt
measurePrompt BYTE "Please enter a measure range. To set a specific number of measures, type it in for both the min and the max."; explains to user what next prompts are for
measurePromptLen DWORD $-measurePrompt
minMeasurePrompt BYTE "Enter the minimum number of measures: "; prompts for min wanted measures
minMeasurePromptLen DWORD $-minMeasurePrompt
maxMeasurePrompt BYTE "Enter the maximum number of measures: "; prompts for max wanted measuers
maxMeasurePromptLen DWORD $-maxMeasurePrompt
outMeasurePrompt BYTE "The generated number of measures is: "; outputs the limited rng measure generated
outMeasurePromptLen DWORD $-outMeasurePrompt
errorMsg BYTE "An error has occured. Terminating."; error message produced if something goes wrong
segmentNumOobErr BYTE "The segment number (in ESI) is out of bounds!"; tells if user segment is out of bounds
measureNumOobErr BYTE "The message number (in BL) is out of bounds!"; tells if user message is out of bounds
timeOorErr BYTE "The time (in BH) is too high!"; tells if inputted time is out of bounds
pitchOorErr BYTE "The pitch (in DL) is too high!"; tells if user pitch is too high
invalidRange BYTE "The range you specified is invalid!"
testStr BYTE "test"
crLfStr BYTE 0dh, 0ah

bytesWritten dd ?
bytesRead dd ?
consoleOutHandle DWORD ?
consoleInHandle DWORD ?

STD_OUTPUT_HANDLE DWORD -11
STD_INPUT_HANDLE DWORD -10

numStr BYTE 8 DUP(0), "h"

.code
GetStdHandle PROTO,
	nStdHandle : DWORD

ReadConsoleA PROTO,
	hConsoleInput : DWORD,
	lpBuffer : DWORD,
	nNumberOfCharsToRead : DWORD,
	lpNumberOfCharsRead : DWORD,
	pInputControl : DWORD

SetConsoleCP PROTO,
	wCodePageID:DWORD

WriteConsoleA PROTO,
	hConsoleOutput:DWORD,
	lpBuffer : DWORD,
	nNumberOfCharsToWrite : DWORD,
	lpNumberOfCharsWritten : DWORD,
	lpReserved : DWORD

; ------------------------------------------------------------------------------
ConsoleWriteHex PROC USES EAX ECX EDX,
	num:DWORD
; ------------------------------------------------------------------------------
	mov ecx, 7
	mov edx, num
	mov eax, edx
convertLoop:
	and eax, 0fh
	cmp eax, 0ah
	jae letter
	add eax, 30h
	jmp store
letter:
	add eax, 37h
store:
	mov numStr[ecx], al
	shr edx, 4
	mov eax, edx
	cmp ecx, 0
	je write
	dec ecx
	jmp convertLoop
write:
	invoke WriteConsoleA, consoleOutHandle, offset numStr, 9, offset bytesWritten, 0
	mov ecx, 7
resetLoop:
	mov numStr[ecx], 0
	cmp ecx, 0
	je done
	dec ecx
	jmp resetLoop
done:
	ret
ConsoleWriteHex ENDP

; ------------------------------------------------------------------------------ -
hexStrToNum PROC USES EBX ECX EDX,
    value:DWORD,
; ------------------------------------------------------------------------------ -
    xor eax, eax
    xor ecx, ecx
check_hexit:
	mov edx, value
	add edx, ecx
	cmp BYTE PTR[edx], "0"
	jb finish
	cmp BYTE PTR[edx], "9"
	jbe add_digit_to_num
	cmp BYTE PTR[edx], "f"
	ja finish
	cmp BYTE PTR[edx], "a"
	jae add_lower_hexit_to_num
	cmp BYTE PTR[edx], "F"
	ja finish
	cmp BYTE PTR[edx], "A"
	jae add_upper_hexit_to_num
	jmp finish
add_digit_to_num:
	shl eax, 4
	movzx ebx, BYTE PTR[edx]
	sub ebx, DWORD PTR 30h
	add eax, ebx
	inc ecx
	jmp check_hexit
add_upper_hexit_to_num:
	shl eax, 4
	movzx ebx, BYTE PTR[edx]
	sub ebx, DWORD PTR 37h
	add eax, ebx
	inc ecx
	jmp check_hexit
add_lower_hexit_to_num:
	shl eax, 4
	movzx ebx, BYTE PTR[edx]
	sub ebx, DWORD PTR 57h
	add eax, ebx
	inc ecx
	jmp check_hexit
finish:
	ret
hexStrToNum ENDP

initIO proc uses eax
	invoke SetConsoleCP, 65001
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov[consoleOutHandle], eax
	invoke GetStdHandle, STD_INPUT_HANDLE
	mov[consoleInHandle], eax
	ret
initIO endp

readConsole PROC,
	readLoc:DWORD,
	readAmount:DWORD
	INVOKE ReadConsoleA, consoleInHandle, readLoc, readAmount, OFFSET bytesRead, 0
	ret
readConsole ENDP

writeConsole PROC,
	prompt:DWORD,
	promptSize:DWORD
	invoke WriteConsoleA, consoleOutHandle, prompt, promptSize, offset bytesWritten, 0
	ret
writeConsole ENDP
END