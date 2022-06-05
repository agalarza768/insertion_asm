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

	fileName	db	"archivo_num3.dat",0
	modo		db	"rb",0

	msjErrorOpen	db	"El archivo no se pudo abrir",0
    debug        db  "AAA",10,0
    msjDebug        db  "%lli ",10,0

    contador    dq  0

    msjFormaOrd     db  "Ordenar de forma ascendente (A) o descendente (D):",0

    msjVectorInicial    db  "Vector inicial:",0

    msjInicioCiclo  db  "Iniciando el ciclo de %lli menor a %lli",10,0

    saltoDeLinea    db  "",10,0

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
    
    call    ordenarVector

    call    imprimirVector
endProgram:
    ;mov		rcx,debug
	;sub		rsp,32
	;call	printf
	;add		rsp,32

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

;   EXPANSION DE BITS -> LLEVAR ESTO AL PRINCIPAL
    mov     al,byte[registro]
    cbw
    cwde
    cdqe
    mov     qword[numero],rax
;   FIN DE EXPANSION DE BITS

;   IMPRESION DE BPF C/S 8 BITS -> TAMBIEN LLEVAR AL OTRO
    ;mov		rcx,msjDebug
    ;mov     rdx,qword[numero]
    ;sub     rsp,32
	;call	printf
    ;add     rsp,32
;   FIN IMPRESION BPF C/S 8 BITS

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

    mov     rbx,qword[contador]
    imul    rbx,8

    mov     rcx,qword[numero]
    mov     [vector + rbx], rcx

    inc     qword[contador]
    ret


imprimirVector:
    cmp     qword[contador],0
    je      finRecorrido

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

    cmp     qword[contador],rbx
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

ordenarVector:

;ESTO SERA NECESARIO?

    ;ESTO SI ES NECESARIO
    cmp     qword[contador],1
    jle     finOrdenamiento

    mov		rcx,msjVectorInicial
	sub		rsp,32
	call	puts
	add		rsp,32

    call    imprimirVector
    
    call   ordenar

finOrdenamiento:
    ret

ordenar:
    mov     rbx,1
recorridoVector:

    mov		rcx,msjInicioCiclo
    mov     rdx,rbx
    mov     r8,qword[contador]
	sub		rsp,32
	call	printf
	add		rsp,32

    push    rbx

    call    desplazar
    
    pop     rbx

    inc     rbx

    cmp     qword[contador],rbx
    jne     recorridoVector

    ret

desplazar:

    sub     rax,rax
    imul    rax,rbx,8

inicioDesplazamiento:
    cmp     rax,0
    je      finDesplazamiento

    mov     rcx,[vector + rax]
    mov     rdx,[vector + rax - 8]

    cmp     byte[formaOrd],'A'
    je      swapAscendente

    cmp     byte[formaOrd],'D'
    je      swapDescendente

    ret

swapAscendente:
    cmp     rcx,rdx
    jge     finDesplazamiento

    jmp     swap

swapDescendente:
    cmp     rcx,rdx
    jle     finDesplazamiento

swap:
    mov     [vector + rax],rdx
    mov     [vector + rax - 8],rcx

    sub     rax,8

    push    rbx
    push    rax
    call    imprimirVector
    pop     rax
    pop     rbx

    jmp     inicioDesplazamiento

finDesplazamiento:
    ret