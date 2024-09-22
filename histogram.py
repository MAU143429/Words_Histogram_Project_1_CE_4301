###########################################################################################
#                                  Tecnológico de Costa Rica                              #
#                                Arquitectura de Computadores I                           #
#                              Proyecto #1 Creador de Histogramas                         #
#                                Mauricio Calderón 2019182667                             #
###########################################################################################
import re
import matplotlib.pyplot as plt



"""
Toma el archivo dado por el usuario lo lee y crea uno nuevo y almacena palabra
por palabra el texto procesado.

"""
import re
import struct

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
        output_file_path = file_path.replace('.txt', '_procesado.bin')
        
        with open(output_file_path, 'wb') as output_file:
            # Crear una cadena con las palabras separadas por comas
            csv_words = ','.join(words)
            
            # Convertir la cadena a bytes y escribir en el archivo binario
            output_file.write(csv_words.encode('utf-8'))
        
        print(f"Preprocesamiento completado. Archivo guardado como: {output_file_path}")
    
    except FileNotFoundError:
        print("Archivo no encontrado. Por favor, verifica la ruta e intenta nuevamente.")
    except Exception as e:
        print(f"Ha ocurrido un error: {e}")




"""
Lee un archivo de texto que contiene palabras y sus frecuencias, luego genera un histograma.
"""
def createHistogram(file_path):
    
    try:
        words = []
        frequencies = []
        
        with open(file_path, 'r', encoding='utf-8') as file:
            for line in file:
                word, frequency = line.split()
                words.append(word)
                frequencies.append(int(frequency))
        
          
        plt.figure(figsize=(10, 6))  

        bars = plt.bar(words, frequencies, color='#CB34FF')
        for bar in bars:
            yval = bar.get_height()
            plt.text(bar.get_x() + bar.get_width()/2, yval + 2, int(yval), ha='center', va='bottom')

        plt.xlabel('Palabras')
        plt.ylabel('Frecuencias')
        plt.title('Histograma de Frecuencias de Palabras')
        plt.xticks(rotation=45, ha='right')  
        plt.tight_layout()  

        plt.show()

    except FileNotFoundError:
        print("Archivo no encontrado. Por favor, verifica la ruta e intenta nuevamente.")
    except Exception as e:
        print(f"Ha ocurrido un error: {e}")

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
