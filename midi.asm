INCLUDE Irvine32.inc
includelib Bcrypt.lib
.data

fileName BYTE 0fbh DUP(0)

invalidInputMsg BYTE "You have put in an invalid input. Please try again.", 0   ; if user entered something that was wrong
fileNamePrompt BYTE "Enter the filename: ", 0                                   ; prompts user for file name
tempoPrompt BYTE "Please enter a tempo range. To set a specific tempo, type it in for both the min and the max.", 0 ; explains prompted input for user
minTempoPrompt BYTE "Enter the minimum tempo: ", 0                              ; prompts for min bpm
maxTempoPrompt BYTE "Enter the maximum tempo: ", 0                              ; prompts for max bpm
outTempoPrompt BYTE "The generated tempo is: ", 0                               ; tells user the limited rng bpm
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

rootNames BYTE "C", 0, 0, 0,
               "C#", 0, 0,
               "D", 0, 0, 0,
               "D#", 0, 0,
               "E", 0, 0, 0,
               "F", 0, 0, 0,
               "F#", 0, 0,
               "G", 0, 0, 0,
               "G#", 0, 0,
               "A", 0, 0, 0,
               "A#", 0, 0,
               "B", 0

chordNames BYTE "M", 5 DUP (0), "m", 5 DUP (0),
                "5", 5 DUP (0), "7", 5 DUP (0),
                "M7", 4 DUP (0), "m7", 4 DUP (0), "mM7", 0, 0, 0
chordNames2 BYTE "6", 5 DUP (0), "m6", 4 DUP (0),
                 "add9", 0, 0, "madd9", 0,
                 "7b5", 0, 0, 0, "7#5", 0, 0, 0,
                 "m7b5", 0, 0, "m7#5", 0

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
tempo dword 0

; piano track
track1ChunkLen dword 84fh

; guitar track
track2ChunkLen dword 100fh

; drum track
track3ChunkLen dword 100fh

cPitch dword 3Ch                                ; middle c in midi

minMeasures dword 0                             ; minimum number of measrues to generate
measureCount dword 0                            ; variable of measures to generate

drumOffset dword 0bh
sequenceCount db 0

currentPitch byte 3ch
currentChord byte 0

rngHandle HANDLE ?

rngIdentifier WORD 52h, 4eh, 47h, 0
STD_OUTPUT_HANDLE EQU - 11

randomNum BYTE ?

numStr BYTE 8 DUP(0), "h"

.data?
hFile  HANDLE ?                                 ; handle to the file
hHeap  HANDLE ?                                 ; handle to the heap
consoleOutHandle dd ?
bytesWritten dd ?
track1Chunk dword ?
track2Chunk dword ?
track3Chunk dword ?
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

BCryptGenRandom PROTO,
    hAlgorithm : PTR DWORD,
    pbBuffer : PTR BYTE,
    cbBuffer : DWORD,
    dwFlags : DWORD,

BCryptOpenAlgorithmProvider PROTO,
    phAlgorithm:PTR DWORD,
    pszAlgId : PTR BYTE,
    pszImplementation : DWORD,
    dwFlags : DWORD

CreateFileW PROTO, ; create new file
    pFilename : PTR BYTE, ; ptr to filename
    accessMode : DWORD, ; access mode
    shareMode : DWORD, ; share mode
    lpSecurity : DWORD, ; can be NULL
    howToCreate : DWORD, ; how to create the file
    attributes : DWORD, ; file attributes
    htemplate : DWORD; handle to template file

GetProcessHeap PROTO

HeapAlloc PROTO,
    hHeap:DWORD, ; handle to private heap block
    dwFlags : DWORD, ; heap allocation control flags
    dwBytes : DWORD; number of bytes to allocate

HeapFree PROTO,
    hHeap:HANDLE, ; handle to heap with memory block
    dwFlags : DWORD, ; heap free options
    lpMem : DWORD; pointer to block to be freed

; ------------------------------------------------------------------------------
ConsoleWriteHex PROC USES EAX ECX,
    num:DWORD
