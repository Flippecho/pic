;RC4-BS
;Written in assembly
;Generally based on RC4 algorithm
;Encoded by a modified Base16 that helps to avoid non-ASCII characters
;Copyright Baluth, All rights reserved.

.MODEL SMALL
.DATA

crlf db 13, 10, '$'
dash_line db '----------------------------------------'
		  db '----------------------------------------$'

msg0  db 'Welcome to use RC4-BS!', 13, 10, '$'
msg1  db 'Here are several options provided: ', 13, 10
	  db '1: Encrypt data from console.', 13, 10
	  db '2: Encrypt data from file.', 13, 10
	  db '3: Decrypt data from console.', 13, 10
	  db '4: Decrypt data from file', 13, 10
	  db '5: Clear Screen', 13, 10
	  db '0: Eixt', 13, 10
	  db 'Please enter a number to choose: $'
msg2  db 'Please enter the string to encrypt(len <= 127): ', 13, 10, '$'
msg3  db 'Please save the string in the file [iencrypt.txt] '
	  db 'before pressing [Enter].', 13, 10, '$'
msg4  db 'Please enter the string to decrypt(len <= 254): ', 13, 10, '$'
msg5  db 'Please save the string in the file [idecrypt.txt] '
	  db 'before pressing [Enter].', 13, 10, '$'
msg6  db 'Hope you enjoyed RC4-BS. See you next time!', 13, 10, '$'
msg7  db 'Wrong input! Please choose again!', 13, 10, '$'
msg8  db 'Please enter the encryption key(1 <= len <= 255): ', 13, 10, '$'
msg9  db 'Encryption done!', 13, 10
      db 'The encrypted string is: $'
msg10 db 'Decryption done!', 13, 10
      db 'The decrypted string is: $'
msg11 db 'Successfully read data from the file!', 13, 10, 'Data: $'
msg12 db 'The result can also be found in the file [oencrypt.txt].', 13, 10, '$'
msg13 db 'The result can also be found in the file [odecrypt.txt].', 13, 10, '$'		

opt_func db 255, 0, 255 dup(0)
variable_i db 0
variable_j db 0
variable_t db 0

iS db 256 dup(0)
iK db 256 dup('$')
aKey db 255, 0, 255 dup('$')

base16_str  db 'Baluth3721STEven$'
base16_dict db 49 dup(0), 9, 8, 6, 3 dup(0), 7, 10 dup(0), 0, 2 dup(0)
			db 12, 13 dup(0), 10, 11, 12 dup(0), 1, 3 dup(0), 14
			db 2 dup(0), 5, 3 dup(0), 2, 0, 15, 5 dup(0), 4, 3, 13

encoded_encrypted_string db 255, 0, 255 dup('$')
encoded_decrypted_string db 255 dup('$')
decoded_encrypted_string db 255 dup('$')
decoded_decrypted_string db 255, 0, 255 dup('$')

handle dw 0

input_encrypt_path  db 'c:\Assembly\iencrypt.txt', 0
input_decrypt_path  db 'c:\Assembly\idecrypt.txt', 0
output_encrypt_path db 'c:\Assembly\oencrypt.txt', 0
output_decrypt_path db 'c:\Assembly\odecrypt.txt', 0

.CODE
.STARTUP

welcome:		
	call clear_screen
	call print_dash_line

	mov ah, 9
	lea dx, msg0					;Welcome to use RC4-BS!
	int 21h

choose_func:
	call print_dash_line

	mov ah, 9
	lea dx, msg1					;Here are several options provided
	int 21h

	mov ah, 0ah
	lea dx, opt_func
	int 21h
	mov al, opt_func[2]
	sub al, 30h
	mov opt_func[2], al
	
	call print_one_crlf				;CRLF after input

	cmp opt_func[2], 0
	je goodbye
	cmp opt_func[2], 1
	je encrypt_from_console
	cmp opt_func[2], 2
	je encrypt_from_file
	cmp opt_func[2], 3
	je decrypt_from_console
	cmp opt_func[2], 4
	je decrypt_from_file
	cmp opt_func[2], 5
	je option_clear_screen

	call print_dash_line

	mov ah, 9
	lea dx, msg7					;Wrong input! Please choose again!
	int 21h

	jmp choose_func

