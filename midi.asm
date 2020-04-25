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
               0, 3,                            ; number of tracks
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
track1Chunk dword ?
track1ChunkLen dword 84fh

; guitar track
track2Chunk dword ? ;db "MTrk",                          ; track identifier
               ;0, 0, 10h, 07h,                  ; length of remaining track data
               ;0, 0C1h, 25,                     ; set the instrument to guitar
               ;1000h DUP(0),                    ; space for note events
               ;0, 0FFh, 2Fh, 0                  ; end of track
track2ChunkLen dword 100fh ;equ $-track2Chunk                ; length of the entire track

; unused track


cPitch dword 3Ch                                ; middle c in midi
currPitch db ?                                  ; variable to store the root pitch of the current chord
currChord db ?                               ; variable to store the form of the current chord
maxMeasures dword 64                            ; how many measures to generate
.data?
hFile  HANDLE ?                                 ; handle to the file
hHeap  HANDLE ?                                 ; handle to the heap
.code
noteEvent PROC
    mov [edi], bh                     ; delta time
    mov [edi+1], bl                  ; note event, channel 0
    mov [edi+2], dl                  ; pitch in dl register
    mov [edi+3], BYTE PTR 40h                 ; velocity of 64 (medium)
    add edi, 4
    ret
noteEvent ENDP


main PROC
    ; initialize the randomizer
    call Randomize

    invoke GetProcessHeap
    .if eax == NULL
        call WriteWindowsMsg
        jmp quit
    .endif
    mov hHeap, eax
    
    ; prompt for the filename and create the file, creating the header chunk
    mov edx, OFFSET fileNamePrompt
    call WriteString
    mov edx, OFFSET fileName
    mov ecx, 0ffh
    call ReadString
    call CreateOutputFile
    .if EAX == INVALID_HANDLE_VALUE
        call WriteWindowsMsg
        jmp quit
    .endif
    mov hFile,eax
    mov ecx, headerChunkLen
    mov edx, OFFSET headerChunk
    call WriteToFile
    .if EAX == 0
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif

    ; prompt for tempo and display the result to the user
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

    ; store the tempo
    mov ebx, eax
    mov eax, 60000000
    mov edx, 0
    div ebx
    mov track0Chunk[0eh], al
    shr eax, 8
    mov track0Chunk[0dh], al
    shr eax, 8
    mov track0Chunk[0ch], al

    ; write the meta chunk
    mov ecx, track0ChunkLen
    mov eax, hFile
    mov edx, OFFSET track0Chunk
    call WriteToFile
    .if EAX == 0
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif

    invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, track1ChunkLen
    .if eax == NULL
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif
    mov track1Chunk, eax

    mov edi, track1Chunk
    mov [edi], BYTE PTR "M"
    mov [edi+1], BYTE PTR "T"
    mov [edi+2], BYTE PTR "r"
    mov [edi+3], BYTE PTR "k"
    mov eax, track1ChunkLen
    sub eax, 8
    mov [edi+7], al
    mov [edi+6], ah
    shr eax, 8
    mov [edi+5], ah
    shr eax, 8
    mov [edi+4], ah
    mov [edi+8], BYTE PTR 0
    mov [edi+9], BYTE PTR 0C0h
    mov [edi+0ah], BYTE PTR 0
    add edi, track1ChunkLen
    mov [edi-4], BYTE PTR 0
    mov [edi-3], BYTE PTR 0ffh
    mov [edi-2], BYTE PTR 2fh
    mov [edi-1], BYTE PTR 0

    invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, track2ChunkLen
    .if eax == NULL
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif
    mov track2Chunk, eax

    mov edi, track2Chunk
    mov [edi], BYTE PTR "M"
    mov [edi+1], BYTE PTR "T"
    mov [edi+2], BYTE PTR "r"
    mov [edi+3], BYTE PTR "k"
    mov eax, track2ChunkLen
    sub eax, 8
    mov [edi+7], al
    mov [edi+6], ah
    shr eax, 8
    mov [edi+5], ah
    shr eax, 8
    mov [edi+4], ah
    mov [edi+8], BYTE PTR 0
    mov [edi+9], BYTE PTR 0C1h
    mov [edi+0ah], BYTE PTR 25
    add edi, track2ChunkLen
    mov [edi-4], BYTE PTR 0
    mov [edi-3], BYTE PTR 0ffh
    mov [edi-2], BYTE PTR 2fh
    mov [edi-1], BYTE PTR 0

    ; prepare counter for looping
    mov ecx, 0

