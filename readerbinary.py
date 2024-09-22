def read_binary_file(file_path):
    try:
        with open(file_path, 'rb') as file:
            data = file.read()
            return data
    except FileNotFoundError:
        print(f"El archivo {file_path} no se encontró.")
    except Exception as e:
        print(f"Ocurrió un error al leer el archivo: {e}")

if __name__ == "__main__":
    file_path = '/home/mau14/Desktop/Proyecto I Arqui I/CE-4301_Proyecto_1/procesado.bin'
    data = read_binary_file(file_path)
    if data:
        print("Datos leídos del archivo binario:")
        print(data)