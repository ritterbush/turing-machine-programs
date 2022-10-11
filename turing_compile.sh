#!/bin/sh

# Version 1.0
# Author: Paul Ritterbush

# 1.0 features:
# Allows for arbitrary amounts of spaces greater than zero between commands and state reference numbers in Turing state commands.
# Allows for comments anywhere; comments are any text that is not a Turing state commands or a reference to a Turing program file (both at the start of a line).
# Verbose option to see intermediary steps.
# Checks against invalid Turing Programs that reference a state past the total state commands available.
# No temporary files.

# Turing state commands are of the form: COMMAND1 STATEREFERENCE1 COMMAND2 STATEREFERENCE2
#   where COMMANDS are one of L, M, R, or S, and STATEREFERENCES are a numeral.
# fn.tm, fn(), fn are valid Turing program file names/references, as long as the file named fn.tm exists in the current directory

show_usage() {
    printf "Usage:\n\n  %s [options] [filename]\n" "$0"
    printf "\n"
    printf "Compiles [filename] of Turing state commands and the names of Turing program files\n"
    printf "    (which have a .tm extension) to a valid Turing program file. Result will be \n"
    printf "    named the same as [filename], but with its extension replaced with .tm. Keeps\n"
    printf "    any comments.\n"
    printf "\n"
    printf "Options:\n"
    printf "  -v|--verbose, Intermediary steps are printed to the console.\n"
    printf "  -l|--line-up, Line up commands to be in same column. Makes the compiled file look better.\n"
    printf "  -h|--help   Print this help.\n"
exit
}

[ $# -eq 0 ] && show_usage

# Needed to allow for a single argument for help option and no [filename]
case "$1" in
    --help|-h)
        show_usage
        ;;
esac

verbose=0
line_up=0

while [ -n "$2" ]; do
    case "$1" in
        --verbose|-v)
            verbose=1
            shift
            ;;
        --line-up|-l)
            line_up=1
            shift
            ;;
        --help|-h)
            show_usage
            ;;
        *)
            echo "Unknown option $1"
            show_usage
            ;;
    esac
done

# Check $1 is not filename.tm, since this is the name of final compiled file
arg_end=$(printf "%s" "$1" | tail -c 3)
case "$arg_end" in
    .tm)
        echo "Don't use the .tm extension to compile to a .tm file. Change extension first."
        exit 1
        ;;
esac

# Source file exists
[ ! -f "$1" ] &&
    { echo "No file $1 exists in this directory."; exit 1; }

filename_no_ext="${1%.*}" # Parameter expansion on $1: drop everything from the end to the first . ; keeps all if $1 has no ext
compiled="$filename_no_ext".tm # Name of final compiled result

[ -f "$compiled" ] &&
    { echo "File $compiled already exists. Perhaps it was already compiled? Remove it or move it to another directory and try again."; exit 1; }

# Takes 1 string arg, and checks if it's a Turing state command line
# Warning: if this is changed, double check get_ref1_ref2 and any code with comments "... is_state_cmd_line except ...."
is_state_cmd_line() {
    if echo "$1" | grep -q "^[LMRS]  *[0-9][0-9]*  *[LMRS]  *[0-9][0-9]*.*" # * = "match 0 or more of the preceding char/[chars]
    then
        return 0
    else
        return 1
    fi
}

# Gets the line references numbers of the next states
# Values assigned to ref1 and ref2
get_ref1_ref2() {
            ref1=$(echo "$line" | tr -s ' ' | cut -d ' ' -f 2)
            ref2=$(echo "$line" | tr -s ' ' | cut -d ' ' -f 4)
            ref2=$(echo "$ref2" | sed 's/^[0-9][0-9]*/& /') # Comments are allowed after final reference number, so mark any with a space
            ref2=$(echo "$ref2" | sed 's/ .*$//') # And delete them
}

# Precompilation:
# * Change any allowable references to program files to be the exact name of the file (i.e. with the .tm extension)
# * Keep any comments that follow a reference to a program file
# * Keep any comments that are on their own lines
# * Inline the contents of any referenced program files without change

