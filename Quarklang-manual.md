Quark
====
*Quantum Analysis and Realization Kit Language*

<div style="page-break-after: always;"></div>

Contents
========
[toc]

<div style="page-break-after: always;"></div>

Introduction
============
###History
In the early 1980's, Richard Feynman observed that certain quantum mechanical effects could not be efficiently simulated using classical computation methods. This led to the proposal for the idea of a "quantum computer", a computer that uses the effects of quantum mechanics, such as superposition and entanglement, to its advantage. 

Classical computers require data to be encoded in binary bits, where each unit is always in a definite state of either 0 or 1. Quantum computation uses qubits, a special unit that can be 0 and 1 at the same time, i.e. a superposition of base states. Measuring a qubit will force it to collapse to either 0 or 1, with a probability distribution determined by its amplitude. 

Qubits effectively operate on exponentially large number of entangled states simultaneously, though all of them will collapse as soon as we make a measurement. With carefully designed quantum algorithms, we are able to speed up certain classical problems dramatically by tapping into such massive computational resources. It is not unlike parallel computing, but powered by quantum mechanical laws. 

Though quantum computing is still in its infancy, the last two decades have witnessed two ingenious algorithms that produced much inspiration and motivation for quantum computing research. One is Shor's algorithm (1994) for integer factorization, which yields exponential speedup over the best classical alternative, and the other is Grover's search algorithm (1996), which provides quadratic speedup for unsorted database search. Once realized, the former would have significant impact on cryptography, while the latter would have great implication on NP-hard problems. 

###Language
Quark is a domain-specific imperative programming language to allow for expression of quantum algorithms. The purpose of QUARK is to ease the burden of writing quantum computing algorithms and describing quantum circuits in a user-friendly way. In theory, our language can produce quantum circuit instructions that are able to run on actual quantum computers in the future. 

Most quantum algorithms can be decomposed into a quantum circuit part and a classical pre/post-processing part. Recognizing this, QUARK is designed to integrate classical and quantum data types and controls in a seamless workflow. Built in types like complex numbers, fractions, matrices and quantum registers combined with a robust built-in gate library make QUARK a great starting point for quantum computing researchers and enthusiasts.

A relatively efficient quantum circuit simulator is included as part of the QUARK architecture. Source code written in QUARK is compiled to C++, which can then be passed onto our quantum simulator.
<div style="page-break-after: always;"></div>

Tutorial
========

