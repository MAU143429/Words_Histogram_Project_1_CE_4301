# 📊 Word Histogram using Assembly

## 🧠 Project Overview

This project consists of building a **word histogram generator using Assembly language**. It's main goal is to read and process a text file, count how many times each word appears, and output the **10 most frequent words**.

The text processing algorithm is fully implemented in Assembly using  `ARM`. To complement this, the input preprocessing (tokenization) and the output visualization (histogram graph) are done using Python.

---

## ⚙️ Requirements to Run

To execute this project successfully, you will need:

- An emulator or debugger compatible with your `ARM`.
- Python to handle preprocessing and postprocessing
- Assembler and linker tools appropriate for `ARM`.
- Ability to execute and debug Assembly code
- A `.txt` file to use as input for word counting

The algorithm should be efficient enough to handle large input files and ideally outperform the same task written in Python.

---

## 🧪 Execution Flow

1. **Preprocessing (Python):**
   - Tokenize the input text file and format it into a clean list of words.

2. **Assembly Program (ARM):**
   - Read the preprocessed file.
   - Count the frequency of each word.
   - Output the 10 most frequent words and their respective counts to a result file.

3. **Postprocessing (Python):**
   - Read the output file.
   - Generate a histogram graph displaying the 10 most frequent words and their frequencies.


The style of the chart is flexible but must be clean and easy to understand.
