/*##########################################################################################
#                                  Tecnológico de Costa Rica                               #
#                                Arquitectura de Computadores I                            #
#                              Proyecto #1 Creador de Histogramas                          #
#                                Mauricio Calderón 2019182667                              #
##########################################################################################*/

.global _start

.section .data
    buffer:      .space 10485760                @ Se establece un buffer de 10MB para almacenar el contenido del archivo
    dictionary:  .space 1400000                 @ Se establece un diccionario de 1.4MB para almacenar las palabras y frecuencias
    finaltext:   .space 1000                    @ Se establece un espacio de 1KB para almacenar el texto final
    character:   .space 1                       @ Se define un espacio de 1B para almacenar un caracter         
    word:        .space 30                      @ Se define un espacio de 30B para almacenar una palabra        
    filedata:    .space 48                      @ Cantidad de bytes para almacenar la información del archivo
    inputfile:   .asciz "text_procesado.txt"    @ Se define el nombre del archivo de entrada
    outputfile:  .asciz "procesado.txt"         @ Nombre del archivo de salida
    read_error:  .asciz "Error reading file\n"  @ Mensaje de error al leer el archivo
    open_error:  .asciz "Error opening file\n"  @ Mensaje de error al abrir el archivo
    newline:     .asciz "\n"                    @ Caracter de nueva línea


.section .bss
    statbuf: .space 100                         @ Se define un espacio de 100B para almacenar la información del archivo

.section .text
_start:


