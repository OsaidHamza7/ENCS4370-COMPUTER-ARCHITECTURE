# ENCS4370-COMPUTER-ARCHITECTURE

## Dictionary-based Compression and Decompression Tool in MIPS Assembly

This project implements a simple Dictionary-based Compression and Decompression Tool using MIPS Assembly language. The tool allows you to compress and decompress files by converting words into codes and vice versa.

### Compression

The compression task takes a file to be compressed and converts each word into a code (e.g., "0x0001"). It also generates a dictionary that maps each word to its code. Compression reduces file size by representing repetitive words with shorter codes.

### Decompression

The decompression task takes a file containing codes generated during compression and converts each code back into the original word using the dictionary. This restores the file to its original state.

## Usage

To use this tool, follow these steps:

1. Clone or download the project repository.
2. Navigate to the MIPS Assembly source code file.
3. Compile the source code using a MIPS Assembler, such as MARS.
4. Load the assembled code onto a MIPS architecture simulator or emulator.
5. Run the simulator or emulator to execute the compression and decompression tool.

Refer to the documentation or user manual of your chosen MIPS simulator or emulator for detailed instructions on loading and executing MIPS Assembly code.

## Contributing

Contributions to this project are welcome! If you encounter any issues or have suggestions for improvements, please submit a pull request or open an issue on the project repository.

## License

This project is licensed under the [MIT License](LICENSE). You are free to modify, distribute, and use the code for both commercial and non-commercial purposes. However, please note that the project is provided "as is," without any warranty.

## Acknowledgments

We would like to acknowledge the ENCS4370 Computer Architecture course for providing inspiration and guidance for this project. We also thank the open-source community for their invaluable resources and contributions in the field of MIPS Assembly programming and computer architecture.
