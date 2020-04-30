INCLUDE Irvine32.inc
.data
fileName BYTE 0fbh DUP(0)

invalidInputMsg BYTE "You have put in an invalid input. Please try again.", 0   ; if user entered something that was wrong
fileNamePrompt BYTE "Enter the filename: ", 0                                   ; prompts user for file name
tempoPrompt BYTE "Please enter a tempo range. To set a specific tempo, type it in for both the min and the max.", 0 ; explains prompted input for user
minTempoPrompt BYTE "Enter the minimum tempo: ", 0                              ; prompts for min bpm
maxTempoPrompt BYTE "Enter the maximum tempo: ", 0                              ; prompts for max bpm
outTempoPrompt BYTE "The generated tempo is: ", 0                               ; tells user the limited rng bpm
modeAskMsg BYTE "Choose a mode; Sequencer (S) or Random (R): ", 0               ; prompts user to choose if music is in sequence or random
sequenceCountAskMsg BYTE "Enter the number of unique sequences: ", 0            ; if sequence is chosen, it asks for the number of them
sequenceMeasuresCountAskMsgP1 BYTE "Enter the number of measures in sequence " , 0
sequenceMeasuresCountAskMsgP2 BYTE ": ", 0                                      ; prompts user for number of measures in sequence
measurePrompt BYTE "Please enter a measure range. To set a specific number of measures, type it in for both the min and the max.", 0 ; explains to user what next prompts are for
minMeasurePrompt BYTE "Enter the minimum number of measures: ", 0               ; prompts for min wanted measures
maxMeasurePrompt BYTE "Enter the maximum number of measures: ", 0               ; prompts for max wanted measuers
outMeasurePrompt BYTE "The generated number of measures is: ", 0                ; outputs the limited rng measure generated
errorMsg BYTE "An error has occured. Terminating.", 0                           ; error message produced if something goes wrong
segmentNumOobErr BYTE "The segment number (in ESI) is out of bounds!", 0        ; tells if user segment is out of bounds
measureNumOobErr BYTE "The message number (in BL) is out of bounds!", 0         ; tells if user message is out of bounds
timeOorErr BYTE "The time (in BH) is too high!", 0                              ; tells if inputted time is out of bounds
pitchOorErr BYTE "The pitch (in DL) is too high!", 0                            ; tells if user pitch is too high
invalidRange BYTE "The range you specified is invalid!", 0

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
minTempo dword 0

; piano track
track1ChunkLen dword 84fh

; guitar track
track2ChunkLen dword 100fh

; drum track (not yet implemented)
track3ChunkLen dword 100fh

cPitch dword 3Ch                                ; middle c in midi

minMeasures dword 0                             ; minimum number of measrues to generate
measureCount dword 0                            ; variable of measures to generate

mode db 0

drumOffset dword 0bh
sequenceCount db 0

.data?
hFile  HANDLE ?                                 ; handle to the file
hHeap  HANDLE ?                                 ; handle to the heap
track1Chunk dword ?
track2Chunk dword ?
track3Chunk dword ?
measuresPerSequence dword ?
measuresInSequence dword ?
.code

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
    jb continue0                                ; jump if time is valid
    call DumpRegs                               ; clear registers
    mov edx, OFFSET timeOorErr                  ; pass type of error
    call Error                                  ; call time error if invalid
continue0:
    mov dl, pitch
    cmp dl, 80h                                 ; check that the pitch is valid
    jb continue1                                ; jump if pitch is valid
    call DumpRegs                               ; clear registers
    mov edx, OFFSET pitchOorErr                 ; pass type of error
    call Error                                  ; call pitch error if invalid
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
    mov edx, OFFSET fileNamePrompt              ; preps prompt for user
    call WriteString                            ; prints prompt for user
    mov edx, OFFSET fileName                    ; preps variable for filename
    mov ecx, 0fbh
    call ReadString                             ; takes user's input
    mov fileName[eax], "."                      ; add .mid extension to file name
    mov fileName[eax+1], "m"
    mov fileName[eax+2], "i"
    mov fileName[eax+3], "d"
    call CreateOutputFile                       ; initializes .mid file creation
    .if EAX == INVALID_HANDLE_VALUE             ; checks for invalid handle
        call WriteWindowsMsg                    ; prints error
        jmp quit                                ; quits program
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
    cmp eax, minTempo
    jae tempoContinue
    mov edx, OFFSET invalidRange
    call Error
tempoContinue:
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
    cmp eax, minMeasures
    jae randomContinue
    mov edx, OFFSET invalidRange
    call Error
randomContinue:
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
    mov ebx, 100h
    xor edx, edx
    mul ebx
    add eax, 0fh
    mov track3ChunkLen, eax

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
    mov [edi+9], BYTE PTR 0C9h
    mov [edi+0ah], BYTE PTR 119
    

    ; prepare counter for looping
    xor ecx, ecx