; ------------------------------------------------------------------------------
    mov ecx, 7
    mov eax, num
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
    mov eax, num
    shr eax, 4
    mov num, eax
    cmp ecx, 0
    je write
    dec ecx
    jmp convertLoop
write:
    invoke WriteConsole, consoleOutHandle, offset numStr, 9, offset bytesWritten, 0
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

;-------------------------------------------------------------------------------
Error PROC
;-------------------------------------------------------------------------------
    invoke WriteConsole, consoleOutHandle, edx, ecx, offset bytesWritten, 0
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
    mov ecx, sizeof timeOorErr
    call Error                                  ; call time error if invalid
continue0:
    mov dl, pitch
    cmp dl, 80h                                 ; check that the pitch is valid
    jb continue1                                ; jump if pitch is valid
    call DumpRegs                               ; clear registers
    mov edx, OFFSET pitchOorErr                 ; pass type of error
    mov ecx, sizeof pitchOorErr
    call Error                                  ; call pitch error if invalid
continue1:
    mov dh, event
    mov [edi], bh                                ; delta time
    mov [edi + 1], dh                            ; note event
    mov [edi + 2], dl                            ; pitch in dl register
    mov [edi + 3], BYTE PTR 40h                  ; velocity of 64 (medium)
    add edi, 4
    ret
noteEvent ENDP

;
randRange PROC USES EAX ECX,
    upperBound:BYTE
;
try:
    invoke BCryptGenRandom, rngHandle, ADDR randomNum, 1, 0
    mov al, randomNum
    cmp al, upperBound
    ja try
    ret
randRange ENDP

main PROC
    ; initialize the randomizer
    call Randomize
    invoke BCryptOpenAlgorithmProvider, ADDR rngHandle, ADDR rngIdentifier, 0, 0

    invoke GetProcessHeap
    .if eax == NULL
        call WriteWindowsMsg
        jmp quit
    .endif
    mov hHeap, eax

    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov[consoleOutHandle], eax
    
    ; prompt for the filename and create the file, creating the header chunk
    invoke WriteConsole, consoleOutHandle, OFFSET fileNamePrompt, sizeof fileNamePrompt, offset bytesWritten, 0
    mov edx, OFFSET fileName                    ; preps variable for filename
    mov ecx, 0fbh
    call ReadString                             ; takes user's input
    mov fileName[eax], "."                      ; add .mid extension to file name
    mov fileName[eax+1], "m"
    mov fileName[eax+2], "i"
    mov fileName[eax+3], "d"
    INVOKE CreateFileA, ADDR fileName, FILE_APPEND_DATA, FILE_SHARE_READ, NULL, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, 0   ;using windows api
    .if EAX == INVALID_HANDLE_VALUE             ; checks for invalid handle
        call WriteWindowsMsg                    ; prints error
        jmp quit                                ; quits program
    .endif
    mov hFile,eax
    mov ecx, headerChunkLen
    mov edx, OFFSET headerChunk
    invoke WriteFile, eax, edx, ecx, NULL, NULL ; using windows api
    .if EAX == 0
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif

    ; prompt for tempo and display the result to the user
    mov edx, OFFSET tempoPrompt
    invoke WriteConsole, consoleOutHandle, OFFSET tempoPrompt, sizeof tempoPrompt, offset bytesWritten, 0
    call crLf
    invoke WriteConsole, consoleOutHandle, OFFSET minTempoPrompt, sizeof minTempoPrompt, offset bytesWritten, 0
    call readInt
    cmp eax, 0
    jg tempoContinue0
    mov edx, OFFSET invalidRange
    mov ecx, sizeof invalidRange
    call Error
tempoContinue0:
    mov minTempo, eax
    invoke WriteConsole, consoleOutHandle, OFFSET maxTempoPrompt, sizeof maxTempoPrompt, offset bytesWritten, 0
    call readInt
    cmp eax, minTempo
    jae tempoContinue
    mov edx, OFFSET invalidRange
    mov ecx, sizeof invalidRange
    call Error