option_clear_screen:
	call clear_screen
	jmp choose_func
	
encrypt_from_console:
	call print_dash_line
	call initialization
	call print_dash_line
	
	mov ah, 9
	lea dx, msg2					;Please enter the string to encrypt:
	int 21h

	mov ah, 0ah
	lea dx, decoded_decrypted_string		;Read in the string to encrypt.
	int 21h

	mov al, decoded_decrypted_string[1]
	shl al, 1 
	mov encoded_encrypted_string[1], al

	jmp encrypt_complete

encrypt_from_file:
	call print_dash_line
	call initialization
	call print_dash_line

	mov ah, 9
	lea dx, msg3					;Please save the string in the file...
	int 21h

	mov ah, 0ah
	lea dx, opt_func
	int 21h

	call print_dash_line

	mov ah, 3dh						;open the input encrypt file
	mov al, 0 						;mode: read only
	lea dx, input_encrypt_path
	int 21h
	jc quit							;quit if error

	mov handle, ax
	mov ah, 3fh						;read the input file
	mov bx, handle
	mov cx, 127						;max bytes to read
	lea dx, decoded_decrypted_string
	add dx, 2
	int 21h
	jc quit

	mov decoded_decrypted_string[1], al 		;record the bytes number
	shl al, 1 
	mov encoded_encrypted_string[1], al 		;record the bytes number

	mov ah, 3eh                 	;close the file
	mov bx, handle
	int 21h
	jc quit                     	;quit if error

	mov ah, 9
	lea dx, msg11					;Successfully read from file: 
	int 21h
	lea dx, decoded_decrypted_string
	add dx, 2
	int 21h

encrypt_complete:	
	call print_one_crlf
	call print_dash_line

	call encryption
	call encoding

	mov ah, 3ch						;open the output file and clear
	mov cx, 0 						;mode: default
    lea dx, output_encrypt_path
    int 21h
    jc quit							;quit if error

	mov handle, ax
	mov ah, 40h                 ;write file or device
	mov bx, handle
	mov cl, encoded_encrypted_string[1]			;number of bytes
	lea dx, encoded_encrypted_string[2]
	int 21h
	jc quit                     ;quit if error

	mov ah, 3eh                 ;close the file
	mov bx, handle
	int 21h

	mov ah, 9
	lea dx, msg9					;Encryption done!
	int 21h

	mov ah, 9
	lea dx, encoded_encrypted_string[2]
	int 21h

	call print_one_crlf				;CRLF after input

	mov ah, 9
	lea dx, msg12					;You may also find the result in the file
	int 21h

	jmp choose_func

decrypt_from_console:
	call print_dash_line
	call initialization
	call print_dash_line
	
	mov ah, 9
	lea dx, msg4					;Please enter the string to decrypt:
	int 21h

	mov ah, 0ah
	lea dx, encoded_encrypted_string		;Read in the string to decrypt.
	int 21h

	mov al, encoded_encrypted_string[1]
	shr al, 1
	mov decoded_decrypted_string[1], al

	jmp decrypt_complete

decrypt_from_file:
	call print_dash_line
	call initialization
	call print_dash_line

	mov ah, 9
	lea dx, msg5					;Please save the string in the file
	int 21h

	mov ah, 0ah
	lea dx, opt_func
	int 21h

	call print_dash_line

	mov ah, 3dh						;open the input decrypt file
	mov al, 0 						;mode: read only
	lea dx, input_decrypt_path
	int 21h
	jc quit							;quit if error

	mov handle, ax
	mov ah, 3fh						;read the input file
	mov bx, handle
	mov cx, 127						;max bytes to read
	lea dx, encoded_encrypted_string
	add dx, 2
	int 21h
	jc quit

	mov encoded_encrypted_string[1], al 		;record the bytes number
	shr al, 1
	mov decoded_decrypted_string[1], al 		;record the bytes number

	mov ah, 3eh                 	;close the file
	mov bx, handle
	int 21h
	jc quit                     	;quit if error

	mov ah, 9
	lea dx, msg11					;Successfully read from file: 
	int 21h
	lea dx, encoded_encrypted_string
	add dx, 2
	int 21h


