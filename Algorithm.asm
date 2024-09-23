section .data
    temp_buffer resb 2         ; Buffer temporal para almacenar los 2 bytes de bx
    filepath db 'sample_procesado.bin', 0  ; Ruta al archivo binario
    save_filepath db 'procesado.bin', 0  ; Ruta al archivo binario
    max_file_size equ 71680              ; Tamaño máximo del archivo (70kB)]
    dictionary times 71680 db '&'        ; Inicializar todo el buffer con '&'
    histogram times 256 db '&'        ; Inicializar todo el buffer con '&'


section .bss
    buffer resb max_file_size            ; Buffer para cargar todo el archivo (70kB)
    file_descriptor resd 1               ; Espacio para el descriptor del archivo
    bytes_read resd 1                    ; Almacenar la cantidad de bytes leídos
    end_of_file_flag resb 1              ; Flag que indica si ya se terminó de leer el archivo
    end_of_buffer_flag resb 1              ; Flag que indica si ya se terminó de leer el archivo
    word_buffer resb 32                  ; Buffer para almacenar la palabra leída (máximo 16 caracteres)
    compare_buffer resb 32               ; Buffer para almacenar la palabra leída (máximo 16 caracteres)


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
    mov byte [end_of_buffer_flag], 0  ; Refrescar la bandera de fin de buffer

    mov al, [esi]              ; Leer un byte del buffer
    cmp al, ','                ; Comprobar si es una coma
    je end_read_word           ; Si es una coma, terminar el bucle

    cmp al, 0                  ; Comprobar si es el byte nulo (fin del texto principal)
    je save_info                    ; Si es nulo, saltar a la salida

    mov [edi], al              ; Almacenar el byte en el buffer de la palabra
    inc edi                    ; Mover el puntero al siguiente byte
    inc esi                    ; Mover el puntero al siguiente byte
    jmp read_word              ; Volver a leer otro byte

end_read_word:  

    mov byte [edi], 0          ; Terminar la palabra con un byte nulo
    mov ecx, esi               ; Mover el puntero del buffer a ESI
    add ecx, 1                 ; Avanzar un byte para omitir la coma
    mov esi, ecx               ; Actualizar el puntero del buffer

    mov edi, word_buffer       ; EDI apunta al buffer de la palabra a comparar
    mov edx, dictionary        ; EDX ahora contiene la dirección de inicio del dictionary

    jmp compare_new_loop       ; Redirigir a la nueva función

compare_new_loop:
    ; Verificar si llegamos al final del dictionary (buscando '&')
    cmp byte [edx], 0x26       ; Comprobar si es el carácter '&'
    je search_word_in_block     ; Si es '&', saltar a buscar la palabra en el bloque

    ; Comparar byte a byte palabra de word_buffer y dictionary
    mov al, [edi]              ; Cargar el byte actual de word_buffer
    mov ah, [edx]              ; Cargar el byte actual de dictionary
    cmp al, ah                 ; Comparar los bytes
    jne find_next_new_word     ; Si no son iguales, buscar la siguiente palabra

    ; Verificar si es el final de la palabra en word_buffer
    cmp al, 0                  ; Comprobar si es el byte nulo en word_buffer
    je check_new_dictionary_delimiter  ; Si es el final, verificar si en dictionary hay '/'

    ; Avanzar ambos punteros
    inc edi                    ; Avanzar al siguiente byte en word_buffer
    inc edx                    ; Avanzar al siguiente byte en dictionary
    jmp compare_new_loop       ; Volver a comparar el siguiente byte



check_new_dictionary_delimiter:
    cmp byte [edx], '/'        ; Verificar si hay un '/' en el dictionary (final de palabra)
    je clear_word_buffer       ; Si lo hay, la palabra está en el dictionary, saltar a new_word_found
    jmp find_next_new_word      ; Si no lo hay, buscar la siguiente palabra


find_next_new_word:
    cmp byte [edx], ','    ; Buscar la coma que separa las palabras
    je move_to_next_new_word   ; Si encontramos la coma, mover al inicio de la siguiente palabra
    inc edx                ; Avanzar al siguiente byte
    jmp find_next_new_word ; Repetir hasta encontrar la coma


move_to_next_new_word:
    inc edx                    ; Avanzar al siguiente byte después de la coma
    jmp compare_new_loop       ; Volver a comparar la palabra


