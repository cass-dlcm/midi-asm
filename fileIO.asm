.686P
.model flat, stdcall
.stack 4096
.data
NULL = 0
FILE_APPEND_DATA = 4
CREATE_NEW = 1
FILE_SHARE_READ = 1
FILE_ATTRIBUTE_NORMAL = 80h
.code

CreateFileA PROTO, ; create new file
	pFilename : PTR BYTE, ; ptr to filename
	accessMode : DWORD, ; access mode
	shareMode : DWORD, ; share mode
	lpSecurity : DWORD, ; can be NULL
	howToCreate : DWORD, ; how to create the file
	attributes : DWORD, ; file attributes
	htemplate : DWORD; handle to template file

ReadFile PROTO,
	hFile:DWORD,
	lpBuffer:DWORD,
	nNumberOfBytesToRead:DWORD,
	lpNumberOfBytesRead:DWORD,
	lpOverlapped:DWORD

WriteFile PROTO,
	hFile:DWORD,
	lpBuffer : DWORD,
	nNumberOfBytesToWrite : DWORD,
	lpNumberOfBytesWritten : DWORD,
	lpOverlapped : DWORD

fileCreate PROC,
	pFilename : PTR BYTE
	invoke CreateFileA, pFilename, FILE_APPEND_DATA, FILE_SHARE_READ, NULL, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, 0; using windows api
	ret
fileCreate ENDP

fileRead PROC,
	hFile:DWORD,
	lpBuffer:DWORD,
	nNumberOfBytesToRead: DWORD
	invoke ReadFile, hFile, lpBuffer, nNumberofBytesToRead, NULL, NULL
	ret
fileRead ENDP

fileWrite PROC, 
	hFile:DWORD,
	lpBuffer : DWORD,
	nNumberOfBytesToWrite : DWORD
	invoke WriteFile, hFile, lpBuffer, nNumberOfBytesToWrite, NULL, NULL
	ret
fileWrite ENDP
END