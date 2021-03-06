SEGMENT CODE ; 1

; C Runtime

%include "variables.asm"
%include "func.mac"

%include "extern.inc"
%include "windows.inc"

; The assembler used to create the C Runtime uses several alternate instruction
; encodings from what nasm produces by default...
%define     _AL     0
%define     _CL     1
%define     _DL     2
%define     _BL     3
%define     _AH     4
%define     _CH     5
%define     _DH     6
%define     _BH     7

%define     _AX     0
%define     _CX     1
%define     _DX     2
%define     _BX     3
%define     _SP     4
%define     _BP     5
%define     _SI     6
%define     _DI     7

%define     _ADDw(r1,r2)    db 0x03, 0xc0 + (r1 * 8) + r2
%define     _ORb(r1,r2)     db 0x0a, 0xc0 + (r1 * 8) + r2
%define     _ORw(r1,r2)     db 0x0b, 0xc0 + (r1 * 8) + r2
%define     _ADCw(r1,r2)    db 0x13, 0xc0 + (r1 * 8) + r2
%define     _ANDw(r1,r2)    db 0x23, 0xc0 + (r1 * 8) + r2
%define     _SUBw(r1,r2)    db 0x2b, 0xc0 + (r1 * 8) + r2
%define     _XORw(r1,r2)    db 0x33, 0xc0 + (r1 * 8) + r2
%define     _CMPw(r1,r2)    db 0x3b, 0xc0 + (r1 * 8) + r2
%define     _MOVw(r1,r2)    db 0x8b, 0xc0 + (r1 * 8) + r2

    times 16 db 0

; 10

winflags:
    dw KERNEL.__WINFLAGS

; 12

loc_12:
    mov al, 0xFF
    push ax
    call far __exit

; 1a

extern start
start:
    _XORw(_BP, _BP)
    push bp
    call far KERNEL.InitTask
    _ORw(_AX, _AX)
    jz short loc_12
    mov [Var14BE], es
    add cx, 0x100
    jb short loc_12
    mov [Var1484], cx
    mov [crt_hPrevInstance], si
    mov [crt_hInstance], di
    mov [crt_lpCmdLine], bx
    mov [crt_lpCmdLine+2], es
    mov [crt_nCmdShow], dx
    call far KERNEL.GetVersion
    mov [WindowsVersion], ax
    mov ah, 0x30                    ; DOS3Call: Get DOS version
    test word [cs:winflags], 1
    jz .label0 ; ↓
    call far KERNEL.DOS3Call
    jmp short .label1 ; ↓
.label0:
    int 21h
.label1:
    mov [DOSVersion], ax
    test word [cs:winflags], 1
    jnz short .label2 ; ↓
    mov al, 0
    mov [Var14C5], al
.label2:
    _XORw(_AX, _AX)
    push ax
    call far KERNEL.WaitEvent
    push word [crt_hInstance]
    call far USER.InitApp
    _ORw(_AX, _AX)
    jz short loc_12
    call far __cinit
    call far __setargv
    call far __setenvp
    call __wcinit
    push word [Var14FA]
    push word [Var14F8]
    push word [Var14F6]
    call far __stubmain
    add sp, byte 6
    push ax
    call far exit

; b6

__nomain:
    ; Never used
    mov ax, 0x15
    jmp __amsg_exit

; bc

extern atoi
atoi:
    jmp __catox

    db 0

; c0

extern atol
atol:
    jmp __catox

    db 0

; c4

func_nods srand
    %arg seed:word ; +6
    mov ax, [seed]
    mov [RandomSeed], ax
    mov [RandomSeed+2], word 0
endfunc

; dc

func_nods rand
    mov ax, 0x43fd
    mov dx, 3
    push dx
    push ax
    push word [RandomSeed+2]
    push word [RandomSeed]
    call far __aFlmul
    add ax, 0x9ec3
    adc dx, byte 0x26
    mov [RandomSeed], ax
    mov [RandomSeed+2], dx
    _MOVw(_AX, _DX)
    and ah, 0x7f