lines_amt=$(sed -n '$=' "$1")
for i in $(seq 1 "$lines_amt")
do
    line=$(sed -n "${i}p" "$1")

    if is_state_cmd_line "$line"
    then
        echo "$line" >> "$compiled"

    else
        program_filename_no_ext="${line%%.tm*}" # Drop everything from the end through the last .tm ; keeps all if no match
        program_filename_no_ext="${program_filename_no_ext%%\(\)*}" # All is kept if no match, so try also with ()
        program_filename="$program_filename_no_ext".tm # Add .tm no matter what

        if [ -f "$program_filename" ]
        then
            [ "$verbose" -eq 1 ] && echo "File $program_filename found, inlining contents."

            line_without_program_filename_no_ext="${line#*"${program_filename_no_ext}"}" # Drop everything from beginning through the first program_filename_no_ext
            # Note: it won't work to sed replace anything up to .tm and then anything up to () or vice versa, because comments may always include such chars after a fn reference name with .tm or ()
            program_filename_ext=$(printf "%s" "$line_without_program_filename_no_ext" | cut -c 1-3) # cut gets chars 1-3 up to as far as they are available
            case "$program_filename_ext" in
                .tm)
                    line=$(echo "$line" | sed 's/'"$program_filename_no_ext"'\.tm/'"$program_filename"'/')
                    ;;
                \(\)*)
                    line=$(echo "$line" | sed 's/'"$program_filename_no_ext"'()/'"$program_filename"'/')
                    ;;
                *)
                    line=$(echo "$line" | sed 's/'"$program_filename_no_ext"'/'"$program_filename"'/')
                    ;;
            esac

            echo "$line" >> "$compiled"
            cat "$program_filename" >> "$compiled"

        else
            echo "$line" >> "$compiled"

        fi
    fi
done

# Compilation: Update the state number references

