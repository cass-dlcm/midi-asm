INCLUDE Irvine32.inc
.data
fileName BYTE 0ffh DUP(0)

invalidInputMsg BYTE "You have put in an invalid input. Please try again.", 0
fileNamePrompt BYTE "Enter the filename: ", 0
tempoPrompt BYTE "Please enter a tempo range. To set a specific tempo, type it in for both the min and the max.", 0
minTempoPrompt BYTE "Enter the minimum tempo: ", 0
maxTempoPrompt BYTE "Enter the maximum tempo: ", 0
outTempoPrompt BYTE "The generated tempo is: ", 0
modeAskMsg BYTE "Choose a mode; Sequencer (S) or Random (R): ", 0
sequenceCountAskMsg BYTE "Enter the number of unique segments (in hexadecimal): ", 0
sequenceMeasuresCountAskMsgP1 BYTE "Enter (in hexadecimal) the number of measures in segment " , 0
sequenceMeasuresCountAskMsgP2 BYTE ": ", 0
howManyInSequenceAskMsg BYTE "Enter (in hexadecimal) the number of segments in your sequence: ", 0
segmentAskMsg BYTE "Enter (in hexadecimal) the number of the segment that comes next: ", 0
measurePrompt BYTE "Please enter a measure range. To set a specific number of measures, type it in for both the min and the max.", 0
minMeasurePrompt BYTE "Enter the minimum number of measures: ", 0
maxMeasurePrompt BYTE "Enter the maximum number of measures: ", 0
outMeasurePrompt BYTE "The generated number of measures is: ", 0

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
track2Chunk dword ?
track2ChunkLen dword 100fh

cPitch dword 3Ch                                ; middle c in midi

minMeasures dword ?                             ; minimum number of measrues to generate
measureCount dword ?                            ; variable of measures to generate

mode db ?

sequenceLen dword ?
segmentCount dword ?
currentMeasure dword 0
measuresPerSequence dword ?
segmentOffsets dword ?
sequence dword ?
measuresInSequence dword ?

.data?
hFile  HANDLE ?                                 ; handle to the file
hHeap  HANDLE ?                                 ; handle to the heap
.code
noteEvent PROC
    mov [edi], bh                               ; delta time
    mov [edi+1], bl                             ; note event, channel 0
    mov [edi+2], dl                             ; pitch in dl register
    mov [edi+3], BYTE PTR 40h                   ; velocity of 64 (medium)
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
    xor edx, edx
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

promptMode:
    ; prompt for mode
    ;mov edx, OFFSET modeAskMsg
    ;call WriteString
    ;call ReadChar
    ;call CrLF
    ;cmp al, "R"
    ;je random
    ;cmp al, "r"
    ;je random
    ;cmp al, "S"
    ;je sequencer
    ;cmp al, "s"
    ;je sequencer
    ;mov edx, OFFSET invalidInputMsg
    ;call WriteString
    ;call CrLf
    ;jmp promptMode
    jmp random

sequencer:
    mov mode, 1
    mov edx, OFFSET sequenceCountAskMsg
    call WriteString
    call ReadHex
    mov segmentcount, eax

    ; allocate memory for sequence count
    invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, segmentCount
    .if eax == NULL
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif
    mov measuresPerSequence, eax
    mov edi, measuresPerSequence
    invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, segmentCount
    .if eax == NULL
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif
    mov segmentOffsets, eax
    xor ebx, ebx
    xor ecx, ecx
    mov measureCount, 0
    mov eax, 0
    mov edi, segmentOffsets

sequenceMeasureRead:
    cmp ecx, segmentCount
    je getSequenceLength
    shl eax, 1
    add ebx, eax
    mov [edi+ecx], bl
    mov al, [edi+ecx]
    call WriteHex
    mov edx, OFFSET sequenceMeasuresCountAskMsgP1
    call WriteString
    mov edx, OFFSET sequenceMeasuresCountAskMsgP2
    call WriteString
    call ReadHex
    mov BYTE PTR measuresPerSequence[ecx], al
    inc ecx
    jmp sequenceMeasureRead

getSequenceLength:
    mov edx, OFFSET howManyInSequenceAskMsg
    call WriteString
    call ReadHex
    mov sequenceLen, eax
    
    ; allocate memory for sequence count
    invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, sequenceLen
    .if eax == NULL
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif
    mov sequence, eax

    mov ecx, 0

getSequence: 
    cmp ecx, sequenceLen
    je setMeasures
    mov edx, OFFSET segmentAskMsg
    call WriteString
    call ReadHex
    call WriteHex
    call CrLf
    call CrLf
    mov BYTE PTR sequence[ecx], al
    inc ecx
    jmp getSequence

setMeasures:
    mov ecx, 0
    mov eax, 0

setMeasuresLoop:
    cmp ecx, sequenceLen
    je trackPrep
    mov bl, BYTE PTR sequence[ecx]
    mov eax, ebx
    mov edx, 0
    mov dl, BYTE PTR measuresPerSequence[ebx]
    mov eax, edx
    mov eax, measureCount
    add eax, edx
    mov measureCount, eax
    inc ecx
    jmp setMeasuresLoop
    
