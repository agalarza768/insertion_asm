global	main
extern  puts
extern  gets
extern  printf
extern  sscanf
extern	fopen
extern	fread
extern	fclose

section	.data
	fileName	db	"archivo_num31.dat",0
	modo		db	"rb",0

	msjErrorOpen    db	"El archivo no se pudo abrir",0

    lenVector       dq  0
    lenMaxVector    dq  30
    posVector       dq  0

    msjFormaOrd     db  "Ordenar de forma ascendente (A) o descendente (D):",0

    msjVectorInicial    db  "Vector inicial:",0
    msjVectorFinal      db  "Vector final:",0

    msjCiclo_i  db  "Iniciando el ciclo de i = %lli menor a %lli:",10,0
    msjCiclo_j  db  "     Ciclo de j = %lli:",10,0

    saltoDeLinea    db  "",10,0

    inicioMsjVector     db  "           |",0
    numVector	        db	" %lli |",0
    msjVectorSinCambios    db  "           No se producen cambios.",0

section .bss
	fileHandle	resq	1
	registro	resb	3

    numero      resq    1

	vector      times   30  resq    1

    formaOrd    resb    1

section  .text
main:
	call    abrirArchivo

    cmp     qword[fileHandle],0
    jle     errorOpen

    call    leerArchivo
    call    insercion
endProgram:
    ret
    

abrirArchivo:
    mov     rcx,fileName
    mov     rdx,modo
    sub     rsp,32
    call    fopen
    add     rsp,32

    mov     qword[fileHandle],rax
    ret


errorOpen:
    mov     rcx,msjErrorOpen
    sub     rsp,32
    call    puts
    add     rsp,32

    jmp     endProgram


leerArchivo:

leerRegistros:
    mov     rcx,registro
    mov     rdx,1
    mov     r8,1
    mov     r9,qword[fileHandle]
    sub     rsp,32
    call    fread
    add     rsp,32

    cmp     rax,0
    jle     EOF

    mov     al,byte[registro]
    cbw
    cwde
    cdqe
    mov     qword[numero],rax

    call    llenarVector

    jmp     leerRegistros
    
EOF:
    mov     rcx,qword[fileHandle]
    sub     rsp,32
    call    fclose
    add     rsp,32
    ret


llenarVector:

    mov     rbx,0

    mov     rbx,qword[lenVector]
    cmp     rbx,qword[lenMaxVector]
    je      finLlenado

    imul    rbx,8

    mov     rcx,qword[numero]
    mov     [vector + rbx], rcx

    inc     qword[lenVector]
finLlenado:
    ret


pedirFormaOrd:
    mov     rcx,msjFormaOrd
    sub     rsp,32
    call    puts
    add     rsp,32

    mov     rcx,formaOrd
    sub     rsp,32
    call    gets
    add     rsp,32
    ret

insercion:
    cmp     qword[lenVector],1
    jle     finInsercion

    call    pedirFormaOrd
    call    imprimirVectorInicial
    call    ordenarVector
    
finInsercion:
    call    imprimirVectorFinal
    ret


ordenarVector:
    mov     qword[posVector],1

ciclo_i:
    call    imprimirInicioCiclo_i
    mov     rbx,qword[posVector]

ciclo_j:
    cmp     rbx,0
    je      finCiclo_j

    call    imprimirInicioCiclo_j
    call    ordenarNumeros

    jmp     ciclo_j

finCiclo_j:
    inc     qword[posVector]

    mov     rbx,qword[posVector]
    cmp     rbx,qword[lenVector]
    jne     ciclo_i
    ret


ordenarNumeros:
    imul    rax,rbx,8

    mov     rcx,[vector + rax]
    mov     rdx,[vector + rax - 8]

    cmp     byte[formaOrd],'A'
    je      swapAscendente

    cmp     byte[formaOrd],'D'
    je      swapDescendente

estanOrdenados:
    mov     rbx,0
    call    imprimirMsjSinCambios

finOrdenamiento:
    ret

swapAscendente:
    cmp     rcx,rdx
    jl      swap

    jmp     estanOrdenados

swapDescendente:
    cmp     rcx,rdx
    jg      swap

    jmp     estanOrdenados

swap:
    mov     [vector + rax],rdx
    mov     [vector + rax - 8],rcx

    push    rbx
    call    imprimirVector
    pop     rbx

    dec     rbx
    jmp     finOrdenamiento


imprimirVector:
    cmp     qword[lenVector],0
    je      finRecorrido

    mov     rcx,inicioMsjVector
    sub     rsp,32
    call    printf
    add     rsp,32

    mov     rbx,0
recorrido:
    imul    rax,rbx,8
    sub 	rdx,rdx

    mov     rdx,[vector + rax]

    inc     rbx

    mov		rcx,numVector
    sub     rsp,32
	call	printf
    add     rsp,32

    cmp     qword[lenVector],rbx
    jne     recorrido

finRecorrido:
    mov     rcx,saltoDeLinea
    sub     rsp,32
    call    printf
    add     rsp,32
    ret


imprimirVectorInicial:
    mov		rcx,msjVectorInicial
	sub		rsp,32
	call	puts
	add		rsp,32

    call    imprimirVector
    ret

imprimirInicioCiclo_i:
    mov		rcx,msjCiclo_i
    mov     rdx,qword[posVector]
    mov     r8,qword[lenVector]
	sub		rsp,32
	call	printf
	add		rsp,32

    ret

imprimirInicioCiclo_j:
    mov		rcx,msjCiclo_j
    mov     rdx,rbx
	sub		rsp,32
	call	printf
	add		rsp,32

    ret

imprimirVectorFinal:
    mov		rcx,msjVectorFinal
	sub		rsp,32
	call	puts
	add		rsp,32

    call    imprimirVector
    ret

imprimirMsjSinCambios:
    mov		rcx,msjVectorSinCambios
	sub		rsp,32
	call	puts
	add		rsp,32

    ret