tempoContinue:
    sub eax, minTempo
    add eax, 1
    invoke randRange, al
    mov al, randomNum
    add eax, minTempo
    mov tempo, eax
    invoke WriteConsole, consoleOutHandle, OFFSET outTempoPrompt, sizeof outTempoPrompt, offset bytesWritten, 0
    invoke ConsoleWriteHex, tempo
    call crLf

    ; store the tempo
    mov ebx, tempo
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
    invoke WriteFile, eax, edx, ecx, NULL, NULL
    .if EAX == 0
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif

random:
    ; prompt for measures and display the result to the user
    invoke WriteConsole, consoleOutHandle, OFFSET measurePrompt, sizeof measurePrompt, offset bytesWritten, 0
    call crLf
    mov edx, OFFSET minMeasurePrompt
    invoke WriteConsole, consoleOutHandle, OFFSET minMeasurePrompt, sizeof minMeasurePrompt, offset bytesWritten, 0
    call readInt
    cmp eax, 0
    jg randomContinue0
    mov edx, OFFSET invalidRange
    mov ecx, sizeof invalidRange
    call Error
randomContinue0:
    mov minMeasures, eax
    mov edx, OFFSET maxMeasurePrompt
    invoke WriteConsole, consoleOutHandle, OFFSET maxMeasurePrompt, sizeof maxMeasurePrompt, offset bytesWritten, 0
    call readInt
    cmp eax, minMeasures
    jae randomContinue1
    mov edx, OFFSET invalidRange
    mov ecx, sizeof invalidRange
    call Error
randomContinue1:
    sub eax, minMeasures
    invoke randRange, al
    mov al, randomNum
    add eax, minMeasures
    mov measureCount, eax
    invoke WriteConsole, consoleOutHandle, OFFSET outMeasurePrompt, sizeof outMeasurePrompt, offset bytesWritten, 0
    mov eax, measureCount
    invoke ConsoleWriteHex, measureCount
    call crLf
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
    mov ebx, 140h
    xor edx, edx
    mul ebx
    add eax, 0fh
    mov track3ChunkLen, eax

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
    mov eax, 3eh
    invoke randRange, al
    mov al, randomNum
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

    ; branch B -> B
belowF:
    cmp eax, 7
    jb below7
    je drumCall7
    ja above7

    ; branch B -> A
aboveF:
    cmp eax, 17h
    jb below17
    je drumCall17
    ja above17

    ; branch A -> B
below2F:
    cmp eax, 27h
    jb below27
    je drumCall27
    ja above27

    ; branch A -> A
above2F:
    cmp eax, 37h
    jb below37
    je drumCall37
    ja above37

    ; branch B -> B -> B
below7:
    cmp eax, 3
    jb below3
    je drumCall3
    ja above3

    ; branch B -> B -> A
above7:
    cmp eax, 0bh
    jb belowB
    je drumCallB
    ja aboveB

    ; branch B -> A -> B
below17:
    cmp eax, 13h
    jb below13
    je drumCall13
    ja above13

    ; branch B -> A -> A
above17:
    cmp eax, 1Bh
    jb below1B
    je drumCall1B
    ja above1B

    ; branch A -> B -> B
below27:
    cmp eax, 23h
    jb below23
    je drumCall23
    ja above23

    ; branch A -> B -> A
above27:
    cmp eax, 2Bh
    jb below2B
    je drumCall2B
    ja above2B

    ; branch A -> A -> B
below37:
    cmp eax, 33h
    jb below33
    je drumCall33
    ja above33

    ; branch A -> A -> A
above37:
    cmp eax, 3Bh
    jb below3B
    je drumCall3B
    ja above3B

    ; branch B -> B -> B -> B
below3:
    cmp eax, 1
    jb drumCall0
    je drumCall1
    ja drumCall2

    ; branch B -> B -> B -> A
above3:
    cmp eax, 5
    jb drumCall4
    je drumCall5
    ja drumCall6

    ; branch B -> B -> A -> B