set -- # Makes a blank array (using shell parameters) to help with post compilation
lines_amt=$(sed -n '$=' "$compiled")
for i in $(seq 1 "$lines_amt")
do
    line=$(sed -n "${i}p" "$compiled")

    if ! is_state_cmd_line "$line"
    then

        # Recall that precompilation changed all program file references to name the file literally with the .tm extension
        # Remove any comments
        program_filename="${line%%.tm*}" # Drop everything from the end through the last .tm ; keeps all if no match
        program_filename="$program_filename".tm # Add back .tm

        if [ -f "$program_filename" ]
        then

            # Post compilation helpers:
            # * Remove $program_filename from $line
            # * If updated $line is empty, then add its line number to the array for deletion
            # The reason we cannot delete it now is that deletion will cause the next line to become this line and get skipped in the next iteration of $i
            sed -i "$i"'s/'"$program_filename"'//' "$compiled"
            #line=$(echo "$line" | sed 's/'"$program_filename"'//') # Alternative to sed cmd above
            line=$(sed -n "${i}p" "$compiled")
            [ -z "$line" ] && set -- "$i" "$@" # $i prepended in order to start with the latest line (reverses the order of insertion)


            # Update state number references

            [ "$verbose" -eq 1 ] && echo "File $program_filename found, updating state references."

            [ "$verbose" -eq 1 ] &&
                { echo "Compiled contents so far:"
                cat "$compiled"
                echo "End of compiled contents so far"
                }

            lines_amt_compiled=$(("$i" - 1))
            state_commands_amt_compiled=0

            for j in $(seq 1 "$lines_amt_compiled")
            do
                line_compiled=$(sed -n "${j}p" "$compiled")
                if is_state_cmd_line "$line_compiled"
                then
                    state_commands_amt_compiled=$(("$state_commands_amt_compiled" + 1))
                fi
            done

            state_commands_amt_compiled_plus1=$(("$state_commands_amt_compiled" + 1)) # Also the line that references fn

            lines_amt_program_file=$(sed -n '$=' "$program_filename") # Total lines of the .tm file ref'ed to by the line
            state_commands_amt_program_file=0

            for j in $(seq 1 "$lines_amt_program_file")
            do
                line_program_file=$(sed -n "${j}p" "$program_filename")
                if is_state_cmd_line "$line_program_file"
                then
                    state_commands_amt_program_file=$(("$state_commands_amt_program_file" + 1))
                fi
            done

            state_commands_amt_program_file_minus1=$(("$state_commands_amt_program_file" - 1)) # Because we count the line that references the fn

            [ "$verbose" -eq 1 ] &&
                { echo "Compiling at line $state_commands_amt_compiled_plus1"
                echo "$state_commands_amt_program_file Turing state commands found in $program_filename"
                }


            # For the compiled file, we need to add the amt of lines of the fn - 1 to any references to lines greater than what has been compiled + 1 (since we count the line with the fn to inline as something to be replaced with the fn's lines, whose first line would be referenced)
            for j in $(seq 1 "$lines_amt")
            do
                line=$(sed -n "${j}p" "$compiled")

                if is_state_cmd_line "$line"
                then
                    # Get
                    get_ref1_ref2

                    # Update and Set
                    if [ "$ref1" -gt "$state_commands_amt_compiled_plus1" ] && [ "$ref2" -gt "$state_commands_amt_compiled_plus1" ]
                    then
                        ref1=$(("$ref1" + "$state_commands_amt_program_file_minus1"))
                        ref2=$(("$ref2" + "$state_commands_amt_program_file_minus1"))
                        sed -i "$j"'s/ [0-9][0-9]* / a /' "$compiled"
                        sed -i "$j"'s/ [0-9][0-9]*/ '"$ref2"'/' "$compiled"
                        sed -i "$j"'s/ a / '"$ref1"' /' "$compiled"

                    elif [ "$ref1" -gt "$state_commands_amt_compiled_plus1" ] && [ "$ref2" -le "$state_commands_amt_compiled_plus1" ]
                    then
                        ref1=$(("$ref1" + "$state_commands_amt_program_file_minus1"))
                        sed -i "$j"'s/ [0-9][0-9]* / '"$ref1"'/' "$compiled"
                    elif [ "$ref1" -le "$state_commands_amt_compiled_plus1" ] && [ "$ref2" -gt "$state_commands_amt_compiled_plus1" ]
                    then
                        ref2=$(("$ref2" + "$state_commands_amt_program_file_minus1"))
                        sed -i "$j"'s/ [0-9][0-9]* / a /' "$compiled"
                        sed -i "$j"'s/ [0-9][0-9]*/ '"$ref2"'/' "$compiled"
                        sed -i "$j"'s/ a / '"$ref1"' /' "$compiled"
                    fi

                    # Below are alternative sed cmds to the above, if we get cmd1 and cmd2
                    #sed -i "$j"'s/^[LMRS] [0-9][0-9]* [LMRS] [0-9][0-9]*//' "$compiled"
                    #sed -i "$j"'s/^/'"$cmd1 $ref1 $cmd2 $ref2"'/' "$compiled"


                fi
            done

            # Next we add the amt of lines compiled to all refs in the fn that was inlined.
            # Change 0 refs to be line after fn that was inlined
            replace_zero_line_ref=$(("$state_commands_amt_compiled_plus1" + "$state_commands_amt_program_file"))

            # Find line range of s/replace: $i + 1 through ($i + 1 + lengthoffnfile)
            inline_program_first_line=$(("$i" + 1))
            inline_program_last_line=$(("$inline_program_first_line" + "$lines_amt_program_file" - 1))
            for j in $(seq "$inline_program_first_line" "$inline_program_last_line")
            do
                line=$(sed -n "${j}p" "$compiled")

                if is_state_cmd_line "$line"
                then
                    # Get
                    get_ref1_ref2

                    # Update
                    ref1=$(("$ref1" + "$state_commands_amt_compiled"))
                    ref2=$(("$ref2" + "$state_commands_amt_compiled"))
                    [ "$state_commands_amt_compiled" -eq "$ref1" ] && ref1="$replace_zero_line_ref" # ref1 was zero, have it ref line after inline fn
                    [ "$state_commands_amt_compiled" -eq "$ref2" ] && ref2="$replace_zero_line_ref" # ref2 was zero, have it ref line after inline fn

                    # Set
                    sed -i "$j"'s/ [0-9][0-9]* / a /' "$compiled"
                    sed -i "$j"'s/ [0-9][0-9]*/ '"$ref2"'/' "$compiled"
                    sed -i "$j"'s/ a / '"$ref1"' /' "$compiled"

                fi
            done

            [ "$verbose" -eq 1 ] &&
                { echo "State references updated."
                echo "Compiled contents after state references updated:"
                cat "$compiled"
                echo "End of compiled contents so far"
                }

        fi
    fi
done

# Post Compilation:
# * Delete lines of references to Turing program files with no comments
# * Check next state references do not reference beyond amount of states available

