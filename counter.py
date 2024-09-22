# Let's open and read the binary file the user provided and count the occurrences of the word "que".
import re

file_path = 'text.txt'
palabra = 'la'

with open(file_path, 'r', encoding='utf-8') as file:
    text = file.read()
    
    # Convertir el texto a minúsculas y eliminar caracteres no alfanuméricos
    text = text.lower()
    text = re.sub(r'[^a-zA-Z0-9\s]', '', text)

# Splitting the text into words and counting the occurrences of "que" only (no substrings)
words = text.split()
count_que = words.count(palabra)

print("lA PALABRA '{}' SE REPITE {} VECES".format(palabra, count_que))