endfunc

; 110
extern __aFldiv
__aFldiv:
    %push func
    %stacksize small
    %arg arg_0:dword ; 6
    %arg arg_4:dword ; A
    push bp
    _MOVw(_BP, _SP)
    push di
    push si
    push bx
    _XORw(_DI, _DI)
    mov ax, [arg_0+2]
    _ORw(_AX, _AX)
    jge short .label0 ; ↓
    inc di
    mov dx, [arg_0]
    neg ax
    neg dx
    sbb ax, byte 0
    mov [arg_0+2], ax
    mov [arg_0], dx
.label0:
    mov ax, [arg_4+2]
    _ORw(_AX, _AX)
    jge short .label1 ; ↓
    inc di
    mov dx, [arg_4]
    neg ax
    neg dx
    sbb ax, byte 0
    mov [arg_4+2], ax
    mov [arg_4], dx
.label1:
    _ORw(_AX, _AX)
    jnz short .label2 ; ↓
    mov cx, [arg_4]
    mov ax, [arg_0+2]
    _XORw(_DX, _DX)
    div cx
    _MOVw(_BX, _AX)
    mov ax, [arg_0]
    div cx
    _MOVw(_DX, _BX)
    jmp short .label6 ; ↓
.label2:
    _MOVw(_BX, _AX)
    mov cx, [arg_4]
    mov dx, [arg_0+2]
    mov ax, [arg_0]
.label3:
    shr bx, 1
    rcr cx, 1
    shr dx, 1
    rcr ax, 1
    _ORw(_BX, _BX)
    jnz short .label3 ; ↑
    div cx
    _MOVw(_SI, _AX)
    mul word [arg_4+2]
    xchg ax, cx
    mov ax, [arg_4]
    mul si
    _ADDw(_DX, _CX)
    jb short .label4 ; ↓
    cmp dx, [arg_0+2]
    ja short .label4 ; ↓
    jb short .label5 ; ↓
    cmp ax, [arg_0]
    jbe short .label5 ; ↓
.label4:
    dec si
.label5:
    _XORw(_DX, _DX)
    xchg ax, si
.label6:
    dec di
    jnz short .label7 ; ↓
    neg dx
    neg ax
    sbb dx, byte 0
.label7:
    pop bx
    pop si
    pop di
    pop bp
    retf 8
    %pop func

; 1aa

func __stubmain
    push word [crt_hInstance]
    push word [crt_hPrevInstance]
    push word [crt_lpCmdLine+2]
    push word [crt_lpCmdLine]
    push word [crt_nCmdShow]
    call far WinMain
endfunc_crt

; 1d6

func __cinit
    mov ax, 0x3500              ; DOS3Call: Get interrupt vector (int 0)
    test word [cs:winflags], 1
    jz short .label0 ; ↓
    call far KERNEL.DOS3Call
    jmp short .label1 ; ↓
.label0:
    int 21h
.label1:
    mov [Int0_Save], bx
    mov [Int0_Save+2], es
    push cs
    pop ds
    mov ax, 0x2500              ; DOS3Call: Set Interrupt vector (int 0)
    mov dx, __cintDIV
    test word [cs:winflags], 1
    jz short .label2 ; ↓
    call far KERNEL.DOS3Call
    jmp short .label3 ; ↓
.label2:
    int 21h
.label3:
    push ss
    pop ds
    mov cx, [Var1518]
    jcxz .label5 ; ↓
    mov es, [Var14BE]
    mov si, [es:0x2c]
    mov ax, [Var151A]
    mov dx, [Var151C]
    _XORw(_BX, _BX)
    call far [Var1516]
    jnb short .label4 ; ↓
    jmp __fptrap
.label4:
    mov ax, [Var151E]
    mov dx, [Var1520]
    mov bx, 3
    call far [Var1516]
.label5:
    mov es, [Var14BE]
    mov cx, [es:0x2c]
    jcxz .label10 ; ↓
    mov es, cx
    _XORw(_DI, _DI)
