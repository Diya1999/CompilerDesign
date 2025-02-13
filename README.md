# CompilerDesign
TestingCD : consists of the all the initial codes for each phase</br>
FinalCD: Consists of the final codes for all the phases. 

# C-Mini-Compiler
## Compiler Design Lab Project, PES University
### Implement the front end of the compiler for C language using Lex and Yacc for the following constructs :
1. Structures
2. While
3. Switch


### How to run
Clone this repository and execute go into the FinalCDMiniCCompiler directory. 
Run each command as shown in the commands.txt file in the same folder

### Project details

Following output files are generated upon execution of commands :

1. Symbol Table : ```./SymbolTable < filename``` <br>
Symbol table contains keywords and identifiers, their datatypes and values with some preliminary evaluation of simple expressions. The output of this file will be in ```symbol_table.txt``` and the errors while creating the symbol table are stored in ```errors.txt```.
The errors handled by the symbol table are
- Undeclared variables
- Multiple declarations of a variable within the same scope
- Invalid value for given datatype

2. Abstract Syntax Tree : ```./AST < filename``` <br>
Uses ```graph.c``` and ```header.h``` to display the abstract syntax tree.

3. Intermediate Code Generation : ```./ICG < filename``` <br>

4. Code Optimization : 
Following code optimizations were performed
- Dead code elimination
- Constant folding<br>
Compile and run the opti1.c with the ICG generated in the previous step.
Compile and run optil2.c with the output of the first optimization<br>

5. Target code Generation
Using Linear Scan register allocation algorithm.<br>
Run the python code with input text file as the Optimized ICG output from previous step<br>

## Files and Folders in the Repository
commands: detailed steps to run each phase</br>
SymbolTable.l : symbol table creation lex file</br>
SymbolTable.y : symbol table creation yacc file</br>
SymbolTable.txt: sample symbol table created for an input
AST.l : Lex file for abstarct syntax tree generation</br>
AST.y: yacc file for abstarct syntax tree generation</br>
graph.c: code to format the abstarct syntax tree generation</br>
header.h: header file that contains data structures used for creation of nodes</br>
ICG.l : Lex file for Intermediate code generation</br>
ICG.y : yacc file for Intermediate code generation</br>
opti1.c and opti2.c: code optimzations
targetcode.py: target code genration code 
all_cases_final.c: sample input for all different cases for structures, switch and while
error.txt: errors encountered in a program


### C Diya  PES1201700246<br>
### Namrata R PES1201700921<br>
### Chiranth J PES1201701438<br>