decrypt_complete:
	call print_one_crlf
	call print_dash_line

	call decoding
	call decryption

	mov ah, 3ch						;open the output file and clear
	mov cx, 0 						;mode: default
    lea dx, output_decrypt_path
    int 21h
    jc quit							;quit if error

	mov handle, ax
	mov ah, 40h                 ;write file or device
	mov bx, handle
	xor cx, cx
	mov cl, decoded_decrypted_string[1]			;number of bytes
	lea dx, decoded_decrypted_string[2]
	int 21h
	jc quit                     ;quit if error

	mov ah, 3eh                 ;close the file
	mov bx, handle
	int 21h

	mov ah, 9
	lea dx, msg10					;Decryption done!
	int 21h

	mov ah, 9
	lea dx, decoded_decrypted_string[2]
	int 21h

	call print_one_crlf				;CRLF after input

	mov ah, 9
	lea dx, msg13					;You may also find the result in the file
	int 21h

	jmp choose_func

goodbye:
	call print_dash_line

	mov ah, 9
	lea dx, msg6					;Hope you enjoyed RC4-BS. See you next time!
	int 21h

	call print_dash_line

quit:
    mov dl, 0dh
    mov ah, 2
    int 21h

    mov dl, 0ah
    mov ah, 2
    int 21h

    mov ax, 4c00h
    int 21h

.EXIT 0

clear_screen:
	mov ah, 15
	int 10h
	mov ah, 0
	int 10h		
	ret		

print_dash_line:
	mov ah, 9
	lea dx, dash_line
	int 21h
	ret

print_one_crlf:
	mov ah, 9
	lea dx, crlf
	int 21h
	ret

initialization:
	init_strings:
		mov si, 0
		mov di, 2
		mov dx, 255
		Loop8:
			mov encoded_encrypted_string[di], '$'
			mov encoded_decrypted_string[si], '$'
			mov decoded_encrypted_string[si], '$'
			mov decoded_decrypted_string[di], '$'
			inc si 
			inc di
			cmp dx, si
			jne Loop8

	mov ah, 9
	lea dx, msg8					;Please enter the encryption key: 
	int 21h

	mov ah, 0ah
	lea dx, aKey					;read in the encryption key
	int 21h

	call print_one_crlf				;CRLF after input

	init_iS:
		mov cx, 0
		mov dx, 256					;for(int i = 0; i < 256; i++)
		Loop1:
			mov si, cx
			mov iS[si], cl			;iS[i] = i 
			inc cx
			cmp dx, cx
			jne Loop1

	init_iK:
		mov cx, 0
		mov dx, 256					;for(int i = 0; i < 256; i++)
		mov bl, aKey[1]				;offset to length
		Loop2:
			mov ax, cx				
			div bl 					;i % aKey.length()
			mov al, ah
			mov ah, 0
			mov di, ax
			add di, 2 				;offset to string
			mov si, cx			
			mov al, aKey[di]
			mov iK[si], al			;iK[i] = Key.charAt((i % aKey.length()))
			inc cx
			cmp dx, cx
			jne Loop2

	rearrange_iS:
		mov variable_j, 0
		mov cx, 0
		mov dx, 256					;for(int i = 0; i < 255; i++)				
		Loop3:
			mov si, cx
			mov al, iS[si]			;iS[i]
			add variable_j, al
			mov al, iK[si]			;iK[i]
			add variable_j, al 		;j = (j + iS[i] + iK[i]) % 256
			xor ax, ax
			mov al, variable_j		
			mov di, ax		
			mov ah, iS[si]	
			mov al, iS[di]
			mov iS[si], al	
			mov iS[di], ah 			;xchg iS[i], iS[j]
			inc cx
			cmp dx, cx
			jne Loop3

	ret

