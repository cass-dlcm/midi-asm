.686P; Pentium Pro or later
.MODEL flat, stdcall
.STACK 4096
includelib Bcrypt.lib
.data
rngHandle DWORD ?
rngIdentifier WORD 52h, 4eh, 47h, 0
randomNum BYTE 0
.code
BCryptGenRandom PROTO,
	hAlgorithm : PTR DWORD,
	pbBuffer : PTR BYTE,
	cbBuffer : DWORD,
	dwFlags : DWORD,

BCryptOpenAlgorithmProvider PROTO,
	phAlgorithm : PTR DWORD,
	pszAlgId : PTR BYTE,
	pszImplementation : DWORD,
	dwFlags : DWORD

randInit PROC
	invoke BCryptOpenAlgorithmProvider, ADDR rngHandle, ADDR rngIdentifier, 0, 0
randInit ENDP

; ------------------------------------------------------------------------------ -
randRange PROC USES ECX,
	upperBound:BYTE
; ------------------------------------------------------------------------------ -
try:
	invoke BCryptGenRandom, rngHandle, ADDR randomNum, 1, 0
	mov al, randomNum
	cmp al, upperBound
	ja try
	ret
randRange ENDP
END