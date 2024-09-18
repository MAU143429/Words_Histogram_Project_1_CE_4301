section .data
    num1 dd 10
    num2 dd 20

section .text
global _start

_start:
    ; Cargar los valores de los números en registros
    mov eax, [num1]            ; Cargar el valor de num1 en eax
    mov ebx, [num2]            ; Cargar el valor de num2 en ebx

    ; Sumar los números
    add eax, ebx               ; Sumar eax y ebx (resultado queda en eax)

    ; El valor de la suma está en el registro eax

    ; Etiqueta para detener el depurador
exit:
    nop                        ; Punto de parada para el depurador en 'exit'

    ; Finalizar el programa
    mov eax, 1                 ; syscall número 1: sys_exit
    xor ebx, ebx               ; Código de salida 0
    int 0x80                   ; Interrupción para salir