belowB:
    cmp eax, 9
    jb drumCall8
    je drumCall9
    ja drumCallA

    ; branch B -> B -> A -> A
aboveB:
    cmp eax, 0dh
    jb drumCallC
    je drumCallD
    ja drumCallE

    ; branch B -> A -> B -> B
below13:
    cmp eax, 11h
    jb drumCall10
    je drumCall11
    ja drumCall12

    ; branch B -> A -> B -> A
above13:
    cmp eax, 15h
    jb drumCall14
    je drumCall15
    ja drumCall16

    ; branch B -> A -> A -> B
below1B:
    cmp eax, 19h
    jb drumCall18
    je drumCall19
    ja drumCall1A

    ; branch B -> A -> A -> A
above1B:
    cmp eax, 1dh
    jb drumCall1C
    je drumCall1D
    ja drumCall1E

    ; branch A -> B -> B -> B
below23:
    cmp eax, 21h
    jb drumCall20
    je drumCall21
    ja drumCall22

    ; branch A -> B -> B -> A
above23:
    cmp eax, 25h
    jb drumCall24
    je drumCall25
    ja drumCall26

    ; branch A -> B -> A -> B
below2B:
    cmp eax, 29h
    jb drumCall28
    je drumCall29
    ja drumCall2A

    ; branch A -> B -> A -> A
above2B:
    cmp eax, 2dh
    jb drumCall2C
    je drumCall2D
    ja drumCall2E

    ; branch A -> B -> B -> B
below33:
    cmp eax, 31h
    jb drumCall30
    je drumCall31
    ja drumCall32

    ; branch A -> B -> B -> A
above33:
    cmp eax, 35h
    jb drumCall34
    je drumCall35
    ja drumCall36

    ; branch A -> B -> A -> B
below3B:
    cmp eax, 39h
    jb drumCall38
    je drumCall39
    ja drumCall3A

    ; branch B -> B -> A -> A
above3B:
    cmp eax, 3dh
    jb drumCall3C
    je drumCall3D
    ja drumCall3E

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
drumCall22:
    call drum22
    jmp notesContinue
drumCall23:
    call drum23
    jmp notesContinue
drumCall24:
    call drum24
    jmp notesContinue
drumCall25:
    call drum25
    jmp notesContinue
drumCall26:
    call drum26
    jmp notesContinue
drumCall27:
    call drum27
    jmp notesContinue
drumCall28:
    call drum28
    jmp notesContinue
drumCall29:
    call drum29
    jmp notesContinue
drumCall2A:
    call drum2A
    jmp notesContinue
drumCall2B:
    call drum2B
    jmp notesContinue
drumCall2C:
    call drum2C
    jmp notesContinue
drumCall2D:
    call drum2D
    jmp notesContinue
drumCall2E:
    call drum2E
    jmp notesContinue
drumCall2F:
    call drum2F
    jmp notesContinue
drumCall30:
    call drum30
    jmp notesContinue
drumCall31:
    call drum31
    jmp notesContinue
drumCall32:
    call drum32
    jmp notesContinue
drumCall33:
    call drum33
    jmp notesContinue
drumCall34:
    call drum34
    jmp notesContinue
drumCall35:
    call drum35
    jmp notesContinue
drumCall36:
    call drum36
    jmp notesContinue
drumCall37:
    call drum37
    jmp notesContinue
drumCall38:
    call drum38
    jmp notesContinue
drumCall39:
    call drum39
    jmp notesContinue
drumCall3A:
    call drum3A
    jmp notesContinue
drumCall3B:
    call drum3B
    jmp notesContinue
drumCall3C:
    call drum3C
    jmp notesContinue
drumCall3D:
    call drum3D
    jmp notesContinue
drumCall3E:
    call drum3E
    jmp notesContinue
    ; back to adding music notes
