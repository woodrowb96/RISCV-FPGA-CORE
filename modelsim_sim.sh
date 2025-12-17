#!/bin/bash

if [ -z $1 ] ; then
  echo "no file specified"
  echo "enter file"
  exit 1
fi

TEST_BENCH_PATH=$1
TEST_BENCH_FILE=${TEST_BENCH_PATH##*/}
TEST_BENCH=${TEST_BENCH_FILE%.*}
TEST_BENCH_PARENT_DIR=${TEST_BENCH_PATH%/*}
PROJECT_ROOT_DIR=$(pwd)

if [ ! -d 'sim' ] ; then 
  echo "no simulation directory found"
  echo $'creating ./sim directory\n'
  mkdir sim
fi

cd sim

if [ ! -d 'modelsim' ] ; then 
  echo "no modelsim directory found"
  echo $'creating ./simulation/modelsim directory\n'
  mkdir modelsim
fi

cd modelsim

if [ ! -d 'work' ] ; then 
  echo "no modelsim work directory found"
  echo $'creating ./simulation/modelsim/work directory\n'
  vlib work
fi

echo "COMPILING TEST BENCH: $TEST_BENCH_FILE"
echo $'\n'
vlog $PROJECT_ROOT_DIR/$TEST_BENCH_PATH
echo $'\n'

echo "COMPILING RTL FILES:"
vlog $PROJECT_ROOT_DIR/rtl/*.sv
echo $'\n'

echo "SIMULATING TEST BENCH: $TEST_BENCH_FILE"
vsim $TEST_BENCH -quiet -do $PROJECT_ROOT_DIR/do/$TEST_BENCH.do
