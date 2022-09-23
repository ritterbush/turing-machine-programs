# Turing machine programs

### See [https://github.com/ritterbush/turing-machines](https://github.com/ritterbush/turing-machines) for a primer on Turing machines. In short,

There are four commands:

* ***L*** signifies erase the symbol, and go left.
* ***M*** signifies write the symbol, and go left.
* ***R*** signifies erase the symbol, and go right.
* ***S*** signifies write the symbol, and go right.

A Turing program has the following form:

    Cmd0 NextState0 Cmd1 NextState1
    Cmd0 NextState0 Cmd1 NextState1
    Cmd0 NextState0 Cmd1 NextState1
    ....

Where


* ***Cmd0*** stands for the command to run given that the cart is not at a symbol (is at a ***0***),
* ***NextState0*** stands for the next state the cart is in given that the cart is not at a symbol (is at a ***0***),
* ***Cmd1*** stands for the command to run given that the cart is at a symbol (is at a ***1***),
* ***NextState1*** stands for the next state the cart is in given that the cart is at a symbol (is at a ***1***),

Which line to run is determined by the state number of the cart. Lines are finite (in theory as well as, of course, in practice).

A concrete example:

    L 2 M 2
    S 0 R 0

Relatively simple, this Turing program tells the cart (in state 1, which references line 1) to erase the symbol below it and go left, if it is has no symbol below it (so just go left, since there's no symbol to erase) and go to the next state, state 2; or else put a symbol below it and go left, if it is has a symbol below it (so just go left, since there's already a symbol below it), and go to the next state, state 2, which references line 2. At line 2, the cart is to put a symbol below it and go right, if it is has no symbol below it, or else erase the symbol below it and go right, if it is has a symbol below it, and go to the next state. Since either way the next state is 0, the cart will halt and finish executing the program.


Commenting is done with a `--` or `#` at the start of the line. Comments are mainly used to explain any nuances about the program. The name of the program provides the most high-level details about what the program does. The name starts with the function that the program implements, followed by underscores, if any, that separate other details. For example, if the function is partial, then this would be included. If the implementation potentially erases or adds ***1***s to areas before where the cart begins, then this is to be marked in the name with `dest`, and further details about how it is destructive can be given in a comment. Also, if the program comes from a book, article, blog, or elsewhere, this should be referenced with an abreviation in the name, followed by a more complete reference in a comment. Turing programs have a `.tm` extension. As an example of all of these, the partial, potentially destructive turing program taken from *Computability and Logic* for multiplication is named `mul_partial_dest_cnl.tm`.


# Busy Beavers

Busy beavers are those Turing programs that are run on a track of no symbols (of all ***0***'s), and end with the greatest amount of symbols (of ***1***s) as possible, given some maximum number of lines (equivalently, given a maximum number of states a cart can be in given a program). Here is a site that keeps track of the current winners of [known Busy Beavers](https://webusers.imj-prg.fr/~pascal.michel/bbc.html).

The goal for this repo would be to have "busy beaver" programs relative to the function the program is made to implement. That is, the most efficient add, subract, multiply, divide, get-element-i-from-list, ...etc. functions. Here, *most efficient* just means done in the fewest amount of states, or lines of the program.

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

Arguments of values greater than one are separated by a single ***0***. If we want to signify values of zero, simply insert additional ***0***'s between the chunks of consecutive ***1***'s, where each additional ***0*** represents an additional zero. For example, 

...0001110011000...\
..........^...................

Signifies the values `3, 0, 2`, which would result in `0`, or a blank track, for a Turing Program that implements multiplication of all three values.