notesContinue:
    mov eax, 11
    invoke randRange, al
    mov al, randomNum
    add eax, cPitch
    mov currentPitch, al
    mov eax, ecx
    xor edx, edx
    mov ebx, 33
    mul ebx
    add eax, 11
    mov edi, eax
    add edi, track1Chunk
    xor edx, edx
    mov eax, 14
    invoke randRange, al
    mov al, randomNum
    mov ebx, 3
    mul ebx
    mov currentChord, al
    xor eax, eax
    mov al, currentChord
    mov esi, OFFSET chordVals
    add esi, eax

    xor edx, edx
    mov dl, currentPitch
    sub edx, cPitch
    shl edx, 2
    add edx, OFFSET rootNames
    push ecx
    invoke WriteConsole, consoleOutHandle, edx, 2, offset bytesWritten, 0
    xor edx, edx
    mov dl, currentChord
    shl edx, 1
    add edx, OFFSET chordNames
    invoke WriteConsole, consoleOutHandle, edx, 5, offset bytesWritten, 0
    pop ecx
    call CrLf

    xor edx, edx

    ; bottom note on
    INVOKE noteEvent, 0, 90h, currentPitch

    ; second note on
    mov dl, currentPitch
    add dl, [esi]
    INVOKE noteEvent, 0, 90h, dl

    ; third note on
    mov dl, currentPitch
    add dl, [esi+1]
    INVOKE noteEvent, 0, 90h, dl

    ; top note on
    mov dl, currentPitch
    add dl, [esi+2]
    INVOKE noteEvent, 0, 90h, dl

    ; bottom note off
    mov dl, currentPitch
    mov [edi], BYTE PTR 83h
    mov [1+edi], BYTE PTR 00h
    mov [2+edi], BYTE PTR 80h
    mov [3+edi], dl
    mov [4+edi], BYTE PTR 40h
    add edi, 5

    ; second note off
    mov dl, currentPitch
    add dl, [esi]
    INVOKE noteEvent, 0, 80h, dl

    ; third note off
    mov dl, currentPitch
    add dl, [esi+1]
    INVOKE noteEvent, 0, 80h, dl

    ; top note off
    mov dl, currentPitch
    add dl, [esi+2]
    INVOKE noteEvent, 0, 80h, dl

    mov eax, ecx
    mov ebx, 40h
    xor edx, edx
    mul ebx
    add eax, 0bh
    mov edi, eax
    add edi, track2Chunk
    xor eax, eax
    mov al, currentChord
    mov esi, OFFSET chordVals
    add esi, eax
    mov eax, 2
    invoke randRange, al
    mov al, randomNum
    cmp eax, 1
    jb guitarPattern0
    je guitarPattern1
    ja guitarPattern2

guitarPattern0:
    ; bottom guitar note on
    mov dl, currentPitch
    sub dl, 12
    INVOKE noteEvent, 0, 91h, dl

    ; top guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 30h, 91h, dl

    ; bottom guitar note off
    mov dl, currentPitch
    sub dl, 12
    INVOKE noteEvent, 30h, 81h, dl


    ; second guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 0, 91h, dl

    ; top guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 30h, 81h, dl
    
    ; third guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 0, 91h, dl

    ; second guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 30h, 81h, dl

    ; bottom guitar note on
    mov dl, currentPitch
    sub dl, 12
    INVOKE noteEvent, 0, 91h, dl

    ; third guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 30h, 81h, dl


    ; top guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 0, 91h, dl


    ; bottom guitar note off
    mov dl, currentPitch
    sub dl, 12
    INVOKE noteEvent, 30h, 81h, dl


    ; second guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 0, 91h, dl

    ; top guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 30h, 81h, dl

    ; third guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 0, 91h, dl


    ; second guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 30h, 81h, dl

    ; third guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 0, 81h, dl

    inc ecx
    jmp notes

