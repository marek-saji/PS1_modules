Modular bash prompt
===================

Usage
-----

Checkout wherever (`~/.bash/PS1/` is a good choice) and use one of the
presets in your `~/.bashrc`:

    mkdir -p ~/.bash/PS1
    git clone https://github.com/marek-saji/PS1_modules.git .
    cat >> ~/.bashrc
    . ~/.bash/PS1/presets/full
    ^D

Your new terminals should look like this:

![Two-line, comprehend PS1 preset.](presets/full.png)



Modules and presets
-------------------

See [presets/](presets/) for an examples on how presets can be made.

Modules should export variable or function with called
`PS1_${MODULE_NAME}` and additionally can export more things called
`PS1_${MODULE_NAME}__${SUBNAME}`. Common example is a function
`PS1_${MODULE_NAME}__get`, which is useful for using in other modules.
Most main modules' function take one parameter: string that is
attached before a value, if any is printed -- it's useful for
adding leading space and colour escape sequence.

See module files for more information on how to use them.



Contributing
------------

Feel free fork and pull-request new modules and/or presets.


License
-------

[MIT License](LICENSE).
