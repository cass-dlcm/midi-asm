.686P
.model flat, stdcall
.stack 4096
.data
NULL = 0
FILE_APPEND_DATA = 4
CREATE_NEW = 1
OPEN_EXISTING = 3
FILE_SHARE_READ = 1
GENERIC_READ = 2147483648
FILE_ATTRIBUTE_NORMAL = 80h
HEAP_ZERO_MEMORY = 8h
readBytes0 DWORD ?
readBytes1 DWORD ?
readBytes2 DWORD ?
readBytes3 DWORD ?

extern hHeap: DWORD
.code

ConsoleWriteHex PROTO,
num : DWORD

CreateFileA PROTO, ; create new file
	pFilename : PTR BYTE, ; ptr to filename
	accessMode : DWORD, ; access mode
	shareMode : DWORD, ; share mode
	lpSecurity : DWORD, ; can be NULL
	howToCreate : DWORD, ; how to create the file
	attributes : DWORD, ; file attributes
	htemplate : DWORD; handle to template file

HeapAlloc PROTO,
	hHeap : DWORD, ; handle to private heap block
	dwFlags : DWORD, ; heap allocation control flags
	dwBytes : DWORD; number of bytes to allocate

HeapFree PROTO,
	hHeap : DWORD, ; handle to heap with memory block
	dwFlags : DWORD, ; heap free options
	lpMem : DWORD; pointer to block to be freed

ReadFile PROTO,
	hFile:DWORD,
	lpBuffer : DWORD,
	nNumberOfBytesToRead : DWORD,
	lpNumberOfBytesRead : DWORD,
	lpOverlapped : DWORD

WriteFile PROTO,
	hFile : DWORD,
	lpBuffer : DWORD,
	nNumberOfBytesToWrite : DWORD,
	lpNumberOfBytesWritten : DWORD,
	lpOverlapped : DWORD

; ------------------------------------------------------------------------------ -
fileCreate PROC,
	pFilename : PTR BYTE
; ------------------------------------------------------------------------------ -
	invoke CreateFileA, pFilename, FILE_APPEND_DATA, FILE_SHARE_READ, NULL, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, 0; using windows api
	ret
fileCreate ENDP

fileLoad PROC,
	pFilename : PTR BYTE
	invoke CreateFileA, pFilename, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	ret
fileLoad ENDP

; ------------------------------------------------------------------------------ -
fileRead PROC,
	hFile:DWORD,
	lpBuffer:DWORD,
	nNumberOfBytesToRead: DWORD
; ------------------------------------------------------------------------------ -
	invoke ReadFile, hFile, lpBuffer, nNumberofBytesToRead, NULL, NULL
	ret
fileRead ENDP

; ------------------------------------------------------------------------------ -
fileWrite PROC,
	hFile:DWORD,
	lpBuffer : DWORD,
	nNumberOfBytesToWrite : DWORD
; ------------------------------------------------------------------------------ -
	invoke WriteFile, hFile, lpBuffer, nNumberOfBytesToWrite, NULL, NULL
	ret
fileWrite ENDP

; ------------------------------------------------------------------------------ -
readVLQ PROC uses edx edi,
	hFile:DWORD
; ------------------------------------------------------------------------------ -
	invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, 1
	mov readBytes0, eax
	invoke fileRead, hFile, readBytes0, 1
	mov edi, readBytes0
	mov al, [edi]
	cmp al, 80h
	jae next
	mov al, [edi]
	ret
next:
	invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, 1
	mov readBytes1, eax
	invoke fileRead, hFile, readBytes1, 1
	mov edi, readBytes1
	mov al, [edi]
	cmp al, 80h
	jae next1
	mov edi, readBytes0
	mov al, [edi]
	and al, 7fh
	shl eax, 7
	mov edi, readBytes1
	add al, [edi]
	ret
next1:
	invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, 1
	mov readBytes2, eax
	invoke fileRead, hFile, readBytes2, 1
	mov edi, readBytes2
	mov al, [edi]
	cmp al, 80h
	jae next2
	mov edi, readBytes0
	mov al, [edi]
	and al, 7fh
	shl eax, 7
	xor edx, edx
	mov edi, readBytes1
	mov dl, [edi]
	add eax, edx
	add eax, -80h
	shl eax, 7
	mov edi, readBytes2
	add al, [edi]
	ret
next2:
	invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, 1
	mov readBytes3, eax
	invoke fileRead, hFile, readBytes3, 1
	mov edi, readBytes3
	mov al, [edi]
	cmp al, 80h
	jae err
	mov edi, readBytes0
	mov al, [edi]
	and al, 7fh
	shl eax, 7
	xor edx, edx
	mov edi, readBytes1
	mov dl, [edi]
	add eax, edx
	add eax, -80h
	shl eax, 7
	xor edx, edx
	mov edi, readBytes2
	mov dl, [edi]
	add eax, edx
	add eax, -80h
	shl eax, 7
	mov edi, readBytes3
	add al, [edi]
	ret
err:
	mov eax, -1
	ret
readVLQ endp


writeVLQ proc uses eax edx edi,
	hFile:DWORD,
	value:DWORD
	invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, 1
	mov edi, eax
	mov edx, value
	cmp edx, 1FFFFFh
	ja fourBytes
	mov edx, value
	cmp edx, 3FFFh
	ja threeBytes
	mov edx, value
	cmp edx, 7Fh
	ja twoBytes
	mov edx, value
	mov [edi], dl
	invoke ConsoleWriteHex, [edi]
	invoke fileWrite, hFile, edi, 1
	ret
twoBytes:
	mov edx, value
	shl edx, 1
	or edx, 8000h
	mov [edi], dh
	invoke fileWrite, hFile, edi, 1
	mov edx, value
	and edx, 7fh
	mov [edi], dl
	invoke fileWrite, hFile, edi, 1
	ret
threeBytes:
	mov edx, value
	shr edx, 6
	or edx, 8000h
	mov [edi], dh
	invoke fileWrite, hFile, edi, 1
	mov edx, value
	shl edx, 1
	or edx, 8000h
	mov [edi], dh
	invoke fileWrite, hFile, edi, 1
	mov edx, value
	and edx, 7fh
	mov[edi], dl
	invoke fileWrite, hFile, edi, 1
	ret
fourBytes:
	mov edx, value
	shr edx, 13
	or edx, 8000h
	mov [edi], dh
	invoke fileWrite, hFile, edi, 1
	mov edx, value
	shr edx, 6
	or edx, 8000h
	mov[edi], dh
	invoke fileWrite, hFile, edi, 1
	mov edx, value
	shl edx, 1
	or edx, 8000h
	mov[edi], dh
	invoke fileWrite, hFile, edi, 1
	mov edx, value
	and edx, 7fh
	mov[edi], dl
	invoke fileWrite, hFile, edi, 1
	ret
writeVLQ endp

END