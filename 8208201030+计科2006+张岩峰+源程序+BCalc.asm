;BCalc
;Written in assembly
;Only integer, bracket ( ), oprater + - * /, equal sign = are supported
;Copyright Baluth, All rights reserved.

.MODEL SMALL
.DATA

crlf db 13, 10, '$'
dash_line db '----------------------------------------'
		  db '----------------------------------------$'

msg0  db 'Welcome to use BCalc!', 13, 10, '$'
msg1  db 'Here are three options to choose from: ', 13, 10
	  db '1: Calculate an expression.', 13, 10
	  db '2: Clear Screen.', 13, 10
	  db '0: Eixt', 13, 10
	  db 'Please enter a number to choose: $'
msg2  db 'Hope you enjoyed BCalc. See you next time!', 13, 10, '$'
msg3  db 'Wrong input! Please choose again!', 13, 10, '$'
msg4  db 'Please enter an expression:', 13, 10, '$'
msg5  db 'Invalid character "$'
msg6  db '" at the index of [$'
msg7  db '].', 13, 10, '$'
msg8  db '" following "$'
msg9  db 'Please check the expression and enter a new one:', 13, 10, '$'
msg10 db 'Unmatched right bracket at the index of [$'
msg11 db 'Invalid right bracket following "$'
msg12 db 'A valid expression starts with a left bracket or an operand.'
      db 13, 10, '$'
msg13 db 'Inappropriate equal sign at the index of [$'
msg14 db 'A valid expression ends with a right bracket or an operand.'
	  db 13, 10, '$'
msg15 db 'Lack of right bracket.', 13, 10, '$'
msg16 db 'Your input without space:', 13, 10, '$'
msg17 db 'Invalid left bracket following "$'
msg18 db 'The post order expression is: ', 13, 10, '$'
msg19 db 'ERROR! OVERFLOW', 13, 10, '$'
msg20 db 'ERROR! DIV ZERO', 13, 10, '$'
msg21 db 'The reuslt is:$'

check_list db 32 dup(0), 7, 7 dup(0), 1, 2, 3, 3, 0, 3, 0, 3, 10 dup(5)
		   db 3 dup(0), 6, 195 dup(0)		
priority_list db 42 dup(0), 2, 1, 0, 1, 0, 2	

temp_byte db 0
temp_word dw 0
zero_flag db 0
cur_char db '$'
last_char db '$'
operand_flag db 0
count_left_brackets db 0
count_right_brackets db 0

opt_func db 255, 0, 255 dup('$')
expression db 255, 0, 255 dup('$')

post_cur_index db 2
post_order_expression dw 0, 255 dup(0)
flag_cur_index db 0
is_operand_flag db 255 dup(0)
stack_cur_index db 0
operator_stack db 255 dup('$')

result dw 0

.CODE
.STARTUP

welcome:
	call clear_screen
	call print_dash_line

	mov ah, 9
	lea dx, msg0							;Welcome to use BCalc!
	int 21h

	call print_dash_line

choose_func:
	mov ah, 9
	lea dx, msg1							;Here are three options to choose...
	int 21h

	mov ah, 0ah
	lea dx, opt_func
	int 21h
	mov al, opt_func[2]
	sub al, 30h
	mov opt_func[2], al
	
	call print_one_crlf						;CRLF after input
	call print_dash_line

	cmp opt_func[1], 1
	jne wrong_input

	cmp opt_func[2], 0
	je goodbye
	cmp opt_func[2], 1
	je get_expression
	cmp opt_func[2], 2
	je option_clear_screen

wrong_input:
	mov ah, 9
	lea dx, msg3							;Wrong input! Please choose again!
	int 21h

	call print_dash_line

	jmp choose_func

option_clear_screen:
	call clear_screen
	jmp choose_func

get_expression:
	
	mov ah, 9
	lea dx, msg4							;Please enter a expression:
	int 21h

	jmp get_expression_not_error

get_expression_if_error:
	mov ah, 9
	lea dx, msg9							;Please check the expression and ...
	int 21h

get_expression_not_error:
	call initialization

	mov ah, 0ah
	lea dx, expression
	int 21h

	call print_one_crlf

