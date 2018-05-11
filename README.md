# fun-with-FPGA

This project consists of a Rust compiler which will compile the fun language into a custom ISA, which will be run on the Altera Cyclone V FPGA. 

## Fun Language

### Language Overview

* Source character encoding: A program is represented as a string of ASCII characters in a .fun whose name is passed as a command line argument to the compiler.

* Lexical rules: the language has the following tokens:

  - keywords: `"if" "else" "while" and "print"`
  - operators and special characters: `= == ( ) { } + *`
  - identifiers: start with lower case letters followed by a sequence of lower case letters and numbers.
  - immediate values: sequences of digits representing integers. They always start with a digit but could contain `_` characters that are ignored

* Syntax: The syntax is C-Like, but `( )` are not allowed in right-hand expressions to specify order of operations.

### Languages Sematics

* All variables are 16 bit unsigned integers
* `+` performs unsigned integer addition (mod 2^16)
* `*` performs unsigned integer multiplications (mod 2^16)
* `x == y` returns 1 if x and y contain the same bit pattern and 0 otherwise
* `x = <exp>` assigns the result of evaluating `<exp>` to `x`
* The `if` statement has one of the forms:
  - `if <exp> <statement>`
  - `if <exp> <statement> else <statement>`
* The `while` statement has the form: `while <exp> <statement>`
* `{ }` is used to block statements, making a sequence of statements appear like a single one
* The `print` statement has the form: `print <exp>` and prints the numerical value of the expression followed by a new line