encryption:
	mov cx, 0 						;count
	mov variable_i, 0
	mov variable_j, 0
	xor dx, dx
	mov dl, decoded_decrypted_string[1]			;offset to length
	Loop4:
		inc variable_i				; i++	automatically modulo
		mov al, variable_i
		mov ah, 0
		mov si, ax					;extended i
		mov al, iS[si]
		add variable_j, al			;j + iS[i]	automatically modulo
		mov al, variable_j
		mov ah, 0
		mov di, ax					;extended j
		mov al, iS[si]
		mov ah, iS[di]
		mov iS[si], ah 
		mov iS[di], al 				;xchg iS[si], iS[di]
		mov variable_t, ah 
		add variable_t, al 			;t = (iS[i] + iS[j]) % 256
		mov al, variable_t
		mov ah, 0 				
		mov si, ax					;extended t
		mov di, cx
		add di, 2
		mov al, decoded_decrypted_string[di]
		xor al, iS[si]
		dec di
		dec di		
		mov decoded_encrypted_string[di], al
		inc cx
		cmp cx, dx
		jne Loop4
	ret

decryption:
	mov cx, 0
	xor dx, dx
	mov variable_i, 0
	mov variable_j, 0
	mov dl, encoded_encrypted_string[1]			;offset to length
	shr dl, 1
	Loop5:
		inc variable_i				; i++	automatically modulo
		mov al, variable_i
		mov ah, 0
		mov si, ax					;extended i
		mov al, iS[si]
		add variable_j, al			;j + iS[i]	automatically modulo
		mov al, variable_j
		mov ah, 0
		mov di, ax					;extended j
		mov al, iS[si]
		mov ah, iS[di]
		mov iS[si], ah 
		mov iS[di], al 				;xchg iS[si], iS[di]
		mov variable_t, ah 
		add variable_t, al 			;t = iS[i] + iS[j]	automatically modulo
		mov al, variable_t
		mov ah, 0 				
		mov si, ax					;extended t
		mov di, cx
		mov al, decoded_encrypted_string[di]
		xor al, iS[si]	
		add di, 2
		mov decoded_decrypted_string[di], al
		inc cx
		cmp cx, dx
		jne Loop5
		ret

encoding:
	mov cx, 0
	mov di, 2
	mov bx, 0
	mov bl, decoded_decrypted_string[1]
	Loop6:
		mov si, cx
		mov al, decoded_encrypted_string[si]
		mov ah, 0
		mov dx, 16
		div dl
		mov dh, ah
		mov ah, 0
		mov si, ax
		mov dl, base16_str[si]		;first character
		mov encoded_encrypted_string[di], dl
		inc di
		mov al, dh
		mov ah, 0
		mov si, ax
		mov dl, base16_str[si]		;second character
		mov encoded_encrypted_string[di], dl
		inc di
		inc cx
		cmp cx, bx
		jne Loop6
	ret

decoding:
	mov cx, 0
	mov si, 2
	mov di, 0
	mov ax, 0
	mov bx, 0
	mov bl, encoded_encrypted_string[1]
	shr bl, 1

	Loop7:
		mov dx, 0
		mov dl, encoded_encrypted_string[si]
		inc si
		mov di, dx
		mov al, base16_dict[di]
		mov dx, 16
	 	mul dl
	 	mov dx, 0
	 	mov dl, encoded_encrypted_string[si]
	 	inc si
	 	mov di, dx
	 	add al, base16_dict[di]
	 	mov di, cx
	 	mov decoded_encrypted_string[di], al 
	 	inc cx
	 	cmp cx, bx
	 	jne Loop7
	ret

	END