.686P
.model flat, stdcall
.stack 4096
.data
externdef drumOffset:dword

extern track3Chunk:dword

drumOffset dword 0bh

.code
noteEvent proto,
    time:byte,
    event:byte,
    pitch:byte

randRange proto,
    upperBound:byte

acousticBassDrumOff proto,
    time:byte
acousticBassDrumOn proto
acousticSnareOff proto,
    time : byte
acousticSnareOn proto
highMidTomOff proto,
    time : byte
highMidTomOn proto

drum0 PROTO
drum1 PROTO
drum2 PROTO

drum3 PROTO

drum4 PROTO
drum5 PROTO
drum6 PROTO


drum7 PROTO


drum8 PROTO
drum9 PROTO
drumA PROTO

drumB PROTO

drumC PROTO
drumD PROTO
drumE PROTO



drumF PROTO



drum10 PROTO
drum11 PROTO
drum12 PROTO

drum13 PROTO

drum14 PROTO
drum15 PROTO
drum16 PROTO


drum17 PROTO


drum18 PROTO
drum19 PROTO
drum1A PROTO

drum1B PROTO

drum1C PROTO
drum1D PROTO
drum1E PROTO




drum1F PROTO




drum20 PROTO
drum21 PROTO
drum22 PROTO

drum23 PROTO

drum24 PROTO
drum25 PROTO
drum26 PROTO


drum27 PROTO


drum28 PROTO
drum29 PROTO
drum2A PROTO

drum2B PROTO

drum2C PROTO
drum2D PROTO
drum2E PROTO



drum2F PROTO



drum30 PROTO
drum31 PROTO
drum32 PROTO

drum33 PROTO

drum34 PROTO
drum35 PROTO
drum36 PROTO


drum37 PROTO


drum38 PROTO
drum39 PROTO
drum3A PROTO

drum3B PROTO

drum3C PROTO
drum3D PROTO
drum3E PROTO

drumChoose proc uses eax
mov eax, 3eh
invoke randRange, al
; root of the decision tree
cmp eax, 1fh
jb below1F
je drumCall1F
ja above1F

; branch B
below1F:
cmp eax, 0fh
jb belowF
je drumCallF
ja aboveF

; branch A
above1F:
cmp eax, 2fh
jb below2F
je drumCall2F
ja above2F

; branch B->B
belowF:
cmp eax, 7
jb below7
je drumCall7
ja above7

; branch B->A
aboveF:
cmp eax, 17h
jb below17
je drumCall17
ja above17

; branch A->B
below2F:
cmp eax, 27h
jb below27
je drumCall27
ja above27

; branch A->A
above2F:
cmp eax, 37h
jb below37
je drumCall37
ja above37

; branch B->B->B
below7:
cmp eax, 3
jb below3
je drumCall3
ja above3

; branch B->B->A
above7:
cmp eax, 0bh
jb belowB
je drumCallB
ja aboveB

; branch B->A->B
below17:
cmp eax, 13h
jb below13
je drumCall13
ja above13

; branch B->A->A
above17:
cmp eax, 1Bh
jb below1B
je drumCall1B
ja above1B

; branch A->B->B
below27:
cmp eax, 23h
jb below23
je drumCall23
ja above23

; branch A->B->A
above27:
cmp eax, 2Bh
jb below2B
je drumCall2B
ja above2B

; branch A->A->B
below37:
cmp eax, 33h
jb below33
je drumCall33
ja above33

; branch A->A->A
above37:
cmp eax, 3Bh
jb below3B
je drumCall3B
ja above3B

; branch B->B->B->B
below3:
cmp eax, 1
jb drumCall0
je drumCall1
ja drumCall2

; branch B->B->B->A
above3:
cmp eax, 5
jb drumCall4
je drumCall5
ja drumCall6

; branch B->B->A->B
belowB:
cmp eax, 9
jb drumCall8
je drumCall9
ja drumCallA

; branch B->B->A->A
aboveB:
cmp eax, 0dh
jb drumCallC
je drumCallD
ja drumCallE

; branch B->A->B->B
below13:
cmp eax, 11h
jb drumCall10
je drumCall11
ja drumCall12

; branch B->A->B->A
above13:
cmp eax, 15h
jb drumCall14
je drumCall15
ja drumCall16