###Environment Installation
Install [Vagrant](https://www.vagrantup.com/downloads.html), a tool for provisioning virtual machines used to maintain a consistent environment. You will also need  to install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) which Vagrant uses for virtualization. After unzipping Quark.tar.gz, navigate to the main Quark directory (the one which contains bootstrap.sh and Vagrantfile) and run `vagrant up`. This will provision and run a Ubuntu 14.04 LTS virtual instance as well as download and install dependencies such as OCaml and g++-4.8. Run `vagrant ssh` to ssh into the VM. Make sure you are in the `/vagrant` directory by running the command `pwd` and if you are not run `cd /vagrant`. You should now see all the files from the Quark folder shared with the VM + this VM has all the dependencies installed. Now we can compile and run Quark programs.

###Compiling and Running Quark Programs
The following Hello World example Quark program is saved in `/tests/hello_world.qk`.

```
def int main:
{
    print("hello world");

    return 0;
}
```

Before we can compile Quark programs into C++ we must build the Quark compiler `quarkc`. Navigate to `/vagrant/quark/` and run `make`. Ensure `quarkc` was properly built by  checking for error messages then running `./quarkc -h`  to see compilation options.
You should see the following:

```
usage: quarkc -s source.qk [-c output.cpp ] [-o executable] [-static] [-g++ /path/to/g++]
  -s : quark source file
  -c : generated C++ file. If unspecified, print generated code to stdout
  -o : compile to executable. Requires g++ (version >= 4.8)
  -sco : shorthand for -s <file>.qk -c <file>.cpp -o <file>
  -sc : shorthand for -s <file>.qk -c <file>.cpp
  -g++ : shorthand for -s <file>.qk -c <file>.cpp
  -static : compile with static lib (otherwise with dynamic lib). Does NOT work on OSX
  -help  Display this list of options
```

As stated above, to compile `tests/hello_world.qk` into C++ and an executable run `./quark/quarkc -s tests/hello_world.qk -c hello_world.cpp -o hello_world`. You can run the hello_world executable `./hello_world` to get the output, and `cat hello_world.cpp` shows the generated C++ as follows:

```
vagrant@vagrant-ubuntu-trusty-64:/vagrant$ ./hello_world
hello world

vagrant@vagrant-ubuntu-trusty-64:/vagrant$ cat hello_world.cpp
#include "qureg.h"
#include "qumat.h"
#include "qugate.h"
#include "quarklang.h"

using namespace Qumat;
using namespace Qugate;

int main()
{
std::cout << std::boolalpha << std::setprecision(6) << std::string("hello world") << std::endl;
return 0;
} // end main()
```

The C++ includes are referencing our quantum simulator and these files can be found in the `lib` directory.

To run some quantum computing programs, compile `shor.qk` and `grover.qk` in the `quark` folder. They are examples of non-trivial programs performing Shor's algorithm and Grover's search. Their implementation can be found in the testing section and the appendix.

Given an actual quantum computer, we would be able to run these algorithms in the stated time. For now, we run them on our simulator in exponential time for small N examples.

Shor's algorithm can factorize large integers in polynomial time.
Run `./quark/quarkc -s quark/shor.qk -c shor.cpp -o shor` and then run the executable`./shor`

Grover's search can search an unsorted database in O(N<sup>1/2</sup>) time.
Run `./quark/quarkc -s quark/grover.qk -c grove.cpp -o grover` and then run the executable `./grover`

###Essential Syntax
Quark syntax resembles something along the lines of Python with static typing. It is influenced by a number of languages including Python, MATLAB and C. If you already know a popular imperative language, you should be able to easily glean the majority of the syntax by simply reading through these examples. Our language manual provides a more explicit outline of the language spec.

```
def int gcd: int x, int y
{
    while y != 0:
    {
        int r = x mod y;
        x = y;
        y = r;
    }
    return x;
}

def int main:
{
    % prints the greatest common divisor of 10 and 20
    print(gcd(10, 20));
    return 0;
}
```

The keyword `def` declares a function, followed by the return type of the function, the function name, `:`, and then comma-separated, typed parameters. The `main` function is the primary entry point to Quark programs. `print` is a builtin function and the full list of builtins and a description of their function can be found in the Language Manual section. Blocks are denoted using  brackets but are not required when the block is only composed of a single line of code. Statements are terminated with `;` and single-line comments written after `%`.

###Control Flow
Conditional statements are supported via the `if`, `elif` and `else` keywords. There's also support for the dangling else case. For example,

```
if x > 0:
    print("positive");
elif x < 0:
    print("negative");
else:
    print("zero");
```

Here is a simple `while` loop,

```
while x > 42: {
    print(x);
    x = x - 1;
}
```

`for val in arr:` will iterate over an array of any type. Or you can iterate over an array created using the range syntax: `for val in [0:5]`; which iterates over `[0,1,2,3,4]`; and `for val in [0:10:3]` which iterates over `[0,3,6,9]` where 3 is the step size.

###Declaration
How you declare each type in Quark,

```
int i = 5;
float f = 3.0;
bool b = true;
string s = "So Long, and Thanks for All the Fish";
fraction f = 10$3;
complex c = i(1.0, 2.0);
string[] arr = ["Ford", "Prefect"];
int[][] arr2 = [[1,2,3],[4,5,6]];
```

###Matrices
Quark matrices have a different syntax than 2-dimensional arrays because they are compiled to Eigen classes as opposed to the built-in C++ vector. This also means n-dimensional arrays can have variable length rows whereas matrices must have equal length rows.

A matrix is declared as follows,

```
float[|] mat = [|1.0, 2.1; 3.2, 42.1|];
```

Where semicolons indicate the end of rows. Matrices can be composed of `int`, `float`, or `complex`. You can transpose a matrix by appending an apostrophe,

```
mat = mat';
```

And matrix elements can be accessed using the bracket notation and zero-indexed row and column integers,

```
float f = mat[2, 1];
```

###Quantum Registers
And last but definitely not least, the quantum register. Quantum registers are a key component for constructing quantum circuits. When declaring quantum registers, the left value denotes the initial size of a quantum register, and the right value denotes the initial bit.

`qreg q = <| 10, 0 |>;`

And `qreg` is the only type that is pass by reference.

You measure the state of a quantum register by using the destructive `?` operator and the non-destructive, but physically unrealistic, `?'` operator.

```
qreg q = <| 10, 0 |>;
int meas = q ? [2:10]; % measures qubits 2 through 10
```

Note, you can only measure LValue `qreg` variables. There are many builtin functions that utilize quantum registers and aid in building quantum circuits and you can find a complete listing in Language Reference.
<div style="page-break-after: always;"></div>

Language Reference Manual
=========================

###Lexical Conventions
A program in QUARK includes at least one function definition, though something trivial like a variable declaration or a string should compile. Programs are written using a basic source character set accepted by the C++ compiler in use. Refer to what source-code file encoding your compiler accepts. The QUARK compiler will only output ASCII.

###Comments
MATLAB style commenting is supported. A MATLAB style comment begins with `%` and ends with `%`. Multi-line MATLAB comments start with `%{` and end with `}%`. Any sequence of characters can appear inside of a comment except the string `}%`. These comments do not nest. 

###Whitespace
Whitespace is defined as the ASCII space, horizontal tab and form feed characters, as well as line terminators and comments.

###Tokens
Tokens in QUARK consist of identifiers, keywords, constants, and separators. Whitespace is ignored and not taken into consideration.

###Identifiers
An identifier is composed of a sequence of letters and digits, the first of which must be a letter. There is no limit on the length of an identifier. The underscore character `_` is included in the regular expression pattern for letters. 

Two identifiers are the same if they have the same ASCII character for every letter and digit. 

```
digit -> ['0'-'9']
letter -> ['a'-'z' 'A'-'Z' '_']
Identifier -> letter (letter | digit)* 
```

###Keywords
The following identifiers are reserved for use as keywords, and may not be used otherwise:

> def
> bool
> int
> float
> fraction
> complex
> qreg
> void
> mod
> in
> return
> continue
> break
> while
> for
> else
> if
> and
> not
> or

####Reserved Prefix
There is only one reserved prefix in QUARK:

`_QUARK_`

####Pseudo-reserved
`i` may be used as a variable name but not a function name. This is due to the way that QUARK handles the syntax for complex numbers. 

####Mathematical Constants
QUARK has two mathematical constants, `PI` and `E`. `PI` is for mathematical constant $\pi$ = 3.141592...
`E` for the mathematical constant e = 2.718281... 

###Punctuation
**Parenthesis** -- Expressions can include expressions inside parenthesis. Parenthesis can also indicate a function call.

**Braces** -- Braces indicate a block of statements.

**Semicolon** -- Semicolons are used at the end of every statement as a terminator. Semicolons are also used to separate rows in the matrix data type.

**Colon** -- Colons are used to denote slicing in arrays and within a function declaration. In a function declaration, formal arguments appear between the colon and a left curly brace. 

**Dollar Sign** -- The dollar sign separates the numerator value from the denominator value in a fraction data type.

**Comma** -- Commas have several use cases. Commas are used to separate formal arguments in a function declaration, elements in arrays and matrices, and the size and initial state of a `qreg`.

###Escape Sequences
Certain characters within strings need to be preceded by a backslash. These characters and the sequences to produce them in a string are:

| Character | Sequence  |
| :--------:| :-------- |
|   \"      |    "      |
|   \n      |  linefeed |
| \r        | carriage return |
| \t        | horizontal tabulation|
| \b        | backspace |

###Data Types
The data types available in QUARK are:

> int
> float
> fraction
> bool
> complex
> string
> qreg
> matrix
> void

Additionally, the aggregate data type of array is available to the user.

####int
An `int` is a 64-bit signed integer.

####float
A `float` is a 64-bit signed floating-point number. Comparing two floats is done to a tolerance of 1e-6.

####fraction
A `fraction` is denoted by two `int` types separated by `$`. The `int` value to the left of `$` represents the numerator, and the `int` value to the right of `$` represents the denominator. QUARK provides an inverse operator `~`. 

```matlab
frac foo = 2$3; % represents 2/3
~foo; % 3$2
```

####Note on int, float, and fraction
Fraction types may be compare to int and float types using the following comparators: `<`, `>`, `<=`, `>=`, `!=`, and `==`.

```matlab
int i = 3;
float ft = 2.0;
frac f = 2$3;

i > f;
ft <= f;
```

####bool
A `bool` value is denoted using the literals `true` or `false`.

####complex
A `complex` type is generated from two `int` or `float` values; if given a mix of `int` and `float` types, QUARK will implicitly type cast. A `complex` type can also be generated with one numerical value, which will be assigned to the real part of a complex number; imaginary will default to 0. The real and imaginary parts of a complex number can be accessed by `real` and `imag` accessors.

```ocaml
complex cnum = i(3.0, 1);
real(cnum); % 3.0
imag(cnum); % 1
complex cnum2 = i(9) % this gives us i(9, 0)
```

Comparing two complex numbers is done with a tolerance of 1e-6.

####string
A `string` is a sequence of characters. String literals are placed between double quotations. QUARK supports string  lexicographic comparison using `<`, `>`, `<=`, `>=`, `!=`, and `==`.

####qreg
A `qreg` type represents a quantum register. A `qreg` accepts two `int` types. The left value denotes the initial size of a quantum register, and the right value denotes the initial bit.

```matlab
qreg q = <| 1, 1 |>;
```

Qreg must be passed as an LValue to any function:

```
% disallowed
hadamard(<|10, 3|>); 

% allowed
qreg q = <|10, 3|>;
hadamard(q);
```

Additionally, qreg values may be measured using the destructive `?` operator and the non-destructive (but unrealistic) <code>?'</code> operator; the `?` and  <code>?'</code> operators may only operate on an LValue of type qreg.

```matlab
q ? [2:10];  % measures qubit 2 to 10
```

####matrix
QUARK allows you to create matrices; a `matrix` uses a special bracket notation to distinguish from arrays, and rows are separated by semicolons. Matrices may be composed of only `int`, `float`, or `complex`. Matrix elements may be accessed with a square bracket notation by separating the column and row index numbers by commas. 

A new matrix with all zeros (real or complex) can be constructed by
 ```type[| row_dim, column_dim |]``` and used in the middle of any expression. 

QUARK provides the special prime operator <code>'</code> for matrix transposition, and power operator ```**``` overloaded for matrix kronecker product. 

Matrices are zero indexed.

```matlab
float[|] mat = [| 1.2, 3.4; 5.6, 7.8 |];
mat[2, 1];
complex[|] mat2 = complex[| 5, 9 |];
% constructs a 5-by-9 complex zero matrix
mat = mat'; % transpose matrix
mat ** mat2; % kronecker product
```

####array
QUARK allows arrays of any of the above data types. Arrays can have variable length and can be arbitrarily dimensional. 

Arrays can be initialized using a comma-separated list delimited by square brackets [ ]. Additionally, arrays can be declared with a size to create an array of default-initialized elements. 

Arrays are zero indexed.

Arrays may be concatenated with the `&` operator as long as there is a dimension and type match. 

```matlab
int[5]; % gives us [0,0,0,0,0]
int[] a = [1, 2, 3]; % array initialization
int[][] b = [[1,2,3], [4,5,6]]; % 2-d array
print(complex[16]); 
% constructs an array of 16 i(0, 0)
[11, 22, 33] & int[3];
% gives us [11, 22, 33, 0, 0, 0]
```

Array indices can be accessed using the square bracket notation with an integer such as:

```matlab
int[] arr = [0, 1, 2];
arr[0]; 
```
or
```matlab
int[] arr = [0, 1, 2];
int i = 0;
arr[i];
```

Indices of multidimensional arrays may be accessed by separating the dimensional index numbers by commas:

```matlab
int[][] arr = [[0,1,2],[3,4,5]]
arr[1, 1]; % accesses 4
```

The built-in `len` function returns an `int` representing the length of the array.

Membership may be tested using the keyword `in`. 

```matlab
int x = 5;
if x in [1:10]:
    % statement here is executed
```

####void
Void is a type for a function that returns normally, but does not provide a result value to the caller.

###Function types
Functions take in zero or more variables of primitive or array types and optionally return a variable of primitive or array type. A function declaration always begins with `def`, the return type of the function, a colon `:`, and a list of formal parameters which may be empty.

```matlab
def void main: int x
{
    % statement
}
```

###Declarations

####Declaring a Variable
Variables can be defined within individual functions or in the global scope. Variables may be declared and then defined, or declared and defined simultaneously. An expression to which a value may be assigned is called an LValue.

```matlab
int x; % definition
x = 5; % declaration
int y = 6; % definition and declaration
```
x and y are LValues. LValues are named as such because they can appear on the left side of an assignment (though they may also appear on the right side).

####Declaring an Array
As previously shown, arrays can be multidimensional, and may be of variable length. Arrays may be declared on their own with a size to get an uninitialized array of the given size. They can also be initialized with values upon declaration.

```matlab
int[5]; % gives us [0,0,0,0,0]
int[] a = [1, 2, 3]; % array initialization
int[][] b = [[1,2,3], [4,5,6]]; % 2-d array
```

####Declaring a Matrix
A matrix declaration uses the special notation of piped square brackets. Matrix rows are distinguished using the `;` separator between elements of rows. Initializing an empty complex matrix initializes an all-zero 3-by-4 complex matrix.

```matlab
float[|] floatmat = [| 1.2, 3.4; 5.6, 7.8 |];
complex[|] mat; % this gives us complex[| 3, 4 |]
```

###Operators

####Arithmetic

|  Operator  |           |
|:---------- |------------------:|
| `+`        | addition          |
| `-`        | subtraction           |
| `++`       | unary increment by one |
| `--`       | unary decrement by one |
| `/`        | division              |
| `*`        | multiplication
| `mod`      | modulo |
| `**`       | power

####Concatenation
|    Operator    |           |
|:---------- |------------------:|
| `&`        | String and array concatenation |

####Assignment
|    Operator    |           |
|:---------- |------------------:|
| `=`            | assigns value or right hand side to left hand side        |
| `+=`       | addition assignment |
| `-=`       | subtraction assignment |
| `*=`       | multiplication assignment |
| `/=`       | division assignment |
| `&=`       | bitand assignment |

Assignment has right to left precedence.

####Logical
|   Operator     |           |
|:---------- |------------------:|
| `!=`       | not equal to |
| `==`       | equal to |
| `>`        | greater than |
| `>=`       | greater than or equal to |
| `<`        | less than |
| `<=`       | less than or equal to |
| `and`      | unary and |
| `or`       | unary or |
| `not`      | unary not |

####Bitwise Logical / Unary
|    Operator    |           |
|:---------- |------------------:|
| `~`        | Bitwise not and fraction inversion |
| `&`        | Bitwise and |
| `^`        | Bitwise xor |
| <code>&#124;</code> | Bitwise or |
| `<<`       | Bitwise left shift |
| `>>`       | Bitwise right shift |            

####Quantum 
|    Operator    |           |
|:---------- |------------------:|
| `?`        | quantum measurement query (destructive) |
| `?'`       | quantum measurement query (non-destructive)

The `?` and `?'` operators may only be invoked on an LValue.

```matlab
q ? [2:10];  % measures qubit 2 to 10
```

####Ternary Operator
QUARK supports Python style ternary conditional operators:

```python
3 if true else 5;

4 if 3 > 2 if not (1==1) else 3 < 2 else -2 if true else 3
```

Ternary operators are right associative.

####Operator Precedence and Associativity 
|    Operator    |  Associativity    |
|:---------- |------------------:|
| `*` `/` `mod` | left  |
| `+` `-`       | left |
| `>>` `<<`     | left |
| `>` `>=` `<` `<=` | left |
| `==` `!=`         | left |
| `&`               | left  |
| `^`               | left  |
| <code>&#124;</code>| left |
| `and`             | left |
| `or`              | left |
| `?`               | right |
| `in`              | left |
| `=` `+=` `-=` `*=` `/=` `&=` | right |

Operators within the same row share the same precedence. Higher rows indicate higher precedence.

###Statements
Statements are the smallest components of a program used to express that an action is to be carried out. Statements are used for variable declarations and assignment, control flow, loops, function calls, and expressions. All statements end with a semicolon `;`. Statements are used within blocks. The following are examples of statements and are by no means exhaustive:

```
string hello = "hello world";
int x = 10;
if x > 5
foo(4);
while x != true
for x in [1:10]
4 + 6
qreg q0 = <| nbit * 2, 0 |>;
```

###Blocks 
A block is defined to be inside curly braces `{ }`, which may include empty statements and variable declarations. 

A block looks like: 
```
{
    % statements here
}
```

###Return Statement
The return keyword accepts an expression, and exits out of the nearest calling block or smallest containing function.

###If elif else Statement
If statements take expressions that reduce to a boolean, and followed by a colon `:` and a statement block. If the following statement is only one line, curly braces are unnecessary.

QUARK allows elif statements, similarly to Python. The else and elif statements are optional. 

```matlab
if p == 1:
    return a;
        
if (3 > 1):
{
    % multiple statements
}

if (x == 3):
    % do something
elif (x == 4):
    % do something
else:
    % do something
```

###While Loop
A while loop is of the form:
```
while(condition): 
{
    % statement
}
```
As with `if elif else` statements, if the following statement is only one line, curly braces `{}` are unnecessary.

```
while exp_mod(b, i, M) != 1:
    i ++;
```

The condition of the while loop may not be empty.

###For Statement
QUARK supports two types of iterators, array and range, for its for statements.

####Array Iterator
An array iterator allows you to sweep a variable across an array, evaluating the inner statement with identifiers assigned to a new value before each iteration. The identifier after `for` is assigned to the value of each element of the array sequentially.

The identifier may be declared ahead of time or within the for statement itself.

```
int[] arr = [1,2,3];
for int i in arr:
    print i;

% 1
% 2
% 3
```

####Range Iterator
A range iterator allows you to sweep a variable across an array, evaluating the inner statement with identifiers assigned to a new value before each iteration. The identifier after `for` is assigned to each integer in the range.

The identifier may be declared ahead of time or within the for statement itself.

```
int i;
for i in [1:10]
for int i in [1:10:2]
```

A range consists of three integers separated by colons `[start : stop : step]`. Start denotes the start of the range, stop denotes the exclusive end of a range, and step denotes the step size of the range. If the step and the last colon is excluded, the step is defaulted to 1. If the start value is excluded, it is defaulted to 0. 

The following are various ways of declaring ranges:

```matlab
0:5:2 % this gives us 0, 2, 4
:5 % 0, 1, 2, 3, 4
1:3 % 1, 2
```

###Break and Continue
The `break` statement causes a while loop or for loop to terminate. 

The `continue` statement provides a way to jump back to the top of a loop earlier than normal; it may be used to bypass the remainder of a loop for an iteration.

###Functions
QUARK allows users to define functions. 

####Function Declaration
Functions are composed of the form:

```
def return_type func_name: type arg1, type arg2 
{
    % statements in function body
    
    return return_type;
}
```

Functions are defined only by identifying the block of code and the keyword `def`, giving the function a name, supplying it with zero or more formal arguments, and defining a function body. Function return types are of any data type previously described, or `void` for no value.

Some examples of function declarations are:

```
def void hello: 
{
    print("hello world");
}

def int addition: int x, int y
{
    return x + y;
}
```

###Imports
QUARK allows users to import qk files containing QUARK statements and definitions. QUARK supports relative file paths. All files are presumed to have the `.qk` extension.

```
import ../lib/mylib1;
import ../lib/herlib2;
```

```
import imported_file; % contains foo2

def int foo:
{
    return foo2(5);
}
```

###Casting
QUARK does not allow explicit type casting.

###Pass by value pass by reference
QUARK passes arguments by value. The only exception to this is the `qreg` type which is passed by reference. This is because `qregs` are too expensive (and meaningless) to copy in C++, our intermediary representation. If you need to copy a qreg, please use the explicit builtin function `qclone()`.

###Overloading
QUARK keeps separate symbol tables for functions and types, and as such the same identifier may be used as a variable and a function at the same time. 

Built-in functions are overridable because they are not stored in the function table, with the exception of the following built-in functions:

> print  (with \n)
> print_noline  
> apply_oracle

Otherwise, function overloading by itself is not supported.

###Scoping
In QUARK, there are both global and local scopes. QUARK uses block scoping. A block is a section of code contained by a function, a conditional (if/while), or looping construct (for). Variables defined in the global scope can be used in any function, as well as in any block within that function.  Each nested block creates a new scope, and variables declared in the new scope supersede variables declared in higher scopes.

Below is an example of the subtleties of QUARK's scoping rules:

```matlab
int i = 1000;
for i in [0:7:2]:
{
    % statement
}

% i changed.

int i = 1000;
for int i in [0:7]:
{
    % statement
}
    
i; % still 1000
```

###Built-in Functions
Below is a list of built-in functions that QUARK provides:

####General
`print(any_type)`: takes any type and returns void

`print_noline(any_type)`: `print` but does not add a newline

`len([any_type])`: takes any array and returns the length

####Fraction
`num(fraction)`: takes a fraction type and returns the numerator as an `int`

`denom(fraction)`: takes a fraction type and returns the denominator as an `int`.

####Complex
`real(complex)`: takes a complex type and returns the real portion of a complex number as a float.

`imag(complex)` takes a complex type and returns the imaginary portion of a complex number as a float.

####Math

`sqrt(float)`: takes the square root of a number and returns a float.

`rand_int(int, int)`: takes two ints as boundaries and returns an int between them.

`rand_float(float, float)`: takes two floats as boundaries and returns a float between them. 

####Matrix

`coldim(any_matrix)`: returns the column dimension of a matrix as an int.

`rowdim(any_matrix)`: returns the row dimension of a matrix as an 

####Matrix Generation
`hadamard_mat(int)`: takes int and returns a complex matrix.

`cnot_mat()`: takes nothing and returns a complex matrix.

`toffoli_mat(int)`: takes int and returns complex matrix.

`generic_control_mat(int, complex_matrix)`: takes int and complex matrix and returns complex matrix.

`pauli_X_mat()`: takes nothing and returns a complex matrix.

`pauli_Y_mat()`: takes nothing and returns a complex matrix.

`pauli_Z_mat()`: takes nothing and returns a complex matrix.

`rot_X_mat(float)`: takes a float and returns a complex matrix.

`rot_Y_mat(float)`: takes a float and returns a complex matrix.

`rot_Z_mat(float)`: takes a float and returns a complex matrix.

`phase_scale_mat(float)`: takes a float and returns a complex matrix.

`phase_shift_mat(float)`: takes a float and returns a complex matrix.

`control_phase_shift_mat(float)`: takes a float and returns a complex matrix.

`swap_mat()`: takes nothing and returns a complex matrix.

`cswap_mat()`: takes nothing and returns a complex matrix.

`qft_mat(int)`: takes int and returns a complex matrix.

`grover_diffuse_mat(int)`: takes int and returns a complex matrix.

####Quantum Registers
`qsize(qreg)`: takes a qreg and returns an int.

`qclone(qreg)`: takes a qreg and returns a qreg.

`prefix_prob(qreg, int, int)`: takes a qreg, and int, and an int, and returns a float.

`apply_orancle(qreg, function, int)`: takes a qreg, a defined function, and an int, and returns void.

####Quantum Gates (Functions apply a specific gate to a quantum register)

#####Single bit gates
`hadamard(qreg)`: takes a qreg and returns void.

`hadamart_top(qreg, int)`: takes qreg and int and returns void.

`pauli_X(qreg, int)`: takes qreg and int and returns void.

`pauli_Y(qreg, int)`: takes qreg and int and returns void.

`paluli_Z(qreg, int)`: takes qreg and int and returns void.

`rot_X(qreg, float, int)`: takes qreg, float, and int and returns void.

`rot_Y(qreg, float, int)`: takes qreg, float, and int and returns void.

`rot_Z(qreg, float, int)`: takes qreg, float, and int and returns void.

`phase_scale(qreg, float, int)`: takes qreg, float, and int and returns void.

`phase_shift(qreg, float, int)`: takes qreg, float, and int and returns void.

#####Multi bit gates
`generic_1gate(qreg, complex_matrix, int)`: takes qreg, complex matrix, and int and returns void.

`generic_2gate(qreg, complex_matrix, int, int)`: takes qreg, complex matrix, int, and int and returns void.

`generic_ngate(qreg, complex_matrix, [int])`: takes qreg, complex matrix, and an array of ints and returns void.

####Control Gates
`cnot(qreg, int, int)`: takes qreg, int, and int, and returns void.

`toffoli(qreg, int, int, int)`: takes qreg, int, int, and int and returns void.

`control_phase_shift(qreg, float, int, int)`: takes a qreg, float, int, and int, and returns void.

`ncnot(qreg, [int], int)`: takes a qreg, and array of ints, and int, and returns void.

`generic_control(qreg, complex_matrix, int, int)`: takes qreg, complex matrix, int, and int, and returns void.

`generic_toffoli(qreg, complex_matrix, int, int, int)`: takes qreg, complex matrix, int, int, and int, and returns void.

`generic_ncontrol(qreg, complex_matrix, [int], int)`: takes qreg, complex matrix, an array of ints, and int, and returns void.

####Other Gates
`swap(qreg, int, int)`: takes qreg, int, and int, and returns void.

`cswap(qreg, int, int, int)`: takes qreg, int, int, and int, and returns void.

`qft(qreg, int, int)`: takes qreg, int, and int, and returns void.

`grover_diffuse(qreg)`: takes qreg and returns void.


###Grammar

Below is the grammar for QUARK. Words in capital letters are tokens passed in from the lexer.

```ocaml
ident:
    ID

vartype:
    INT 
  | FLOAT
  | BOOLEAN 
  | STRING  
  | QREG    
  | FRACTION 
  | COMPLEX 
  | VOID     

datatype:
  | vartype
  | datatype []
  | datatype [|]

/* Variables that can be assigned a value */
lvalue:
  | ident                           
  | ident [expr_list]

expr:
  /* Logical */
  | expr < expr          
  | expr <= expr         
  | expr > expr          
  | expr >= expr         
  | expr == expr      
  | expr != expr  
  | expr and expr        
  | expr or expr          
  
  /* Unary */
  | ~expr            
  | -expr
  | not expr                
  | expr`             

  /* Arithmetic */
  | expr + expr    
  | expr - expr   
  | expr * expr  
  | expr / expr  
  | expr mod expr  
  | expr ** expr  

  /* Bitwise */
  | expr & expr       
  | expr ^ expr       
  | expr | expr         
  | expr << expr        
  | expr >> expr        

  /* Query */
  | expr ? expr         
  | expr ?` expr 
  | expr ? [ : expr ]
  | expr ?` [ : expr ] 
  | expr ? [expr : expr ]       
  | expr ?` [expr : expr]

  /* Parenthesis */
  | (expr)

  /* Assignment */
  | lvalue = expr
  | lvalue   
  
  /* Special assignment */
  | lvalue += expr 
  | lvalue -= expr 
  | lvalue *= expr
  | lvalue /= expr
  | lvalue &= expr

  /* Post operation */
  | lvalue ++ 
  | lvalue --

  /* Membership testing with keyword 'in' */
  | expr in expr

  /* Python-style tertiary */
  | expr if expr else expr  

  /* literals */
  | INT_LITERAL              
  | FLOAT_LITERAL                 
  | BOOLEAN_LITERAL                    
  | expr $ expr                          
  | STRING_LITERAL                             
  | [ expr_list ]                
  | datatype [ expr ]       
  | [| matrix_row_list |]          
  | datatype [| expr , expr |]
  | i( expr , expr )     
  | i( expr )                  
  | <| expr , expr |>                

  /* function call */
  | ident ()            
  | ident (expr_list) 

expr_list:
  | expr , expr_list
  | expr      

/* [| r00, r01; r10, r11; r20, r21 |] */
matrix_row_list:
  | expr_list ; matrix_row_list
  | expr_list  

decl:
  | datatype ident = expr ;             
  | datatype ident ;                          

statement:

  | if expr : statement else statement
  | if expr : statement

  | while expr : statement
  | for iterator : statement

  | {statement_seq}

  | expr;
  | ;
  | decl

  | return expr;
  | return;
  
  /* Control flow */
  | break
  | continue

iterator:
  | ident in [range]
  | datatype ident in [range] 
  | datatype ident in expr

range:
  | expr : expr : expr
  | expr : expr 
  | : expr : expr
  | : expr

top_level_statement:
  | def datatype ident : param_list {statement_seq}
  | datatype ident : param_list ;
  | decl 

param:
  | datatype ident

non_empty_param_list:
  | param, non_empty_param_list
  | param

param_list:
  | non_empty_param_list
  | []

top_level:
  | top_level_statement top_level
  | top_level_statement

statement_seq:
  | statement statement_seq
  | []

```

<div style="page-break-after: always;"></div>

Project Plan
============
Tools used:
- Trello for task assignment
- Git for version control
- GitHub for code management
- Vagrant with Ubuntu 14.04 LTS 64-bit for consistent development environments

We also used an external simulator that Jim created over the summer. Our compiler's
output is C++ specifically designed to work with the simulator.

###Project Timeline:
These are goals we set for our project.

| Date     | Goal                           |
| -------- |:------------------------------:|
| 11/1/14  | Complete scanner and parser    |
| 11/14/14 | Complete semantic checking     |
| 11/25/14 | Complete code generation       |
| 12/16/14 | Complete test suite            |
| 12/1/14  | Complete end-to-end            |
| 12/5/14  | Finish testing and code freeze |
| 12/8/14  | Complete project report        |

###Project Log:
Actual progress of project.

| Date     | Milestones                                   |
| -------- |:--------------------------------------------:|
| 9/8/14   | Team formed                                  |
| 9/9/14   | Set up dev environment and GitHub repository |
| 9/10/14  | Decided on language specifics                |
| 9/17/14  | Assigned team roles                          |
| 9/24/14  | Language proposal complete                   |
| 10/26/14 | First draft of Language Reference Manual     |
| 11/10/14 | Basic scanner and parser complete            |
| 11/21/14 | Scanner and parser complete                  |
| 11/28/14 | Semantic checking started                    |
| 12/5/14  | Semantic checking complete                   |
| 12/7/14  | Code generation complete                     |
| 12/8/14  | Test suite complete                          |
| 12/9/14  | End-to-end working                           |
| 12/10/14 | Modifications to simulator for compatibility |
| 12/13/14 | Rewrote Language Reference Manual            |
| 12/15/14 | Complete testing and code freeze             |
| 12/16/14 | Project report complete                      |

###Roles and Responsibilities
Here are our official roles for the project.

| Role                      | Name                  | 
| ------------------------- | :-------------------: |
| Project Manager           | Parthiban Loganathan  |
| Language Guru             | Jim Fan               |
| System Architect          | Jamis Johnson         |
| Verification & Validation | Daria Jung            |

In practice, we didn't follow these roles very strictly. All of us worked on multiple parts of the code
and took responsibility for whatever we touched. The parts of the compiler and project that we primarily worked on can roughly be split up into the following:

| Category                  | Names                                           | 
| ------------------------- | :---------------------------------------------: |
| Project Management        | Parthiban Loganathan                            |
| Language Reference Manual | Daria Jung                                      |
| Scanner, Parser           | Parthiban Loganathan, Daria Jung, Jim Fan                |
| Semantic Checking         | Jim Fan, Jamis Johnson                          |
| Code Generation           | Jim Fan                                         |
| Testing                   | All                                             |
| Simulator                 | Jim Fan                                         |
| Project Report            | All                                             |
| Presentation              | Parthiban Loganathan                            |

Though some names are not listed under certain sections, it doesn't mean they didn't contribute towards it. For example, Daria helped with project management in the middle of the semester when things were hectic and no one was co-operating. All of us worked on different chunks of semantic checking before we decided on a major rewrite since it was hard to separate it from code generation. Due to our decision to follow the "democracy" approach as opposed to the "dictatorship" approach we faced issues with accountability, but each one of us also got to see more of the compiler in the process.

<div style="page-break-after: always;"></div>

Architecture
============
####Global Overview
The Quark architecture primarily consists of two major components, a compiler frontend and a simulator backend. The compiler translates Quark source code into C++ code, which is then compiled with Quark++ (simulator) headers by GNU g++.  

When the program runs, it links with precompiled a Quark++ dynamic library and executes the quantum circuit simulation instructions. Optionally, the user can compile the generated C++ code with a static library to produce one portable executable, without any external dependencies. This option can be enabled with ```quarkc -static```. It only works on Windows and Linux. 

The Quark compiler is OS aware and will extract the correct library automatically. It supports all major OSes (tested on Windows 7 & 8, Mac OS X and Ubuntu 14.04).

#### Compiler Architecture
The compiler is written entirely in OCaml. This section outlines the compilation pipeline we design. 

1. *Preprocessing*

    The preprocessor mainly resolves all ```import``` statements. The file path following each ```import``` is checked and added to a hashtable, which ensures that no circular or repetitive imports is allowed. 
    
    The imported file can contain ```import``` themselves, so the preprocessor recursively expands all imported sources until no more ```import``` statments left. 

2. *Scanning*

    The scanner tokenizes the source code into OCaml symbols. Details of the scanner rules can be found in the LRM.

3. *Parsing*

    The parser defines the syntactical rules of the Quark language. It takes the stream of tokens produced by the scanner as input, and produces an abstract syntax tree (AST), a recursive data structure. 
    More details of the grammar can be found in the LRM.

4. *Semantic checking*

    The semantic checker ensures that no type conflicts, variable/function declaration/definition errors exist in a syntactically correct AST. It takes an AST as input and produces a similar recursive structure - the Semantic Abstract Syntax Tree (SAST). 

	The struct ```var_info``` keeps information about a variable's type and depth in scope. A semantic exception is thrown if a variable with the same name is redeclared within the same scope.
	```ocaml
	type var_info = {
	  v_type: A.datatype;
	  v_depth: int;
	}
	```
	The struct ```func_info``` keeps information about a function interface.
	```ocaml
	type func_info = {
	  f_args: A.datatype list;
	  f_return: A.datatype;
	  f_defined: bool; (* for forward declaration *)
	}
	```
	The environment struct is carried along every recursive call to the semantic checker. It contains a variable table, a function table, the current scope depth, ```is_returned``` to check whether a function is properly returned, and ```in_loop``` to ensure that ```continue``` and ```break``` statements appear only in loops.
	```ocaml
	type environment = {
	    var_table: var_info StrMap.t;
	    func_table: func_info StrMap.t;
	    (* current function name waiting for 'return' *)
	    (* if "", we are not inside any function *)
	    func_current: string; 
	    depth: int;
	    is_returned: bool;
	    in_loop: bool;  (* check break/continue validity *)
	}
	```

    Our SAST is carefully designed to minimize code generation efforts. A major discovery is that the SAST does not need to carry the type information. Instead, a special ```op_tag``` is added, which contains all the information the code generator requires to produce C++. 

    For example, the binary ampersand ```&``` in Quark is used for both integer bitwise ```and``` and array/string concatenation. The SAST does not need to carry along the operands' type information to tell the code generator which meaning of ```&``` to translate. It only needs to tag the binary operator expression with either ```OpVerbatim``` or ```OpConcat```. 

	A separate source file ```builtin.ml``` includes all the builtin function interfaces supported by the Quark++ simulator. The user, however, is free to  The ```print``` and ```print_noline``` are special because they take an arbitrary number of arguments of arbitrary type. 
	
	The semantic checker also features very informative error messages to help the user debug better. The following is a few examples:
	- "A function is confused with a variable: u"
	- "Function foo() is forward declared, but called without definition"
	- "If statement predicate must be bool, but fraction provided"
	- "Array style for-loop must operate on array type, not complex[|]"
	- "Matrix element unsupported: string"
	- "Incompatible operands for **: string -.- fraction"
	- "All rows in a matrix must have the same length"

5. *Code Generation*

    The code generator takes an SAST as input and produces a string of translated C++ code, excluding the headers. 

	The following is a list of type mappings:
	- ```int``` → C++ ```int64_t```
	- ```float``` → C++ primitive ```float```
	- ```string``` → C++ ```std::string```
	- ```complex``` → C++ ```std::complex<float>```
	- arrays → C++ ```std::vector<>```
	- matrices → ```Eigen::Matrix<float, Dynamic, Dynamic>```
	- ```fraction``` → Quark++ ```Frac``` class
	- ```qreg``` → Quark++ ```Qureg``` class

	The generator relies on the ```op_tag``` given by the semantic checker to generate the right C++ function. For example, ```OpCastComplex1``` instructs the generator to cast the first operand of a binary operator to ```std::complex<float>```.

	The generator uses a very special way to handle for-loops. Our for-range loop syntax is
	 ```for int i in [ start : end : step ]``` 
	 When ```step``` is negative, the for loop must go in the reverse direction. The sign of ```step```, however, is not available at compilation time. So the code generator uses system reserved temporary variables to handle this situation. 
	 The temporary identifier has the format ```_QUARK_[10_random_ascii_chars]```. 

	As an example, the following quark code
	```
	    for int i in [10 : 0 : step()]:
        print(i);
	```
	is compiled to
	``` c
	int64_t _QUARK_5H0aq5mw6x = 0;
	int64_t _QUARK_v3YH0O1B0h = step();
	int64_t _QUARK_l03AMaXh6u = _QUARK_v3YH0O1B0h > 0 ? 1 : -1;
	for (int64_t i = 10; _QUARK_l03AMaXh6u * i < _QUARK_l03AMaXh6u * 0; i += _QUARK_v3YH0O1B0h){
	std::cout << std::boolalpha << std::setprecision(6) << i << std::endl;
	}
	```

    The code generator must conform to the Quark++ simulator library interface. In practice, the simulator has to be updated with minor changes to accomodate the compiled code as well as its interaction with the [Eigen](eigen.tuxfamily.org) matrix library.

6. *User Interface*

    Quarkc implements a number of command line arguments to improve user experience. Shorthand args are also provided for convenience. 

    The project is self-contained. It requires little to no user-managed dependencies. 

#### Quark++ Simulator
The simulator is written by Jim Fan before the beginning of this term. It contains around 6,000 lines of C++ 11 code, compiles and runs successfully on Windows, Mac and Ubuntu. 

It features a complete and optimized quantum circuit simulation engine that is able to run the most celebrated quantum algorithms ever conceived, including but not limited to Shor's factorization, Grover's search, Simon's period finding algorithm, etc. It can be included in other quantum computing research projects as a standalone library.