random:
    mov mode, 0

    ; prompt for measures and display the result to the user
    mov edx, OFFSET measurePrompt
    call WriteString
    call crLf
    mov edx, OFFSET minMeasurePrompt
    call WriteString
    call readInt
    mov minMeasures, eax
    mov edx, OFFSET maxMeasurePrompt
    call WriteString
    call readInt
    sub eax, minMeasures
    add eax, 1
    call RandomRange
    add eax, minMeasures
    mov edx, OFFSET outMeasurePrompt
    call WriteString
    call WriteDec
    call crLf
    mov measureCount, eax
    jmp trackPrep

trackPrep:
    mov ebx, 33
    xor edx, edx
    mul ebx
    add eax, 0fh
    mov track1ChunkLen, eax
    mov eax, measureCount
    mov ebx, 40h
    xor edx, edx
    mul ebx
    add eax, 0fh
    mov track2ChunkLen, eax

    mov eax, measureCount
    shl eax, 1
    invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, eax
    .if eax == NULL
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif
    mov measuresInSequence, eax

    ; allocate memory for track 1
    invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, track1ChunkLen
    .if eax == NULL
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif
    mov track1Chunk, eax

    ; set meta info for track 1
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

    ; allocate memory for track 2
    invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, track2ChunkLen
    .if eax == NULL
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif
    mov track2Chunk, eax

    ; set meta info for track 2
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
<<<<<<< HEAD
    xor ecx, ecx
    xor ecx, ecx
    cmp mode, 0
    je genRandom
    jmp notesSequenceCreate

genRandom: 
    cmp ecx, measureCount
    je notesPrep
    mov eax, 12
    call RandomRange
    add eax, cPitch
    mov ebx, ecx
    shl ebx, 1
    mov BYTE PTR measuresInSequence[ebx], al
    xor edx, edx
    mov eax, 15
    call RandomRange
    mov ebx, 3
    mul ebx
    mov ebx, ecx
    shl ebx, 1
    mov BYTE PTR measuresInSequence[ebx+1], al
    xor eax, eax
    inc ecx
    jmp genRandom

notesPrep:
    xor ecx, ecx

notes:
    cmp ecx, measureCount
    je write
    mov eax, ecx
    mov edx, 0
    mov ebx, 33
    mul ebx
    add eax, 11
    mov edi, eax
    mov eax, 0
    mov ebx, ecx
    shl ebx, 1
    mov al, BYTE PTR measuresInSequence[ebx+1]
    mov esi, OFFSET chordVals
    add esi, eax
    add edi, track1Chunk

    ; bottom note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    xor bh, bh
    mov bl, 90h
    mov al, dl
    call noteEvent

    ; second note on
    add dl, [esi]
    mov bl, 90h
    call noteEvent

    ; third note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    xor bh, bh
    mov bl, 90h
    add dl, [esi+1]
    call noteEvent

    ; top note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    xor bh, bh
    mov bl, 90h
    add dl, [esi+2]
    call noteEvent

    ; bottom note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    mov [edi], BYTE PTR 83h
    mov [1+edi], BYTE PTR 00h
    mov [2+edi], BYTE PTR 80h
    mov [3+edi], dl
    mov [4+edi], BYTE PTR 40h
    add edi, 5

    ; second note off
    add dl, [esi]
    xor bh, bh
    mov bl, 80h
    CALL noteEvent

    ; third note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    xor bh, bh
    add dl, [esi+1]
    mov bl, 80h
    CALL noteEvent

    ; top note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    xor bh, bh
    add dl, [esi+2]
    mov bl, 80h
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
    xor edx, edx
    mov ebx, 40h
    mul ebx
    add eax, 0bh
    mov edi, eax
    xor eax, eax
    mov ebx, ecx
    shl ebx, 1
    mov al, BYTE PTR measuresInSequence[ebx+1]
    mov esi, OFFSET chordVals
    add esi, eax
    add edi, track2Chunk

    ; bottom guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; top guitar note on
    add dl, [esi+2]
    mov bl, 91h
    mov bh, 30h
    call noteEvent

    ; bottom guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; second guitar note on
    add dl, [esi]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; top guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    mov bl, 81h
    mov bh, 30h
    call noteEvent
    
    ; third guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; second guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; bottom guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; third guitar note off
    add dl, [esi+1]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; top guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; bottom guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; second guitar note on
    add dl, [esi]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; top guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; third guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; second guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; third guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
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
    xor edx, edx
    mul ebx
    add eax, 0bh
    mov edi, eax
    xor eax, eax
    mov ebx, ecx
    shl ebx, 1
    mov al, BYTE PTR measuresInSequence[ebx+1]
    mov esi, OFFSET chordVals
    add esi, eax
    add edi, track2Chunk
    
    ; bottom guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; third guitar note on
    add dl, [esi+1]
    mov bl, 91h
    mov bh, 30h
    call noteEvent

    ; bottom guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; second guitar note on
    add dl, [esi]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; third guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    mov bl, 81h
    mov bh, 30h
    call noteEvent
    
    ; top guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; second guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; bottom guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; top guitar note off
    add dl, [esi+2]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; third guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; bottom guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; second guitar note on
    add dl, [esi]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; third guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; top guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; second guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; top guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
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
    xor edx, edx
    mul ebx
    add eax, 0bh
    mov edi, eax
    xor eax, eax
    mov ebx, ecx
    shl ebx, 1
    mov al, BYTE PTR measuresInSequence[ebx+1]
    mov esi, OFFSET chordVals
    add esi, eax
    add edi, track2Chunk
    
    ; bottom guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; top guitar note on
    add dl, [esi+2]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; bottom guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    mov bl, 81h
    mov bh, 60h
    call noteEvent

    ; second guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; top guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    mov bl, 81h
    mov bh, 30h
    call noteEvent
    
    ; third guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; second guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; bottom guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; third guitar note off
    add dl, [esi+1]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; top guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; bottom guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; second guitar note on
    add dl, [esi]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; top guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; third guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    mov bl, 91h
    xor bh, bh
    call noteEvent

    ; second guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi]
    mov bl, 81h
    mov bh, 30h
    call noteEvent

    ; third guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    mov [edi], BYTE PTR 0
    mov [1+edi], BYTE PTR 81h
    mov [2+edi], dl
    mov [3+edi], BYTE PTR 40h

    inc ecx
    jmp notes

