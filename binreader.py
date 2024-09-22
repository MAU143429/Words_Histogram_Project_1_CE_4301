import collections
import re

def leer_archivo_binario(ruta_archivo):
    with open(ruta_archivo, 'rb') as archivo:
        contenido = archivo.read()
    return contenido.decode('utf-8')

def contar_palabras(texto):
    palabras = re.findall(r'\b\w+\b', texto.lower())
    contador_palabras = collections.Counter(palabras)
    return contador_palabras

def main():
    ruta_archivo = '/home/mau14/Desktop/Proyecto I Arqui I/CE-4301_Proyecto_1/sample_procesado.bin'
    texto = leer_archivo_binario(ruta_archivo)
    contador_palabras = contar_palabras(texto)
    palabras_comunes = contador_palabras.most_common(10)
    palabras_unicas = len(contador_palabras)
    
    print("Las 10 palabras más repetidas son:")
    for palabra, frecuencia in palabras_comunes:
        print(f"{palabra}: {frecuencia}")
    
    print(f"\nCantidad de palabras únicas: {palabras_unicas}")

if __name__ == "__main__":
    main()
