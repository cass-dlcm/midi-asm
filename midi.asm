INCLUDE Irvine32.inc
.data
fileName BYTE 0ffh DUP(0)

fileNamePrompt BYTE "Enter the filename: ", 0
tempoPrompt BYTE "Please enter a tempo range. To set a specific tempo, type it in for both the min and the max.", 0
minTempoPrompt BYTE "Enter the minimum tempo: ", 0
maxTempoPrompt BYTE "Enter the maximum tempo: ", 0
outTempoPrompt BYTE "The generated tempo is: ", 0

chordNames BYTE "M", 0,
                "m", 0,
                "5", 0,
                "7", 0,
                "M7", 0,
                "m7", 0,
                "mM7", 0,
                "6", 0,
                "m6", 0,
                "add9", 0,
                "madd9", 0,
                "7b5", 0,
                "7#5", 0,
                "m7b5", 0,
                "m7#5", 0

chordVals BYTE 4, 7, 12, 3, 7, 12,              ; M & m
               7, 12, 19, 4, 7, 10,             ; 5 & 7
               4, 7, 11, 3, 7, 10, 3, 7, 11,    ; M7, m7, & mM7
               4, 7, 9, 3, 7, 9,                ; 6 & m6
               2, 4, 7, 2, 3, 7,                ; add9 & madd9
               4, 6, 10, 4, 8, 10,              ; 7b5 & 7#5
               3, 6, 10, 3, 8, 10               ; m7b5 & m7#5

; header
headerChunk db "MThd",                          ; file identifier
               0, 0, 0, 6,                      ; length of remaining header chunk
               0, 1,                            ; midi format
               0, 4,                            ; number of tracks
               0, 60h                           ; number of divisions in a quarter note
headerChunkLen equ $-headerChunk                ; length of the header

; meta track
track0Chunk db 4dh, 54h, 72h, 6bh,              ; track identifier
               0, 0, 0, 25,                     ; length of remainig track data
               0, 0FFh, 51h, 3, 0, 0, 0,        ; tempo of song
               0, 0FFh, 58h, 4, 4, 2, 18h, 8,   ; time signature of song
               0, 0FFh, 59h, 2, 0, 0,           ; key signature of song
               00h, 0FFh, 2Fh, 0                ; end of track
track0ChunkLen equ $-track0Chunk                ; length of the entire track
minTempo dword ?

; piano track
track1Chunk db "MTrk",                          ; track identifier
               0, 0, 8h, 47h,                   ; length of remaining track data
               0, 0C0h, 0,                      ; set the instrument to piano
               840h DUP(0),                     ; space for note events
               0, 0FFh, 2Fh, 0                  ; end of track
track1ChunkLen equ $-track1Chunk

; guitar track
track2Chunk db "MTrk",                          ; track identifier
               0, 0, 10h, 07h,                  ; length of remaining track data
               0, 0C1h, 25,                     ; set the instrument to guitar
               1000h DUP(0),                    ; space for note events
               0, 0FFh, 2Fh, 0                  ; end of track
track2ChunkLen equ $-track2Chunk                ; length of the entire track

; unused track
track3Chunk db "MTrk",                          ; track identifier
               0, 0, 0, 4,                      ; length of remaining track data
               0, 0ffh, 2fh, 0                  ; end of track
track3ChunkLen equ $-track3Chunk                ; length of the entire track

cPitch dword 3Ch                                ; middle c in midi
currPitch db ?                                  ; variable to store the root pitch of the current chord
currChord dword ?                                  ; variable to store the form of the current chord
maxMeasures dword 64                            ; how many measures to generate
.data?
hFile  HANDLE ?                                 ; handle to the file
.code
noteEventTrack1 PROC
    mov track1Chunk[edi], 0                     ; delta time
    mov track1Chunk[edi+1], bl                  ; note event, channel 0
    mov track1Chunk[edi+2], dl                  ; pitch in dl register
    mov track1Chunk[edi+3], 40h                 ; velocity of 64 (medium)
    add edi, 4
    ret
noteEventTrack1 ENDP

noteEventTrack2 PROC
    mov track2Chunk[edi], bh                    ; delta time
    mov track2Chunk[edi+1], bl                  ; note event, channel 0
    mov track2Chunk[edi+2], dl                  ; pitch in dl register
    mov track2Chunk[edi+3], 40h                 ; velocity of 64 (medium)
    add edi, 4
    ret
noteEventTrack2 ENDP

main PROC
    mov edx, OFFSET fileNamePrompt
    call WriteString
    mov edx, OFFSET fileName
    mov ecx, 0ffh
    call ReadString
    call CreateOutputFile
    mov hFile,eax
    mov ecx, headerChunkLen
    mov edx, OFFSET headerChunk
    call WriteToFile
    call Randomize

    mov edx, OFFSET tempoPrompt
    call WriteString
    call crLf
    mov edx, OFFSET minTempoPrompt
    call WriteString
    call readInt
    mov minTempo, eax
    mov edx, OFFSET maxTempoPrompt
    call WriteString
    call readInt
    sub eax, minTempo
    add eax, 1
    call RandomRange
    add eax, minTempo
    mov edx, OFFSET outTempoPrompt
    call WriteString
    call WriteDec
    call crLf

    mov ebx, eax
    mov eax, 60000000
    mov edx, 0
    div ebx
    mov track0Chunk[0eh], al
    shr eax, 8
    mov track0Chunk[0dh], al
    shr eax, 8
    mov track0Chunk[0ch], al

    mov ecx, track0ChunkLen
    mov eax, hFile
    mov edx, OFFSET track0Chunk
    call WriteToFile

    mov ecx, 0