guitarPattern1:
    ; bottom guitar note on
    mov dl, currentPitch
    sub dl, 12
    INVOKE noteEvent, 0, 91h, dl

    ; third guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 30h, 91h, dl

    ; bottom guitar note off
    mov dl, currentPitch
    sub dl, 12
    INVOKE noteEvent, 30h, 81h, dl

    ; second guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 0, 91h, dl

    ; third guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 30h, 81h, dl
    
    ; top guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 0, 91h, dl

    ; second guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 30h, 81h, dl

    ; bottom guitar note on
    mov dl, currentPitch
    sub dl, 12
    INVOKE noteEvent, 0, 91h, dl

    ; top guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 30h, 81h, dl

    ; third guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 0, 91h, dl

    ; bottom guitar note off
    mov dl, currentPitch
    sub dl, 12
    INVOKE noteEvent, 30h, 81h, dl

    ; second guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 0, 91h, dl

    ; third guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 30h, 81h, dl

    ; top guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 0, 91h, dl

    ; second guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 30h, 81h, dl

    ; top guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 0, 81h, dl
    
    inc ecx
    jmp notes

guitarPattern2:
    ; bottom guitar note on
    mov dl, currentPitch
    sub dl, 12
    INVOKE noteEvent, 0, 91h, dl

    ; top guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 0, 91h, dl

    ; bottom guitar note off
    mov dl, currentPitch
    sub dl, 12
    INVOKE noteEvent, 60h, 81h, dl

    ; second guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 0, 91h, dl

    ; top guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 30h, 81h, dl
    
    ; third guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 0, 91h, dl

    ; second guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 30h, 81h, dl

    ; bottom guitar note on
    mov dl, currentPitch
    sub dl, 12
    INVOKE noteEvent, 0, 91h, dl

    ; third guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 30h, 81h, dl

    ; top guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 0, 91h, dl

    ; bottom guitar note off
    mov dl, currentPitch
    sub dl, 12
    INVOKE noteEvent, 30h, 81h, dl

    ; second guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 0, 91h, dl

    ; top guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+2]
    INVOKE noteEvent, 30h, 81h, dl

    ; third guitar note on
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi+1]
    INVOKE noteEvent, 0, 91h, dl

    ; second guitar note off
    mov dl, currentPitch
    sub dl, 12
    add dl, [esi]
    INVOKE noteEvent, 30h, 81h, dl

    ; third guitar note off
    mov dl, currentPitch
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
    invoke WriteFile, eax, edx, ecx, NULL, NULL
    .if EAX == 0
        call WriteWindowsMsg
        jmp closeAndQuit
   .endif
    invoke HeapFree, hHeap, 0, track1Chunk

    ; write the second track
    mov ecx, track2ChunkLen
    mov eax, hFile
    mov edx, track2Chunk
    invoke WriteFile, eax, edx, ecx, NULL, NULL
    .if EAX == 0
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif
    invoke HeapFree, hHeap, 0, track2Chunk

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
    invoke WriteFile, eax, edx, ecx, NULL, NULL
    .if EAX == 0
        call WriteWindowsMsg
        jmp closeAndQuit
    .endif
    invoke HeapFree, hHeap, 0, track3Chunk

closeAndQuit:
    mov eax, hFile
    invoke CloseHandle, eax         ; using windows api

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
    invoke noteEvent, 12, 99h, 48   ; Hi Mid Tom
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
    cmp ecx, 0
    je endLoop0
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    loop drumLoop0
endLoop0:
    mov ecx, 4
drumLoop1:
    cmp ecx, 0
    je endLoop1
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 38
    dec ecx
    loop drumLoop1
endLoop1:
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

drum21 PROC USES EDI                ; hard rock hats var 2
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

drum22 PROC USES ECX EDI            ; upbeat hats 1
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 80h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum22 ENDP

drum23 PROC USES ECX EDI            ; upbeat hats 2
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 90h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum23 ENDP

drum24 PROC USES ECX EDI            ;tricky snares 1
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
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
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
drum24 ENDP

drum25 PROC USES ECX EDI            ; tricky snares 2
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
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
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
drum25 ENDP

drum26 PROC USES ECX EDI            ; tricky snares 3
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
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
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
drum26 ENDP

drum27 PROC USES ECX EDI            ; tricky snares 4
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
    invoke noteEvent, 24, 89h, 48
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
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
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
drum27 ENDP