.label6:
    cmp byte [es:di], 0
    jz short .label10 ; ↓
    mov cx, 0xd
    mov si, s_cFileInfo
    repe cmpsb
    jz short .label7 ; ↓
    mov cx, 0x7fff
    _XORw(_AX, _AX)
    repne scasb
    jnz short .label10 ; ↓
    jmp short .label6 ; ↑
.label7:
    push es
    push ds
    pop es
    pop ds
    _MOVw(_SI, _DI)
    mov di, Var14CE
    mov cl, 4
.label8:
    lodsb
    sub al, 0x41
    jb short .label9; ↓
    shl al, cl
    xchg ax, dx
    lodsb
    sub al, 0x41
    jb short .label9 ; ↓
    _ORb(_AL, _DL)
    stosb
    jmp short .label8 ; ↑
.label9:
    push ss
    pop ds
.label10:
    mov si, NMSG
    mov di, NMSG
    call FUN_1_037C
    mov si, NMSG
    mov di, NMSG
    call FUN_1_037C
    mov si, NMSG
    mov di, NMSG
    call FUN_1_037C
endfunc_crt

; 2b5

func exit
    _XORw(_CX, _CX)
    jmp short exit_common
endstub

; 2c3

func __exit
    mov cx, 1
    jmp short exit_common
endstub

; 2d2

func __cexit
    push si
    push di
    mov cx, 0x100
    jmp short exit_common
endstub

; 2e3

func __c_exit
    push si
    push di
    mov cx, 0x101
    ; Continue to exit_common
endstub

; 2f2

stub exit_common
    %arg arg_0:word ; +6
    mov [Var1503], ch
    push cx
    _ORb(_CL, _CL)
    jnz short .label0 ; ↓
    mov si, Var167C
    mov di, Var167C
    call FUN_1_037C
    mov si, NMSG
    mov di, NMSG
    call FUN_1_037C
    mov si, [arg_0]
    push si
    call __wcinit
    add sp, byte 2
.label0:
    mov si, NMSG
    mov di, NMSG
    call FUN_1_037C
    mov si, NMSG
    mov di, NMSG
    call FUN_1_037C
    call __ctermsub
    pop ax
    _ORb(_AH, _AH)
    jnz short .label2 ; ↓
    mov ax, [arg_0]
    mov ah, 0x4C                ; DOS3Call: Terminate program with return code
    test word [cs:winflags], 1
    jz short .label1 ; ↓
    call far KERNEL.DOS3Call
    jmp short .label2 ; ↓
.label1:
    int 21h
.label2:
    pop di
    pop si
endfunc_crt

; 353

__ctermsub:
    mov cx, [Var1518]
    jcxz .label0 ; ↓
    mov bx, 2
    call far [Var1516]
.label0:
    push ds
    lds dx, [Int0_Save]
    mov ax, 0x2500              ; DOS3Call: Set Interrupt vector (int 0)
    test word [cs:winflags], 1
    jz short .label1 ; ↓
    call far KERNEL.DOS3Call
    jmp short .label2 ; ↓
.label1:
    int 21h
.label2:
    pop ds
    retn

; 37c

FUN_1_037C:
    _CMPw(_SI, _DI)
    jnb short .end
    sub di, byte 4
    mov ax, [di]
    or ax, [di+2]
    jz short FUN_1_037C
    call far [di]
    jmp short FUN_1_037C
.end:
    retn

    db 0

; 390
func __FF_MSGBANNER
    mov ax, 0xfc
    push ax
    push cs
    call __NMSG_WRITE
    mov ax, 0xff
    push ax
    push cs
    call __NMSG_WRITE
endfunc_crt

    db 0

; 3b4

__setargv:
    pop word [Var1508]
    pop word [Var1508+2]
    mov ax, 0x104
    mov cx, 8
    call __myalloc
    mov [Var14FC+2], dx
    mov [Var14FC], ax
    push dx
    push ax
    push word [crt_hInstance]
    push dx
    push ax
    mov ax, 0x104
    push ax
    call far KERNEL.GetModuleFileName
    pop bx
    pop es
    _ADDw(_BX, _AX)
    mov byte [es:bx], 0
    mov dx, 1
    mov di, 1
    mov si, 0x81
    mov ds, [Var14BE]
