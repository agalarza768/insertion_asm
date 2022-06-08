global	main
extern  puts
extern  gets
extern  printf
extern  sscanf
extern	fopen
extern	fread
extern	fclose

section	.data
	numFormat	db	"%lli ",0

	fileName	db	"archivo_num6.dat",0
	modo		db	"rb",0

	msjErrorOpen	db	"El archivo no se pudo abrir",0
    debug        db  "AAA",10,0
    msjDebug        db  "%lli ",10,0

    lenVector   dq  0
    posVector   dq  0

    msjFormaOrd     db  "Ordenar de forma ascendente (A) o descendente (D):",0

    msjVectorInicial    db  "Vector inicial:",0
    msjVectorFinal    db  "Vector final:",0

    msjInicioCiclo_i  db  "Iniciando el ciclo de i = %lli menor a %lli",10,0
    msjInicioCiclo_j  db  "     Iniciando el ciclo de j = %lli mayor a 0",10,0

    saltoDeLinea    db  "",10,0

    msjEspacios     db  "           ",0

section .bss
	fileHandle	resq	1
	registro	resb	3

    numero      resq    1

	vector      times   30  resq    1

    formaOrd    resb    1

    numeroValido    resb    1

section  .text
main:
	call    abrirArchivo

    cmp     qword[fileHandle],0
    jle     errorOpen

    call    leerArchivo

    call    pedirFormaOrd
    
    call    insercion

    call    imprimirVectorFinal
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
    imul    rbx,8

    mov     rcx,qword[numero]
    mov     [vector + rbx], rcx

    inc     qword[lenVector]
    ret


imprimirVector:
    cmp     qword[lenVector],0
    je      finRecorrido

    mov     rcx,msjEspacios
    sub     rsp,32
    call    printf
    add     rsp,32

    mov     rbx,0
recorrido:
    imul    rax,rbx,8
    sub 	rdx,rdx

    mov     rdx,[vector + rax]

    inc     rbx

    mov		rcx,numFormat
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

    call    imprimirVectorInicial

    call    ordenarVector
    

finInsercion:
    ret


ordenarVector:
    mov     qword[posVector],1

recorridoVector:
    call    imprimirInicioCiclo_i

    call    ciclo_i

    inc     qword[posVector]


    mov     rbx,qword[posVector]
    cmp     rbx,qword[lenVector]
    jne      recorridoVector
    ret

ciclo_i:
    mov     rbx,qword[posVector]

    call    ciclo_j

    ret

ciclo_j:

    cmp     rbx,0
    je      finCiclo_j

    sub     rax,rax
    imul    rax,rbx,8

    mov     rcx,[vector + rax]
    mov     rdx,[vector + rax - 8]

    cmp     byte[formaOrd],'A'
    je      swapAscendente

    cmp     byte[formaOrd],'D'
    je      swapDescendente

    jmp     ciclo_j

finCiclo_j:
    ret


swapAscendente:
    cmp     rcx,rdx
    jge     finSwap

    jmp     swap

swapDescendente:
    cmp     rcx,rdx
    jle     finSwap

swap:
    mov     [vector + rax],rdx
    mov     [vector + rax - 8],rcx

    call    imprimirInicioCiclo_j
    dec     rbx

    push    rbx
    call    imprimirVector
    pop     rbx

    jmp     ciclo_j

finSwap:
    ret

imprimirVectorInicial:
    mov		rcx,msjVectorInicial
	sub		rsp,32
	call	puts
	add		rsp,32

    call    imprimirVector
    ret

imprimirInicioCiclo_i:
    mov		rcx,msjInicioCiclo_i
    mov     rdx,qword[posVector]
    mov     r8,qword[lenVector]
	sub		rsp,32
	call	printf
	add		rsp,32

    ret


imprimirInicioCiclo_j:
    mov		rcx,msjInicioCiclo_j
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