drum28 PROC USES EDI                ; punk toms
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0f8h
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 89h, 35
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 89h, 35
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 12, 89h, 45
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 89h, 35
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 89h, 35
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 12, 89h, 45
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 89h, 35
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 89h, 35
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 89h, 35
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 89h, 35
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 89h, 35
    ret
drum28 ENDP

drum29 PROC USES ECX EDI              ; reggaeton
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
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum29 ENDP

drum2A PROC USES ECX EDI              ; a latin rhythm
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
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
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
drum2A ENDP

drum2B PROC USES ECX EDI            ; big band toms
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 120h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 89h, 45
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 12, 89h, 45
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 45
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 45
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 45
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 24, 89h, 45
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 45    ; low tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 89h, 45
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum2B ENDP

drum2C PROC USES EDI                ; snare polyrhythm
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0f0h
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
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
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    ret
drum2C ENDP

drum2D PROC USES ECX EDI            ; 16th double kicks 1
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
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 48
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
drum2D ENDP

drum2E PROC USES ECX EDI            ; 16th double kicks 2
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0f0h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
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
drum2E ENDP

drum2F PROC USES EDI                ; kick this way
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0e0h
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
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
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
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
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
    ret
drum2F ENDP

drum30 PROC USES ECX EDI            ; metal motown
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
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
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
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum30 ENDP

drum31 PROC USES EDI                ; kick polyrhythm
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0f0h
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
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
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
    invoke noteEvent, 24, 89h, 48
    ret
drum31 ENDP

drum32 PROC USES ECX EDI            ; snare doubles 1
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
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
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
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum32 ENDP

drum33 PROC USES ECX EDI            ; snare doubles 2
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
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum33 ENDP

drum34 PROC USES ECX EDI            ; smells like that beat
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0e0h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 36, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 36, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 24, 89h, 35
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum34 ENDP

drum35 PROC USES ECX EDI            ; disco 1
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 120h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum35 ENDP

drum36 PROC USES ECX EDI            ; disco 2
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 140h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum36 ENDP

drum37 PROC USES ECX EDI            ; disco 3
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 140h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum37 ENDP

drum38 PROC USES ECX EDI            ; disco 4
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 120h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum38 ENDP

drum39 PROC USES ECX EDI            ; the beat that feeds
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 100h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 12, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum39 ENDP

drum3A PROC USES ECX EDI            ; fast punk 1
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 100h
    mov ecx, 8
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum3A ENDP

drum3B PROC USES ECX EDI            ; fast punk 2
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
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum3B ENDP

drum3C PROC USES ECX EDI            ; fast punk 3
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 120h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 24, 89h, 35
    invoke noteEvent, 0, 89h, 48
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
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 24, 89h, 48
    invoke noteEvent, 0, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum3C ENDP

drum3D PROC USES ECX EDI            ; swing the hats
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0c0h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 36, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 36, 89h, 48
    invoke noteEvent, 0, 89h, 38
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 12, 89h, 48
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum3D ENDP

drum3E PROC USES ECX EDI            ; swing the kick
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 0a0h
    mov ecx, 4
drumLoop:
    cmp ecx, 0
    je endLoop
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 36, 89h, 35
    invoke noteEvent, 0, 89h, 48
    invoke noteEvent, 0, 99h, 35    ; Acoustic Bass Drum
    invoke noteEvent, 12, 89h, 35
    invoke noteEvent, 0, 99h, 48    ; Hi Mid Tom
    invoke noteEvent, 0, 99h, 38    ; Acoustic Snare
    invoke noteEvent, 48, 89h, 48
    invoke noteEvent, 0, 89h, 38
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum3E ENDP

drum PROC USES ECX EDI            ;
    mov edi, drumOffset
    add edi, track3Chunk
    add drumOffset, 140h
    mov ecx, 2
drumLoop:
    cmp ecx, 0
    je endLoop
    dec ecx
    jmp drumLoop
endLoop:
    ret
drum ENDP


END main