notesSequenceCreate:
    xor ecx, ecx
    xor edx, edx
outer:
    cmp ecx, segmentCount
    je notesSequencePrep
    mov ebx, ecx
    xor ecx, ecx

inner:
    cmp cl, BYTE PTR measuresPerSequence[ebx]
    je loopAfter
    push ebx
    mov eax, 12
    call RandomRange
    add eax, cPitch
    mov ebx, ecx
    shl ebx, 1
    mov BYTE PTR measuresInSequence[edx+ebx], al
    call WriteHex
    call CrLf
    push edx
    xor edx, edx
    mov eax, 15
    call RandomRange
    mov ebx, 3
    mul ebx
    pop edx
    mov ebx, ecx
    shl ebx, 1
    mov BYTE PTR measuresInSequence[edx+ebx+1], al
    pop ebx
    inc cl
    jmp inner

loopAfter:
    mov ecx, ebx
    xor eax, eax
    mov al, BYTE PTR measuresPerSequence[ecx]
    add edx, eax
    inc ecx
    jmp outer

notesSequencePrep:
    xor ecx, ecx
    mov edi, track1Chunk

notesSequence:
    cmp ecx, sequenceLen
    je write
    push ecx
    mov al, BYTE PTR sequence[ecx]
    xor ecx, ecx
    innerNotes:
        cmp cl, BYTE PTR measuresPerSequence[eax]
        je loopAfterNotes
        xor ebx, ebx
        add bl, BYTE PTR segmentOffsets[eax]
        mov esi, ebx
        push eax
        mov eax, ecx
        xor edx, edx
        mov ebx, 33
        mul ebx
        add eax, 11
        mov edi, eax
        add edi, track1Chunk
        mov eax, ecx
        shl eax, 1
        ; bottom note on
        mov dl, BYTE PTR measuresInSequence[esi+eax]
        mov bl, 90h
        xor bh, bh
        call noteEvent
        ; second note on
        mov dl, BYTE PTR measuresInSequence[esi+eax+1]
        mov dl, chordVals[edx]
        add dl, BYTE PTR measuresInSequence[esi+eax]
        mov bl, 90h
        call noteEvent
        ; third note on
        mov dl, BYTE PTR measuresInSequence[esi+eax+1]
        mov dl, chordVals[edx+1]
        add dl, BYTE PTR measuresInSequence[esi+eax]
        mov bl, 90h
        add dl, chordVals[esi+1]
        call noteEvent

        ; top note on
        mov dl, BYTE PTR measuresInSequence[esi+eax+1]
        mov dl, chordVals[edx+2]
        add dl, BYTE PTR measuresInSequence[esi+eax]
        mov bl, 90h
        add dl, chordVals[esi+2]
        call noteEvent

        ; bottom note off
        mov dl, BYTE PTR measuresInSequence[esi]
        mov [edi], BYTE PTR 83h
        mov [1+edi], BYTE PTR 00h
        mov [2+edi], BYTE PTR 80h
        mov [3+edi], dl
        mov [4+edi], BYTE PTR 40h
        add edi, 5

        ; second note off
        add dl, chordVals[esi]
        xor bh, bh
        mov bl, 80h
        CALL noteEvent

        ; third note off
        mov dl, BYTE PTR measuresInSequence[esi+1]
        mov dl, chordVals[edx]
        add dl, BYTE PTR measuresInSequence
        mov bl, 80h
        CALL noteEvent

        ; top note off
        mov dl, BYTE PTR measuresInSequence[esi]
        add dl, chordVals[esi+2]
        mov bl, 80h
        CALL noteEvent
        pop eax
        inc ecx
        inc currentMeasure
        jmp innerNotes
loopAfterNotes:
    pop ecx
    inc ecx
    jmp notesSequence
        

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