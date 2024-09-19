section .data
    filepath db 'text_procesado.bin', 0  ; Ruta al archivo binario
    buffer_size equ 2048                 ; Tamaño del buffer (2kB)

section .bss
    file_descriptor resd 1               ; Espacio para el descriptor del archivo
    buffer resb buffer_size              ; Buffer para cargar los datos (2kB)
    bytes_read resd 1                    ; Almacenar la cantidad de bytes leídos

section .text
global _start

_start:
    ; Abrir el archivo en modo de solo lectura (O_RDONLY = 0)
    mov eax, 5                 ; syscall número 5: sys_open
    mov ebx, filepath          ; Ruta del archivo a abrir
    xor ecx, ecx               ; Modo de solo lectura (O_RDONLY = 0)
    int 0x80                   ; Interrupción para realizar la llamada al sistema
    mov [file_descriptor], eax  ; Guardar el descriptor del archivo

    ; Verificar si se abrió correctamente (si eax es negativo, hubo un error)
    cmp eax, 0
    js exit                    ; Salir si hubo error al abrir el archivo

    ; Leer el archivo en bloques de 2kB (2048 bytes)
    mov eax, 3                 ; syscall número 3: sys_read
    mov ebx, [file_descriptor] ; Descriptor del archivo
    mov ecx, buffer            ; Dirección del buffer donde se almacenará lo leído
    mov edx, buffer_size       ; Leer 2048 bytes (2kB)
    int 0x80                   ; Interrupción para realizar la llamada al sistema

    ; Guardar la cantidad de bytes leídos
    mov [bytes_read], eax

    ; Verificar si llegamos al final del archivo o si hubo error
    cmp eax, 0
    je exit                    ; Si no se leyeron más bytes o hubo error, salir

exit:
    ; Cerrar el archivo
    mov eax, 6                 ; syscall número 6: sys_close
    mov ebx, [file_descriptor] ; Descriptor del archivo a cerrar
    int 0x80                   ; Interrupción para realizar la llamada al sistema

    ; Finalizar el programa
    mov eax, 1                 ; syscall número 1: sys_exit
    xor ebx, ebx               ; Código de salida 0
    int 0x80                   ; Interrupción para salir
