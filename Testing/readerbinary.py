from collections import Counter

def read_binary_file(file_path):
    try:
        with open(file_path, 'rb') as file:
            data = file.read()
            return data
    except FileNotFoundError:
        print(f"El archivo {file_path} no se encontró.")
    except Exception as e:
        print(f"Ocurrió un error al leer el archivo: {e}")

def parse_data(data):
    words = []
    i = 0
    while i < len(data):
        if data[i:i+1] == b'&':
            break
        end = data.find(b'/', i)
        if end == -1:
            break
        word = data[i:end].decode('utf-8')
        i = end + 1
        if i + 1 >= len(data):
            break
        # Leer los dos bytes para la frecuencia
        freq = int.from_bytes(data[i:i+2], 'little')
        words.append((word, freq))
        i += 2
    return words

def get_top_words(words, top_n=10):
    counter = Counter()
    for word, freq in words:
        counter[word] += freq
    return counter.most_common(top_n)

if __name__ == "__main__":
    file_path = '/home/mau14/Desktop/Proyecto I Arqui I/CE-4301_Proyecto_1/procesado.bin'
    data = read_binary_file(file_path)
    if data:
        words = parse_data(data)
        top_words = get_top_words(words)
        print("Las 10 palabras con mayor frecuencia son:")
        for word, freq in top_words:
            print(f"{word}: {freq}")