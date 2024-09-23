###########################################################################################
#                                  Tecnológico de Costa Rica                              #
#                                Arquitectura de Computadores I                           #
#                              Proyecto #1 Creador de Histogramas                         #
#                                Mauricio Calderón 2019182667                             #
###########################################################################################
import re
import matplotlib.pyplot as plt
import struct

"""
Toma el archivo dado por el usuario lo lee y crea uno nuevo y almacena palabra
por palabra el texto procesado.

"""

def preProcessing(file_path):
    try:
        # Leer el archivo de entrada
        with open(file_path, 'r', encoding='utf-8') as file:
            text = file.read()
        
        # Convertir el texto a minúsculas y eliminar caracteres no alfanuméricos
        text = text.lower()
        text = re.sub(r'[^a-zA-Z0-9\sñáéíóú]', '', text)

        # Reemplazar tildes y ñ
        text = text.replace('á', 'a').replace('é', 'e').replace('í', 'i').replace('ó', 'o').replace('ú', 'u').replace('ñ', 'n')

        # Dividir el texto en palabras
        words = text.split()

        # Crear el archivo binario de salida
        output_file_path = file_path.replace('.txt', '_procesado.txt')
        
        with open(output_file_path, 'wb') as output_file:
            # Crear una cadena con las palabras separadas por saltos de línea
            newline_words = '\n'.join(words)
            
            # Convertir la cadena a bytes y escribir en el archivo binario
            output_file.write(newline_words.encode('utf-8'))
        
        print(f"Preprocesamiento completado. Archivo guardado como: {output_file_path}")
    
    except FileNotFoundError:
        print("Archivo no encontrado. Por favor, verifica la ruta e intenta nuevamente.")
    except Exception as e:
        print(f"Ha ocurrido un error: {e}")



"""
Lee un archivo de texto que contiene palabras y sus frecuencias, luego genera un histograma.
"""
def createHistogram(input_file):
    word_freq = {}

    with open(input_file, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    for line in lines:
        parts = line.split()

        if len(parts) == 2:  
            word = parts[0]
            freq_ascii = parts[1]

            try:
                frequency = ord(freq_ascii)
            except ValueError:
                frequency = 0  

            word_freq[word] = frequency

    words = list(word_freq.keys())
    frequencies = list(word_freq.values())

    plt.figure(figsize=(10, 6))
    bars = plt.bar(words, frequencies, color='aqua')
    plt.xticks(rotation=45, ha='right') 
    plt.tight_layout()
    plt.xlabel('Palabras')
    plt.ylabel('Frecuencias')
    plt.title('Histograma de Frecuencias de Palabras')
        
    
    for bar in bars:
        height = bar.get_height()
        plt.text(bar.get_x() + bar.get_width() / 2, height, f'{int(height)}', 
                 ha='center', va='bottom')

    plt.show()

def main():
    
    print("Bienvenido al Pre y Post Procesamiento de Histogramas")
    print("Por favor, elige una opción de las mostradas a continuación:")
    print("1. Preprocesamiento de texto")
    print("2. Postprocesamiento (Crear Histograma)")

    action = input("Introduce el número de la opción que deseas realizar (1 o 2): ")
    
    if action == '1':
        file_path = input("Introduce la ruta del archivo de texto para el preprocesamiento: ")
        preProcessing(file_path)
    elif action == '2':
        file_path = input("Introduce la ruta del archivo de texto para el postprocesamiento: ")
        createHistogram(file_path)
    else:
        print("Opción no válida. Por favor, selecciona 1 o 2.")

if __name__ == "__main__":
    main()
