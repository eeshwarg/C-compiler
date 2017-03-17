# C-compiler
This is the frontend of a compiler for a subset of C. The stages of the compiler implemented are lexical, syntax and semantic phases. It includes support for the datatypes `int` and `char`. Conditional statements that are supported are if-else. Support is also provided for the `while` iteration statement. 
## Getting started
The tools used for building this compiler are `flex` for the lexical phase and `yacc` for the syntax and semantic phases. 
### Installing
The tools can be installed with the commands 
```
  sudo apt-get install flex
```
and 
```
  sudo apt-get install yacc
```
respectively.

## Using the compiler
Navigate to the root directory of the repository. The compiler can be built using the command 
```
./compile
```
Once built, it can be run using the command
```
./a.out test.c
```
where test.c is the C code that you wish to be compiled.
