INCLUDE Irvine32.inc
INCLUDE Macros.inc
;Eduardo Rocha & Sergio Vasquez
;Assembly CS66

.386
.stack 4096
ExitProcess proto,dwExitcode:dword
INVALID_HANDLE_VALUE = 0;
.data
	;PROMPTS FOR KEY LENGTH --------------------
	prompt1 BYTE "Enter key length(0-9): ",0
	prompt2 BYTE "Your Key Length is: ",0
	arrayKey BYTE 10 DUP(0)		;The key generates
	sizetho DWORD ?				;size of ???
	len DWORD ?					;length of the key

	;VARIABLES FOR FILE INPUT -----------------
    BUFFER_SIZE = 5000		
	MAX = 5000
	filename BYTE 80 DUP(?)
    buffer BYTE MAX DUP(?)
    bytesRead DWORD ?
	fileHandle HANDLE ?
	byteCount DWORD ?
	modifiedByteCount DWORD ?

	;KEYS -------------------------
	arr DWORD 10 DUP(?)			;main key 
	encryptCode Dword 10 dup(?) ;encypted key
	decryptCode DWORD 10 dup(?) ;decrypted key = main key
	minVal DWORD ?

	;MESSAGE THAT WILL HOLD THE FILE -----------
	msg BYTE 550 DUP (' '),0				;original
	encryptedMsg BYTE 550 DUP(' '),0		;encrypted
	decryptedMsg BYTE 550 DUP(' '),0		;decrypted should = original
	row DWORD ?								;rows
	placeHolder DWORD 0

	counter DWORD 0

.code
main PROC

	call Randomize
	;--- OPENING UP THE FILE ----
	call Crlf
	mWrite "************* PART ONE ******************"
	call Crlf
	call openUp
	call Crlf
	
	;--- ASKING USER FOR KEY LENGTH ---
	mov edx,OFFSET prompt1
	call WriteString
	call ReadInt
	call Crlf
	mov edx,OFFSET prompt2
	call WriteString
	mov len,eax
	call WriteDec
	call Crlf

	;--- GENERATING RANDOM KEY of LENGTH--
	push OFFSET arr
	push len
	call generateKey

	;--testing the sub array by 10--
	;push offset arr
	;call restoreArray
	call Crlf
	
	;--GETTING THE ROW COUNT NEEDED--
	call getRows
	call Crlf

	;--ENCRYPTING THE KEY --
	mov ecx,0
	.while(ecx < len)
		call getMinEncrypt
		mov encryptCode[ecx*4],eax
		inc ecx
	.endw
	call Crlf

	;----ENCRYPTING THE MSG----
	mov ecx,0
	.while(ecx<len)
		mov eax,ecx					;eax = i
		imul eax,row				;eax = i*length
		push eax
		push encryptCode[ecx*4]		;encrypt[i]
		call encrypt
		inc ecx
	.endw
	mWrite "Encrypted Message: "
	call Crlf
	mov edx,OFFSET encryptedMsg
	call WriteString
	call Crlf

	;--------get the decrypted code---
	mov ecx,0
	.while(ecx<len)
		call getMinDecrypt
		mov decryptCode[ecx*4],eax
		inc ecx
	.endw


	;This segment of the code is used to decrpyt the key
	mov ecx,0
	.while(ecx<len)
		push ecx;i
		mov eax,row						;eax  = row
		imul eax,decryptCode[ecx*4]		;eax = decryptode[i]*length
		push eax
		call decrypt
		inc ecx
	.endw
	call Crlf
	mWrite "Decrypted Message: "
	call Crlf
	mov edx,OFFSET decryptedMsg
	call WriteString
	call Crlf
	call Crlf

	;========================================================================================
	mWrite "************* PART TWO ******************"
	call Crlf
	mov ebx,1
	mov eax,0
	.WHILE(eax != ebx) ;while we havent found the correct msg

	;--- GENERATING RANDOM KEY of LENGTH--
	push OFFSET arr
	push len
	call generateKey

	;--ENCRYPTING THE KEY --
	mov ecx,0
	.while(ecx < len)
		call getMinEncrypt
		mov encryptCode[ecx*4],eax
		inc ecx
	.endw

	;--------GET THE DECRYPTED KEY---
	mov ecx,0
	.while(ecx<len)
		call getMinDecrypt
		mov decryptCode[ecx*4],eax
		inc ecx
	.endw

	;-----DECRYPT THE MESSAGE----
	mov ecx,0
	.while(ecx<len)
		push ecx;i
		mov eax,row						;eax  = row
		imul eax,decryptCode[ecx*4]		;eax = decryptode[i]*length
		push eax
		call decrypt
		inc ecx
	.endw
	
	mov edx,counter
	inc edx
	mov counter,edx

	call linearSearch
	.ENDW
	call Crlf
	mWrite "FINALLY DONE! Decrypted Message: "
	call Crlf
	mov edx, OFFSET decryptedMsg
	call WriteString
	call Crlf
	mWrite "Attempt Count: "
	mov eax,counter
	call WriteDec
	call Crlf
		INVOKE ExitProcess,0
