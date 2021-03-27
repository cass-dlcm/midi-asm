.686P; Pentium Pro or later
.MODEL flat, stdcall
.STACK 4096
.data
extern segmentNumOobErr:BYTE
extern measureNumOobErr:BYTE
extern velocityOorErr:BYTE
extern pitchOorErr:BYTE
extern errorMsg:BYTE
extern errorMsgLen:DWORD
timeVLQ DWORD 0
timeVLQLen byte 0

.code
Error proto

ConsoleWriteHex proto,
	num:DWORD

toVLQ proc uses edx,
	outVal : DWORD,
	value : DWORD
	mov edx, value
	cmp edx, 1FFFFFh
	ja fourBytes
	mov edx, value
	cmp edx, 3FFFh
	ja threeBytes
	mov edx, value
	cmp edx, 7Fh
	ja twoBytes
	mov edx, value
	xor eax, eax
	mov al, dl
	shl eax, 24
	mov outVal, eax
	mov eax, 1
	ret
twoBytes :
	xor eax, eax
	mov edx, value
	shl edx, 1
	or edx, 8000h
	mov al, dh
	shl eax, 8
	mov edx, value
	and edx, 7fh
	mov al, dl
	shl eax, 16
	mov outVal, eax
	mov eax, 2
	ret
threeBytes :
	xor eax, eax
	mov edx, value
	shr edx, 6
	or edx, 8000h
	mov al, dh
	shl eax, 8
	mov edx, value
	shl edx, 1
	or edx, 8000h
	mov al, dh
	shl eax, 8
	mov edx, value
	and edx, 7fh
	mov al, dl
	shl eax, 8
	mov outVal, eax
	mov eax, 3
	ret
fourBytes :
	xor eax, eax
	mov edx, value
	shr edx, 13
	or edx, 8000h
	mov al, dh
	shl eax, 8
	mov edx, value
	shr edx, 6
	or edx, 8000h
	mov al, dh
	shl eax, 8
	mov edx, value
	shl edx, 1
	or edx, 8000h
	mov al, dh
	shl eax, 8
	mov edx, value
	and edx, 7fh
	mov al, dl
	mov outVal, eax
	mov eax, 4
	ret
toVLQ endp


; ------------------------------------------------------------------------------ -
noteEvent proc uses eax ebx edx,
	time:dword, ; the delta time of the event
	event:byte, ; the type of note event
	pitch:byte, ; the pitch of the note
	velocity:byte; the loudness of the note
; stores a note event in the dword specified by EDI
; Returns: nothing
; ------------------------------------------------------------------------------ -
	invoke toVLQ, timeVLQ, time
	mov timeVLQLen, al
	mov bl, velocity
	cmp bl, 80h; check that the velocity is valid
	jb continue0; jump if velocity is valid
	mov edx, OFFSET velocityOorErr; pass type of error
	mov ecx, sizeof velocityOorErr
	call Error; call time error if invalid
continue0:
	mov dl, pitch
	cmp dl, 80h; check that the pitch is valid
	jb continue1; jump if pitch is valid
	mov edx, OFFSET pitchOorErr; pass type of error
	mov ecx, sizeof pitchOorErr
	call Error; call pitch error if invalid
continue1:
	mov dh, event
	mov eax, [timeVLQ]
	mov [edi], eax
	xor eax, eax
	mov al, timeVLQLen
	add edi, eax
	mov[edi + 1], dh; note event
	mov[edi + 2], dl; pitch in dl register
	mov[edi + 3], BYTE PTR 40h; velocity of 64 (medium)
	add edi, 4
	ret
noteEvent endp

acousticBassDrumOff proc,
	time:byte
	invoke noteEvent, time, 89h, 35, 40h
	ret
acousticBassDrumOff endp

acousticBassDrumOn proc
	invoke noteEvent, 0, 99h, 35, 40h
	ret
acousticBassDrumOn endp

acousticSnareOff proc,
	time:byte
	invoke noteEvent, time, 89h, 38, 40h
	ret
acousticSnareOff endp

acousticSnareOn proc
	invoke noteEvent, 0, 99h, 38, 40h
	ret
acousticSnareOn endp

bassDrum1Off proc,
	time:byte
	invoke noteEvent, time, 89h, 24h, 40h
	ret
bassDrum1Off endp

bassDrum1On proc
	invoke noteEvent, 0, 99h, 24h, 40h
	ret
bassDrum1On endp

clavesOff proc,
	time:byte
	invoke noteEvent, time, 89h, 4bh, 40h
	ret
clavesOff endp

clavesOn proc,
	time:byte
	invoke noteEvent, time, 99h, 4bh, 40h
	ret
clavesOn endp

closedHiHatOff proc,
	time:byte
	invoke noteEvent, time, 89h, 2ah, 40h
	ret
closedHiHatOff endp

closedHiHatOn proc
	invoke noteEvent, 0, 99h, 2ah, 40h
	ret
closedHiHatOn endp

highMidTomOff proc,
	time:byte
	invoke noteEvent, time, 89h, 48, 40h
	ret
highMidTomOff endp

highMidTomOn proc
	invoke noteEvent, 0, 99h, 48, 40h
	ret
highMidTomOn endp
end