notes: 
    cmp ecx, measureCount
    je write
    call drum21
    jmp notesContinue
    mov eax, 14
    call RandomRange
    ; root of the decision tree
    cmp eax, 0fh
    jb belowF
    je drumCallF
    ja aboveF

    ; branch B
belowF:
    cmp eax, 7
    jb below7
    je drumCall7
    ja above7

    ; branch A
aboveF:
    cmp eax, 17h
    jb below17
    je drumCall17
    ja above17

    ; branch B -> B
below7:
    cmp eax, 3
    jb below3
    je drumCall3
    ja above3

    ; branch B -> A
above7:
    cmp eax, 0bh
    jb belowB
    je drumCallB
    ja aboveB

    ; branch A -> B
below17:
    cmp eax, 13h
    jb below13
    je drumCall13
    ja above13

    ; branch A -> A
above17:
    cmp eax, 1Bh
    jb below1B
    je drumCall1B
    ja above1B

    ; branch B -> B -> B
below3:
    cmp eax, 1
    jb drumCall0
    je drumCall1
    ja drumCall2

    ; branch B -> B -> A
above3:
    cmp eax, 5
    jb drumCall4
    je drumCall5
    ja drumCall6

    ; branch B -> A -> B
belowB:
    cmp eax, 9
    jb drumCall8
    je drumCall9
    ja drumCallA

    ; branch B -> A -> A
aboveB:
    cmp eax, 13
    jb drumCallC
    je drumCallD
    ja drumCallE

    ; branch A -> B -> B
below13:
    cmp eax, 11h
    jb drumCall10
    je drumCall11
    ja drumCall12

    ; branch A -> B -> A
above13:
    cmp eax, 15h
    jb drumCall14
    je drumCall15
    ja drumCall16

    ; branch A -> A -> B
below1B:
    cmp eax, 19h
    jb drumCall18
    je drumCall19
    ja drumCall1A

    ; branch A -> A -> A
above1B:
    cmp eax, 1dh
    jb drumCall1C
    je drumCall1D
    ja drumCall1E

    ; the calls themselves
drumCall0:
    call drum0
    jmp notesContinue
drumCall1:
    call drum1
    jmp notesContinue
drumCall2:
    call drum2
    jmp notesContinue
drumCall3:
    call drum3
    jmp notesContinue
drumCall4:
    call drum4
    jmp notesContinue
drumCall5:
    call drum5
    jmp notesContinue
drumCall6:
    call drum6
    jmp notesContinue
drumCall7:
    call drum7
    jmp notesContinue
drumCall8:
    call drum8
    jmp notesContinue
drumCall9:
    call drum9
    jmp notesContinue
drumCallA:
    call drumA
    jmp notesContinue
drumCallB:
    call drumB
    jmp notesContinue
drumCallC:
    call drumC
    jmp notesContinue
drumCallD:
    call drumD
    jmp notesContinue
drumCallE:
    call drumE
    jmp notesContinue
drumCallF:
    call drumF
    jmp notesContinue
drumCall10:
    call drum10
    jmp notesContinue
drumCall11:
    call drum11
    jmp notesContinue
drumCall12:
    call drum12
    jmp notesContinue
drumCall13:
    call drum13
    jmp notesContinue
drumCall14:
    call drum14
    jmp notesContinue
drumCall15:
    call drum15
    jmp notesContinue
drumCall16:
    call drum16
    jmp notesContinue
drumCall17:
    call drum17
    jmp notesContinue
drumCall18:
    call drum18
    jmp notesContinue
drumCall19:
    call drum19
    jmp notesContinue
drumCall1A:
    call drum1A
    jmp notesContinue
drumCall1B:
    call drum1B
    jmp notesContinue
drumCall1C:
    call drum1C
    jmp notesContinue
drumCall1D:
    call drum1D
    jmp notesContinue
drumCall1E:
    call drum1E
    jmp notesContinue
drumCall1F:
    call drum1F
    jmp notesContinue
drumCall20:
    call drum20
    jmp notesContinue
drumCall21:
    call drum21
    jmp notesContinue

    ; back to adding music notes
notesContinue:
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

    mov eax, drumOffset
    add eax, 4h
    mov track3ChunkLen, eax
    mov edi, track3Chunk
    mov eax, track3ChunkLen
    sub eax, 8
    mov [edi+7], al
    mov [edi+6], ah
    shr eax, 8
    mov [edi+5], ah
    shr eax, 8
    mov [edi+4], ah
    add edi, track3ChunkLen
    mov [edi-4], BYTE PTR 0
    mov [edi-3], BYTE PTR 0ffh
    mov [edi-2], BYTE PTR 2fh
    mov [edi-1], BYTE PTR 0

    ; write the third track
    mov ecx, track3ChunkLen
    mov eax, hFile
    mov edx, track3Chunk
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

