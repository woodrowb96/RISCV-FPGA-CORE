#!/usr/bin/env bash

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

#TODO: get this all fleshed out later
print_usage()
{
  cat <<EOF
Usage: $SCRIPT_NAME <tb_file> [options]

Run '$SCRIPT_NAME -h' for help

EOF
}

#Print options message
print_options() 
{
  cat <<EOF
Options:
  -t <test_name>      Run a single UVM test
  -r <testlist_file>  Run UVM regression
  -g                  Run simulation using the gui (only works in -t mode)
  -h                  Print help
EOF
}

#TODO: rewrite at the end
print_help() 
{
  print_usage
  print_options
  cat <<EOF
Description:
  Script will simulate the <tb_file> testbench.

  By default script will run the simulation in cli mode, and will attempt to use the
  testbench's default tcl file (tcl file named <tb_file>.tcl, located in tcl directory).
  If no default do file exists, simulation will run without a tcl file.

Note:
  Script should be placed in, and run from the projects root directory.

EOF
}

#-----------------------------------------------------------------------#
#--------------------------- Directory Vars ----------------------------#
#-----------------------------------------------------------------------#

PROJECT_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM_DIR="$PROJECT_ROOT_DIR/sim"
XSIM_DIR="$SIM_DIR/xsim"
XSIM_WORKING_DIR="$XSIM_DIR/xsim.dir/work"
SCRIPTS_DIR="$PROJECT_ROOT_DIR/scripts/xsim"


#-----------------------------------------------------------------------#
#------------- Make sure we are running in proj root dit ---------------#
#-----------------------------------------------------------------------#

if [ "$(pwd)" != "$PROJECT_ROOT_DIR" ] ; then
  echo "Error: Please run script from project root directory"
  print_usage
  exit 1
fi

#-----------------------------------------------------------------------#
#--------------------------- Parse Options -----------------------------#
#-----------------------------------------------------------------------#

TB_PATH=""
UVM_TEST_NAME=""
UVM_TESTLIST=""
GUI_MODE="false"

if [[ $# == 0 ]] ; then
  print_usage
  exit 1
fi

case "$1" in
  -h|--help)
    print_help
    exit 0
    ;;
  -*)
    echo "Error: TB name required as first argument"
    print_usage
    exit 1
    ;;
  *)
    TB_PATH="$1"
    shift
    ;;
esac

while getopts ":t:r:gh" FLAG; do
  case "$FLAG" in
    t) UVM_TEST_NAME="$OPTARG" ;;
    r) UVM_TESTLIST="$OPTARG" ;;
    g) GUI_MODE="true" ;;
    h) print_help; exit 0 ;;
    :) echo "Error: -$OPTARG missing argument"; exit 1 ;;
    \?) echo "Error: unknown option -$OPTARG"; exit 1 ;;
  esac
done

shift $((OPTIND-1))