; branch B->A->A->B
below1B:
cmp eax, 19h
jb drumCall18
je drumCall19
ja drumCall1A

; branch B->A->A->A
above1B:
cmp eax, 1dh
jb drumCall1C
je drumCall1D
ja drumCall1E

; branch A->B->B->B
below23:
cmp eax, 21h
jb drumCall20
je drumCall21
ja drumCall22

; branch A->B->B->A
above23:
cmp eax, 25h
jb drumCall24
je drumCall25
ja drumCall26

; branch A->B->A->B
below2B:
cmp eax, 29h
jb drumCall28
je drumCall29
ja drumCall2A

; branch A->B->A->A
above2B:
cmp eax, 2dh
jb drumCall2C
je drumCall2D
ja drumCall2E

; branch A->B->B->B
below33:
cmp eax, 31h
jb drumCall30
je drumCall31
ja drumCall32

; branch A->B->B->A
above33:
cmp eax, 35h
jb drumCall34
je drumCall35
ja drumCall36

; branch A->B->A->B
below3B:
cmp eax, 39h
jb drumCall38
je drumCall39
ja drumCall3A

; branch B->B->A->A
above3B:
cmp eax, 3dh
jb drumCall3C
je drumCall3D
ja drumCall3E

; the calls themselves
drumCall0:
call drum0
ret
drumCall1:
call drum1
ret
drumCall2:
call drum2
ret
drumCall3:
call drum3
ret
drumCall4:
call drum4
ret
drumCall5:
call drum5
ret
drumCall6:
call drum6
ret
drumCall7:
call drum7
ret
drumCall8:
call drum8
ret
drumCall9:
call drum9
ret
drumCallA:
call drumA
ret
drumCallB:
call drumB
ret
drumCallC:
call drumC
ret
drumCallD:
call drumD
ret
drumCallE:
call drumE
ret
drumCallF:
call drumF
ret
drumCall10:
call drum10
ret
drumCall11:
call drum11
ret
drumCall12:
call drum12
ret
drumCall13:
call drum13
ret
drumCall14:
call drum14
ret
drumCall15:
call drum15
ret
drumCall16:
call drum16
ret
drumCall17:
call drum17
ret
drumCall18:
call drum18
ret
drumCall19:
call drum19
ret
drumCall1A:
call drum1A
ret
drumCall1B:
call drum1B
ret
drumCall1C:
call drum1C
ret
drumCall1D:
call drum1D
ret
drumCall1E:
call drum1E
ret
drumCall1F:
call drum1F
ret
drumCall20:
call drum20
ret
drumCall21:
call drum21
ret
drumCall22:
call drum22
ret
drumCall23:
call drum23
ret
drumCall24:
call drum24
ret
drumCall25:
call drum25
ret
drumCall26:
call drum26
ret
drumCall27:
call drum27
ret
drumCall28:
call drum28
ret
drumCall29:
call drum29
ret
drumCall2A:
call drum2A
ret
drumCall2B:
call drum2B
ret
drumCall2C:
call drum2C
ret
drumCall2D:
call drum2D
ret
drumCall2E:
call drum2E
ret
drumCall2F:
call drum2F
ret
drumCall30:
call drum30
ret
drumCall31:
call drum31
ret
drumCall32:
call drum32
ret
drumCall33:
call drum33
ret
drumCall34:
call drum34
ret
drumCall35:
call drum35
ret
drumCall36:
call drum36
ret
drumCall37:
call drum37
ret
drumCall38:
call drum38
ret
drumCall39:
call drum39
ret
drumCall3A:
call drum3A
ret
drumCall3B:
call drum3B
ret
drumCall3C:
call drum3C
ret
drumCall3D:
call drum3D
ret
drumCall3E:
call drum3E
ret
drumChoose endp

drum0 PROC USES ECX EDI; tricky kicks 1
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0e0h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 12
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum0 ENDP

drum1 PROC USES ECX EDI; tricky kicks 2
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0f0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum1 ENDP

drum2 PROC USES ECX EDI; tricky kicks 3
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0e0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum2 ENDP

drum3 PROC USES ECX EDI; tricky kicks 4
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 100h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 12
invoke acousticSnareOff, 0
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum3 ENDP

drum4 PROC USES ECX EDI; 8th note hats
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0a0h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum4 ENDP

