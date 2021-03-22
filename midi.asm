.686P; Pentium Pro or later
.MODEL flat, stdcall
.STACK 4096
.data
extern segmentNumOobErr:BYTE
extern measureNumOobErr:BYTE
extern velocityOorErr:BYTE
extern pitchOorErr:BYTE
.code
Error proto

; ------------------------------------------------------------------------------ -
noteEvent proc uses ebx edx,
	time:byte, ; the delta time of the event
	event:byte, ; the type of note event
	pitch:byte, ; the pitch of the note
	velocity:byte; the loudness of the note
; stores a note event in the dword specified by EDI
; Returns: nothing
; ------------------------------------------------------------------------------ -
	mov bh, time
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
	mov[edi], bh; delta time
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