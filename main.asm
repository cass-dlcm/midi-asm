.686P
.MODEL flat, stdcall
.STACK 4096
includelib Kernel32.lib
.data 
extern fileNamePrompt:BYTE
extern fileNamePromptLen:DWORD
extern tempoPrompt:BYTE
extern tempoPromptLen:DWORD
extern minTempoPrompt:BYTE
extern minTempoPromptLen:DWORD
extern maxTempoPrompt:BYTE
extern maxTempoPromptLen:DWORD
extern outTempoPrompt:BYTE
extern outTempoPromptLen:DWORD
extern measurePrompt:BYTE
extern measurePromptLen:DWORD
extern minMeasurePrompt:BYTE
extern minMeasurePromptLen:DWORD
extern maxMeasurePrompt:BYTE
extern maxMeasurePromptLen:DWORD
extern outMeasurePrompt:BYTE
extern outMeasurePromptLen:DWORD
extern errorMsg:BYTE
extern invalidRange:BYTE
extern testStr:BYTE
extern crLfStr:BYTE
extern consoleOutHandle:DWORD
extern consoleInHandle:DWORD
extern bytesRead:DWORD
extern numStr:BYTE
extern drumOffset:DWORD

externdef track3Chunk:dword

fileName BYTE 0ffh DUP(0)

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

sequenceCount db 0

currentPitch byte 3ch
currentChord byte 0

HEAP_ZERO_MEMORY = 00000008h
NULL = 0
INVALID_HANDLE_VALUE = -1
FILE_APPEND_DATA = 4
CREATE_NEW = 1
FILE_SHARE_READ = 1
FILE_ATTRIBUTE_NORMAL = 80h
inString BYTE 8 DUP(0), "h"

.data?
hFile  DWORD ?                                  ; handle to the file
hHeap  DWORD  ?                                 ; handle to the heap
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

CreateFileA PROTO, ; create new file
pFilename : PTR BYTE, ; ptr to filename
accessMode : DWORD, ; access mode
shareMode : DWORD, ; share mode
lpSecurity : DWORD, ; can be NULL
howToCreate : DWORD, ; how to create the file
attributes : DWORD, ; file attributes
htemplate : DWORD; handle to template file

CloseHandle PROTO,
hObject:DWORD

ConsoleWriteHex PROTO,
num : DWORD

ExitProcess PROTO,
uExitCode : DWORD

GetProcessHeap PROTO

GetStdHandle PROTO,
nStdHandle : DWORD

HeapAlloc PROTO,
hHeap : DWORD, ; handle to private heap block
dwFlags : DWORD, ; heap allocation control flags
dwBytes : DWORD; number of bytes to allocate

HeapFree PROTO,
hHeap:DWORD, ; handle to heap with memory block
dwFlags : DWORD, ; heap free options
lpMem : DWORD; pointer to block to be freed

hexStrToNum PROTO,
value:DWORD

initIO PROTO

readConsole PROTO,
readLoc : DWORD,
readAmount : DWORD

randInit PROTO

randRange PROTO,
    :BYTE

writeConsole PROTO,
    prompt : DWORD,
    promptSize : DWORD

WriteFile PROTO,
    hFile:DWORD,
    lpBuffer:DWORD,
    nNumberOfBytesToWrite:DWORD,
    lpNumberOfBytesWritten:DWORD,
    lpOverlapped:DWORD

; procedures from midi.asm
noteEvent proto,
    time:byte,
    event:byte,
    pitch:byte

; procedures from drumGen.asm
drumChoose proto

; ------------------------------------------------------------------------------ -
Error PROC
; ------------------------------------------------------------------------------ -
    invoke writeConsole, edx, ecx
    invoke ExitProcess, 0
    ret
Error ENDP