get_expression_without_space_nor_invalid_char:
	mov si, 2
	mov cl, expression[1]
	mov bx, 2
	mov ax, 2
	add al, cl 
	Loop0:
		cmp ax, si 
		je print_expression_without_space
		mov dl, expression[si]
		mov cur_char, dl
		mov expression[si], '$'
		inc si
		mov dh, 0
		mov di, dx
		mov ch, check_list[di]
		cmp ch, 0
		je invalid_character
		cmp dl, 32
		je Loop0
		mov expression[bx], dl
		inc bx
		jmp Loop0

print_expression_without_space:
	sub bx, 2
	mov expression[1], bl 					;record the new len without space
	call print_dash_line

	mov ah, 9
	lea dx, msg16							;Your input without space:
	int 21h

	mov ah, 9
	lea dx, expression
	add dx, 2
	int 21h

	call print_one_crlf

	call print_dash_line

check_expression:
	mov si, 2
	mov cl, expression[1]

	mov dl, expression[si]					;get the first character
	mov cur_char, dl 						;record the current character
	mov dh, 0
	mov di, dx
	mov ch, check_list[di]					;check the type of character

	cmp ch, 5
	je back_loop1
	cmp ch, 1
	je check_expression_left_bracket_at_the_start

	mov ah, 9
	lea dx, msg12							;A valid expression starts with ...
	int 21h

	call print_dash_line

	jmp get_expression_if_error

check_expression_left_bracket_at_the_start:
	inc count_left_brackets
	jmp back_loop1

	Loop1:
		mov last_char, dl 					;record the last character
		mov dl, expression[si]				;get the next character
		mov cur_char, dl 					;record the current character
		mov dh, 0
		mov di, dx
		mov ch, check_list[di]				;check the type of character

		cmp ch, 6
		je check_equal_sign
		cmp ch, 1
		je check_left_bracket
		cmp ch, 2
		je check_right_bracket
		cmp ch, 3
		je check_operator
		cmp ch, 5
		je check_operand

	back_loop1:
		inc si 								;move to next character
		mov ax, si 
		sub ax, 2 
		cmp cl, al 							;loop until all chars checked
		jne Loop1

check_expression_end_with_operand_or_right_bracket:
	mov di, si 
	dec di
	mov dl, expression[di]
	mov dh, 0
	mov di, dx
	mov ch, check_list[di]
	cmp ch, 2
	je check_expression_left_bracket_equal_to_right_bracket
	cmp ch, 5
	je check_expression_left_bracket_equal_to_right_bracket

	mov ah, 9
	lea dx, msg14							;A valid expression ends with a ...
	int 21h

	call print_dash_line
	jmp get_expression_if_error

check_expression_left_bracket_equal_to_right_bracket:
	mov ah, count_left_brackets
	mov al, count_right_brackets
	cmp ah, al 
	je get_post_expression

	mov ah, 9
	lea dx, msg15							;Lack of right bracket
	int 21h

	call print_dash_line
	jmp get_expression_if_error

get_post_expression:
	mov si, 2 								;current index of expression
	mov cl, expression[1]
	mov bx, 2
	add bl, cl 								;max index of expression

	Loop2:
		cmp bx, si 
		je treat_the_end_of_the_expression
		mov dl, expression[si]
		mov dh, 0
		mov di, dx
		mov ch, check_list[di]
		cmp ch, 1
		je meet_left_bracket
		cmp ch, 2
		je meet_right_bracket
		cmp ch, 3
		je meet_operator
		
		mov operand_flag, 1 				;which means operands not ...

		mov bh, dl 							;store a copy
		mov ax, 10
		mov dl, post_cur_index
		mov dh, 0
		mov di, dx
		imul post_order_expression[di]
		mov post_order_expression[di], ax
		mov dl, bh 							;restore to dl
		mov bh, 0 
		mov ch, dl
		sub ch, 30h
		mov al, ch 
		mov ah, 0
		add post_order_expression[di], ax

	back_loop2:
		inc si 
		jmp Loop2

meet_left_bracket:
	inc stack_cur_index
	mov al, stack_cur_index
	mov ah, 0
	mov di, ax
	mov operator_stack[di], dl
	jmp back_loop2

