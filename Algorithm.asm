section .data
    filepath db 'text_procesado.bin', 0  ; Ruta al archivo binario
    max_file_size equ 71680              ; Tamaño máximo del archivo (70kB)]


section .bss
    buffer resb max_file_size            ; Buffer para cargar todo el archivo (70kB)
    file_descriptor resd 1               ; Espacio para el descriptor del archivo
    bytes_read resd 1                    ; Almacenar la cantidad de bytes leídos
    end_of_file_flag resb 1              ; Flag que indica si ya se terminó de leer el archivo
    end_of_buffer_flag resb 1              ; Flag que indica si ya se terminó de leer el archivo
    word_buffer resb 32                  ; Buffer para almacenar la palabra leída (máximo 16 caracteres)
    compare_buffer resb 32               ; Buffer para almacenar la palabra leída (máximo 16 caracteres)
    word_count resd 1                    ; Contador de palabras

section .text
global _start

_start:

    ; Abrir el archivo en modo de solo lectura (O_RDONLY = 0)
    mov eax, 5                 ; syscall número 5: sys_open
    mov ebx, filepath          ; Ruta del archivo a abrir
    xor ecx, ecx               ; Modo de solo lectura (O_RDONLY = 0)
    int 0x80                   ; Interrupción para realizar la llamada al sistema

    ; Verificar si el archivo se abrió correctamente
    cmp eax, 0
    js error_opening_file       ; Si eax es negativo, hubo un error, saltar al manejo de error

    mov [file_descriptor], eax  ; Guardar el descriptor del archivo si todo está bien

    ; Leer el archivo completo (hasta 70KB)
    mov eax, 3                 ; syscall número 3: sys_read
    mov ebx, [file_descriptor] ; Descriptor del archivo
    mov ecx, buffer            ; Dirección del buffer donde se almacenará el archivo
    mov edx, max_file_size      ; Leer hasta 70kB
    int 0x80                   ; Interrupción para realizar la llamada al sistema

    ; Verificar si hubo un error al leer el archivo
    cmp eax, 0
    js error_reading_file       ; Si eax es negativo, hubo un error

    mov [bytes_read], eax       ; Guardar la cantidad de bytes leídos

    ; Marcar fin de archivo si se leyó menos de 70KB
    cmp eax, max_file_size
    jl file_read_complete

    ; Saltar al controlador del algoritmo principal
    jmp get_word

file_read_complete:
    mov byte [end_of_file_flag], 1  ; Indicar que se ha llegado al final del archivo
    jmp get_word


get_word:

    mov esi, ecx               ; ESI ahora contiene la dirección del buffer
    mov edi, word_buffer       ; EDI apunta al buffer donde se almacenará la palabra

    jmp read_word

read_word:
    mov al, [esi]              ; Leer un byte del buffer
    cmp al, ','                ; Comprobar si es una coma
    je end_read_word           ; Si es una coma, terminar el bucle

    mov [edi], al              ; Almacenar el byte en el buffer de la palabra
    inc edi                    ; Mover el puntero al siguiente byte
    inc esi                    ; Mover el puntero al siguiente byte
    jmp read_word              ; Volver a leer otro byte

end_read_word:  

    mov byte [edi], 0          ; Terminar la palabra con un byte nulo
    mov ecx, esi               ; Mover el puntero del buffer a ESI
    add ecx, 1                 ; Avanzar un byte para omitir la coma
    mov esi, ecx               ; Actualizar el puntero del buffer

    jmp search_word_in_block


search_word_in_block:

    mov ebp, buffer            ; EBP ahora contiene la dirección del buffer grande
    mov edi, word_buffer       ; EDI apunta al buffer de la palabra a comparar
    mov edx, compare_buffer    ; EBX apunta al buffer donde se almacenará la palabra
        
    jmp read_loop

read_loop:

    mov al, [ebp]              ; Leer un byte del buffer
    cmp al, 0                  ; Comprobar si es el final del buffer
    je end_of_buffer
    cmp al, ','                ; Comprobar si es una coma
    je end_read_loop           ; Si es una coma, terminar el bucle

    mov [edx], al              ; Almacenar el byte en el buffer de la palabra
    inc edx                    ; Mover el puntero al siguiente byte
    inc ebp                    ; Mover el puntero al siguiente byte
    
    jmp read_loop              ; Volver a leer otro byte


end_of_buffer:
    mov byte [end_of_buffer_flag], 1  ; Indicar que se ha llegado al final del buffer
    jmp end_read_loop


end_read_loop:
    mov byte [edx], 0          ; Terminar la palabra con un byte nulo ;CUIDADO CON ESTO!!
    inc ebp                    ; Mover el puntero al siguiente byte para omitir la coma

    jmp compare_loop

compare_loop:

    cmp byte [end_of_buffer_flag], 1
    je end_compare_loop

    mov edx, compare_buffer    ; EDX apunta al buffer de la palabra leída
    mov edi, word_buffer       ; EDI apunta al buffer de la palabra a comparar

    jmp compare_loop_inner
    
compare_loop_inner:

    mov al, [edx]              ; Leer un byte de la palabra leída usando el contador
    mov bl, [edi]              ; Leer un byte de la palabra a comparar usando el contador
    cmp al, bl                 ; Comparar los bytes
    jne words_not_equal        ; Si no son iguales, salir

    cmp al, 0                  ; Comprobar si es el final de la palabra
    je words_equal             ; Si es el final, las palabras son iguales

    inc edx                    ; Mover el puntero al siguiente byte
    inc edi                    ; Mover el puntero al siguiente byte

    jmp compare_loop_inner     ; Repetir la comparación


words_not_equal:
    xor eax, eax               ; Indicar que las palabras no son iguales
    jmp verify_word

words_equal:
    mov eax, 1                 ; Indicar que las palabras son iguales
    jmp verify_word

verify_word:
    ; Si las palabras coinciden, incrementar el contador
    cmp eax, 1
    jne clear_compare_buffer

    inc dword [word_count]

    jmp clear_compare_buffer


clear_compare_buffer:

    mov edx, compare_buffer    ; EDX apunta al inicio del buffer
    mov ecx, 32                ; Número de bytes a limpiar (32 bytes)
    xor eax, eax               ; Valor a escribir (0)

    jmp clear_loop

clear_loop:
    mov [edx], al              ; Escribir 0 en el buffer
    inc edx                    ; Mover al siguiente byte del buffer
    loop clear_loop            ; Repetir hasta que ECX sea 0

    jmp read_loop


end_compare_loop:

    jmp exit

error_opening_file:
    ; Manejo del error al abrir el archivo
    mov eax, 1                 ; syscall número 1: sys_exit
    xor ebx, ebx               ; Código de salida 0 (Error)
    int 0x80                   ; Salir del programa

error_reading_file:
    ; Manejo del error al leer el archivo
    mov eax, 1                 ; syscall número 1: sys_exit
    xor ebx, ebx               ; Código de salida 0 (Error)
    int 0x80                   ; Salir del programa

exit:
    ; Cerrar el archivo
    mov eax, 6                 ; syscall número 6: sys_close
    mov ebx, [file_descriptor] ; Descriptor del archivo a cerrar
    int 0x80                   ; Interrupción para realizar la llamada al sistema

    ; Finalizar el programa
    mov eax, 1                 ; syscall número 1: sys_exit
    xor ebx, ebx               ; Código de salida 0
    int 0x80                   ; Interrupción para salir






