main PROC
    ; initialize the randomizer
    call randInit
    invoke GetProcessHeap
    .if eax == NULL
        jmp quit
    .endif
    mov hHeap, eax

    call initIO
    
    ; prompt for the filename and create the file, creating the header chunk
    invoke writeConsole, offset fileNamePrompt, fileNamePromptLen
    invoke readConsole, offset fileName, 0fdh
    mov eax, bytesRead
    sub eax, 2                                  ; to account for the Cr and Lf chars
    mov fileName[eax], "."                      ; add .mid extension to file name
    mov fileName[eax+1], "m"
    mov fileName[eax+2], "i"
    mov fileName[eax+3], "d"
    INVOKE CreateFileA, ADDR fileName, FILE_APPEND_DATA, FILE_SHARE_READ, NULL, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, 0   ;using windows api
    .if EAX == INVALID_HANDLE_VALUE             ; checks for invalid handle
        jmp quit                                ; quits program
    .endif
    mov hFile,eax
    mov ecx, headerChunkLen
    mov edx, OFFSET headerChunk
    invoke WriteFile, eax, edx, ecx, NULL, NULL ; using windows api
    .if EAX == 0
        jmp closeAndQuit
    .endif

    ; prompt for tempo and display the result to the user
    mov edx, OFFSET tempoPrompt
    invoke writeConsole, offset tempoPrompt, tempoPromptLen
    invoke writeConsole, offset crLfStr, 2
    invoke writeConsole, offset minTempoPrompt, minTempoPromptLen
    invoke readConsole, offset inString, 11
    INVOKE hexStrToNum, OFFSET inString
    ;INVOKE consoleWriteHex, eax
    cmp eax, 0
    jg tempoContinue0
    mov edx, OFFSET invalidRange
    mov ecx, sizeof invalidRange
    call Error
tempoContinue0:
    mov minTempo, eax
    invoke writeConsole, offset maxTempoPrompt, maxTempoPromptLen
    invoke readConsole, offset inString, 11
    invoke hexStrToNum, offset inString
    cmp eax, minTempo
    jae tempoContinue
    mov edx, OFFSET invalidRange
    mov ecx, sizeof invalidRange
    call Error
tempoContinue:
    sub eax, minTempo
    invoke randRange, al
    add eax, minTempo
    mov tempo, eax
    invoke writeConsole, offset outTempoPrompt, outTempoPromptLen
    invoke ConsoleWriteHex, tempo
    invoke writeConsole, offset crLfStr, 2

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
        jmp closeAndQuit
    .endif

random:
    ; prompt for measures and display the result to the user
    invoke writeConsole, offset measurePrompt, measurePromptLen
    invoke writeConsole, offset crLfStr, 2
    invoke writeConsole, offset minMeasurePrompt, minMeasurePromptLen
    invoke readConsole, offset inString, 11
    invoke hexStrToNum, offset inString
    cmp eax, 0
    jg randomContinue0
    mov edx, OFFSET invalidRange
    mov ecx, sizeof invalidRange
    call Error
randomContinue0:
    mov minMeasures, eax
    invoke writeConsole, offset maxMeasurePrompt, maxMeasurePromptLen
    invoke readConsole, offset inString, 11
    invoke hexStrToNum, offset inString
    cmp eax, minMeasures
    jae randomContinue1
    mov edx, OFFSET invalidRange
    mov ecx, sizeof invalidRange
    call Error
randomContinue1:
    sub eax, minMeasures
    invoke randRange, al
    add eax, minMeasures
    mov measureCount, eax
    invoke writeConsole, offset outMeasurePrompt, outMeasurePromptLen
    invoke ConsoleWriteHex, measureCount
    invoke writeConsole, offset crLfStr, 2
    jmp trackPrep

trackPrep:
    mov eax, measureCount
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
    call drumChoose
    ; back to adding music notes
notesContinue:
    mov eax, 11
    invoke randRange, al
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
    invoke writeConsole, edx, 2
    xor edx, edx
    mov dl, currentChord
    shl edx, 1
    add edx, OFFSET chordNames
    invoke writeConsole, edx, 5
    invoke writeConsole, offset crLfStr, 2
    pop ecx

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
        jmp closeAndQuit
   .endif
    invoke HeapFree, hHeap, 0, track1Chunk

    ; write the second track
    mov ecx, track2ChunkLen
    mov eax, hFile
    mov edx, track2Chunk
    invoke WriteFile, eax, edx, ecx, NULL, NULL
    .if EAX == 0
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
        jmp closeAndQuit
    .endif
    invoke HeapFree, hHeap, 0, track3Chunk

closeAndQuit:
    mov eax, hFile
    invoke CloseHandle, eax         ; using windows api

quit:
	INVOKE ExitProcess, 0			; end the program
main ENDP

PUBLIC main
END main