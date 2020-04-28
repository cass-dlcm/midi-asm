INCLUDE Irvine32.inc
.data
fileName BYTE 0fbh DUP(0)

invalidInputMsg BYTE "You have put in an invalid input. Please try again.", 0 ;if user entered something that was wrong
fileNamePrompt BYTE "Enter the filename: ", 0 ;prompts user for file name
tempoPrompt BYTE "Please enter a tempo range. To set a specific tempo, type it in for both the min and the max.", 0 ;explains prompted input for user
minTempoPrompt BYTE "Enter the minimum tempo: ", 0 ;prompts for min bpm
maxTempoPrompt BYTE "Enter the maximum tempo: ", 0 ;prompts for max bpm
outTempoPrompt BYTE "The generated tempo is: ", 0 ;tells user the limited rng bpm
modeAskMsg BYTE "Choose a mode; Sequencer (S) or Random (R): ", 0 ;prompts user to choose if music is in sequence or random
sequenceCountAskMsg BYTE "Enter the number of unique sequences: ", 0 ;if sequence is chosen, it asks for the number of them
sequenceMeasuresCountAskMsgP1 BYTE "Enter the number of measures in sequence " , 0
sequenceMeasuresCountAskMsgP2 BYTE ": ", 0 ;prompts user for number of measures in sequence
measurePrompt BYTE "Please enter a measure range. To set a specific number of measures, type it in for both the min and the max.", 0 ;explains to user what next prompts are for
minMeasurePrompt BYTE "Enter the minimum number of measures: ", 0 ;prompts for min wanted measures
maxMeasurePrompt BYTE "Enter the maximum number of measures: ", 0 ;prompts for max wanted measuers
outMeasurePrompt BYTE "The generated number of measures is: ", 0 ;outputs the limited rng measure generated
errorMsg BYTE "An error has occured. Terminating.", 0
segmentNumOobErr BYTE "The segment number (in ESI) is out of bounds!", 0
measureNumOobErr BYTE "The message number (in BL) is out of bounds!", 0
timeOorErr BYTE "The time (in BH) is too high!", 0
pitchOorErr BYTE "The pitch (in DL) is too high!", 0

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

; drum track (not yet implemented)
track3Chunk dword ?
track3ChunkLen dword 100fh

cPitch dword 3Ch                                ; middle c in midi

minMeasures dword ?                             ; minimum number of measrues to generate
measureCount dword ?                            ; variable of measures to generate

mode db ?

sequenceCount db 0
measuresPerSequence dword ?
measuresInSequence dword ?
.data?
hFile  HANDLE ?                                 ; handle to the file
hHeap  HANDLE ?                                 ; handle to the heap
.code

;-------------------------------------------------------------------------------
Error PROC
;-------------------------------------------------------------------------------
    call WriteString
    invoke ExitProcess, 0
Error ENDP

;-------------------------------------------------------------------------------
noteEvent PROC USES ebx edx,
    time:BYTE,                                  ; the delta time of the event
    event:BYTE,                                 ; the type of note event
    pitch:BYTE                                  ; the pitch of the note
; stores a note event in the dword specified by EDI
; Returns: nothing
;-------------------------------------------------------------------------------
    mov bh, time
    cmp bh, 80h                                 ; check that the time is valid
    jb continue0
    call DumpRegs
    mov edx, OFFSET timeOorErr
    call Error
continue0:
    mov dl, pitch
    cmp dl, 80h                                 ; check that the pitch is valid
    jb continue1
    call DumpRegs
    mov edx, OFFSET pitchOorErr
    call Error
continue1:
    mov dh, event
    mov [edi], bh                               ; delta time
    mov [edi+1], dh                             ; note event
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
    mov ecx, 0fbh
    call ReadString
    mov fileName[eax], "."
    mov fileName[eax+1], "m"
    mov fileName[eax+2], "i"
    mov fileName[eax+3], "d"
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
    call ReadInt
    mov sequenceCount, al

    ; allocate memory for track 1
    invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, sequenceCount
    .if eax == NULL
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif
    mov measuresPerSequence, eax
    mov edi, measuresPerSequence
    xor ecx, ecx
    mov measureCount, 0

sequenceMeasureRead:
    cmp cl, sequenceCount
    je trackPrep
    mov edx, OFFSET sequenceMeasuresCountAskMsgP1
    call WriteString
    mov eax, ecx
    call WriteHex
    mov edx, OFFSET sequenceMeasuresCountAskMsgP2
    call WriteString
    call ReadInt
    mov [edi+ecx], al
    add measureCount, eax
    inc cl
    jmp sequenceMeasureRead

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
    jmp trackPrep

trackPrep:
    mov measureCount, eax
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

    ; allocate memory for track 3
    invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, track3ChunkLen
    .if eax == NULL
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif
    mov track3Chunk, eax

    ; set meta info for track 3
    mov edi, track3Chunk
    mov [edi], BYTE PTR "M"
    mov [edi+1], BYTE PTR "T"
    mov [edi+2], BYTE PTR "r"
    mov [edi+3], BYTE PTR "k"
    mov eax, track3ChunkLen
    sub eax, 8
    mov [edi+7], al
    mov [edi+6], ah
    shr eax, 8
    mov [edi+5], ah
    shr eax, 8
    mov [edi+4], ah
    mov [edi+8], BYTE PTR 0
    mov [edi+9], BYTE PTR 0CAh
    mov [edi+0ah], BYTE PTR 77h
    add edi, track3ChunkLen
    mov [edi-4], BYTE PTR 0
    mov [edi-3], BYTE PTR 0ffh
    mov [edi-2], BYTE PTR 2fh
    mov [edi-1], BYTE PTR 0

    ; prepare counter for looping
    xor ecx, ecx

