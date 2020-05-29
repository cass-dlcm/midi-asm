.686P; Pentium Pro or later
.MODEL flat, stdcall
.STACK 4096
.data
extern segmentNumOobErr:BYTE
extern measureNumOobErr:BYTE
extern timeOorErr:BYTE
extern pitchOorErr:BYTE
.code
Error proto

; ------------------------------------------------------------------------------ -
noteEvent proc uses ebx edx,
	time:byte, ; the delta time of the event
	event:byte, ; the type of note event
	pitch:byte; the pitch of the note
; stores a note event in the dword specified by EDI
; Returns: nothing
; ------------------------------------------------------------------------------ -
	mov bh, time
	cmp bh, 80h; check that the time is valid
	jb continue0; jump if time is valid
	mov edx, OFFSET timeOorErr; pass type of error
	mov ecx, sizeof timeOorErr
	call Error; call time error if invalid
continue0 :
	mov dl, pitch
	cmp dl, 80h; check that the pitch is valid
	jb continue1; jump if pitch is valid
	mov edx, OFFSET pitchOorErr; pass type of error
	mov ecx, sizeof pitchOorErr
	call Error; call pitch error if invalid
continue1:
	mov dh, event
	mov[edi], bh; delta time
	mov[edi + 1], dh; note event
	mov[edi + 2], dl; pitch in dl register
	mov[edi + 3], BYTE PTR 40h; velocity of 64 (medium)
	add edi, 4
	ret
noteEvent endp

acousticBassDrumOff proc,
	time:byte
	invoke noteEvent, time, 89h, 35
	ret
acousticBassDrumOff endp

acousticBassDrumOn proc
	invoke noteEvent, 0, 99h, 35
	ret
acousticBassDrumOn endp

acousticSnareOff proc,
	time:byte
	invoke noteEvent, time, 89h, 38
	ret
acousticSnareOff endp

acousticSnareOn proc
	invoke noteEvent, 0, 99h, 38
	ret
acousticSnareOn endp

highMidTomOff proc,
	time:byte
	invoke noteEvent, time, 89h, 48
	ret
highMidTomOff endp

highMidTomOn proc
	invoke noteEvent, 0, 99h, 48
	ret
highMidTomOn endp
end