main ENDP

;----------------
getRows PROC
;----------------------
push ebp
mov ebp,esp
mov edx,1
mov ecx, byteCount
.while(edx != 0)
	mov eax,ecx
	mov edx, 0    
	mov ebx, len
	div ebx 
	.if(edx != 0)
		inc ecx
	.endif
	mov row,eax
.endw
mov modifiedByteCount,ecx
pop ebp
ret
getRows ENDP

;------------------------------------------------
generateKey PROC
;
;---------------------------------------------------
push ebp
mov ebp,esp
pushad
mov esi,[ebp+12]
mov ecx,[ebp+8]
EVALUATE:
	mov eax,10
	call RandomRange
	mov [esi],eax
	;inc esi
	add esi,4
	;call Randomize
	LOOP EVALUATE
QUIT:
	popad
	pop ebp
	ret 8
generateKey ENDP

;--------------------------
restoreArray PROC
; &arr
; ret 
; ebp
;----------------------------
push ebp
mov ebp,esp			;typical stack frame setup
mov ecx,len			;for(int i =0;i<length;++i)
mov esi,[ebp+8]
	L1:
		sub dword ptr [esi],10
		add esi,4
	loop L1
	pop ebp
	ret 4
restoreArray ENDP


;----------------------
getMinEncrypt PROC
;example 
;7 3 2 1
;----------------------
push ecx
push ebp
mov ebp,esp
mov ecx,0
mov ebx,0
mov minVal,0
.while(ecx<len)
	mov ebx,minVal
	mov ebx,arr[ebx*4];
	mov edx,arr[ecx*4]
	.IF(ebx > edx)
	mov minVal,ecx
	.ENDIF
	inc ecx
.endw
mov ebx,minVal
add arr[ebx*4],10
pop ebp
pop ecx
mov eax,minVal
ret
getMinEncrypt ENDP

;----------------
openUp PROC
;
;----------------
mWrite "Enter a filename: "
mov  EDX,OFFSET filename
mov ECX,MAX
call ReadString

mov  EDX,OFFSET filename
call OpenInputFile
mov  fileHandle, EAX

mov  eax,fileHandle
mov  edx,OFFSET buffer
mov  ecx,BUFFER_SIZE
call ReadFromFile
jc   ERROR
mov  bytesRead,eax
mWrite "TEXT: "
mov  edx,OFFSET buffer
call WriteString
call crlf
mWrite "BYTE COUNT: "
mov byteCount,eax
call WriteDec
call crlf

mov ecx,0
.while(ecx < byteCount)
mov al,BYTE PTR [edx]
mov msg[ecx],al
inc ecx
inc edx
.endw

RET
ERROR:
	mWrite "INVALID PATH!"
	RET
openUp ENDP


;----------------------
encrypt PROC
;
;----------------------
push ecx
push ebp
mov ebp,esp
mov ecx,0
mov esi,[ebp+12]	;esi = code
mov ebx,[ebp+16]	;ebx= r
.while(ecx < row)
	mov edx,ecx
	imul edx,len
	add edx,esi		;edx = i*len+code
	mov  al, byte ptr msg[edx]
	mov  encryptedMsg[ebx],al	
	inc ecx
	add ebx,1		;r++
.endw
	mov placeHolder,ebx
	pop ebp
	pop ecx
	ret 8
encrypt ENDP

;-----------------
getMinDecrypt PROC
;
;-----------------
push ecx
push ebp
mov ebp,esp
mov ecx,0
mov ebx,0
mov minVal,0
.while(ecx<len)
	mov ebx,minVal
	mov ebx,encryptCode[ebx*4]
	mov edx,encryptCode[ecx*4]
	.IF(ebx>edx)
		mov minVal,ecx
	.ENDIF
	inc ecx
.endw
mov ebx,minVal
add	encryptCode[ebx*4],10
	pop ebp
	pop ecx
	mov eax,minVal
	ret
getMinDecrypt ENDP

;--------------------
decrypt PROC
;
;--------------------
push ecx
push ebp
mov ebp,esp
mov ecx,0
mov edx,[ebp+12]	;edx = decryptcode[i]*length
mov ebx,[ebp+16]	;ebx  =  i
.while(ecx < row)
	mov eax,ecx;eax = i 
	imul eax,len;eax = i*length
	add eax,ebx;eax = i*length + r 
	push edx
	mov dl,byte ptr encryptedMsg[edx]
	mov decryptedMsg[eax],dl
	pop edx
	;mov decryptMsg[eax],encryptedMsg[edx]
	add edx,1
	inc ecx
.endw
pop ebp
pop ecx
ret 8
decrypt ENDP

;----------------------------------------									
;				PART 2 
;----------------------------------------
linearSearch PROC
	mov ecx,0
	mov eax,0
	mov esi,byteCount
	.while(ecx < esi)
		mov dl,msg[ecx]
		mov bl,decryptedMsg[ecx]
		.if(bl != dl)
			jmp QUIT
		.endif
		inc ecx
	.endw
	mov eax,1
	QUIT:
		mov ebx,1
		ret
linearSearch ENDP
end main