"""Generates a makefile for a ECI-based CFS application's tables

Usage
python genMakeFile.py
    Generates a table makefile for the app contained within the apps
    directory which contains this script.
python genMakeFile.py /path/to/apps/dir/of/target/app
    Generates a table makefile for the app contained within the apps
    directory passed as an argument.
    
This script must EITHER:
    - Be stored within the apps directory for which you wish 
    to generate a makefile (usually saved in 
    <app_name>/fsw/for_build)
    - Be called with the path of the target directory as the 
    first argument (any path within the app directory is fine)
"""


import os
import sys

# define makefile contents with format replacements
makefile_contents = """###############################################################################
#
# File: CFS Application Table Makefile 
#
# $Id: $
#
# $Log: $
#
###############################################################################
#
# The Application needs to be specified here
#
PARENTAPP = {appNameLower}

#
# List the tables that are generated here.
# Restrictions:
# 1. The table file name must be the same as the C source file name
# 2. There must be a single C source file for each table
#
{tblFiles}

##################################################################################
# Normally, nothing has to be changed below this line
# The following are changes that may have to be made for a custom app environment:
# 1. INCLUDE_PATH - This may be customized to tailor the include path for an app
# 2. VPATH - This may be customized to tailor the location of the table sources.
#            For example: if the tables were stored in a "tables" subdirectory
#                        ( build/cpu1/sch/tables )
#################################################################################

#
# Object files required for tables
#
OBJS = $(TABLES:.tbl=.o)

#
# Source files required to build tables.
#
SOURCES = $(OBJS:.o=.c)

##
## Specify extra C Flags needed to build this subsystem
##
LOCAL_COPTS = 

##
## EXEDIR is defined here, just in case it needs to be different for a custom
## build
##
EXEDIR=../exe

########################################################################
# Should not have to change below this line, except for customized 
# Mission and cFE directory structures
########################################################################

#
# Set build type to CFE_APP. This allows us to 
# define different compiler flags for the cFE Core and Apps.
# 
BUILD_TYPE = CFE_TABLE

## 
## Include all necessary cFE make rules
## Any of these can be copied to a local file and 
## changed if needed.
##
##
##       cfe-config.mak contians arch, BSP, and OS selection
##
include ../cfe/cfe-config.mak

##
##       debug-opts.mak contains debug switches -- Note that the table must be
##       built with -g for the elf2tbl utility to work.
##
include ../cfe/debug-opts.mak

##
##       compiler-opts.mak contains compiler definitions and switches/defines
##
include $(CFE_PSP_SRC)/$(PSP)/make/compiler-opts.mak

##
## Setup the include path for this subsystem
## The OS specific includes are in the build-rules.make file
##
## If this subsystem needs include files from another app, add the path here.
##
INCLUDE_PATH = \
-I$(OSAL_SRC)/inc \
-I$(CFE_CORE_SRC)/inc \
-I$(CFE_PSP_SRC)/$(PSP)/inc \
-I$(CFE_PSP_SRC)/inc \
-I$(CFS_APP_SRC)/inc \
-I$(CFS_APP_SRC)/$(PARENTAPP)/fsw/src \
-I$(CFS_APP_SRC)/eci/fsw/src \
-I$(CFS_MISSION_INC) \
-I../cfe/inc \
-I../inc \
-I../$(PARENTAPP)

##
## Define the VPATH make variable. 
## This can be modified to include source from another directory.
## If there is no corresponding app in the cfe-apps directory, then this can be discarded, or
## if the mission chooses to put the src in another directory such as "src", then that can be 
## added here as well.
##
VPATH = $(CFS_APP_SRC)/$(PARENTAPP)/fsw/tables

##
## Include the common make rules for building a cFE Application
##
include $(CFE_CORE_SRC)/make/table-rules.mak

"""

if __name__ == "__main__":

    # parse arguments
    # if provided, use the argument as the path containing
    # the app directory of the target apps
    if len(sys.argv) > 1:
        scriptPath = sys.argv[1]
    # otherwise use the location of this script
    else:
        scriptPath = os.path.realpath(__file__)

    # find apps dir within target path
    print("Found script path: {}".format(scriptPath))
    scriptPathList = scriptPath.split(os.sep)
    appIdx = scriptPathList.index("apps") + 1

    # error is there's no 'apps' directory within path, user
    # must've used this script incorrectly
    if appIdx is None:
        raise Exception("Could not find apps directory")

    # get apps path
    appPath = os.path.join(scriptPathList[0], *scriptPathList[1 : appIdx + 1])
    print('Found app path: "{}"'.format(appPath))

    # get app name based off directory name
    appNameLower = str(scriptPathList[appIdx]).lower()
    print('Found app name: "{}"'.format(appNameLower))

    # find src files of target app
    tablePath = os.path.join(appPath, "fsw", "tables")
    print('Found tables path: "{}"'.format(tablePath))
    tableFiles = [f for f in os.listdir(tablePath) if f.endswith(".c")]
    tblFilesList = [f.replace(".c", ".tbl") for f in tableFiles]

    # make list of source files for the makefile
    tblFilesStr = ""
    isFirst = True
    for file in tblFilesList:
        if isFirst:
            tblFilesStr = "TABLES := {}\n".format(file)
            isFirst = False
        else:
            tblFilesStr += "TABLES += {}\n".format(file)
        print('Found table file: "{}"'.format(file))

    # write the makefile
    buildPath = os.path.join(appPath, "fsw", "for_build")
    print("Found buildPath path: {}".format(buildPath))
    outFileName = str(os.path.join(buildPath, appNameLower + "tables.mak"))
    with open(outFileName, "w") as makefile:
        makefile.write(
            makefile_contents.format(appNameLower=appNameLower, tblFiles=tblFilesStr)
        )
