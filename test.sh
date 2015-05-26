#!/usr/bin/env bash

BASEDIR="$PWD"
TMPDIR="$( mktemp -d )"

# Script will return with that status
STATUS=0
error_in_output ()
{
    printf '\nERROR in preset %s: %s\n---\n%s\n---\n' "$@"
    export STATUS=1
}

cd "$TMPDIR"

# If PS1 modules are already running, this may interfere with tests
PS1_debug_trap=
PROMPT_COMMAND=

for PRESET in "$BASEDIR"/presets/*
do
    if [ "$( file --mime-type "$PRESET" | cut -d: -f2 )" != " text/x-shellscript" ]
    then
        continue
    fi

    printf '.'

    OUTPUT="$( . "$PRESET" 2>&1 > /dev/null )"
    if [ -n "$OUTPUT" ]
    then
        error_in_output "$PRESET" "Output on stderr" "$OUTPUT"
    fi


    printf '.'

    printf 'export PATH="%s"\n' "$PATH" > .bashrc
    printf '. "%s"\n' "$PRESET" >> .bashrc

    # Go to base dir as there's a git repository
    OUTPUT="$( printf '\ncd "%s"\nexit\n' "$BASEDIR" | SHELL="$( which bash )" HOME="$TMPDIR" script /dev/null )"

    if ( echo "$OUTPUT" | grep -Eq '^bash: ' )
    then
        error_in_output "$PRESET" 'Lines starting with "bash: "' "$OUTPUT"
    fi


    if ( echo "$OUTPUT" | grep -Eq '^PS1_' )
    then
        error_in_output "$PRESET" 'Lines starting with "PS1_"' "$OUTPUT"
    fi

    if [[ $OUTPUT =~ "command not found" ]]
    then
        error_in_output "$PRESET" 'Lines containing "command not found"' "$OUTPUT"
    fi

    rm .bashrc

    printf ' '
done
printf '\n'

cd - > /dev/null
rm -rf "$TMPDIR"

exit $STATUS
