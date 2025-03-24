# 📊 Word Histogram using Assembly

## 🧠 Project Overview

This project consists of building a **word histogram generator using Assembly language**. Its main goal is to read and process a text file, count how many times each word appears, and output the **10 most frequent words**.

The text processing algorithm is fully implemented in Assembly using a selected Instruction Set Architecture (ISA), such as `x86`, `ARM`, or `RISC-V`. To complement this, the input preprocessing (tokenization) and the output visualization (histogram graph) are done using high-level languages like Python.

This project allows developers to explore:
- Low-level instruction handling
- Manual memory and register management
- File handling in Assembly
- Performance optimization compared to high-level solutions

---

## ⚙️ Requirements to Run

To execute this project successfully, you will need:

- An emulator or debugger compatible with your chosen ISA (e.g., `qemu`, `gdb`, `emu8086`, etc.)
- Python or another high-level language to handle preprocessing and postprocessing
- Assembler and linker tools appropriate for the selected ISA
- Ability to execute and debug Assembly code
- A `.txt` file to use as input for word counting

The algorithm should be efficient enough to handle large input files and ideally outperform the same task written in Python.

---

## 🧪 Execution Flow

1. **Preprocessing (High-Level Language):**
   - Tokenize the input text file and format it into a clean list of words.

2. **Assembly Program:**
   - Read the preprocessed file.
   - Count the frequency of each word.
   - Output the 10 most frequent words and their respective counts to a result file.

3. **Postprocessing (High-Level Language):**
   - Read the output file.
   - Generate a histogram graph displaying the 10 most frequent words and their frequencies.

---

## 📁 Suggested Folder Structure

```
📁 preprocessor/       # Tokenizer script (e.g., Python)
📁 asm_code/           # Assembly source code
📁 postprocessor/      # Graph generation (e.g., Python + matplotlib)
📁 samples/            # Input text files
📁 outputs/            # Output with top 10 words and frequencies
📄 README.md           # Project description
```

---

## 📷 Example Output

The histogram should look similar to the following:

```
coffee   | █████████████ 34
travel   | ███████████   28
sunset   | ████████      22
...
```

The style of the chart is flexible but must be clean and easy to understand.
