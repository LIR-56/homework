.286
.model tiny
.code
org 100h
start:

	jmp Init
	
file_error:																					;что-то навроде обработки ошибок(если проблемы с файлами, пишем что проблемы с файлами)
	mov ah, 59h
	xor bx, bx
	int 21h
	push ax
	push bx
	push dx
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov bp, sp
	mov ah, 9
	mov dx, offset string
	int 21h
	mov dx, word ptr cs:[bp+6]
	int 21h
	
	

	add sp, 8
	ret
Init:																						
	
	mov ah,03dh								;открываем файл Image
	mov al, 00000010b
	mov dx, offset filename2
	push dx
	int 21h
	jc file_error
	
	mov bx, ax									;считываем его	
	mov ah, 3fh
	mov cx, 1000
	mov dx, offset buf
	int 21h
	jc file_error
	
	mov ah, 3Eh								;закрываем файл
	int 21h											
	jc file_error
	add sp, 2
	
	mov ah,03dh								;открываем файл Config.qwe																					
	mov al, 00000010b
	mov dx, offset filename1
	push dx
	int 21h
	jc file_error
	
	mov bx, ax									;считываем его			
	mov ah, 3fh
	mov cx, 40
	mov dx, offset config 
	int 21h
	jc file_error
	
	mov ah, 3Eh								;закрываем файл
	int 21h
	jc file_error
	add sp, 2				

cycle:												;большой цикл по которому собственно и бегает весь алгоритм
	mov bx, offset config
	cmp byte ptr ds:[bx], 0aah			;сравниваем значение первого провода с 0aah, если не равен то провод считается сломаннымм и мы ставим имеющееся значение, если же равен, то пишем в ah содержимое UkKom	
	jne go1											
	xor ax, ax
	mov ah, UkKom											
	jmp go1_0
go1:
	mov ah, byte ptr ds:[bx]
go1_0:
	
	mov ukkom2, ah							;сохраняем в память текущее состояние регистра Укком
	inc bx
	cmp byte ptr ds:[bx], 0aah			;сравниваем значение второго провода с 0aah, если не равен то провод считается сломаннымм и мы ставим имеющееся значение, если же равен, то пишем в al содержимое ah(то есть при работающем механизме содержимое УкКом)	
	jne go2
	mov al, ah
	jmp go2_0
go2:
	mov al, byte ptr ds:[bx]
go2_0:	
	
	
	inc bx
	cmp byte ptr ds:[bx], 0aah			;анализируем третий провод по той же схеме, что и первые 2 (собственно всего я насчитал 38 проводов и они все анализируются примерно таким образом, при этом запоминаются значение либо в регистры, либо в стэк, либо в память)
	jne go3
	push bx
	xor bx, bx
	mov bl, al
	shl bl, 1
	add bx, offset buf
	mov ch, byte ptr ds:[bx]
	jmp go3_0
go3:
	push bx
	mov ch, byte ptr ds:[bx]
go3_0:	

	pop bx
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go3_
	push bx
	xor bx, bx
	mov bl, al
	shl bl, 1
	add bx, offset buf
	inc bx
	mov cl, byte ptr ds:[bx]
	jmp go3_0_
go3_:
	push bx
	mov cl, byte ptr ds:[bx]
go3_0_:	
	pop bx
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go4
	inc ah
	jmp go4_0
go4:
	mov ah, byte ptr ds:[bx]
go4_0:
	mov cop, ah

	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go5
	jmp go5_0
go5:
	mov ch, byte ptr ds:[bx]
go5_0:
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go6
	mov al, IR
	jmp go6_0
go6:
	mov al, byte ptr ds:[bx]
go6_0:
	
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go7
	jmp go7_0
go7:
	mov cl, byte ptr ds:[bx]
go7_0:
	add cl, al
	
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go8
	mov al, RONpr 
	jmp go8_0
go8:
	mov al, byte ptr ds:[bx]
go8_0:
	
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go9
	mov dl, RVVfl   
	jmp go9_0
