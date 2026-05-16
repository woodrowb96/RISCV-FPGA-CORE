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

#If we in regression mode make sure the testlist actually exists
#and get the real path so we can use the path when we cd later
if [ -n "$UVM_TESTLIST" ] ; then
  if [ ! -f "$UVM_TESTLIST" ] ; then
    echo "#----------------------------------------------------------------------#"
    echo "ERROR: testlist not found: $UVM_TESTLIST"
    echo "#----------------------------------------------------------------------#"
    exit 1
  fi
  UVM_TESTLIST="$(realpath "$UVM_TESTLIST")"
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

#all outputs for this TB live under here
TB_OUTPUT_DIR="$XSIM_DIR/$TB_NAME"

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
#--------------------- Run Simulation: regression (-r) ----------------------------#
#----------------------------------------------------------------------------------#

if [ -n "$UVM_TESTLIST" ] ; then

  #Strip the path from the testlist so we have just the name
  TESTLIST_NAME=${UVM_TESTLIST##*/}
  TESTLIST_NAME=${TESTLIST_NAME%.*}

  #build directory names for regression testing
  REGRESSION_OUTPUT_DIR="$TB_OUTPUT_DIR/regression/$TESTLIST_NAME"
  LOG_DIR="$REGRESSION_OUTPUT_DIR/logs"
  COV_DB_DIR="$REGRESSION_OUTPUT_DIR/cov_db"
  COV_REPORT_DIR="$REGRESSION_OUTPUT_DIR/cov_report_merged"

  #clean up anything from previous runs
  rm -rf "$REGRESSION_OUTPUT_DIR"
  mkdir -p "$LOG_DIR" "$COV_DB_DIR"

  #parse testlist
  TESTS=()
  while IFS= read -r line ; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue #skip blank lines and comments
    TESTS+=("$line")
  done < "$UVM_TESTLIST"

  if [ ${#TESTS[@]} -eq 0 ] ; then
    echo "ERROR: testlist is empty: $UVM_TESTLIST"
    exit 1
  fi

  PASS=0
  FAIL=0
  FAILED_TESTS=()

  for test in "${TESTS[@]}" ; do
    echo "--- Running $test ---"

    #remove any prevous coverage runs
    rm -rf "$XSIM_DIR/xsim.covdb"

    XSIM_ARGS=("$TB_NAME" -testplusarg "UVM_TESTNAME=$test")
    if [ -n "$TCL_FILE" ] ; then
      XSIM_ARGS+=(-tclbatch "$TCL_FILE")
    else
      XSIM_ARGS+=(-runall)  #if now tcl file, just runall
    fi

    #run the test and dump the outputs to the log directory
    xsim "${XSIM_ARGS[@]}" 2>&1 | tee "$LOG_DIR/${test}.log"

    if grep -q "TEST PASSED" "$LOG_DIR/${test}.log" ; then
      PASS=$((PASS+1))
    else
      FAIL=$((FAIL+1))
      FAILED_TESTS+=("$test")
    fi

    #move coverage for this test run into its own directory
    if [ -d "$XSIM_DIR/xsim.covdb" ] ; then
      mv "$XSIM_DIR/xsim.covdb" "$COV_DB_DIR/${test}.covdb"
    fi
  done

  #merge coverage once after all tests complete
  if compgen -G "$COV_DB_DIR"/*.covdb > /dev/null ; then
    echo "#----------------------------------------------------------------------#"
    echo "MERGING COVERAGE"
    echo "#----------------------------------------------------------------------#"

    XCRG_ARGS=()
    for covdb in "$COV_DB_DIR"/*.covdb ; do
        XCRG_ARGS+=(-dir "$covdb")
    done
    XCRG_ARGS+=(-report_dir "$COV_REPORT_DIR" -report_format all)

    xcrg "${XCRG_ARGS[@]}"
  fi

  echo "#----------------------------------------------------------------------#"
  echo "REGRESSION SUMMARY"
  echo "#----------------------------------------------------------------------#"
  echo "PASSED: $PASS"
  echo "FAILED: $FAIL"
  if [ $FAIL -gt 0 ] ; then
    echo "Failed tests:"
    for t in "${FAILED_TESTS[@]}" ; do
      echo "  - $t"
    done
  fi

  #merged coverage summary from xcrg text report
  COV_TEXT_REPORT="$COV_REPORT_DIR/functionalCoverageReport/xcrg_func_cov_report.txt"
  if [ -f "$COV_TEXT_REPORT" ] ; then
    awk -F',' '/Coverage Score/ {gsub(/^ *| *$/, "", $2); print "MERGED COVERAGE: " $2 "%"}' "$COV_TEXT_REPORT"
    echo "Full report: $COV_REPORT_DIR/functionalCoverageReport/dashboard.html"
  fi
  echo "#----------------------------------------------------------------------#"

  if [ $FAIL -gt 0 ] ; then
    exit 1
  else
    exit 0
  fi
fi

#----------------------------------------------------------------------------------#
#--------------------- Run Simulation: single (-t or no-arg) ----------------------#
#----------------------------------------------------------------------------------#

#get the testname so we can build its directory
if [ -n "$UVM_TEST_NAME" ] ; then
  SINGLE_RUN_NAME="$UVM_TEST_NAME"
else
  SINGLE_RUN_NAME="default" #if its not a uvm_test then just use the default dir
fi

SINGLE_OUTPUT_DIR="$TB_OUTPUT_DIR/single/$SINGLE_RUN_NAME"
LOG_FILE="$SINGLE_OUTPUT_DIR/xsim.log"
COV_DB_PATH="$SINGLE_OUTPUT_DIR/cov.covdb"
COV_REPORT_DIR="$SINGLE_OUTPUT_DIR/cov_report"

#fresh slate for this single run
rm -rf "$SINGLE_OUTPUT_DIR"
mkdir -p "$SINGLE_OUTPUT_DIR"

#clean any stale covdb so the move below picks up only this run's
rm -rf "$XSIM_DIR/xsim.covdb"

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

xsim "${XSIM_ARGS[@]}" 2>&1 | tee "$LOG_FILE"

#move covdb to the per-run slot
if [ -d "$XSIM_DIR/xsim.covdb" ] ; then
  mv "$XSIM_DIR/xsim.covdb" "$COV_DB_PATH"
fi

#generate human-readable coverage report
if [ -d "$COV_DB_PATH" ] ; then
  xcrg -dir "$COV_DB_PATH" -report_dir "$COV_REPORT_DIR"
fi