# Delete lines
for i in "$@" # Iterate over lines of fn file references that have no comments
do
    sed -i "$i"'d' "$compiled"
done

# Assigns maximum state reference number to max_ref (used below)
# Assigns total Turing state command lines to total_states
# The error check for references greater than total states available is done at the last step of this script
lines_amt=$(sed -n '$=' "$compiled")
total_states=0
max_ref=0
for i in $(seq 1 "$lines_amt")
do
    line=$(sed -n "${i}p" "$compiled")

    if is_state_cmd_line "$line"
    then
        total_states=$(("$total_states" + 1))

        # Get
        get_ref1_ref2

        # Ensure ref1 >= ref2
        if [ "$ref1" -lt "$ref2" ]
        then
            ref1="$ref2"
        fi

        # Ensure max_ref >= ref1
        if [ "$ref1" -gt "$max_ref" ]
        then
            max_ref="$ref1"
        fi
    fi
done



# Line up commands and references by column
if [ "$line_up" -eq 1 ]
then

    [ -f "$filename_no_ext".tm ] || { echo "${filename_no_ext}.tm not found. Compilation may have failed. Nothing to line up."; exit 1; }

    # Warning: ensure max_ref was assigned above and has not been changed, for the assignment below

    # Set column spacing based in part on max_ref's amt of digits
    max_ref_digits_amt="${#max_ref}"

    for i in $(seq 1 "$lines_amt")
    do
        line=$(sed -n "${i}p" "$compiled")

        if is_state_cmd_line "$line"
        then

            # Get
            get_ref1_ref2

            # Spaces need to be max_ref's amt of digits - (amt of digits of ref1*Or*2 - 1)
            #L 3   R 2
            #L 1   R 155
            #L 12  R 155
            #L 12  R 15
            #L 155 R 1

            # Update

            # ref1
            spaces_amt_ref1=$(("$max_ref_digits_amt" - ("${#ref1}" - 1)))
            spaces_ref1=''
            for j in $(seq 1 "$spaces_amt_ref1")
            do
                spaces_ref1=' '"$spaces_ref1"
            done

            # ref2
            spaces_amt_ref2=$(("$max_ref_digits_amt" - ("${#ref2}" - 1)))
            spaces_ref2=''
            for j in $(seq 1 "$spaces_amt_ref2")
            do
                spaces_ref2=' '"$spaces_ref2"
            done

            # Set

            # Same grep match as is_state_cmd_line except a comment character is checked.
            # Note: using . instead of [^0-9] matches numbers that have more than one digit. Why? Probably because the * that preceeds it allows for 0 matches, and . allows for any match, so the next digit of a number can match no digits and one char that is a digit. And since it can allow this, it does.
            if echo "$line" | grep -q "^[LMRS]  *[0-9][0-9]*  *[LMRS]  *[0-9][0-9]*[^0-9].*$" # * = "match 0 or more of the preceding char/[chars]
            then
                sed -i "$i"'s/^[LMRS]  *[0-9][0-9]*  *[LMRS]  *[0-9][0-9]*/&'"$spaces_ref2"'/' "$compiled"
            fi

            # Can't work to replace the above if block, since if there's spaces_ref2 amount of spaces at the end of a comment, it would get removed
            #sed -i "$i"'s/^[LMRS]  *[0-9][0-9]*  *[LMRS]  *[0-9][0-9]*/&'"$spaces_ref2"'/' "$compiled"
            #sed -i "$i"'s/'"$spaces_ref2"'$//' "$compiled"

            sed -i "$i"'s/  */a/' "$compiled"
            sed -i "$i"'s/  */a/' "$compiled"
            sed -i "$i"'s/  */ /' "$compiled"
            #sed -i "$i"'s/  */'"$spaces_ref2"'/' "$compiled" # This could be an alternative to the above if block: just append the space to every Turing command line; the downside is trailing whitepace for every non-commented line.
            sed -i "$i"'s/a/ /' "$compiled"
            sed -i "$i"'s/a/'"$spaces_ref1"'/' "$compiled"
        fi
    done
fi


# Save the invalid Turing Program check for the end so a completed compile can be examined
[ "$max_ref" -gt "$total_states" ] && { echo "Error: State $max_ref is referenced, but there are only $total_states states available. $compiled has been created but is an invalid Turing Program."; exit 1; }