go9:
	mov dl, byte ptr ds:[bx]
go9_0:
	
	
	pusha																						;далее идущие переходы сначала выставляют значения И, П, ОП и ПЕРЕХ в зависимости от команды и переходит к deccom_beg
	cmp ch, 00h
	jne c1
	mov ah, 0
	mov bx, 0
	mov perech, 0
	mov op,0
	jmp deccom_beg
c1:	
	
	cmp ch, 11h
	jne c2
	mov ah, 0
	mov bl, 1
	mov bh, 1
	mov perech, 0
	mov op, 1
	jmp deccom_beg
c2:	
	
	cmp ch, 15h
	jne c3	
	mov ah, 1
	mov bh, 1
	mov bl, 1
	mov perech, 0
	mov op, 1
	jmp deccom_beg
c3:
	
	cmp ch, 02h
	jne c4	
	mov bh, 2
	mov bl, 0
	mov perech, 0
	mov op, 0
	jmp deccom_beg
c4:
	
	cmp ch, 21h
	jne c5	
	mov ah, 0
	mov bh, 1
	mov bl, 2
	mov perech, 0
	mov op, 2
	jmp deccom_beg
c5:
	
	cmp ch, 25h
	jne c6	
	mov ah, 1
	mov bh, 1
	mov bl, 2
	mov perech, 0
	mov op, 2
	jmp deccom_beg
c6:
	cmp ch, 31h
	jne c7	
	mov ah, 0
	mov bh, 1
	mov bl, 3
	mov perech, 0
	mov op, 3
	jmp deccom_beg
c7:
	cmp ch, 0FEh
	jne c8	
	mov ah, 1
	mov bh, 4
	mov bl, 0fh
	mov op, 0Fh
	mov perech, 1
	jmp deccom_beg
c8:
	
	cmp ch, 0f0h
	jne c9	
	mov bh, 4
	mov bl, 0fh
	mov op, 0Fh
	cmp al, 0
	jne g0
	mov perech,1
	jmp deccom_beg
g0:
	mov perech, 0
	jmp deccom_beg

c9:	
	
	cmp ch, 0f1h
	jne c10	
	mov bh, 4
	mov bl, 0fh
	mov op, 0Fh
	cmp al, 0
	je g1
	mov perech,1
	jmp deccom_beg
g1:
	mov perech, 0
	jmp deccom_beg

c10:
	
	cmp ch, 0f4h
	jne c11	
	mov bh, 4
	mov bl, 0fh
	mov op, 0Fh
	cmp dl, 0
	jne g2
	mov perech,1
	jmp deccom_beg
g2:
	mov perech, 0
	jmp deccom_beg

c11:
	
	cmp ch, 0f5h
	jne c12	
	mov bh, 4
	mov bl, 0fh
	mov op, 0Fh
	cmp dl, 0
	je g3
	mov perech,1
	jmp deccom_beg
g3:
	mov perech, 0
	jmp deccom_beg

c12:
	mov bh, 4
	mov bl, 0fh
	cmp dl, 0
	mov op, 0Fh
	mov perech,0
	
	
deccom_beg:						;эмуляция работы деккома, выставляем флаги запп, зам2, выб, пуск, зам1, взап1, чист
	mov sapp, 0
	cmp bh, 0
	jne _1
	inc sapp
_1:	
	mov sam1, 0
	cmp bh, 1
	jne _2
	inc sam1
_2:
	mov sam2, 0
	cmp bh, 3
	je _3
	inc sam2
_3:	
	mov vsap1, 0
	cmp bh, 3
	jne _4
	inc vsap1 
_4:	
	mov vib, ah
	
	mov chist, 1
	cmp bh, 2
	jne _5
	mov chist, 0
_5:	
	cmp bh, 3
	jne _6
	mov chist, 0
_6:	
	mov pusk, 1
	cmp ch, 0ffh
	jne _7
	dec pusk
	
