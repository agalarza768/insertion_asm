global	main
extern  puts
extern  gets
extern  printf
extern  sscanf
extern	fopen
extern	fread
extern	fclose

section	.data
	numFormat	db	"%lli",0

	fileName	db	"archivo_num3.dat",0
	modo		db	"rb",0

	msjErrorOpen	db	"El archivo no se pudo abrir",0
    debug        db  "AAA",10,0
    msjDebug        db  "%lli",10,0

    contador    dq  0

    msjFormaOrd     db  "Ordenar de forma ascendente (A) o descendente (D):",0

    msjDebugAsc     db  "ORDENAMIENTO ASCENDENTE",0
    msjDebugDesc    db  "ORDENAMENTO DESCENDENTE",0

    msjInicioOrd    db  "Inicio ordenamiento",0

    msjInicioCiclo  db  "Iniciando el ciclo de i - long(vector)"

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

    call    inicioOrdenamiento

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
    mov     rdx,4
    mov     r8,1
    mov     r9,qword[fileHandle]
    sub     rsp,32
    call    fread
    add     rsp,32

    cmp     rax,0
    jle     EOF

    mov		rcx,registro
	mov		rdx,numFormat
	mov		r8,numero
	sub		rsp,32
	call 	sscanf
	add		rsp,32
    
    cmp     rax,1
    jl      leerRegistros

    call    validarNumero

    cmp     byte[numeroValido],'N'
    je      leerRegistros

    call    llenarVector

    jmp     leerRegistros
    
EOF:
    mov     rcx,qword[fileHandle]
    sub     rsp,32
    call    fclose
    add     rsp,32

    ret

validarNumero:
;En un BPF c/s de 8 bits los limites son - 2^(n-1) y 2^(n-1)-1 
;siendo n la cantidad de bits se
;tiene entonces:
;Minimo Exponente: - 2^7 | 10 = -128
;Maximo Exponente: 2^7-1 | 10 = 127

    mov     byte[numeroValido],'S'
    
    cmp     qword[numero],-128
    jl      esInvalido

    cmp     qword[numero],127
    jg      esInvalido
    ret

esInvalido:
    mov     byte[numeroValido],'N'
    ret

llenarVector:
    mov     rbx,0

    mov     rbx,qword[contador]

    mov     rcx,qword[numero]
    mov     [vector + rbx], rcx

    add     qword[contador],8
    ret

imprimirVector:

    mov     rbx,0
recorrido:
    sub 	rdx,rdx

    mov     rdx,[vector + rbx]

    add     rbx,8

    mov		rcx,msjDebug
    sub     rsp,32
	call	printf
    add     rsp,32

    cmp     qword[contador],rbx
    jne     recorrido

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

inicioOrdenamiento:
    mov		rcx,msjInicioOrd
	sub		rsp,32
	call	puts
	add		rsp,32
    
    call   ordAscendente

    ret

ordAscendente:
    mov     rbx,8
recorridoOrd:
    sub 	rdx,rdx

    ;mov     rdx,[vector + rbx]
    call    swapAscendente

    add     rbx,8

    cmp     qword[contador],rbx
    jne     recorridoOrd

    ret

ordDescendente:

    ret

swapAscendente:
    sub     rax,rax
    mov     rax,rbx

inicioSwap:
    cmp     rax,0
    je      finSwap

    mov     rcx,[vector + rax]
    mov     rdx,[vector + rax - 8]

    cmp     rcx,rdx
    jge     finSwap

    mov     [vector + rax],rdx
    mov     [vector + rax - 8],rcx

    sub     rax,8
    jmp     inicioSwap
finSwap:
    ret