.label0:
    lodsb
    cmp al, 0x20        ; ' '
    jz short .label0 ; ↑
    cmp al, 9           ; '\t'
    jz short .label0 ; ↑
    cmp al, 13          ; '\r'
    jz short .label11 ; ↓
    _ORb(_AL, _AL)
    jz short .label11 ; ↓
    inc di
.label1:
    dec si
.label2:
    lodsb
    cmp al, 0x20        ; ' '
    jz short .label0 ; ↑
    cmp al, 9           ; '\t'
    jz short .label0 ; ↑
    cmp al, 13          ; '\r'
    jz short .label11 ; ↓
    _ORb(_AL, _AL)
    jz short .label11 ; ↓
    cmp al, 0x22        ; '"'
    jz short .label7 ; ↓
    cmp al, 0x5C        ; '\\'
    jz short .label3 ; ↓
    inc dx
    jmp short .label2 ; ↑
.label3:
    _XORw(_CX, _CX)
.label4:
    inc cx
    lodsb
    cmp al, 0x5C        ; '\\'
    jz short .label4 ; ↑
    cmp al, 0x22        ; '"'
    jz short .label5 ; ↓
    _ADDw(_DX, _CX)
    jmp short .label1 ; ↑
.label5:
    _MOVw(_AX, _CX)
    shr cx, 1
    _ADCw(_DX, _CX)
    test al, 1
    jnz short .label2 ; ↑
    jmp short .label7 ; ↓
.label6:
    dec si
.label7:
    lodsb
    cmp al, 13          ; '\r'
    jz short .label11 ; ↓
    _ORb(_AL, _AL)
    jz short .label11 ; ↓
    cmp al, 0x22        ; '"'
    jz short .label2 ; ↑
    cmp al, 0x5C        ; '\\'
    jz short .label8 ; ↓
    inc dx
    jmp short .label7 ; ↑
.label8:
    _XORw(_CX, _CX)
.label9:
    inc cx
    lodsb
    cmp al, 0x5C        ; '\\'
    jz short .label9 ; ↑
    cmp al, 0x22        ; '"'
    jz short .label10 ; ↓
    _ADDw(_DX, _CX)
    jmp short .label6 ; ↑
.label10:
    _MOVw(_AX, _CX)
    shr cx, 1
    _ADCw(_DX, _CX)
    test al, 1
    jnz short .label7 ; ↑
    jmp short .label2 ; ↑
.label11:
    push ss
    pop ds
    mov [Var14F6], di
    _ADDw(_DX, _DI)
    inc di
    shl di, 1
    _ADDw(_DX, _DI)
    inc dx
    and dl, 0xfe
    _SUBw(_SP, _DX)
    _MOVw(_AX, _SP)
    mov [Var14F8], ax
    _MOVw(_BX, _AX)
    _ADDw(_DI, _BX)
    push ss
    pop es
    lds si, [Var14FC]
    mov [ss:bx], si
    inc bx
    inc bx
    mov ds, [ss:Var14BE]
    mov si, 0x81
    jmp short .label13 ; ↓
.label12:
    _XORw(_AX, _AX)
    stosb
.label13:
    lodsb
    cmp al, 0x20        ; ' '
    jz short .label13 ; ↓
    cmp al, 9           ; '\t'
    jz short .label13 ; ↓
    cmp al, 13          ; '\r'
    jz short .label25 ; ↓
    _ORb(_AL, _AL)
    jz short .label25 ; ↓
    mov [ss:bx], di
    inc bx
    inc bx
.label14:
    dec si