drum5 PROC USES ECX EDI; surfing with two hands
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0b0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum5 ENDP

drum6 PROC USES ECX EDI; mixed hands
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0c0h
mov ecx, 4
drumLoop0:
cmp ecx, 0
je endLoop0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
loop drumLoop0
endLoop0 :
mov ecx, 4
drumLoop1 :
    cmp ecx, 0
    je endLoop1
    call highMidTomOn
    call acousticSnareOn
    invoke highMidTomOff, 24
    invoke acousticSnareOff, 0
    call acousticSnareOn
    invoke noteEvent, 24, 89h, 38
    dec ecx
    loop drumLoop1
    endLoop1 :
ret
drum6 ENDP

drum7 PROC USES ECX EDI; 1 / 4 note surfin
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 70h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call highMidTomOn
invoke highMidTomOff, 48
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticSnareOn
invoke noteEvent, 24, 89h, 38
call highMidTomOn
invoke highMidTomOff, 48
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 48
invoke acousticSnareOff, 0
dec ecx
jmp drumLoop
endLoop :
ret
drum7 ENDP

drum8 PROC USES ECX EDI; 2 hand swing
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0a0h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
invoke noteEvent, 0, 99h, 45; low tom
invoke noteEvent, 32, 89h, 45
invoke noteEvent, 0, 99h, 45; low tom
invoke noteEvent, 16, 89h, 45
call acousticSnareOn
invoke noteEvent, 0, 99h, 45; low tom
invoke noteEvent, 32, 89h, 38
invoke noteEvent, 0, 89h, 45
invoke noteEvent, 0, 99h, 45; low tom
invoke noteEvent, 16, 89h, 45
dec ecx
jmp drumLoop
endLoop :
ret
drum8 ENDP

drum9 PROC USES ECX EDI; kickand snare
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 40h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
invoke noteEvent, 48, 89h, 35
call acousticSnareOn
invoke noteEvent, 48, 89h, 38
dec ecx
jmp drumLoop
endLoop :
ret
drum9 ENDP

drumA PROC USES ECX EDI; kickand snare var 1
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 40h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
invoke noteEvent, 48, 89h, 35
call acousticSnareOn
invoke noteEvent, 72, 89h, 38
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
call acousticSnareOn
invoke noteEvent, 48, 89h, 38
dec ecx
jmp drumLoop
endLoop :
ret
drumA ENDP

drumB PROC USES ECX EDI; kickand snare var 2
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 50h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
invoke noteEvent, 48, 89h, 35
call acousticSnareOn
invoke noteEvent, 48, 89h, 38
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
call acousticSnareOn
invoke noteEvent, 48, 89h, 38
dec ecx
jmp drumLoop
endLoop :
ret
drumB ENDP

drumC PROC USES ECX EDI; kickand snare var 3
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 60h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
invoke noteEvent, 48, 89h, 35
call acousticSnareOn
invoke noteEvent, 48, 89h, 38
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
call acousticSnareOn
invoke noteEvent, 24, 89h, 38
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drumC ENDP

drumD PROC USES ECX EDI; baby's first rock beat
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0c0h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drumD ENDP

drumE PROC USES ECX EDI; blitzkrieg toms
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0c0h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
invoke noteEvent, 0, 99h, 45; low tom
call acousticBassDrumOn
invoke noteEvent, 24, 89h, 45
invoke acousticBassDrumOff, 0
invoke noteEvent, 0, 99h, 45; low tom
invoke noteEvent, 24, 89h, 45
call acousticSnareOn
invoke noteEvent, 0, 99h, 45; low tom
invoke noteEvent, 24, 89h, 38
invoke noteEvent, 0, 89h, 45
invoke noteEvent, 0, 99h, 45; low tom
invoke noteEvent, 24, 89h, 45
dec ecx
jmp drumLoop
endLoop :
ret
drumE ENDP

drumF PROC USES ECX EDI
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0c0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drumF ENDP

drum10 PROC USES ECX EDI; kick var 2
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0c0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum10 ENDP

drum11 PROC USES ECX EDI; kick var 3
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0d0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum11 ENDP

drum12 PROC USES ECX EDI; 8th note kicks 1
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0d0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum12 ENDP

drum13 PROC USES ECX EDI; 8th note kicks 2
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0d0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum13 ENDP

