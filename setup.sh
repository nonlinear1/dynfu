#!/bin/sh

RUN_CMAKE=false
RUN_MAKE=false
RUN_COVERAGE=false
RUN_SET_PATHS=false
RUN_INSTALL_DEPENDENCIES=false
QUIET=false

usage() {
    echo "USAGE: source setup.sh [options]"
    echo "OPTIONS:"
    echo "\t--help                 -h: Display help"
    echo "\t--set-paths            -p: Setup the enviroment path"
    echo "\t--cmake                -c: Run CMake"
    echo "\t--coverage             -v: Generate Coverage Report"
    echo "\t--make                 -m: Run make"
    echo "\t--quiet                -q: Set quiet option"
    echo "\t--all                  -a: Run all the settings"
}

# Parse through the arguments and check if any relavant flag exists
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        -p | --set-paths)
            RUN_SET_PATHS=true
            ;;
        -i | --install-dependencies)
            RUN_INSTALL_DEPENDENCIES=true
            ;;
        -c | --cmake)
            RUN_CMAKE=true
            ;;
        -m | --make)
            RUN_MAKE=true
            ;;
        -v | --coverage)
            RUN_COVERAGE=true
            ;;
        -a | --all)
            RUN_SET_PATHS=true
            RUN_INSTALL_DEPENDENCIES=true
            RUN_CMAKE=true
            RUN_MAKE=true
            ;;
        -q | --quiet)
            QUIET=true
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            return 1
            ;;
    esac
    shift
done

# If build does not exist create one
mkdir -p build
cd build

if $RUN_SET_PATHS
then
    # Set the enviroment
    echo "Setting up the enviroment paths"
    export PATH=$PATH:/vol/project/2017/362/g1736211/
    source /vol/cuda/8.0.44/setup.sh
    export CUDA_HOME=$CUDA_PATH
    echo "CUDA_HOME set to $CUDA_HOME"
fi

if $RUN_INSTALL_DEPENDENCIES &&  [ ! -d terra ]
then
    # Install terra dependency
    echo "Missing terra dependency, installing terra ..."

    if ! $QUIET
    then
        wget https://github.com/zdevito/terra/releases/download/release-2016-03-25/terra-Linux-x86_64-332a506.zip
        unzip terra-Linux-x86_64-332a506.zip
    else
        wget https://github.com/zdevito/terra/releases/download/release-2016-03-25/terra-Linux-x86_64-332a506.zip >/dev/null 2>&1
        unzip terra-Linux-x86_64-332a506.zip >/dev/null 2>&1
    fi

    # Save the binary files into appropiate name and reference it in a PATH
    mv terra-Linux-x86_64-332a506 terra
    export PATH=$PATH:$(pwd)/terra/bin
    echo "Installing terra complete"
fi

if $RUN_INSTALL_DEPENDENCIES && [ ! -d Opt ]
then
    # Install Opt dependency
    echo "Missing Opt, installing Opt ..."
    # TODO use sed to automatically fix Opt
    # Currently uses local file stored in shared drive, customised for the lab machine
    cp -r /vol/project/2017/362/g1736211/DynamicFusionOpt .
    mv DynamicFusionOpt Opt
    cd Opt/API
    if ! $QUIET
    then
        make  || (cd ../ && return 1)
    else
        make >/dev/null 2>&1 || (cd ../ && return 1)
    fi
    cd ../..
    echo "Installing Opt complete"
fi

if $RUN_CMAKE
then
    echo "Running CMake ..."
    if ! $QUIET
    then
        cmake -DCMAKE_PREFIX_PATH="/vol/project/2017/362/g1736211/share/OpenCV" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DBUILD_TESTS=ON .. || (cd ../ && return 1)
    else
        cmake -DCMAKE_PREFIX_PATH="/vol/project/2017/362/g1736211/share/OpenCV" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DBUILD_TESTS=ON .. >/dev/null 2>&1 || (cd ../ && return 1)
    fi
fi

if $RUN_MAKE
then
    echo "Running make ..."
    if ! $QUIET
    then
        make -j4 || (cd ../ && return 1)
    else
        make -j4 >/dev/null 2>&1 || (cd ../ && return 1)
    fi
    echo "Make complete!"
fi

if $RUN_COVERAGE
then
    echo "Generating coverage report ..."
    if ! $QUIET
    then
        make coverage -j4 || (cd ../ && return 1)
    else
        make coverage -j4 >/dev/null 2>&1 || (cd ../ && return 1)
    fi
    echo "Coverage Report generation complete!"
fi
cd ..