_7:
	popa
	
	
	inc bx																;продолжаем бегать по провадам, проверять их корректность и изменять(или не изменять) значения в зависимости от результата
	cmp byte ptr ds:[bx], 0aah
	jne go10
	jmp go10_0
go10:
	mov cl, byte ptr ds:[bx]
go10_0:
	mov addr, cl
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go11
	mov ch, cl
	jmp go11_0
go11:
	mov ch, byte ptr ds:[bx]
go11_0:
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go12
	mov ah, cl
	jmp go12_0
go12:
	mov ah, byte ptr ds:[bx]
go12_0:
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go13
	mov al, cop
	jmp go13_0
go13:
	mov al, byte ptr ds:[bx]
go13_0:

	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go14
	mov dh, perech
	jmp go14_0
go14:
	mov dh, byte ptr ds:[bx]
go14_0:

	cmp dh, 0
	jne go_14_
	mov dh, al
	jmp go14_0_
go_14_:
	mov dh, ah
go14_0_:
	
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go15
	mov ah, RVV
	jmp go15_0

go15:
	mov ah, byte ptr ds:[bx]
go15_0:

	inc bx
	cmp byte ptr ds:[bx], 0aah
	je go16_0
	mov cl, byte ptr ds:[bx]
go16_0:

	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go17
	push bx
	xor bx, bx
	mov bl, ch
	add bx, offset buf
	mov al, byte ptr ds:[bx]
	jmp go17_0
go17:
	push bx
	mov al, byte ptr ds:[bx]
go17_0:	
	pop bx
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go18
	mov ch, vib
	jmp go18_0
go18:
	mov ch, byte ptr ds:[bx]
go18_0:	
	
	cmp ch, 1																		;тут эмулируется работа блока выб(чуть левее АЛУ)
	jb vib_m1 	
	ja vib_m2
	mov ch, cl
	jmp vib_m3
vib_m1:
	mov ch, al
	jmp vib_m3
vib_m2:
	mov ch, ah
vib_m3:
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	je go19_0
	mov ch, byte ptr ds:[bx]
go19_0:	
	
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go20
	mov cl, RON 
	jmp go20_0
go20:
	mov cl, byte ptr ds:[bx]
go20_0:	
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go21
	mov al, op
	jmp go21_0
go21:
	mov al, byte ptr ds:[bx]
go21_0:	
	
	cmp al, 0																	;собственно, эмуляциа АЛУ
	jne c_alu_0
	mov al, cl
	mov ah, 0
	cmp al, 0
	je end_alu
	mov ah, 1
	jmp end_alu
c_alu_0:	
	cmp al, 1
	jne c_alu_1
	mov al, ch
	mov ah, 0
	cmp al, 0
	je end_alu
	mov ah, 1
	jmp end_alu
c_alu_1:	
	cmp al, 2
	jne c_alu_2
	mov al, cl
	add al, ch
	mov ah, 0
	cmp al, 0
	je end_alu
	mov ah, 1
	jmp end_alu
c_alu_2:	
	cmp al, 3
	jne end_alu
	mov al, cl
	sub al, ch
	mov ah, 0
	cmp al, 0
	je end_alu
	mov ah, 1
end_alu:	
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	je go22
	mov dh, byte ptr ds:[bx]
go22:
		
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go23
	mov dl, pusk
	jmp go23_0

go23:
	mov dl, byte ptr ds:[bx]
go23_0:

	cmp dl, 0																	;если пуск=1, то пишем новое значение в УкКом
	je jajmp
	
	mov UkKom, dh

jajmp:

	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	je go24
	mov al, byte ptr ds:[bx]
go24:

	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go25
	mov cl, al
	jmp go25_0
	
go25:
	mov cl, byte ptr ds:[bx]
go25_0:
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go26
	mov ch, vsap1
	jmp go26_0
	
go26:
	mov ch, byte ptr ds:[bx]
go26_0:
			
	cmp ch, 1																		;пищем в РВВ, если взап1 =1				
	jne no_vsap1	
 	mov RVV, cl
	mov RVVfl, 1