drum14 PROC USES ECX EDI; boom boom chick
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0e0h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum14 ENDP

drum15 PROC USES ECX EDI; you will, you will, rock us
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0e0h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
dec ecx
jmp drumLoop
endLoop :
ret
drum15 ENDP

drum16 PROC USES ECX EDI; robot rock
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 100h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
dec ecx
jmp drumLoop
endLoop :
ret
drum16 ENDP

drum17 PROC USES ECX EDI; 4 on the floor
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0e0h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke noteEvent, 0, 89h, 48
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
call acousticSnareOn
invoke acousticBassDrumOff, 24
invoke noteEvent, 0, 89h, 48
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum17 ENDP

drum18 PROC USES EDI; slow jam
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0b8h
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
ret
drum18 ENDP

drum19 PROC USES ECX EDI; surf's up
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0d0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum19 ENDP

drum1A PROC USES ECX EDI; poodle skirt
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0d0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum1A ENDP

drum1B PROC USES ECX EDI; motor city 1
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0e0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
dec ecx
jmp drumLoop
endLoop :
ret
drum1B ENDP

drum1C PROC USES ECX EDI; motor city 2
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0f0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
call acousticSnareOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
dec ecx
jmp drumLoop
endLoop :
ret
drum1C ENDP

drum1D PROC USES ECX EDI; late snare
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0e0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
dec ecx
jmp drumLoop
endLoop :
ret
drum1D ENDP

drum1E PROC USES ECX EDI; prog rock
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 100h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
dec ecx
jmp drumLoop
endLoop :
ret
drum1E ENDP

drum1F PROC USES ECX EDI; hard rock hats
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 80h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke noteEvent, 48, 89h, 35
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 48
invoke acousticSnareOff, 0
dec ecx
jmp drumLoop
endLoop :
ret
drum1F ENDP

drum20 PROC USES ECX EDI; hard rocl hats var 1
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 090h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
invoke noteEvent, 0, 99h, 45; low tom
call acousticBassDrumOn
invoke noteEvent, 48, 89h, 45
invoke acousticBassDrumOff, 0
invoke noteEvent, 0, 99h, 45; low tom
call acousticSnareOn
invoke noteEvent, 24, 89h, 45
invoke acousticSnareOff, 0
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
invoke noteEvent, 0, 99h, 45; low tom
invoke noteEvent, 24, 89h, 45
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
invoke noteEvent, 0, 99h, 45; low tom
call acousticSnareOn
invoke noteEvent, 48, 89h, 45
invoke acousticSnareOff, 0
dec ecx
jmp drumLoop
endLoop :
ret
drum20 ENDP

drum21 PROC USES EDI; hard rock hats var 2
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0a0h
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke noteEvent, 48, 89h, 35
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 48
invoke acousticSnareOff, 0
ret
drum21 ENDP

drum22 PROC USES ECX EDI; upbeat hats 1
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 80h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call acousticSnareOn
invoke noteEvent, 24, 89h, 38
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum22 ENDP

drum23 PROC USES ECX EDI; upbeat hats 2
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 90h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call acousticSnareOn
invoke noteEvent, 24, 89h, 38
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call acousticSnareOn
invoke noteEvent, 24, 89h, 38
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum23 ENDP

drum24 PROC USES ECX EDI; tricky snares 1
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0d0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum24 ENDP

drum25 PROC USES ECX EDI; tricky snares 2
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0d0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 12
invoke highMidTomOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum25 ENDP

drum26 PROC USES ECX EDI; tricky snares 3
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0e0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 12
invoke highMidTomOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum26 ENDP

drum27 PROC USES ECX EDI; tricky snares 4
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0f0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 12
invoke highMidTomOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum27 ENDP