.label15:
    lodsb
    cmp al, 0x20        ; ' '
    jz short .label12 ; ↑
    cmp al, 9           ; '\t'
    jz short .label12 ; ↑
    cmp al, 13          ; '\r'
    jz short .label24 ; ↓
    _ORb(_AL, _AL)
    jz short .label24 ; ↓
    cmp al, 0x22        ; '"'
    jz short .label20 ; ↓
    cmp al, 0x5C        ; '\\'
    jz short .label16 ; ↓
    stosb
    jmp short .label15 ; ↑
.label16:
    _XORw(_CX, _CX)
.label17:
    inc cx
    lodsb
    cmp al, 0x5C        ; '\\'
    jz short .label17 ; ↑
    cmp al, 0x22        ; '"'
    jz short .label18 ; ↓
    mov al, 0x5C        ; '\\'
    rep stosb
    jmp short .label14 ; ↑
.label18:
    mov al, 0x5C        ; '\\'
    shr cx, 1
    rep stosb
    jnb short .label20 ; ↓
    mov al, 0x22        ; '"'
    stosb
    jmp short .label15 ; ↑
.label19:
    dec si
.label20:
    lodsb
    cmp al, 13          ; '\r'
    jz short .label24 ; ↓
    _ORb(_AL, _AL)
    jz short .label24 ; ↓
    cmp al, 0x22        ; '"'
    jz short .label15 ; ↑
    cmp al, 0x5C        ; '\\'
    jz short .label21 ; ↓
    stosb
    jmp short .label20 ; ↑
.label21:
    _XORw(_CX, _CX)
.label22:
    inc cx
    lodsb
    cmp al, 0x5C        ; '\\'
    jz short .label22 ; ↑
    cmp al, 0x22        ; '"'
    jz short .label23 ; ↓
    mov al, 0x5C        ; '\'
    rep stosb
    jmp short .label19 ; ↑
.label23:
    mov al, 0x5C        ; '\\'
    shr cx, 1
    rep stosb
    jnb .label15 ; ↑
    mov al, 0x22        ; '"'
    stosb
    jmp short .label20 ; ↑
.label24:
    _XORw(_AX, _AX)
    stosb
.label25:
    push ss
    pop ds
    mov word [bx], 0
    jmp far [Var1508]

    db 0

; 536

func __setenvp
    push ds
    call far KERNEL.GetDOSEnvironment
    _ORw(_AX, _AX)
    jz short .label0 ; ↓
    _MOVw(_DX, _AX)
.label0:
    _MOVw(_BX, _DX)
    mov es, dx
    _XORw(_AX, _AX)
    _XORw(_SI, _SI)
    _XORw(_DI, _DI)
    mov cx, -1
    _ORw(_BX, _BX)
    jz short .label2 ; ↓
    cmp byte [es:0], 0
    jz short .label2 ; ↓
.label1:
    repne scasb
    inc si
    scasb
    jnz short .label1 ; ↑
.label2:
    _MOVw(_AX, _DI)
    inc ax
    and al, 0xfe
    inc si
    _MOVw(_DI, _SI)
    shl si, 1
    mov cx, 9
    call __myalloc
    push ax
    _MOVw(_AX, _SI)
    call __myalloc
    mov [Var14FA], ax
    push es
    push ds
    pop es
    pop ds
    _MOVw(_CX, _DI)
    _MOVw(_BX, _AX)
    _XORw(_SI, _SI)
    pop di
    dec cx
    jcxz .label6 ; ↓
.label3:
    mov ax, [si]
    cmp ax, [ss:s_cFileInfo]
    jnz short .label4 ; ↓
    push cx
    push si
    push di
    mov di, s_cFileInfo
    mov cx, 6
    repe cmpsw
    pop di
    pop si
    pop cx
    jz short .label5 ; ↓
.label4:
    mov [es:bx], di
    inc bx
    inc bx
.label5:
    lodsb
    stosb
    _ORb(_AL, _AL)
    jnz short .label5 ; ↑
    loop .label3 ; ↑
.label6:
    mov [es:bx], cx
    pop ds
endfunc_crt

    db 0

