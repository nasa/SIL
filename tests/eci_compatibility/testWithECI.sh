#!/usr/bin/env bash
# intended to be run from root of repo and will end at root of repo

# enable exit on error when in CI environment
if [[ "$CI" == true ]]; then 
	set -e 
fi

## move to test directory
cwd=$(pwd)
cd tests/eci_compatibility

## get ECI from repo
# Note: getting testing branch for now, eventually get master when its moved
rm -rf ./ECI
git clone --single-branch --branch master https://github.com/nasa/ECI ./ECI 

## get CFE (using ECI CI script)
. ./ECI/ci/fetchCFE.sh

## integrate generated code
cfsDir=./cfs
appsDir=$cfsDir/apps
silTestDir=$appsDir/siltest

# copy generated source code
mkdir -p $silTestDir/fsw/src
unzip ./generatedCode.zip -d $silTestDir/fsw/src

# copy tables
mkdir -p $silTestDir/fsw/tables
grep ECI_TBL_FILEDEF $silTestDir/fsw/src/*.c -l | xargs mv -t $silTestDir/fsw/tables

# generate makefile
mkdir -p $silTestDir/fsw/for_build
python3 genMakeFile.py $silTestDir/fsw/for_build
python3 genTblMakeFile.py $silTestDir/fsw/tables

# copy perfID header
mkdir -p $silTestDir/fsw/platform_inc
cp ./sil_app_msgids.h $silTestDir/fsw/platform_inc/sil_app_msgids.h

# copy msgID header
mkdir -p $silTestDir/fsw/mission_inc
cp ./sil_app_perfids.h $silTestDir/fsw/mission_inc/sil_app_perfids.h

# copy ECI source code to CFS apps dir 
mkdir -p $appsDir/eci/fsw
cp -r ./ECI/fsw/* $appsDir/eci/fsw/

# integrate new app with cfs
cd $cfsDir
# make any code changes needed to integrate this app
# ensure CFS builds new app we added
sed -i '44a THE_APPS += siltest' ./build/cpu1/Makefile
sed -i '50a THE_TBLS += siltest' ./build/cpu1/Makefile
# configure the app to run when CFS starts
sed -i '5a CFE_APP, /cf/apps/siltest.so,          siltest_AppMain,     SILTest,       90,   8192, 0x0, 0;' ./build/cpu1/exe/cfe_es_startup.scr
sed -i '26a #include "sil_app_msgids.h"' ./apps/sch_lab/fsw/platform_inc/sch_lab_sched_tab.h
sed -i '74a      { SILTEST_TICK_MID,   1, 0 },' ./apps/sch_lab/fsw/platform_inc/sch_lab_sched_tab.h
# update makefile to include math library
sed -i '42s/.*/\t$(COMPILER) -m32 -shared -o $@ $(OBJS) -lm/' ./psp/fsw/pc-linux/make/link-rules.mak
# Note: this should be a temporary fix until its determined how to
# add a library via a supported mechanism

# prepare environment
. ./setvars.sh
cd ./build/cpu1

# compile CFS
make clean
make config
make

cd exe

# run CFS for 5 sec to view initialization
timelimit -t 5 -T 5 -s 2 ./core-linux.bin | tee output.file

echo "Looking for failures:"
if ! grep 'Could not load' -i output.file; then
    echo "Found a failure to start in the log"
    # exit with error if CI
    if [[ "$CI" == true ]]; then 
        exit 1
    fi
fi
if ! grep 'Error' -i output.file; then
    echo "Found an error in the log"
    # exit with error if CI
    if [[ "$CI" == true ]]; then 
        exit 1
    fi
fi

# return to root
cd $cwd