drum0 PROC USES ECX EDI             ; tricky kicks 1
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0e0h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 12, 99h, 48  ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 35   ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48   ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48  ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum0 ENDP

drum1 PROC USES ECX EDI             ; tricky kicks 2
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0f0h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum1 ENDP

drum2 PROC USES ECX EDI             ; tricky kicks 3
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0e0h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum2 ENDP

drum3 PROC USES ECX EDI             ; tricky kicks 4
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 100h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum3 ENDP

drum4 PROC USES ECX EDI             ; 8th note hats
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0a0h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum4 ENDP

drum5 PROC USES ECX EDI             ; surfing with two hands
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0b0h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum5 ENDP

drum6 PROC USES ECX EDI             ; mixed hands
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0c0h
    mov ecx, 4
drumLoop0:
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    loop drumLoop0
    mov ecx, 4
drumLoop1:
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 38
    loop drumLoop1
    ret
drum6 ENDP

drum7 PROC USES ECX EDI             ; 1/4 note surfin
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 70h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 48, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 48, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 48, 89h, 48
    invoke noteEvent, 0, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum7 ENDP

drum8 PROC USES ECX EDI             ; 2 hand swing
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0a0h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 32, 89h, 45
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 16, 89h, 45
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 32, 89h, 38
    invoke noteEvent, 0, 89h, 45
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 16, 89h, 45
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum8 ENDP

drum9 PROC USES ECX EDI             ; kick and snare
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 40h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 48, 89h, 35
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 48, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum9 ENDP

drumA PROC USES ECX EDI             ; kick and snare var 1
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 40h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 48, 89h, 35
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 72, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 48, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drumA ENDP

drumB PROC USES ECX EDI             ; kick and snare var 2
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 50h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 48, 89h, 35
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 48, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 48, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drumB ENDP

drumC PROC USES ECX EDI             ; kick and snare var 3
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 60h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 48, 89h, 35
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 48, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    dec ecx
    jmp drumLoop
endLoop:
    ret
drumC ENDP

drumD PROC USES ECX EDI             ; baby's first rock beat
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0c0h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drumD ENDP

drumE PROC USES ECX EDI             ; blitzkrieg toms
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0c0h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 89h, 35
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 24, 89h, 38
    invoke noteEvent, 0, 89h, 45
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 24, 89h, 45
    dec ecx
    jmp drumLoop
endLoop:
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
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drumF ENDP

drum10 PROC USES ECX EDI            ; kick var 2
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0c0h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum10 ENDP

drum11 PROC USES ECX EDI             ; kick var 3
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0d0h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum11 ENDP

drum12 PROC USES ECX EDI             ; 8th note kicks 1
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0d0h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum12 ENDP

drum13 PROC USES ECX EDI            ; 8th note kicks 2
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0d0h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum13 ENDP

drum14 PROC USES ECX EDI            ; boom boom chick
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0e0h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum14 ENDP

drum15 PROC USES ECX EDI            ; you will, you will, rock us
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0e0h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum15 ENDP

drum16 PROC USES ECX EDI            ; robot rock
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 100h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum16 ENDP

drum17 PROC USES ECX EDI            ; 4 on the floor
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0e0h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum17 ENDP

drum18 PROC USES EDI                ; slow jam
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0b8h
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    ret
drum18 ENDP

drum19 PROC USES ECX EDI            ; surf's up
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0d0h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum19 ENDP

drum1A PROC USES ECX EDI          ; poodle skirt
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0d0h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum1A ENDP

drum1B PROC USES ECX EDI            ; motor city 1
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0e0h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum1B ENDP

drum1C PROC USES ECX EDI            ; motor city 2
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0f0h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum1C ENDP

drum1D PROC USES ECX EDI            ; late snare
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0e0h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum1D ENDP

drum1E PROC USES ECX EDI            ; prog rock
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 100h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum1E ENDP

drum1F PROC USES ECX EDI            ; hard rock hats
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 80h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 48, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 48, 89h, 48
    invoke noteEvent, 0, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum1F ENDP

drum20 PROC USES ECX EDI            ; hard rocl hats var 1
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 090h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 48, 89h, 45
    invoke noteEvent, 0, 89h, 35
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 48, 89h, 45
    invoke noteEvent, 0, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum20 ENDP

drum21 PROC USES ECX EDI            ; hard rock hats var 2
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0a0h
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 48, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 48, 89h, 48
    invoke noteEvent, 0, 89h, 38
    ret
drum21 ENDP

drumStub PROC USES ECX EDI
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 100h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    dec ecx
    jmp drumLoop
endLoop:
    ret
drumStub ENDP

END main