if [ $# -gt 0 ] ; then
  echo "Error: unexpected arguments: $@"
  print_usage
  exit 1
fi

#We cant run it -t and -r modes at the same time
if [[ -n "$UVM_TEST_NAME" && -n "$UVM_TESTLIST" ]] ; then
  echo "Error: -t and -r are mutually exclusive"
  echo "(cannot run single test and regression together)"
  print_usage
  exit 1
fi

#We cant run gui in FILELIST MODE
if [[ -n "$UVM_TESTLIST" && "$GUI_MODE" == "true" ]] ; then
  echo "Error: cant have -g set in -r mode"
  echo "(Cant run the gui when running in regression mode)"
  print_usage
  print_options
  exit 1
fi

#----------------------------------------------------------------------------------#
#-------------------------- Derive TB arguments -----------------------------------#
#----------------------------------------------------------------------------------#

TB_NAME=${TB_PATH##*/}  #strip path from TB_NAME
TB_NAME=${TB_NAME%.*}   #strip .sv from TB_NAME

#----------------------------------------------------------------------------------#
#-------------------------- Find default TCL script -------------------------------#
#----------------------------------------------------------------------------------#

TCL_FILE=""
if [[ -f "$SCRIPTS_DIR/$TB_NAME.tcl" ]] ; then  #if default tcl file exists
  TCL_FILE="$SCRIPTS_DIR/$TB_NAME.tcl"
else
  echo "#----------------------------------------------------------------------#"
  echo "WARNING:  Default TCL file ($TB_NAME.tcl) not found."
  echo "          Running sim with no tcl file"
  echo "#----------------------------------------------------------------------#"
  echo $'\n'
fi

#----------------------------------------------------------------------------------#
#-------------------------------- Find filelist -----------------------------------#
#----------------------------------------------------------------------------------#

if [[ -f "$SCRIPTS_DIR/filelist/$TB_NAME.f" ]] ; then #If filelist exists
  FILELIST="$SCRIPTS_DIR/filelist/$TB_NAME.f"
else
  echo "#----------------------------------------------------------------------#"
  echo "ERROR: Missing filelist $TB_NAME.f"
  echo "#----------------------------------------------------------------------#"
  echo $'\n'
  exit 1
fi

#----------------------------------------------------------------------------------#
#---------- Split out cpp and sv files dependencies into sep filelists ------------#
#----------------------------------------------------------------------------------#

FILELIST_SV="/tmp/${TB_NAME}_files_sv.f"
FILELIST_CPP="/tmp/${TB_NAME}_files_cpp.f"

#cleanup any stale temp files
trap 'rm -f "$FILELIST_SV" "$FILELIST_CPP"' EXIT

if [ -f "$FILELIST" ] ; then
  grep '\.sv' "$FILELIST" > "$FILELIST_SV"
  grep '\.cpp' "$FILELIST" > "$FILELIST_CPP"
fi

#----------------------------------------------------------------------------------#
#----------------------- Ensure the sim directory exists --------------------------#
#----------------------------------------------------------------------------------#

#Check if sim directory exists at project root, if not the create it
if [ ! -d "$SIM_DIR" ] ; then 
  echo "no simulation directory found"
  echo $'creating ./sim directory\n'
  mkdir -p "$SIM_DIR"
fi

#Check if xsim directory exists in sim dir, if not create it
if [ ! -d "$XSIM_DIR" ] ; then
  echo "no xsim directory found"
  echo $'creating ./sim/xsim directory\n'
  mkdir -p "$XSIM_DIR"
fi

#----------------------------------------------------------------------------------#
#--------------------------- Compile CPP files ------------------------------------#
#----------------------------------------------------------------------------------#

if [ -s "$FILELIST_CPP" ] ; then  #if the cpp filelist is not empty
  echo "#----------------------------------------------------------------------#"
  echo "COMPILING FILELIST: $TB_NAME.f .cpp dependencies"
  echo "#----------------------------------------------------------------------#"
  echo $'\n'

  #move into the xsim dir
  #(I do this since im having trouble getting --work to work with xsc.
  # In the future ill maybe clean this up)
  cd "$XSIM_DIR"

  #prepend the absolute path to each cpp file, then compile
  xsc $(cat "$FILELIST_CPP" | sed "s|^|$PROJECT_ROOT_DIR/|")

  #exit if the comp failed
  if [ $? -ne 0 ] ; then
    echo $'\n'
    echo "ERROR $SCRIPT_NAME: $FILELIST CPP compilation failed"
    exit 1
  fi

  #move back to the root
  cd "$PROJECT_ROOT_DIR"

  echo $'\n'
fi

#----------------------------------------------------------------------------------#
#--------------------------- Compile SV files ------------------------------------#
#----------------------------------------------------------------------------------#

if [ -s "$FILELIST_SV" ] ; then  #if the sv filelist is not empty
  echo "#----------------------------------------------------------------------#"
  echo "COMPILING FILELIST: $FILELIST sv dependencies"
  echo "#----------------------------------------------------------------------#"
  echo $'\n'
  xvlog -sv -L uvm --work work="$XSIM_WORKING_DIR" --log "$XSIM_DIR/xvlog.log" -f "$FILELIST_SV"

  #If we failed to compile the dependencies, then dont run the sim
  if [ $? -ne 0 ] ; then
    echo "#----------------------------------------------------------------------#"
    echo "ERROR $SCRIPT_NAME: $FILELIST SV compilation failed"
    echo "#----------------------------------------------------------------------#"
    echo $'\n'
    exit 1
  fi
  echo $'\n'
fi

#----------------------------------------------------------------------------------#
#--------------------------- Compile TB_NAME  ----------------------------------#
#----------------------------------------------------------------------------------#

echo "COMPILING TEST BENCH: $TB_NAME"
echo $'\n'
xvlog -sv -L uvm --work work="$XSIM_WORKING_DIR" --log "$XSIM_DIR/xvlog.log" "$PROJECT_ROOT_DIR/$TB_PATH"

#If we failed to compile the tb, then dont run the sim
if [ $? -ne 0 ] ; then
  echo "#----------------------------------------------------------------------#"
  echo "ERROR $SCRIPT_NAME: $TB_NAME compilation failed"
  echo "#----------------------------------------------------------------------#"
  echo $'\n'
  exit 1
fi
echo $'\n'

#----------------------------------------------------------------------------------#
#--------------------------- Elaborate TB_NAME  --------------------------------#
#----------------------------------------------------------------------------------#

cd "$XSIM_DIR" || exit 1

echo "#----------------------------------------------------------------------#"
echo "ELABORATING TEST BENCH: $TB_NAME"
echo "#----------------------------------------------------------------------#"
echo $'\n'

#if we have cpp files, elab with dpi else just do normal elab
if [ -s "$FILELIST_CPP" ] ; then 
  xelab -L uvm $TB_NAME -debug typical -sv_lib "xsim.dir/work/xsc/dpi"
else
  xelab -L uvm $TB_NAME -debug typical
fi

#If we failed the elaboration, then dont run the sim
if [ $? -ne 0 ] ; then
  echo "#----------------------------------------------------------------------#"
  echo "ERROR $SCRIPT_NAME: elaboration failed"
  echo "#----------------------------------------------------------------------#"
  echo $'\n'
  exit 1
fi
echo $'\n'

#----------------------------------------------------------------------------------#
#------------------------------ Run Simulation ------------------------------------#
#----------------------------------------------------------------------------------#

echo "#----------------------------------------------------------------------#"
echo "SIMULATING TEST BENCH: $TB_NAME"
echo "#----------------------------------------------------------------------#"
echo $'\n'

XSIM_ARGS=("$TB_NAME")

if [ "$GUI_MODE" = "true" ] ; then
  XSIM_ARGS+=(-gui)
fi

if [ -n "$TCL_FILE" ] ; then
  XSIM_ARGS+=(-tclbatch "$TCL_FILE")
elif [ "$GUI_MODE" = "false" ] ; then
  XSIM_ARGS+=(-runall)
fi

if [ -n "$UVM_TEST_NAME" ] ; then
  XSIM_ARGS+=(-testplusarg "UVM_TESTNAME=$UVM_TEST_NAME")
fi

if [ -n "$UVM_TESTLIST" ]; then
    echo "Regression mode not yet implemented"
    exit 0
fi

xsim "${XSIM_ARGS[@]}"
