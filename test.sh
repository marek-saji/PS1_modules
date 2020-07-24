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

cd "$TMPDIR" || exit 1

# If PS1 modules are already running, this may interfere with tests
# shellcheck disable=SC2034
PS1_debug_trap=
PROMPT_COMMAND=

for PRESET in "$BASEDIR"/presets/*
do
    if [ "$( file --mime-type --brief "$PRESET" )" != "text/x-shellscript" ]
    then
        continue
    fi

    printf 'module %s: ' "$( basename "$PRESET" )"

    # shellcheck disable=1090
    OUTPUT="$( . "$PRESET" 2>&1 > /dev/null )"
    if [ -n "$OUTPUT" ]
    then
        error_in_output "$PRESET" "Output on stderr" "$OUTPUT"
    else
        printf '.'
    fi

    printf 'export PATH="%s"\n' "$PATH" > .bashrc
    printf '. "%s"\n' "$PRESET" >> .bashrc

    # Go to base dir as there's a git repository
    OUTPUT="$( printf '\ncd "%s"\nexit\n' "$BASEDIR" | SHELL="$( command -v bash )" HOME="$TMPDIR" script /dev/null )"

    if ( echo "$OUTPUT" | grep -Eq '^bash: ' )
    then
        error_in_output "$PRESET" 'Lines starting with "bash: "' "$OUTPUT"
    else
        printf '.'
    fi


    if ( echo "$OUTPUT" | grep -Eq '^PS1_' )
    then
        error_in_output "$PRESET" 'Lines starting with "PS1_"' "$OUTPUT"
    else
        printf '.'
    fi

    if [[ $OUTPUT =~ "command not found" ]]
    then
        error_in_output "$PRESET" 'Lines containing "command not found"' "$OUTPUT"
    else
        printf '.'
    fi

    rm .bashrc

    if ! shellcheck "$PRESET"
    then
        STATUS=1
    else
        printf '.'
    fi

    printf '\n'
done

for MODULE in "$BASEDIR"/modules/*
do
    if [ "$( file --mime-type --brief "$MODULE" )" != "text/x-shellscript" ]
    then
        continue
    fi

    printf 'preset %s: ' "$( basename "$MODULE" )"

    if ! shellcheck "$MODULE"
    then
        STATUS=1
    else
        printf '.'
    fi

    printf '\n'
done

cd - > /dev/null || exit 1
rm -rf "$TMPDIR"

exit $STATUS