search_word_in_block:

    mov ebp, buffer            ; EBP ahora contiene la dirección del buffer grande
    mov edi, word_buffer       ; EDI apunta al buffer de la palabra a comparar
    mov edx, compare_buffer    ; EBX apunta al buffer donde se almacenará la palabra
    mov bx, 0                  ; Inicializar el contador de palabras
        
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
        
    jmp insert_word_in_dictionary


end_read_loop:
    mov byte [edx], 0          ; Terminar la palabra con un byte nulo ;
    inc ebp                    ; Mover el puntero al siguiente byte para omitir la coma
    jmp compare_loop

compare_loop:

    mov edx, compare_buffer    ; EDX apunta al buffer de la palabra leída
    mov edi, word_buffer       ; EDI apunta al buffer de la palabra a comparar

    jmp compare_loop_inner
    
compare_loop_inner:

    mov al, [edx]              ; Leer un byte de la palabra leída usando el contador
    mov ah, [edi]              ; Leer un byte de la palabra a comparar usando el contador
    cmp al, ah                 ; Comparar los bytes
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

    inc bx

    jmp clear_compare_buffer


clear_word_buffer:

    xor bx, bx               ; Inicializar el contador de palabras
    mov edi, word_buffer       ; EDX apunta al inicio del buffer
    mov ecx, 32                ; Número de bytes a limpiar (32 bytes)
    xor eax, eax               ; Valor a escribir (0)

    jmp word_clear_loop


word_clear_loop:
    mov [edi], al              ; Escribir 0 en el buffer PUEDE QUE SEA CON EDX LA LIMPIEZA
    inc edi                    ; Mover al siguiente byte del buffer
    loop word_clear_loop            ; Repetir hasta que ECX sea 0

    mov edi, word_buffer       ; EDX apunta al inicio del buffer
    
    jmp clear_compare_buffer

clear_compare_buffer:

    mov edx, compare_buffer    ; EDX apunta al inicio del buffer
    mov ecx, 32                ; Número de bytes a limpiar (32 bytes)
    xor eax, eax               ; Valor a escribir (0)

    jmp compare_clear_loop

compare_clear_loop:
    mov [edx], al              ; Escribir 0 en el buffer
    inc edx                    ; Mover al siguiente byte del buffer
    loop compare_clear_loop            ; Repetir hasta que ECX sea 0

    mov edx, compare_buffer    ; EDX apunta al inicio del buffer
    
    cmp byte [end_of_buffer_flag], 1
    je read_word

    jmp read_loop

insert_word_in_dictionary:
    push bx                    ; Guardamos bx (frecuencia) en la pila
    push edi                   ; Guardamos edi (dirección de word_buffer) en la pila
    mov ecx, dictionary        ; Cargar la dirección base de dictionary

find_free_space:
    cmp byte [ecx], 0x26        ; Comprobar si es un byte nulo (espacio libre)
    je copy_word             ; Si encuentra espacio libre, saltar a la inserción
    inc ecx                    ; Mover al siguiente byte en dictionary
    jmp find_free_space        ; Repetir hasta encontrar espacio libre

copy_word:
    mov al, [edi]              ; Leer un byte de la palabra desde word_buffer
    cmp al, 0                  ; Comprobar si es el byte nulo de final de palabra
    je insert_separator        ; Si es nulo, saltar a insertar '/'
    mov [ecx], al              ; Escribir el byte en dictionary

    inc edi                    ; Mover al siguiente byte de la palabra
    inc ecx                    ; Mover al siguiente byte en dictionary
    jmp copy_word              ; Repetir el proceso para copiar la palabra

insert_separator:
    mov byte [ecx], '/'        ; Insertar el separador '/'
    inc ecx                    ; Mover al siguiente byte en dictionary
    jmp insert_frequency       ; Saltar a insertar la frecuencia

insert_frequency:
    ; Insertar la frecuencia en 16 bits (bx)
    mov [ecx], bx              ; Almacenar el valor de bx (frecuencia) en dictionary
    add ecx, 2                 ; Avanzar 2 bytes, porque ebx es de 32 bits
    jmp insert_comma           ; Saltar a insertar la coma

insert_comma:
    mov byte [ecx], ','        ; Insertar la coma separadora
    inc ecx                    ; Mover al siguiente byte en dictionary
    jmp restore_registers      ; Saltar a restaurar los registros

restore_registers:
    pop edi                    ; Restaurar edi
    pop bx                     ; Restaurar bx
    jmp clear_word_buffer      ; Saltar a limpiar el buffer de la palabra