meet_right_bracket:
	cmp operand_flag, 1
	jne pop_next_operator
	add post_cur_index, 2
	mov al, flag_cur_index
	mov ah, 0
	mov di, ax
	mov is_operand_flag[di], 1 				;mark it an operand
	inc flag_cur_index
	inc post_order_expression[0]
	mov operand_flag, 0

	pop_next_operator:
		mov dl, stack_cur_index
		mov dh, 0
		mov di, dx
		mov al, operator_stack[di]
		cmp al, 40							;meet left bracket
		jne move_to_post_expression
		dec stack_cur_index
		jmp back_loop2

	move_to_post_expression:
		mov dl, post_cur_index
		mov dh, 0
		mov di, dx
		mov ah, 0
		mov post_order_expression[di], ax
		inc post_order_expression[0]
		add post_cur_index, 2
		inc flag_cur_index					;mark it an operator
		dec stack_cur_index
		jmp pop_next_operator
	
meet_operator:
	mov temp_byte, dl
	cmp operand_flag, 1
	jne pop_next_operator_2
	add post_cur_index, 2
	mov cl, flag_cur_index
	mov ch, 0
	mov di, cx
	mov is_operand_flag[di], 1 				;mark it an operand
	inc flag_cur_index
	inc post_order_expression[0]
	mov operand_flag, 0

	pop_next_operator_2:
		cmp stack_cur_index, 0
		je push_cur_operator
		mov ah, bl 							;store a copy
		mov dh, 0
		mov dl, temp_byte
		mov di, dx
		mov al, priority_list[di]
		mov cl, stack_cur_index
		mov ch, 0
		mov di, cx
		mov dl, operator_stack[di]
		mov di, dx
		mov dh, priority_list[di]
		mov bl, ah 							;restore to bl
		mov ah, dh
		cmp ah, al 
		jae move_to_post_expression_2

	push_cur_operator:
		inc stack_cur_index
		mov cl, stack_cur_index
		mov ch, 0
		mov di, cx
		mov dl, temp_byte
		mov operator_stack[di], dl
		jmp back_loop2

	move_to_post_expression_2:
		mov ax, di
		mov cl, post_cur_index
		mov ch, 0
		mov di, cx
		mov post_order_expression[di], ax
		add post_cur_index, 2
		inc flag_cur_index					;mark it an operator
		inc post_order_expression[0]
		mov cl, flag_cur_index
		mov ch, 0
		mov di, cx 
		mov is_operand_flag[di], 0
		dec stack_cur_index
		jmp pop_next_operator_2

treat_the_end_of_the_expression:
	cmp operand_flag, 1
	jne pop_the_unmoved_operators

	add post_cur_index, 2
	mov cl, flag_cur_index
	mov ch, 0
	mov di, cx
	mov is_operand_flag[di], 1 				;mark it an operand
	inc flag_cur_index
	inc post_order_expression[0]
	mov operand_flag, 0

	pop_the_unmoved_operators:
	mov cl, stack_cur_index
	mov ch, 0
	mov di, cx 
	mov cx, post_order_expression[0]
	mov si, 2
	add si, cx
	add si, cx
	Loop4:
		cmp di, 0
		je print_post_expression
		mov al, operator_stack[di]
		mov ah, 0
		mov post_order_expression[si], ax
		inc post_order_expression[0]
		dec di 
		add si, 2 
		jmp Loop4

print_post_expression:

	mov ah, 9
	lea dx, msg18
	int 21h

	mov cx, post_order_expression[0]
	mov di, 2 
	mov si, 2
	add si, cx
	add si, cx
	mov flag_cur_index, 0
	Loop3:
		cmp di, si 
		je calculate
		mov al, flag_cur_index
		inc flag_cur_index
		mov ah,0
		mov bx, ax
		mov al, is_operand_flag[bx]
		cmp al, 0
		je print_it_directly
		mov bx, post_order_expression[di]
		call binaryToDecimal
	back_loop3:
		add di, 2 

		mov ah, 2
		mov dl, 32							;print a space as a separator
		int 21h

		jmp Loop3
	print_it_directly:
		mov ah, 2
		mov dx, post_order_expression[di]
		int 21h
		jmp back_loop3