no_vsap1:		

	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go27
	mov ch, al
	jmp go27_0
go27:
	mov ch, byte ptr ds:[bx]
go27_0:

	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go28
	mov cl, chist
	jmp go28_0
	
go28:
	mov cl, byte ptr ds:[bx]
go28_0:


	mov dl, 0
	cmp cl, 0
	jne chist_IR
	mov dl, ch
chist_IR:
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	je go29
	mov dl, byte ptr ds:[bx]
go29:

	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go30
	mov dh, sam2
	jmp go30_0
	
go30:
	mov dh, byte ptr ds:[bx]
go30_0:

	cmp dh, 1																	;пишем в Индекс Регистр(ИР), если зам=1
	jne no_sam2
	mov IR, dl
no_sam2:	
	
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go31
	mov cl, al
	jmp go31_0
	
go31:
	mov cl, byte ptr ds:[bx]
go31_0:

	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go32
	mov ch, addr
	jmp go32_0
	
go32:
	mov ch, byte ptr ds:[bx]
go32_0:

	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go33
	mov dl, sapp
	jmp go33_0
	
go33:
	mov dl, byte ptr ds:[bx]
go33_0:

	cmp dl, 1
	jne no_sapp
	push bx
	xor bx, bx 																				;пишем в память, если запп=1
	mov bl, ch
	add bx, offset buf
	mov byte ptr ds:[bx], cl
	pop bx
no_sapp:						
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go34
	mov ch, res2
	jmp go34_0
	
go34:
	mov ch, byte ptr ds:[bx]
go34_0:
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go35
	mov cl, vsap2
	jmp go35_0
	
go35:
	mov cl, byte ptr ds:[bx]
go35_0:
	
	cmp cl, 1																		;пишем в РВВ, если взап2=1
	jne no_vsap2
	mov RVV, ch
	mov RVVfl, 0
no_vsap2:	
	
	inc bx
	cmp byte ptr ds:[bx], 0aah
	je go36
	mov al, byte ptr ds:[bx]
go36:

	inc bx
	cmp byte ptr ds:[bx], 0aah
	je go37
	mov ah, byte ptr ds:[bx]
go37:

	inc bx
	cmp byte ptr ds:[bx], 0aah
	jne go38
	mov ch, sam1
	jmp go38_0
go38:
	mov ch, byte ptr ds:[bx]
go38_0:																		;пишем в РОН, если зам1=1
	cmp ch, 1
	jne no_sam1
	mov RON, al
	mov RONpr, ah
no_sam1:	
	xor ax, ax
	mov al, ukkom2													;сравниваем уккомы, если равны, то проверяем значение по этому адресу, если там FF, то записываем память в выходной файл в заканчиваем программу 
	cmp al, UkKom
	je end_or_not
	jmp cycle
end_or_not:	
	mov bx, offset buf
	shl al, 1
	add bx, ax
	cmp byte ptr ds:[bx], 0ffh 
	je in_conc
	jmp cycle
in_conc:	
	mov ah, 03ch
	mov cx, 00
	mov dx, offset filename3
	push dx
	int 21h
	jc smth_str
	mov bx, ax 
	mov ah, 40h
	mov cx, 0ffh
	mov dx, offset buf 
	int 21h
	jc smth_str
	mov ah, 3Eh
	int 21h
	jc smth_str
	add sp, 2
	ret
smth_str:
	jmp file_error	
filename1 db 'Config.qwe', 0,'$'
filename2 db 'Image', 0 ,'$'
filename3 db 'Im_res.txt', 0,'$'
string db "Error while working with file: $"
buf db 0ffh dup(0ffh)
config db 40 dup(0aah)
UkKom db 0
IR db 0
RON db 0
RONpr db 0
RVV db 0
RVVfl db 0
res2 db 0
vsap2 db 0 
addr db 0
cop db 0
pusk db 0
vsap1 db 0
sam1 db 0
sam2 db 0
chist db 0
op db 0
vib db 0
sapp db 0
perech db 0
ukkom2 db 0
end start