notes: 
    cmp ecx, maxMeasures
    je write
    mov eax, 12
    call RandomRange
    add eax, cPitch
    mov currPitch, al
    mov eax, ecx
    mov ebx, 33
    mul bx
    add eax, 11
    mov edi, eax
    mov eax, 15
    call RandomRange
    mov ebx, 3
    mul bx
    mov currChord, eax

    ; bottom note on
    mov dl, currPitch
    mov bl, 90h
    call noteEventTrack1

    ; second note on
    add dl, chordVals[eax]
    call noteEventTrack1

    ; third note on
    mov dl, currPitch
    add dl, chordVals[eax+1]
    call noteEventTrack1

    ; top note on
    mov dl, currPitch
    add dl, chordVals[eax+2]
    call noteEventTrack1

    ; bottom note off
    mov dl, currPitch
    mov track1Chunk[edi], 83h
    mov track1Chunk[1+edi], 00h
    mov track1Chunk[2+edi], 80h
    mov track1Chunk[3+edi], dl
    mov track1Chunk[4+edi], 40h
    add edi, 5

    ; second note off
    mov dl, currPitch
    add dl, chordVals[eax]
    mov bl, 80h
    CALL noteEventTrack1

    ; third note off
    mov dl, currPitch
    add dl, chordVals[eax+1]
    CALL noteEventTrack1

    ; top note off
    mov dl, currPitch
    add dl, chordVals[eax+2]
    CALL noteEventTrack1

    mov eax, 3
    call RandomRange
    cmp eax, 1
    jb guitarPattern0
    je guitarPattern1
    ja guitarPattern2
guitarPattern0:
    mov eax, ecx
    mov ebx, 40h
    mul bx
    add eax, 0bh
    mov edi, eax
    mov eax, currChord

    ; bottom guitar note on
    mov dl, currPitch
    sub dl, 12
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; top guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+2]
    mov bl, 91h
    mov bh, 30h
    call noteEventTrack2

    ; bottom guitar note off
    mov dl, currPitch
    sub dl, 12
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; second guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; top guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+2]
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2
    
    ; third guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+1]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; second guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+1]
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; bottom guitar note on
    mov dl, currPitch
    sub dl, 12
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; third guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+1]
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; top guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+2]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; bottom guitar note off
    mov dl, currPitch
    sub dl, 12
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; second guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; top guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+2]
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; third guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+1]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; second guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax]
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; third guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+1]
    mov track2Chunk[edi], 0
    mov track2Chunk[1+edi], 81h
    mov track2Chunk[2+edi], dl
    mov track2Chunk[3+edi], 40h
    inc ecx
    jmp notes
guitarPattern1:
    mov eax, ecx
    mov ebx, 40h
    mul bx
    add eax, 0bh
    mov edi, eax
    mov eax, currChord
    
    ; bottom guitar note on
    mov dl, currPitch
    sub dl, 12
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; third guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+1]
    mov bl, 91h
    mov bh, 30h
    call noteEventTrack2

    ; bottom guitar note off
    mov dl, currPitch
    sub dl, 12
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; second guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; third guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+1]
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2
    
    ; top guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+2]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; second guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax]
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; bottom guitar note on
    mov dl, currPitch
    sub dl, 12
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; top guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+2]
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; third guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+1]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; bottom guitar note off
    mov dl, currPitch
    sub dl, 12
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; second guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; third guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+1]
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; top guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+2]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; second guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax]
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; top guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+2]
    mov track2Chunk[edi], 0
    mov track2Chunk[1+edi], 81h
    mov track2Chunk[2+edi], dl
    mov track2Chunk[3+edi], 40h
    inc ecx
    jmp notes
guitarPattern2:
    mov eax, ecx
    mov ebx, 40h
    mul bx
    add eax, 0bh
    mov edi, eax
    mov eax, currChord
    
    ; bottom guitar note on
    mov dl, currPitch
    sub dl, 12
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; top guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+2]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; bottom guitar note off
    mov dl, currPitch
    sub dl, 12
    mov bl, 81h
    mov bh, 60h
    call noteEventTrack2

    ; second guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; top guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+2]
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2
    
    ; third guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+1]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; second guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax]
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; bottom guitar note on
    mov dl, currPitch
    sub dl, 12
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; third guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+1]
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; top guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+2]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; bottom guitar note off
    mov dl, currPitch
    sub dl, 12
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; second guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; top guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+2]
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; third guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+1]
    mov bl, 91h
    mov bh, 0
    call noteEventTrack2

    ; second guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax]
    mov bl, 81h
    mov bh, 30h
    call noteEventTrack2

    ; third guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, chordVals[eax+1]
    mov track2Chunk[edi], 0
    mov track2Chunk[1+edi], 81h
    mov track2Chunk[2+edi], dl
    mov track2Chunk[3+edi], 40h
    inc ecx
    jmp notes
write:
    mov ecx, track1ChunkLen
    mov eax, hFile
    mov edx, OFFSET track1Chunk
    call WriteToFile
    mov ecx, track2ChunkLen
    mov eax, hFile
    mov edx, OFFSET track2Chunk
    call WriteToFile
    mov ecx, track3ChunkLen
    mov eax, hFile
    mov edx, OFFSET track3Chunk
    call WriteToFile
    mov eax, hFile
    call CloseFile
	INVOKE ExitProcess, 0			; end the program
main ENDP
END main