calculate:
	call print_one_crlf
	call print_dash_line

	mov si, 2
	mov bx, 2
	add bx, post_order_expression[0]
	add bx, post_order_expression[0]
	mov temp_word, bx
	mov bx, 2
	mov di, 0 
	Loop6:
		cmp temp_word, si 
		je exit_loop6
		mov dl, is_operand_flag[di]
		cmp dl, 0
		je check_operator_type
		mov cx, post_order_expression[si]
		mov post_order_expression[bx], cx
		back_loop6:
		add bx, 2
		add si, 2 
		inc di
		jmp loop6

	check_operator_type:
		sub bx, 2
		mov cx, post_order_expression[si]
		cmp cx, 43
		je do_add_operation
		cmp cx, 45
		je do_sub_operation
		cmp cx, 42
		je do_imul_operation
		cmp cx, 47
		je do_idiv_operation

do_add_operation:
	sub bx, 2
	mov ax, post_order_expression[bx]
	add bx, 2
	add ax, post_order_expression[bx]
	jo print_overflow
	sub bx, 2
	mov post_order_expression[bx], ax
	jmp back_loop6

do_sub_operation:
	sub bx, 2
	mov ax, post_order_expression[bx]
	add bx, 2
	sub ax, post_order_expression[bx]
	jo print_overflow
	sub bx, 2
	mov post_order_expression[bx], ax
	jmp back_loop6

do_imul_operation:
	mov dx, 0
	sub bx, 2
	mov ax, post_order_expression[bx]
	add bx, 2
	mov cx, post_order_expression[bx]
	imul cx
	jo print_overflow
	sub bx, 2
	mov post_order_expression[bx], ax
	jmp back_loop6

do_idiv_operation:
	mov dx, 0
	sub bx, 2
	mov ax, post_order_expression[bx]
	add bx, 2
	mov cx, post_order_expression[bx]
	cmp cx, 0
	je print_div_zero
	idiv cx 
	sub bx, 2
	mov post_order_expression[bx], ax
	jmp back_loop6

print_overflow:
	mov ah, 9
	lea dx, msg19							;ERROR! OVERFLOW
	int 21h

	call print_dash_line
	jmp get_expression_if_error

print_div_zero:
	mov ah, 9
	lea dx, msg20							;ERROR! DIV ZERO
	int 21h

	call print_dash_line
	jmp get_expression_if_error

exit_loop6:
	mov ah, 9
	lea dx, msg21
	int 21h

	mov bx, post_order_expression[2]
	cmp bx, 0
	jl print_neg_sign
print_positive:
	call binaryToDecimal
	call print_one_crlf
	call print_dash_line

jmp choose_func

print_neg_sign:
	mov ah, 2
	mov dl, '-'
	int 21h 

	neg bx
	jmp print_positive

invalid_character:
	mov ah, 9
	lea dx, msg5							;Invalid character
	int 21h

	mov ah, 2
	mov dl, cur_char
	int 21h

	call print_post_cur_index

	call print_dash_line

	jmp get_expression_if_error

check_equal_sign:
	mov dx, si 
	dec dx
	cmp cl, dl 
	je check_equal_sign_at_the_end_okay

	mov ah, 9
	lea dx, msg13							;Inappropriate equal sign at the ...
	int 21h

	mov bx, si 
	sub bx, 1
	call binaryToDecimal

	mov ah, 9
	lea dx, msg7
	int 21h

	call print_dash_line
	jmp get_expression_if_error

check_equal_sign_at_the_end_okay:
	mov expression[si], '$'
	dec expression[1]
	jmp check_expression_end_with_operand_or_right_bracket

check_left_bracket:
	mov al, last_char
	mov ah, 0
	mov di, ax
	mov ch, check_list[di]
	cmp ch, 3
	je check_left_bracket_following_operator_or_left_bracket_okay
	cmp ch, 1
	je check_left_bracket_following_operator_or_left_bracket_okay

	mov ah, 9
	lea dx, msg17							;Invalid left bracket following
	int 21h

	mov ah, 2
	mov dl, last_char
	int 21h

	call print_post_cur_index
	call print_dash_line

	jmp get_expression_if_error

check_left_bracket_following_operator_or_left_bracket_okay:
	inc count_left_brackets
	jmp back_loop1

check_right_bracket:
	mov ah, count_left_brackets
	mov al, count_right_brackets
	cmp ah, al
	ja check_right_bracket_left_greater_than_right_oaky

	mov ah, 9
	lea dx, msg10							;Unmatched right bracket at the ...
	int 21h

	mov bx, si 
	sub bx, 2
	call binaryToDecimal

	mov ah, 9
	lea dx, msg7
	int 21h

	call print_dash_line
	jmp get_expression_if_error