drum28 PROC USES EDI; punk toms
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0f8h
invoke noteEvent, 0, 99h, 45; low tom
call acousticBassDrumOn
invoke noteEvent, 24, 89h, 45
invoke acousticBassDrumOff, 0
invoke noteEvent, 0, 99h, 45; low tom
call acousticBassDrumOn
invoke noteEvent, 24, 89h, 45
invoke acousticBassDrumOff, 0
invoke noteEvent, 0, 99h, 45; low tom
call acousticSnareOn
invoke noteEvent, 24, 89h, 45
invoke acousticSnareOff, 0
invoke noteEvent, 0, 99h, 45; low tom
invoke noteEvent, 12, 89h, 45
call highMidTomOn
invoke highMidTomOff, 12
invoke noteEvent, 0, 99h, 45; low tom
call acousticBassDrumOn
invoke noteEvent, 24, 89h, 45
invoke acousticBassDrumOff, 0
invoke noteEvent, 0, 99h, 45; low tom
call acousticBassDrumOn
invoke noteEvent, 24, 89h, 45
invoke acousticBassDrumOff, 0
invoke noteEvent, 0, 99h, 45; low tom
call acousticSnareOn
invoke noteEvent, 24, 89h, 45
invoke acousticSnareOff, 0
invoke noteEvent, 0, 99h, 45; low tom
invoke noteEvent, 12, 89h, 45
call highMidTomOn
invoke highMidTomOff, 12
invoke noteEvent, 0, 99h, 45; low tom
call acousticBassDrumOn
invoke noteEvent, 24, 89h, 45
invoke acousticBassDrumOff, 0
invoke noteEvent, 0, 99h, 45; low tom
call acousticBassDrumOn
invoke noteEvent, 24, 89h, 45
invoke acousticBassDrumOff, 0
invoke noteEvent, 0, 99h, 45; low tom
call acousticSnareOn
invoke noteEvent, 24, 89h, 45
invoke acousticSnareOff, 0
invoke noteEvent, 0, 99h, 45; low tom
call acousticBassDrumOn
invoke noteEvent, 24, 89h, 45
invoke acousticBassDrumOff, 0
invoke noteEvent, 0, 99h, 45; low tom
invoke noteEvent, 24, 89h, 45
invoke noteEvent, 0, 99h, 45; low tom
call acousticBassDrumOn
invoke noteEvent, 24, 89h, 45
invoke acousticBassDrumOff, 0
invoke noteEvent, 0, 99h, 45; low tom
call acousticSnareOn
invoke noteEvent, 24, 89h, 45
invoke acousticSnareOff, 0
invoke noteEvent, 0, 99h, 45; low tom
call acousticBassDrumOn
invoke noteEvent, 24, 89h, 45
invoke acousticBassDrumOff, 0
ret
drum28 ENDP

drum29 PROC USES ECX EDI; reggaeton
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 100h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
dec ecx
jmp drumLoop
endLoop :
ret
drum29 ENDP

drum2A PROC USES ECX EDI; a latin rhythm
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0d0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum2A ENDP

drum2B PROC USES ECX EDI; big band toms
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 120h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke noteEvent, 0, 99h, 45; low tom
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
invoke noteEvent, 0, 89h, 45
invoke noteEvent, 0, 99h, 45; low tom
invoke noteEvent, 12, 89h, 45
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke noteEvent, 0, 99h, 45; low tom
invoke acousticBassDrumOff, 24
invoke noteEvent, 0, 89h, 45
call highMidTomOn
invoke noteEvent, 0, 99h, 45; low tom
invoke highMidTomOff, 24
invoke noteEvent, 0, 89h, 45
call acousticBassDrumOn
invoke noteEvent, 0, 99h, 45; low tom
invoke acousticBassDrumOff, 12
invoke noteEvent, 0, 89h, 45
call highMidTomOn
invoke highMidTomOff, 12
invoke noteEvent, 0, 99h, 45; low tom
invoke noteEvent, 24, 89h, 45
call acousticBassDrumOn
call highMidTomOn
invoke noteEvent, 0, 99h, 45; low tom
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
invoke noteEvent, 0, 89h, 45
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
dec ecx
jmp drumLoop
endLoop :
ret
drum2B ENDP

drum2C PROC USES EDI; snare polyrhythm
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0f0h
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 12
invoke highMidTomOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
call acousticSnareOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 12
invoke highMidTomOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
ret
drum2C ENDP

drum2D PROC USES ECX EDI; 16th double kicks 1
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0d0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 12
invoke highMidTomOff, 0
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum2D ENDP

drum2E PROC USES ECX EDI; 16th double kicks 2
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0f0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 12
invoke highMidTomOff, 0
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum2E ENDP

drum2F PROC USES EDI; kick this way
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0e0h
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
ret
drum2F ENDP

