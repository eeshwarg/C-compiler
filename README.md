# C-compiler
This is the frontend of a compiler for a subset of C. The stages of the compiler implemented are lexical, syntax and semantic phases. It includes support for the datatypes `int` and `char`. Conditional statements that are supported are if-else. Support is also provided for the `while` iteration statement. All the basic error checking for each of the three phases is implemented.
## Getting started
The tools used for building this compiler are `flex` for the lexical phase and `yacc` for the syntax and semantic phases.
### Installing
The tools can be installed with the commands
```
  sudo apt-get install flex yacc
```

## Using the compiler
Navigate to the root directory of the repository. To run the compiler on a source program, say test.c, run the following command:
```
./compile test.c
```