check_right_bracket_left_greater_than_right_oaky:
	mov al, last_char
	mov ah, 0
	mov di, ax
	mov ch, check_list[di]
	cmp ch, 5
	je check_right_bracket_following_operand_or_right_bracket_okay
	cmp ch, 2
	je check_right_bracket_following_operand_or_right_bracket_okay

	mov ah, 9
	lea dx, msg11							;Invalid right bracket following
	int 21h

	mov ah, 2
	mov dl, last_char
	int 21h

	call print_post_cur_index
	call print_dash_line

	jmp get_expression_if_error

check_right_bracket_following_operand_or_right_bracket_okay:
	inc count_right_brackets
	jmp back_loop1

check_operator:
	mov al, last_char
	mov ah, 0
	mov di, ax
	mov ch, check_list[di]
	cmp ch, 2
	je check_operator_following_operand_or_right_bracket_okay
	cmp ch, 5
	je check_operator_following_operand_or_right_bracket_okay

	mov ah, 9
	lea dx, msg5							;Invalid
	int 21h

	mov ah, 2
	mov dl, cur_char
	int 21h

	mov ah, 9
	lea dx, msg8							;following
	int 21h

	mov ah,2
	mov dl, last_char
	int 21h

	call print_post_cur_index
	call print_dash_line

	jmp get_expression_if_error

check_operator_following_operand_or_right_bracket_okay:
	jmp back_loop1

check_operand:
	mov al, last_char
	mov ah, 0
	mov di, ax
	mov ch, check_list[di]
	cmp ch, 2
	jne back_loop1

	mov ah, 9
	lea dx, msg5							;Invalid
	int 21h

	mov ah, 2
	mov dl, cur_char
	int 21h

	mov ah, 9
	lea dx, msg8							;following
	int 21h

	mov ah,2
	mov dl, last_char
	int 21h

	call print_post_cur_index
	call print_dash_line

	jmp get_expression_if_error

goodbye:
	mov ah, 9
	lea dx, msg2							;Hope you enjoyed this application
	int 21h

	call print_dash_line

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

print_post_cur_index:
	mov ah, 9
	lea dx, msg6							;at the index of
	int 21h

	mov bx, si 
	sub bx, 2
	call binaryToDecimal

	mov ah, 9
	lea dx, msg7
	int 21h

	ret

initialization:
	mov temp_byte, 0
	mov temp_word, 0
	mov zero_flag, 0
	mov cur_char, '$'
	mov last_char, '$'
	mov operand_flag, 0
	mov count_left_brackets, 0
	mov count_right_brackets, 0

	mov flag_cur_index, 0
	mov stack_cur_index, 0
	mov post_cur_index, 2

	mov di, 0 
	mov si, 255
	mov bx, 0
	Loop5:
		mov expression[di], '$'
		mov is_operand_flag[di], 0
		mov operator_stack[di], '$'
		mov post_order_expression[bx], 0
		inc di 
		add bx, 2
		cmp di, si
		jne Loop5

	mov post_order_expression[bx], 0
	mov post_order_expression[di], '$'
	inc di
	mov post_order_expression[di], '$'

	mov result, 0

	ret

;move the binary num into bx in davance
binaryToDecimal:
	mov zero_flag, 0
    mov cx, 10000d          				;get the highest single num
    call dec_div            
    mov cx, 1000d           				;get the second highest single num
    call dec_div
    mov cx, 100d
    call dec_div
    mov cx, 10d
    call dec_div
    mov cx, 1               				;get the last single num
    call dec_div
    ret

 dec_div:
    mov ax, bx              				;move dividend to ax
    mov dx, 0               				;clear reminder
    div cx                  				;get the target single num
    mov bx, dx             					;renew bx with the reminder
    mov dl, al              				;mov the quotient to dl
    cmp cx, 1
    je print_it_anyway
    cmp dl, 0
    je skip_print_zero
print_it_anyway:
    add dl, 30h             				;transform to ascii format
    mov ah, 2               				;print it to console
    int 21h
    mov zero_flag, 1
    ret
skip_print_zero:
	cmp zero_flag, 1
	je print_it_anyway
    ret

	END