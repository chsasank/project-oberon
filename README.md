## VOC

https://github.com/vishaps/voc

This seems to be the best.

The following are oberon-7 compilers.

## OberonC

Compiling and running oberon programs

1. Install https://github.com/lboasso/oberonc
2. Add lines similar to this in bashrc:

    ```
    # oberon
    export OBERON_BIN="/home/sasank/code/systems/oberonc/bin"
    alias oberonc="java -cp $OBERON_BIN oberonc"
    oberon () {
        java -cp $OBERON_BIN:$1 $2
    }
    ```

    Restart the terminal

3. Compile and run Hello.mod

    ```
    mkdir build
    oberonc build/ Hello.Mod
    oberon build/ Hello
    ```


## OBNC
Second option:

Ref: https://rsdoiel.github.io/blog/2020/04/11/Mostly-Oberon.html

1. Install compiler from here: https://miasap.se/obnc/
2. obnc Hello.Mod
3. ./Hello