open_file:

    ldr r0, =inputfile       @ Se carga la dirección del nombre del archivo
    mov r1, #0               @ Modo de solo lectura
    mov r7, #5               @ Llamada al sistema open
    swi 0                    @ Se realiza la llamada al sistema
    
    mov r4, r0               @ Se almacena el descriptor de archivo en r4
    
    cmp r0, #0               @ Se verifica si el archivo se abrió correctamente
    blt file_open_error      @ Si no, salta a open_fail
    
    mov r0, r4               @ Descriptor de archivo (dirección del archivo)
    ldr r1, =statbuf         @ Puntero a filedata
    mov r7, #108             @ Llamada al sistema stat
    swi 0                    @ Se realiza la llamada al sistema
    ldr r2, =statbuf         @ Puntero a filedata
    ldr r11, [r2, #4]        @ Tamaño del archivo en r11


readfile:

    mov r0, r4               @ Descriptor de archivo (dirección del archivo)
    ldr r1, =buffer          @ Buffer para almacenar el contenido del archivo
    mov r2, r11              @ Tamaño del archivo a r2 (256B)
    mov r7, #3               @ Llamada al sistema read
    swi 0                    @ Realizar la llamada al sistema  

    mov r0, r4               @ Descriptor de archivo (dirección del archivo)
    mov r7, #6               @ Llamada al sistema close  
    swi 0                    @ Realizar la llamada al sistema

    mov r12, r1              @ Almacenar la dirección del buffer en r12  

    cmp r0, #0               @ Verificar si el archivo se leyó correctamente
    blt file_read_error      @ Si no, saltar a read_fail  

    mov r4, #0               @ Inicializar r4 a 0
    b read_word_0            @ Saltar a read_word_0  

read_word_0:

    ldr r5, =word            @  Cargar la dirección de la palabra
    ldr r10, =dictionary     @  Cargar la dirección del diccionario, índice del diccionario (r6)

read_first_word:
    ldrb r3, [r12], #1       @  Cargar el carácter del buffer a r3, incrementar la dirección del buffer en 1 para leer el siguiente carácter
    
    cmp r3, #0               @  Verificar si el carácter es nulo (fin del texto)
    beq end_text             @  Si es así, saltar a end_text

    cmp r3, #10              @  Verificar si el carácter es nueva línea
    beq end_first_word       @  Si es así, saltar a end_first_word

    strb r3, [r5, r4]        @  Almacenar el carácter en el buffer de la palabra en el índice r4

    add r4, r4, #1           @  Incrementar el índice de la palabra en 1 y mover el offset de la palabra
    
    b read_first_word        @  Saltar a read_first_word

end_first_word:
    bl add_new_word          @  Llamar a la función addword para agregar la palabra al diccionario
    mov r4, #0               @  Reiniciar el índice de la palabra a 0
    b read_word              @  Saltar a read_word

read_word:
    ldrb r3, [r12], #1       @  Cargar el carácter del buffer a r3, incrementar la dirección del buffer en 1 para leer el siguiente carácter

    cmp r3, #0               @  Verificar si el carácter es nulo (fin del texto)
    beq end_text             @  Si es así, saltar a endoftext

    cmp r3, #10              @  Verificar si el carácter es nueva línea
    beq end_word             @  Si es así, saltar a endofword
    
    strb r3, [r5, r4]        @  Almacenar el carácter en el buffer de
    
    add r4, r4, #1           @  Incrementar el índice de la palabra en 1 y mover el offset de la palabra
    
    b read_word              @  Saltar a read_word (recursivo)

end_word:
    bl search_word_0         @  Llamar a la función searchword para buscar la palabra en el diccionario

    mov r4, #0               @  Reiniciar el índice de la palabra a 0

    b read_word              @  Saltar a read_word (continuar leyendo el buffer de texto)

end_text:
    bl search_word_0         @  Llamar a la función searchword para buscar la palabra en el diccionario

    ldr r0, =dictionary      @  Cargar la dirección del diccionario
    ldr r2, =finaltext       @  Cargar la dirección del texto final
    mov r3, #0               @  Inicializar el contador para las 10 palabras principales en el diccionario en r3
    b create_text

create_text:                 @  Crear el texto de palabras y frecuencias para el postprocesamiento a ser leído por histogram.py
    cmp r0, r10              @  Verificar si es el fin del diccionario
    beq create_output_file   @  Si es así, saltar a create_output_file

    cmp r3, #10              @  Verificar si ya se encontraron las 10 palabras principales
    beq create_output_file   @  Si es así, saltar a create_output_file

    ldr r8, [r0]             @  Obtener la dirección inicial de la palabra
    ldr r5, [r0, #4]         @  Obtener el número de caracteres en la palabra
    mov r7, #0               @  Inicializar el contador para el índice de la palabra en r7
    bl write_text            @  Llamar a la función write_text para escribir la palabra en el buffer de texto final

    mov r11, #32             @  Cargar el valor ASCII de espacio en r11
    strb r11, [r2], #1       @  Almacenar el espacio en el buffer de texto final en el índice r2
    
    ldr r11, [r0, #8]        @  Obtener la frecuencia de la palabra
    str r11, [r2], #1        @  Almacenar la frecuencia en el buffer de texto final 
    
    mov r11, #10             @  Cargar el valor ASCII de nueva línea en r11
    str r11, [r2], #1        @  Almacenar la nueva línea en el buffer de texto final
    
    add r0, r0, #16          @  Incrementar el índice del diccionario en 16 para mover a la siguiente palabra
    add r3, r3, #1           @  Incrementar el contador para las 10 palabras principales en 1
    b create_text            @  Saltar a create_text (recursivo)

create_output_file:
    ldr r0, =outputfile      @  Cargar la dirección del nombre del archivo de salida
    mov r1, #0101            @  Modo de lectura y escritura
    mov r2, #0644            @  Permisos del archivo para escribir
    mov r7, #5               @  Llamada al sistema open
    swi 0                    @  Realizar la llamada al sistema

    mov r4, r0               @  Almacenar el descriptor de archivo en r4

    cmp r0, #0               @  Verificar si el archivo se abrió correctamente
    blt file_open_error      @  Si no, saltar a open_fail         
    
    mov r0, r4               @  Mover el descriptor de archivo a r0
    ldr r1, =finaltext       @  Cargar la dirección del texto final 
    mov r2, #1000            @  Tamaño del archivo a escribir
    mov r7, #4               @  Llamada al sistema write
    swi 0                    @  Realizar la llamada al sistema
    
    mov r0, r4               @  Mover el descriptor de archivo a r0
    mov r7, #7               @  Llamada al sistema exit (close)
    swi 0                    @  Realizar la llamada al sistema

    b end                    @  Saltar a end

write_text:
    cmp r5, r7               @  Verificar si es el fin de la palabra
    beq write_text_final     @  Si es así, saltar a write_text_final

    add r7, r7, #1           @  Incrementar el índice de la palabra en 1

    ldr r9, [r8], #1         @  Cargar el carácter en r8 e incrementar en 1
    strb r9, [r2], #1        @  Almacenar el carácter en el buffer de texto final en el índice r2 e incrementar en 1
    
    b write_text             @  Saltar a write_text (recursivo)

write_text_final:
    bx lr                    @  Retornar (fin de la función)

search_word_0:
    ldr r6, =dictionary      @  Cargar la dirección inicial del diccionario 
    
search_word:
    cmp r6, r10              @  Verificar si es el fin del diccionario, si no hay coincidencias, agregar la palabra al diccionario
    beq add_new_word         @  Si es así, saltar a add_new_word
    
    ldr r8, [r6, #4]         @  Cargar el número de caracteres en la palabra a r8
    
    cmp r8, r4               @  Si el número de caracteres es el mismo, comparar la palabra
    beq compare_words        @  Si es así, saltar a compare_words
    
    add r6, r6, #16          @  Si no es igual el número de caracteres, mover a la siguiente palabra en el diccionario
    
    b search_word            @  Saltar a search_word (recursivo)

compare_words:

    mov r0, #0               @  Índice de la palabra 0 para comparación con r4
    ldr r5, =word            @  Cargar la dirección inicial de la palabra a r5
    ldr r8, [r6]             @  Cargar la dirección inicial de la palabra en el diccionario a r8

    b compare_words_loop     @  Saltar a compare_words_loop

compare_words_loop:   
    cmp r0, r4               @  Verificar si todos los caracteres se compararon, si es así, agregar a la frecuencia
    beq frequency_increase   @  Si es así, saltar a frequency_increase

    ldrb r2, [r5, r0]        @  Cargar el carácter del buffer de la palabra a r2
    ldrb r3, [r8, r0]        @  Cargar el carácter del buffer de la palabra del diccionario a r3

    add r0, r0, #1           @  Incrementar el índice de la palabra en 1
    
    cmp r2, r3               @  Comparar los caracteres, si son iguales, seguir comparando caracteres
    beq compare_words_loop   @  Si es así, saltar a compare_words_loop (seguir recursivo)
    
    add r6, r6, #16          @  Si no son iguales, dejar de comparar y buscar otras palabras en el diccionario
    b search_word            @  Saltar a search_word

frequency_increase:          @  Agregar 1 a la frecuencia de la palabra en el diccionario
    
    ldr r2, [r6, #8]         @  Cargar la frecuencia de la palabra en el diccionario a r2
    add r2, r2, #1           @  Incrementar la frecuencia en 1
    str r2, [r6, #8]         @  Almacenar la frecuencia en el diccionario

    ldr r3, =dictionary      @  Cargar la dirección del diccionario
    b order_by_frequency     @  Saltar a order_by_frequency

order_by_frequency:          @  Reorganizar el diccionario por frecuencia en orden descendente
    cmp r6, r3               @  Verificar si es el fin del diccionario
    beq order_by_frequency_out @  Si es así, saltar a order_by_frequency_out

    sub r6, r6, #16          @  Mover el índice del diccionario a la palabra anterior
    ldr r7, [r6, #8]         @  Cargar la frecuencia de la palabra anterior a r7
    ldr r2, [r6, #24]        @  Cargar la frecuencia de la palabra actual a r2
    
    cmp r7, r2               @  Comparar las frecuencias de las palabras anterior y actual
    blt move_word_by_frequency @  Si la palabra anterior tiene una frecuencia menor, mover la palabra actual a la palabra anterior 

    bx lr                    @  Retornar (fin de la función)
    
move_word_by_frequency:      @  Mover la palabra en el diccionario por frecuencia en orden descendente

    ldr r0, [r6]             @  Cargar la dirección inicial de la palabra anterior a r0
    ldr r2, [r6, #16]        @  Cargar la dirección inicial de la palabra actual a r2

    str r0, [r6, #16]        @  Almacenar la palabra anterior en la palabra actual
    str r2, [r6]             @  Almacenar la palabra actual en la palabra anterior

    ldrb r0, [r6, #4]        @  Cargar el número de caracteres en la palabra anterior a r0
    ldrb r2, [r6, #20]       @  Cargar el número de caracteres en la palabra actual a r2

    strb r0, [r6, #20]       @  Almacenar el número de caracteres en la palabra anterior en la palabra actual
    strb r2, [r6, #4]        @  Almacenar el número de caracteres en la palabra actual en la palabra anterior

    ldr r0, [r6, #8]         @  Cargar la frecuencia de la palabra anterior a r0
    ldr r2, [r6, #24]        @  Cargar la frecuencia de la palabra actual a r2

    str r0, [r6, #24]        @  Almacenar la frecuencia de la palabra anterior en la palabra actual
    str r2, [r6, #8]         @  Almacenar la frecuencia de la palabra actual en la palabra anterior

    b order_by_frequency     @  Saltar a order_by_frequency (recursivo)


order_by_frequency_out:      @  Retornar a la función principal
    bx lr                    @  Retornar (fin de la función)

add_new_word:                @  Agregar la palabra al diccionario
    mov r8, r12              @  Almacenar la dirección de la palabra en r8
    sub r8, r8, r4           @  Restar el número de caracteres en la palabra de la dirección de la palabra para obtener la dirección inicial de la palabra
    sub r8, r8, #1           @  Restar 1 de la dirección inicial de la palabra para obtener la dirección inicial de la palabra

    str r8, [r10]            @  Almacenar la dirección inicial del primer carácter de la palabra en el diccionario

    str r4, [r10, #4]        @  Almacenar el número de caracteres en la palabra en el diccionario

    mov r8, #1               @  Inicializar la frecuencia de la palabra en 1
    str r8, [r10, #8]        @  Almacenar la frecuencia de la palabra en el diccionario

    add r10, r10, #16        @  Incrementar el índice del diccionario en 16 para mover a la siguiente palabra

    bx lr                    @  Retornar (fin de la función)

file_open_error:
    ldr r1, =open_error      @  Cargar la dirección del mensaje de error al abrir el archivo  
    b end

file_read_error:
    ldr r1, =read_error      @  Cargar la dirección del mensaje de error al leer el archivo 

end:

    mov r7, #1               @  Llamada al sistema exit      
    swi 0                    @  Realizar la llamada al sistema