notes: 
    cmp ecx, measureCount
    je write
    mov eax, 12
    call RandomRange
    add eax, cPitch
    mov ebx, ecx
    shl ebx, 1
    mov BYTE PTR measuresInSequence[ebx], al
    mov eax, ecx
    xor edx, edx
    mov ebx, 33
    mul ebx
    add eax, 11
    mov edi, eax
    xor edx, edx
    mov eax, 15
    call RandomRange
    mov ebx, 3
    mul ebx
    mov ebx, ecx
    shl ebx, 1
    mov BYTE PTR measuresInSequence[ebx+1], al
    xor eax, eax
    mov al, BYTE PTR measuresInSequence[ebx+1]
    mov esi, OFFSET chordVals
    add esi, eax
    add edi, track1Chunk

    ; bottom note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    INVOKE noteEvent, 0, 90h, BYTE PTR measuresInSequence[ebx]

    ; second note on
    add dl, [esi]
    INVOKE noteEvent, 0, 90h, dl

    ; third note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    add dl, [esi+1]
    INVOKE noteEvent, 0, 90h, dl

    ; top note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    add dl, [esi+2]
    INVOKE noteEvent, 0, 90h, dl

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
    INVOKE noteEvent, 0, 80h, dl

    ; third note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    add dl, [esi+1]
    INVOKE noteEvent, 0, 80h, dl

    ; top note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    add dl, [esi+2]
    INVOKE noteEvent, 0, 80h, dl

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
    INVOKE noteEvent, 0, 91h, dl

    ; top guitar note on
    add dl, [esi+2]
    INVOKE noteEvent, 30h, 91h, dl

    ; bottom guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    INVOKE noteEvent, 30h, 81h, dl


    ; second guitar note on
    add dl, [esi]
    INVOKE noteEvent, 0, 91h, dl


    ; top guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 30h, 81h, dl
    
    ; third guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 0, 91h, dl

    ; second guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 30h, 81h, dl

    ; bottom guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    INVOKE noteEvent, 0, 91h, dl

    ; third guitar note off
    add dl, [esi+1]
    INVOKE noteEvent, 30h, 81h, dl


    ; top guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 0, 91h, dl


    ; bottom guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    INVOKE noteEvent, 30h, 81h, dl


    ; second guitar note on
    add dl, [esi]
    INVOKE noteEvent, 0, 91h, dl

    ; top guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 30h, 81h, dl

    ; third guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 0, 91h, dl


    ; second guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 30h, 81h, dl

    ; third guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 0, 81h, dl

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
    INVOKE noteEvent, 0, 91h, dl

    ; third guitar note on
    add dl, [esi+1]
    INVOKE noteEvent, 30h, 91h, dl

    ; bottom guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    INVOKE noteEvent, 30h, 81h, dl

    ; second guitar note on
    add dl, [esi]
    INVOKE noteEvent, 0, 91h, dl

    ; third guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 30h, 81h, dl
    
    ; top guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 0, 91h, dl

    ; second guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 30h, 81h, dl

    ; bottom guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    INVOKE noteEvent, 0, 91h, dl

    ; top guitar note off
    add dl, [esi+2]
    INVOKE noteEvent, 30h, 81h, dl

    ; third guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 0, 91h, dl

    ; bottom guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    INVOKE noteEvent, 30h, 81h, dl

    ; second guitar note on
    add dl, [esi]
    INVOKE noteEvent, 0, 91h, dl

    ; third guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 30h, 81h, dl

    ; top guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 0, 91h, dl

    ; second guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 30h, 81h, dl

    ; top guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 0, 81h, dl
    
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
    INVOKE noteEvent, 0, 91h, dl

    ; top guitar note on
    add dl, [esi+2]
    INVOKE noteEvent, 0, 91h, dl

    ; bottom guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    INVOKE noteEvent, 60h, 81h, dl

    ; second guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 0, 91h, dl

    ; top guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 30h, 81h, dl
    
    ; third guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 0, 91h, dl

    ; second guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 30h, 81h, dl

    ; bottom guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    INVOKE noteEvent, 0, 91h, dl

    ; third guitar note off
    add dl, [esi+1]
    INVOKE noteEvent, 30h, 81h, dl

    ; top guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 0, 91h, dl

    ; bottom guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    INVOKE noteEvent, 30h, 81h, dl

    ; second guitar note on
    add dl, [esi]
    INVOKE noteEvent, 0, 91h, dl

    ; top guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 30h, 81h, dl

    ; third guitar note on
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 0, 91h, dl

    ; second guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 30h, 81h, dl

    ; third guitar note off
    mov ebx, ecx
    shl ebx, 1
    mov dl, BYTE PTR measuresInSequence[ebx]
    sub dl, 12
    add dl, [esi+1]
   INVOKE noteEvent, 0, 81h, dl

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