drum30 PROC USES ECX EDI; metal motown
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 100h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 12
invoke acousticSnareOff, 0
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 12
invoke acousticSnareOff, 0
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum30 ENDP

drum31 PROC USES EDI; kick polyrhythm
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0f0h
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
call acousticSnareOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 12
invoke acousticSnareOff, 0
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 24
ret
drum31 ENDP

drum32 PROC USES ECX EDI; snare doubles 1
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0f0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 24
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 12
invoke acousticSnareOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 12
invoke acousticSnareOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum32 ENDP

drum33 PROC USES ECX EDI; snare doubles 2
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 100h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 12
invoke acousticSnareOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
invoke highMidTomOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 12
invoke acousticSnareOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call highMidTomOn
invoke highMidTomOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum33 ENDP

drum34 PROC USES ECX EDI; smells like that beat
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0e0h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 36
invoke highMidTomOff, 0
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 36
invoke acousticSnareOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 12
invoke highMidTomOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call acousticBassDrumOn
invoke acousticBassDrumOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum34 ENDP

drum35 PROC USES ECX EDI; disco 1
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 120h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call acousticSnareOn
invoke acousticBassDrumOff, 12
invoke acousticSnareOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum35 ENDP

drum36 PROC USES ECX EDI; disco 2
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 140h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call acousticSnareOn
invoke acousticBassDrumOff, 12
invoke acousticSnareOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticBassDrumOn
call acousticSnareOn
invoke acousticBassDrumOff, 12
invoke acousticSnareOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum36 ENDP

drum37 PROC USES ECX EDI; disco 3
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 140h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call acousticSnareOn
invoke acousticBassDrumOff, 12
invoke acousticSnareOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticBassDrumOn
call acousticSnareOn
invoke acousticBassDrumOff, 12
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum37 ENDP

drum38 PROC USES ECX EDI; disco 4
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 120h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call acousticSnareOn
invoke acousticBassDrumOff, 12
invoke acousticSnareOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticBassDrumOn
call acousticSnareOn
invoke acousticBassDrumOff, 12
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
call highMidTomOn
invoke highMidTomOff, 12
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum38 ENDP

drum39 PROC USES ECX EDI; the beat that feeds
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 100h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call acousticSnareOn
invoke acousticBassDrumOff, 24
invoke acousticSnareOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call acousticSnareOn
invoke acousticSnareOff, 24
call acousticSnareOn
invoke acousticSnareOff, 24
dec ecx
jmp drumLoop
endLoop :
ret
drum39 ENDP

drum3A PROC USES ECX EDI; fast punk 1
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 100h
mov ecx, 8
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
dec ecx
jmp drumLoop
endLoop :
ret
drum3A ENDP

drum3B PROC USES ECX EDI; fast punk 2
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 100h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
dec ecx
jmp drumLoop
endLoop :
ret
drum3B ENDP

drum3C PROC USES ECX EDI; fast punk 3
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 120h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 24
invoke highMidTomOff, 0
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 12
invoke acousticSnareOff, 0
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
invoke highMidTomOff, 12
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 24
invoke acousticSnareOff, 0
dec ecx
jmp drumLoop
endLoop :
ret
drum3C ENDP

drum3D PROC USES ECX EDI; swing the hats
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0c0h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 36
invoke highMidTomOff, 0
call highMidTomOn
invoke highMidTomOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 36
invoke acousticSnareOff, 0
call highMidTomOn
invoke highMidTomOff, 12
dec ecx
jmp drumLoop
endLoop :
ret
drum3D ENDP

drum3E PROC USES ECX EDI; swing the kick
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 0a0h
mov ecx, 4
drumLoop:
cmp ecx, 0
je endLoop
call acousticBassDrumOn
call highMidTomOn
invoke acousticBassDrumOff, 36
invoke highMidTomOff, 0
call acousticBassDrumOn
invoke acousticBassDrumOff, 12
call highMidTomOn
call acousticSnareOn
invoke highMidTomOff, 48
invoke acousticSnareOff, 0
dec ecx
jmp drumLoop
endLoop :
ret
drum3E ENDP

drum PROC USES ECX EDI;
mov edi, drumOffset
add edi, track3Chunk
add drumOffset, 140h
mov ecx, 2
drumLoop:
cmp ecx, 0
je endLoop
dec ecx
jmp drumLoop
endLoop :
ret
drum ENDP
END