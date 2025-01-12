#!/bin/bash
# -e coverage.sh
#
# Use gcov to show the coverage of the file passed in params
# 
# Codes :
#   0 - everything fine
#   1 - sudo needed
#   2 - incompatible os
#   3 - installation failed
#   4 - wrong usage


usage() {

    echo "Usage: $0 <c dirs> <.c> ..."
}

# Setup for gcov on machine without it 
# # # 
install() {
    if [ $(whoami) != "root" ];
    then
        echo "Command gcov not installed"
        echo "Restart as: sudo $0 or install it by yourself"
        exit 1
    fi

    if [ ${OSTYPE} != "linux-gnu" ];
    then
        echo "Sorry is reserved to linux, install gcov by yourself"
        exit 2
    fi

    apt-get install lcov

    if ! type gcov &>/dev/null;
    then
        echo ""
        echo "Installation failed: try installing gcov by yourself"
        exit 3
    fi
}

# Compile C into an executable file adapted to gcov
# and run the file
# # #
compile_start() {

    NAME_OUTPUT=${1:0:-2}
    mkdir bin &>/dev/null
    cd bin && gcc -fprofile-arcs -ftest-coverage -o ${NAME_OUTPUT} -g ../$1 ../add.c
    ./${NAME_OUTPUT} &>/dev/null
}

# Launch gcov and modify the output of the coverage to 
# get something more readable
# # #
coverage() {

    gcov -f -k $1 -o bin/
}

# Clear the output files from gcov
# # #
clean_dir() {

    NAME_OUTPUT=${1:0:-2}
    rm -rf ${NAME_OUTPUT}.gc*
    rm -rf ${NAME_OUTPUT}.c.gc*
    rm -rf ${NAME_OUTPUT}
    rm -rf minunit.h.gc*
    rm -rf ./bin/*
}

if ! type gcov &>/dev/null;
then
    install
fi

if [ $# -lt 1 ];
then
    usage
    exit 4
fi

compile_start $1
coverage $1
clean_dir $1

exit 0