; 5C6
__cintDIV:
    push ss
    pop ds
    mov ax, 3
    ; Continue to __amsg_exit

; 5cb

__amsg_exit:
    push ax
    push ax
    push cs
    call __FF_MSGBANNER
    push cs
    call __NMSG_WRITE
    push cs
    call __NMSG_TEXT
    _XORw(_BX, _BX)
    _ORw(_AX, _AX)
    jz short .label1 ; ↓
    _MOVw(_DI, _AX)
    mov ax, 9
    cmp byte [di], 0x4d
    jnz short .label0 ; ↓
    mov ax, 0xf
.label0:
    _ADDw(_DI, _AX)
    push di
    push ds
    pop es
    mov al, 0xd
    mov cx, 0x22
    repne scasb
    mov [di-1], bl
    pop ax
.label1:
    push bx
    push ds
    push ax
    call far KERNEL.FatalAppExit
    mov ax, 0xff
    push ax
    call far KERNEL.FatalExit

    db 0

; 60e

__catox:
    %push func
    %stacksize small
    %arg arg_0:word ; +6
    push bp
    _MOVw(_BP, _SP)
    push di
    push si
    mov si, [arg_0]
    _XORw(_AX, _AX)
    cwd
    _XORw(_BX, _BX)
.label0:
    lodsb
    cmp al, 0x20    ; ' '
    jz short .label0 ; ↑
    cmp al, 9       ; '\t'
    jz short .label0 ; ↑
    push ax
    cmp al, 0x2D    ; '-'
    jz short .label1 ; ↓
    cmp al, 0x2B    ; '+'
    jnz short .label2 ; ↓
.label1:
    lodsb
.label2:
    cmp al, 0x39    ; '9'
    ja short .label3 ; ↓
    sub al, 0x30    ; '0'
    jb short .label3 ; ↓
    shl bx, 1
    rcl dx, 1
    _MOVw(_CX, _BX)
    _MOVw(_DI, _DX)
    shl bx, 1
    rcl dx, 1
    shl bx, 1
    rcl dx, 1
    _ADDw(_BX, _CX)
    _ADCw(_DX, _DI)
    _ADDw(_BX, _AX)
    adc dx, byte 0
    jmp short .label1 ; ↑
.label3:
    pop ax
    cmp al, 0x2D    ; '-'
    xchg ax, bx
    jnz short .label4 ; ↓
    neg ax
    adc dx, byte 0
    neg dx
.label4:
    pop si
    pop di
    pop bp
    retf
    %pop func

; 662
extern __aFlmul
__aFlmul:
    %push func
    %stacksize small
    %arg arg_0:dword ; +6
    %arg arg_4:dword ; +A
    push bp
    _MOVw(_BP, _SP)
    mov ax, [arg_0+2]
    mov cx, [arg_4+2]
    _ORw(_CX, _AX)
    mov cx, [arg_4]
    jnz short .label0 ; ↓
    mov ax, [arg_0]
    mul cx
    pop bp
    retf 8
.label0:
    push bx
    mul cx
    _MOVw(_BX, _AX)
    mov ax, [arg_0]
    mul word [arg_4+2]
    _ADDw(_BX, _AX)
    mov ax, [arg_0]
    mul cx
    _ADDw(_DX, _BX)
    pop bx
    pop bp
    retf 8
    %pop func

; 694

__wcinit:
    push bp
    _MOVw(_BP, _SP)
    pop bp
    retn

; 699

__wopen:
    mov ax, 20
    jmp __amsg_exit

    db 0

; 6a0

__fptrap:
    mov ax, 2
    jmp __amsg_exit

; 6a6

func __NMSG_TEXT
    %assign %$argsize 0x2
    %arg arg_0:word ; +6
    push si
    push di
    push ds
    pop es
    mov dx, [arg_0]
    mov si, NMSG_Table
.label0:
    lodsw
    _CMPw(_AX, _DX)
    jz short .label1 ; ↓
    inc ax
    xchg ax, si
    jz short .label1 ; ↓
    xchg ax, di
    _XORw(_AX, _AX)
    mov cx, -1
    repne scasb
    _MOVw(_SI, _DI)
    jmp short .label0 ; ↑