save_info:
    ; Abrir el archivo en modo de escritura (O_WRONLY | O_CREAT)
    mov eax, 5                 ; syscall número 5: sys_open
    mov ebx, save_filepath     ; Ruta del archivo donde guardar el diccionario
    mov ecx, 0101o             ; Modo de escritura y creación si no existe (O_WRONLY | O_CREAT)
    mov edx, 0644o             ; Permisos del archivo rw-r--r--
    int 0x80                   ; Llamada al sistema
    cmp eax, 0                 ; Verificar si se abrió correctamente
    js error_opening_file      ; Saltar en caso de error
    mov [file_descriptor], eax ; Guardar el descriptor del archivo

    ; Escribir el diccionario en el archivo
    mov eax, 4                 ; syscall número 4: sys_write
    mov ebx, [file_descriptor] ; Descriptor del archivo
    mov ecx, dictionary        ; Dirección del diccionario
    mov edx, max_file_size     ; Tamaño del diccionario
    int 0x80                   ; Llamada al sistema para escribir

    ; Cerrar el archivo
    mov eax, 6                 ; syscall número 6: sys_close
    mov ebx, [file_descriptor] ; Descriptor del archivo a cerrar
    int 0x80                   ; Llamada al sistema para cerrar el archivo

    jmp exit



error_writing_file:
    mov eax, 1                 ; syscall número 1: sys_exit
    xor ebx, ebx               ; Código de salida 0 (Error)
    int 0x80                   ; Salir del programa en caso de error

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










;find_highest_frequency:
;    xor bx, bx                 ; Inicializar la frecuencia máxima a 0
;    xor ax, ax                 ; Limpiar AX para comparar frecuencias
;    xor bp, bp                 ; Limpiar BP para almacenar el contador de palabras
;    push 0                     ; Inicializar el contador de palabras encontradas en la pila

;    jmp search_next_frequency


;search_next_frequency:

;    cmp byte [esi], 0x26        ; Comprobar si es el carácter '&' (fin del dictionary)
;    je find_word_with_highest_frequency                    ; Si es '&', terminar la búsqueda

;    ; Buscar el separador '/' para pasar a la frecuencia
;    jmp skip_to_frequency

;skip_to_frequency:
;    cmp byte [esi], '/'        ; Buscar el separador '/'
;    je extract_frequency       ; Si es '/', saltar a extraer la frecuencia
;    inc esi                    ; Avanzar al siguiente byte en el diccionario
;    jmp skip_to_frequency      ; Repetir hasta encontrar el separador

;extract_frequency:
;    mov ax, [esi + 1]          ; Cargar los 2 bytes de la frecuencia en AX
;    cmp ax, bx                 ; Comparar la frecuencia con la mayor frecuencia guardada en BX
;    jle skip_to_next_entry     ; Si la frecuencia actual es menor o igual, saltar

;    ; Si encontramos una frecuencia mayor, actualizamos BX
;    mov bx, ax                 ; Actualizar la frecuencia más alta en BX
;    jmp skip_to_next_entry     ; Saltar al siguiente bloque de palabras

;skip_to_next_entry:
;    ; Saltar al siguiente bloque de palabras (después de la coma)
;    add esi, 4                 ; Avanzar para saltar la frecuencia (2 bytes) y la coma (1 byte)
;    jmp search_next_frequency  ; Repetir el proceso



;find_word_with_highest_frequency:
;    mov esi, dictionary        ; Reiniciar ESI al inicio del dictionary
;    xor edi, edi               ; Reiniciar EDI para la palabra más repetida


;    jmp search_word_with_frequency

;search_word_with_frequency:
;    cmp byte [esi], 0x26         ; Comprobar si es el carácter '&' (fin del dictionary)
;    je exit                    ; Si es '&', salir

;    ; Buscar el separador '/' para pasar a la frecuencia
;    jmp skip_to_frequency_again

;skip_to_frequency_again:
;    cmp byte [esi], '/'        ; Buscar el separador '/'
;    je check_frequency_again   ; Si es '/', saltar a verificar la frecuencia
;    inc esi                    ; Avanzar al siguiente byte en el diccionario
;    jmp skip_to_frequency_again ; Repetir hasta encontrar el separador

;check_frequency_again:
;    mov ax, [esi + 1]          ; Cargar los 2 bytes de la frecuencia
;    cmp ax, bx                 ; Comparar con la frecuencia almacenada en BX
;    jne skip_to_next_entry_again ; Si no coincide, saltar al siguiente bloque

