# Turing machine programs

## See [https://github.com/ritterbush/turing-machines](https://github.com/ritterbush/turing-machines) for a primer on Turing machines.

These programs follow the same form followed by my Turing machine implementations, linked above. Namely:

'L' signifies erase the symbol, and go left.
'M' signifies write the symbol, and go left.
'R' signifies erase the symbol, and go right.
'S' signifies write the symbol, and go right.

Cmd0 Cmd1 NextState0 NextState1\
Cmd0 Cmd1 NextState0 NextState1\
Cmd0 Cmd1 NextState0 NextState1\
....

Where\
**Cmd0** stands for the command to run given that the cart is not at a symbol (is at a '0'),\
**Cmd1** stands for the command to run given that the cart is at a symbol (is at a '1'),\
**NextState0** is the next state the cart will be in given that the cart is not at a symbol (is at a '0'),\
**NextState1** is the next state the cart will be in given that the cart is not at a symbol (is at a '1'),

Which line to run is determined by the state number of the cart. Lines are finite (in theory as well as, of course, in practice).

A concrete example:

L M 2 2\
S R 0 0

Relatively simple, this Turing program tells the cart (in state 1, which references line 1) to erase the symbol below it and go left, if it is has no symbol below it (so just go left, since there's no symbol to erase), or else put a symbol below it and go left, if it is has a symbol below it (so just go left, since there's already a symbol below it), and go to the next state, which references line 2. At line 2, the cart is to put a symbol below it and go right, if it is has no symbol below it, or else erase the symbol below it and go right, if it is has a symbol below it, and go to the next state. Since the next state is 0, the cart will halt and finish executing the program.