.label1:
    xchg ax, si
    pop di
    pop si
endfunc_crt

; 6dd

func __NMSG_WRITE
    %assign %$argsize 0x2
    %arg arg_0:word ; +6
    push di
    cmp word [Var150C], byte 0
    jz short .end
    push word [arg_0]
    push cs
    call __NMSG_TEXT
    _ORw(_AX, _AX)
    jz short .end
    xchg ax, dx
    _MOVw(_DI, _DX)
    _XORw(_AX, _AX)
    mov cx, -1
    repne scasb
    not cx
    dec cx
    mov bx, [Var14C8]
    call __wopen
.end:
    pop di
endfunc_crt

; 71a

__myalloc:
    push bp
    _MOVw(_BP, _SP)
    push bx
    push es
    push cx
    mov cx, 0x1000
    xchg cx, [Var150E]
    push cx
    push ax
    call far __nmalloc
    pop bx
    pop word [Var150E]
    pop cx
    mov dx, ds
    _ORw(_AX, _AX)
    jz short .label0 ; ↓
    pop es
    pop bx
    jmp short .label1 ; ↓
.label0:
    _MOVw(_AX, _CX)
    jmp __amsg_exit
.label1:
    _MOVw(_SP, _BP)
    pop bp
    retn

    db 0

; 748

__growseg:
    push cx
    push di
    test byte [bx+2], 1
    jz short .label8 ; ↓
    call __findlast
    _MOVw(_DI, _SI)
    mov ax, [si]
    test al, 1
    jz short .label0 ; ↓
    _SUBw(_CX, _AX)
    dec cx
.label0:
    inc cx
    inc cx
    mov si, [bx+4]
    _ORw(_SI, _SI)
    jz short .label8 ; ↓
    _ADDw(_CX, _SI)
    jnb short .label1 ; ↓
    _XORw(_AX, _AX)
    mov dx, -16
    jcxz .label6 ; ↓
    jmp short .label8 ; ↓
.label1:
    push ss
    pop es
    mov ax, [es:Var150E]
    cmp ax, 0x1000
    jz .label4 ; ↓
    mov dx, 0x8000
.label2:
    _CMPw(_DX, _AX)
    jb .label3 ; ↓
    shr dx, 1
    jnz short .label2 ; ↑
    jmp short .label7 ; ↓
.label3:
    cmp dx, byte 8
    jb .label7 ; ↓
    shl dx, 1
    _MOVw(_AX, _DX)
.label4:
    dec ax
    _MOVw(_DX, _AX)
    _ADDw(_AX, _CX)
    jnb short .label5 ; ↓
    _XORw(_AX, _AX)
.label5:
    not dx
    _ANDw(_AX, _DX)
.label6:
    push dx
    call __incseg
    pop dx
    jnb .label9 ; ↓
    cmp dx, byte -0x10
    jz .label8 ; ↓
.label7:
    mov ax, 0x10
    jmp short .label4 ; ↑
.label8:
    stc
    jmp short .end
.label9:
    _MOVw(_DX, _AX)
    sub dx, [bx+4]
    mov [bx+4], ax
    mov [bx+10], di
    mov si, [bx+12]
    dec dx
    mov [si], dx
    inc dx
    _ADDw(_SI, _DX)
    mov word [si], -2
    mov [bx+12], si
.end:
    pop di
    pop cx
    retn

; 7d4

__incseg:
    _MOVw(_DX, _AX)
    test byte [bx+2], 4
    jz short .label0 ; ↓
    jmp short .label4 ; ↓
.label0:
    push dx
    push cx
    push bx
    mov si, [bx+6]
    mov bx, [cs:winflags]
    _XORw(_CX, _CX)
    _ORw(_DX, _DX)
    jnz short .label1 ; ↓
    test bx, 0x10
    jnz short .label5 ; ↓
    inc cx
