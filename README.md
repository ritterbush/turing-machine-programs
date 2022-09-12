# Turing machine programs

### See [https://github.com/ritterbush/turing-machines](https://github.com/ritterbush/turing-machines) for a primer on Turing machines.

These programs follow the same form as my Turing machine implementations, linked above. In short: 

There are four commands:

* ***L*** signifies erase the symbol, and go left.
* ***M*** signifies write the symbol, and go left.
* ***R*** signifies erase the symbol, and go right.
* ***S*** signifies write the symbol, and go right.

A Turing program has the following form:

    Cmd0 Cmd1 NextState0 NextState1
    Cmd0 Cmd1 NextState0 NextState1
    Cmd0 Cmd1 NextState0 NextState1
    ....

Where


* ***Cmd0*** stands for the command to run given that the cart is not at a symbol (is at a '0'),
* ***Cmd1*** stands for the command to run given that the cart is at a symbol (is at a '1'),
* ***NextState0*** is the next state the cart will be in given that the cart is not at a symbol (is at a '0'),
* ***NextState1*** is the next state the cart will be in given that the cart is not at a symbol (is at a '1'),

Which line to run is determined by the state number of the cart. Lines are finite (in theory as well as, of course, in practice).

A concrete example:

    L M 2 2
    S R 0 0

Relatively simple, this Turing program tells the cart (in state 1, which references line 1) to erase the symbol below it and go left, if it is has no symbol below it (so just go left, since there's no symbol to erase), or else put a symbol below it and go left, if it is has a symbol below it (so just go left, since there's already a symbol below it), and go to the next state, which references line 2. At line 2, the cart is to put a symbol below it and go right, if it is has no symbol below it, or else erase the symbol below it and go right, if it is has a symbol below it, and go to the next state. Since the next state is 0, the cart will halt and finish executing the program.

# Busy Beavers

Busy beavers are those Turing programs that are run on a track of no symbols (of all ***0***'s), and end with the greatest amount of symbols (of ***1***s) as possible, given some maximum number of lines (equivalently, given a maximum number of states a cart can be in given a program). This site keeps track of current winners of [known Busy Beavers](https://webusers.imj-prg.fr/~pascal.michel/bbc.html).

The goal for this repo would be to have "busy beaver" programs relative to the function the program is made to implement. That is, the most efficient add, subract, multiply, divide, get-element-i-from-list, ...etc. functions. Here, *most efficient* just means done in the fewest amount of lines.

To explain how Turing machines can implement functions at all, consider a cart on a track with no ***1*** symbols before it, when considered as ordered from left to right. Number values for functions are understood to be unbroken strings of ***1***'s, if any, starting from the cart's position. Any breaks between ***1***'s signify new numbers.

For example, the track (with the cart's position pointed to by '...^...'):

...000111011000...\
..........^...................

Means that the function implemented by the Turing program has the input arguments `3, 2`. If the Turing program is one that implements multiplication, then the cart must halt at the first block of the result `6`, or:

...000111111000...\
..........^..................

What about a `0` argument? For this, use strings of no-symbols (or ***0***'s) relative to the cart's postion:

...000011000000...\
..........^....................

The above has arguments `0, 2`, assuming a binary function, and the result of a multiplication Turing program will just be a blank track.

There are a few more nuances to cover.