notes: 
    cmp ecx, maxMeasures
    je write
    mov eax, 12
    call RandomRange
    add eax, cPitch
    mov currPitch, al
    mov eax, ecx
    mov edx, 0
    mov ebx, 33
    mul ebx
    add eax, 11
    mov edi, eax
    mov edx, 0
    mov eax, 15
    call RandomRange
    mov ebx, 3
    mul ebx
    mov currChord, al
    mov eax, 0
    mov al, currChord
    mov esi, OFFSET chordVals
    add esi, eax
    add edi, track1Chunk
    mov bh, 0

    ; bottom note on
    mov dl, currPitch
    mov bl, 90h
    call noteEvent

    ; second note on
    add dl, [esi]
    call noteEvent

    ; third note on
    mov dl, currPitch
    add dl, [esi+1]
    call noteEvent

    ; top note on
    mov dl, currPitch
    add dl, [esi+2]
    call noteEvent

    ; bottom note off
    mov dl, currPitch
    mov [edi], BYTE PTR 83h
    mov [1+edi], BYTE PTR 00h
    mov [2+edi], BYTE PTR 80h
    mov [3+edi], dl
    mov [4+edi], BYTE PTR 40h
    add edi, 5

    ; second note off
    mov dl, currPitch
    add dl, [esi]
    mov bl, 80h
    CALL noteEvent

    ; third note off
    mov dl, currPitch
    add dl, [esi+1]
    CALL noteEvent

    ; top note off
    mov dl, currPitch
    add dl, [esi+2]
    CALL noteEvent

    mov eax, 3
    call RandomRange
    cmp eax, 1
    jb guitarPattern0
    je guitarPattern1
    ja guitarPattern2

guitarPattern0:
    ; prepare edi to point to the chunk
    mov eax, ecx
    mov edx, 0
    mov ebx, 40h
    mul ebx
    add eax, 0bh
    mov edi, eax
    mov eax, 0
    mov al, currChord
    mov esi, OFFSET chordVals
    add esi, eax
    add edi, track2Chunk

    ; bottom guitar note on
    mov dl, currPitch
    sub dl, 12
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; top guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+2]
    mov bl, 91h
    mov bh, 30h
    call noteEvent

    ; bottom guitar note off
    mov dl, currPitch
    sub dl, 12
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; second guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; top guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+2]
    mov bl, 81h
    mov bh, 30h
    call noteEvent
    
    ; third guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+1]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; second guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+1]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; bottom guitar note on
    mov dl, currPitch
    sub dl, 12
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; third guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+1]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; top guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+2]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; bottom guitar note off
    mov dl, currPitch
    sub dl, 12
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; second guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; top guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+2]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; third guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+1]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; second guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; third guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+1]
    mov [edi], BYTE PTR 0
    mov [1+edi], BYTE PTR 81h
    mov [2+edi], dl
    mov [3+edi], BYTE PTR 40h

    inc ecx
    jmp notes

guitarPattern1:
    mov eax, ecx
    mov ebx, 40h
    mov edx, 0
    mul ebx
    add eax, 0bh
    mov edi, eax
    mov eax, 0
    mov al, currChord
    mov esi, OFFSET chordVals
    add esi, eax
    add edi, track2Chunk
    
    ; bottom guitar note on
    mov dl, currPitch
    sub dl, 12
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; third guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+1]
    mov bl, 91h
    mov bh, 30h
    call noteEvent

    ; bottom guitar note off
    mov dl, currPitch
    sub dl, 12
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; second guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; third guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+1]
    mov bl, 81h
    mov bh, 30h
    call noteEvent
    
    ; top guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+2]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; second guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; bottom guitar note on
    mov dl, currPitch
    sub dl, 12
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; top guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+2]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; third guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+1]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; bottom guitar note off
    mov dl, currPitch
    sub dl, 12
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; second guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; third guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+1]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; top guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+2]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; second guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; top guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+2]
    mov [edi], BYTE PTR 0
    mov [1+edi], BYTE PTR 81h
    mov [2+edi], dl
    mov [3+edi], BYTE PTR 40h
    
    inc ecx
    jmp notes

guitarPattern2:
    mov eax, ecx
    mov ebx, 40h
    mov edx, 0
    mul ebx
    add eax, 0bh
    mov edi, eax
    mov eax, 0
    mov al, currChord
    mov esi, OFFSET chordVals
    add esi, eax
    add edi, track2Chunk
    
    ; bottom guitar note on
    mov dl, currPitch
    sub dl, 12
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; top guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+2]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; bottom guitar note off
    mov dl, currPitch
    sub dl, 12
    mov bl, 81h
    mov bh, 60h
    call noteEvent

    ; second guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; top guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+2]
    mov bl, 81h
    mov bh, 30h
    call noteEvent
    
    ; third guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+1]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; second guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; bottom guitar note on
    mov dl, currPitch
    sub dl, 12
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; third guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+1]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; top guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+2]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; bottom guitar note off
    mov dl, currPitch
    sub dl, 12
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; second guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; top guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+2]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; third guitar note on
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+1]
    mov bl, 91h
    mov bh, 0
    call noteEvent

    ; second guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; third guitar note off
    mov dl, currPitch
    sub dl, 12
    add dl, [esi+1]
    mov [edi], BYTE PTR 0
    mov [1+edi], BYTE PTR 81h
    mov [2+edi], dl
    mov [3+edi], BYTE PTR 40h

    inc ecx
    jmp notes

write:
    ; write the first track
    mov ecx, track1ChunkLen
    mov eax, hFile
    mov edx, track1Chunk
    call WriteToFile
    .if EAX == 0
        call WriteWindowsMsg
        jmp closeAndQuit
   .endif

    ; write the second track
    mov ecx, track2ChunkLen
    mov eax, hFile
    mov edx, track2Chunk
    call WriteToFile
    .if EAX == 0
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif

closeAndQuit:
    mov eax, hFile
    call CloseFile

quit:
	INVOKE ExitProcess, 0			; end the program
main ENDP
END main