.label1:
    mov ax, 2
    test bx, 1
    jnz short .label2 ; ↓
    mov ax, 0x20
.label2:
    push si
    push cx
    push dx
    push ax
    call far KERNEL.GlobalReAlloc
    _ORw(_AX, _AX)
    jz short .label5 ; ↓
    _CMPw(_AX, _SI)
    jnz short .label4 ; ↓
    push si
    call far KERNEL.GlobalSize
    _ORw(_DX, _AX)
    jz short .label4 ; ↓
    pop bx
    pop cx
    pop dx
    _MOVw(_AX, _DX)
    test byte [bx+2], 4
    jz short .label3 ; ↓
    dec dx
    mov [bx-2], dx
.label3:
    clc
    jmp short .end
.label4:
    mov ax, 0x12
    jmp __amsg_exit
.label5:
    pop bx
    pop cx
    pop dx
    stc
.end:
    retn

; 83a

__findlast:
    push di
    mov si, [bx+10]
    cmp si, [bx+12]
    jnz short .label0 ; ↓
    mov si, [bx+8]
.label0:
    lodsw
    cmp ax, byte -2
    jz short .label1 ; ↓
    _MOVw(_DI, _SI)
    and al, 0xfe
    _ADDw(_SI, _AX)
    jmp short .label0 ; ↑
.label1:
    dec di
    dec di
    _MOVw(_SI, _DI)
    pop di
    retn

; 85a

func_nods __nmalloc
    %arg arg_0:word ; +6
    %local local_4:word ; -4
    sub sp, byte 4
    cmp word [arg_0], byte 0
    jnz short .label0 ; ↓
    mov word [arg_0], 1
.label0:
    mov ax, -1
    push ax
    call far KERNEL.LockSegment
    mov ax, 0x20
    push ax
    push word [arg_0]
    call far KERNEL.LocalAlloc
    mov [local_4], ax
    mov ax, -1
    push ax
    call far KERNEL.UnlockSegment
    cmp word [local_4], byte 0
    jnz short .label1 ; ↓
    mov ax, [Var1510+2]
    or ax, [Var1510]
    jz short .label1 ; ↓
    push word [arg_0]
    call far [Var1510]
    add sp, byte 2
    _ORw(_AX, _AX)
    jnz short .label0 ; ↑
.label1:
    mov ax, [local_4]
endfunc

; 8b6

func_nods __nfree
    %arg arg_0:word ; +6
    cmp word [arg_0], byte 0
    jz short .end
    push word [arg_0]
    call far KERNEL.LocalFree
.end:
endfunc

; 8d0

func_nods __nrealloc
    %arg arg_0:word ; +6
    %arg arg_2:word ; +8
    %local local_4:word ; -4
    sub sp, byte 6
    cmp word [arg_0], byte 0
    jnz short .label0 ; ↓
    push word [arg_2]
    call far __nmalloc
    add sp, byte 2
    jmp short .end
    align 2
.label0:
    cmp word [arg_2], byte 0
    jnz short .label1 ; ↓
    push word [arg_0]
    call far __nfree
    add sp, byte 2
    _XORw(_AX, _AX)
    jmp short .end
    align 2
.label1:
    mov ax, -1
    push ax
    call far KERNEL.LockSegment
    push word [arg_0]
    cmp word [arg_2], byte 0
    jz short .label2 ; ↓
    mov ax, [arg_2]
    jmp short .label3 ; ↓
    align 2
.label2:
    mov ax, 1
.label3:
    push ax
    mov ax, 0x62
    push ax
    call far KERNEL.LocalReAlloc
    mov [local_4], ax
    mov ax, -1
    push ax
    call far KERNEL.UnlockSegment
    mov ax, [local_4]
.end:
endfunc

; 93e

func_nods __nmsize
    %arg arg_0:word ; +6
    push word [arg_0]
    call far KERNEL.LocalSize
endfunc

; 952

GLOBAL _segment_1_size
_segment_1_size equ $ - $$

; vim: syntax=nasm