;    ; Si la frecuencia coincide con BX, retroceder hasta la coma anterior
;    mov ecx, esi               ; Guardar la posición actual
;    jmp find_comma

;find_comma:
;    dec ecx                    ; Retroceder byte a byte
;    cmp byte [ecx], ','        ; Comprobar si encontramos la coma ','
;    jne find_comma             ; Si no es la coma, seguir retrocediendo

;    lea edi, [ecx + 1]         ; EDI apunta al inicio de la palabra (después de la coma)
;    mov edx, word_buffer       ; EDX apunta al buffer word_buffer para almacenar la palabra

;    jmp copy_word_to_buffer

;copy_word_to_buffer:
;    mov al, [edi]              ; Leer un byte de la palabra
;    cmp al, '/'                ; Comprobar si es el separador '/' (fin de la palabra)
;    je end_copy_word           ; Si es '/', terminar la copia
;    mov [edx], al              ; Almacenar el byte en el buffer de la palabra
;    inc edi                    ; Avanzar al siguiente byte de la palabra
;    inc edx                    ; Avanzar al siguiente byte en el buffer de la palabra
;    jmp copy_word_to_buffer    ; Repetir hasta copiar la palabra completa

;end_copy_word:
;    mov byte [edx], 0          ; Terminar la palabra con un byte nulo
;    jmp store_in_histogram                   ; Terminar

;skip_to_next_entry_again:
;    ; Saltar al siguiente bloque de palabras (después de la coma)
;    add esi, 4                 ; Avanzar para saltar la frecuencia (2 bytes) y la coma (1 byte)
;    jmp search_word_with_frequency ; Repetir el proceso



;store_in_histogram:
;    mov esi, word_buffer       ; ESI apunta a la palabra en word_buffer
;    mov edi, histogram         ; EDI apunta al inicio del buffer histogram

;    ; Buscar una posición libre en el buffer
;    jmp find_free_space_in_histogram

;find_free_space_in_histogram:


;    cmp byte [edi], 0x26       ; Comprobar si llegamos al final del buffer
;    je copy_word_to_histogram  ; Si llegamos al final, saltar a copiar la palabra

;    inc edi                    ; Avanzar al siguiente byte

;    jmp find_free_space        ; Repetir hasta encontrar espacio libre

;copy_word_to_histogram:
;    mov edx, esi               ; EDX apuntará a la palabra en word_buffer (temporal)
;    jmp copy_word_loop         ; Saltar a copiar la palabra en el histogram

;copy_word_loop:
;    mov al, [edx]              ; Leer un byte de la palabra
;    cmp al, 0                  ; Comprobar si es el byte nulo (fin de la palabra)
;    je add_separator           ; Si es 0, saltar para agregar el separador '/'
;    mov [edi], al              ; Copiar el byte al histogram
;    inc edx                    ; Avanzar al siguiente byte en word_buffer
;    inc edi                    ; Avanzar al siguiente byte en histogram
;    jmp copy_word_loop              ; Repetir hasta que se copie toda la palabra

;add_separator:
;    mov byte [edi], '/'        ; Agregar el separador '/'
;    inc edi                    ; Avanzar al siguiente byte en histogram

;    jmp store_frequency        ; Saltar a almacenar la frecuencia

;store_frequency:
;    mov [edi], bx              ; Almacenar los dos bytes de la frecuencia en histogram
;    add edi, 2                 ; Avanzar 2 bytes después de la frecuencia

;    jmp add_comma              ; Saltar a agregar la coma

;add_comma:
;    mov byte [edi], ','        ; Agregar la coma
;    inc edi                    ; Avanzar al siguiente byte en histogram

;    ; Incrementar el contador de iteraciones
;    pop ax                     ; Recuperar el contador actual de la pila
;    inc ax                     ; Incrementar el contador
;    push ax                    ; Guardar el nuevo valor en la pila

;    cmp ax, 10                 ; Comprobar si se han agregado 10 palabras
;    je exit                    ; Si se han agregado 10 palabras, salir

;    ; Preparar para la siguiente iteración
;    push bx                    ; Guardar la frecuencia máxima actual en la pila
;    jmp find_next_highest_frequency ; Buscar la siguiente frecuencia más alta

;find_next_highest_frequency:
;    pop bx                     ; Recuperar la frecuencia máxima anterior desde la pila

;    ; Reiniciar búsqueda de la siguiente palabra con frecuencia más baja
;    mov esi, dictionary        ; Reiniciar ESI al inicio del dictionary

;    jmp search_next_frequency 





































