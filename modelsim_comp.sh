#!/bin/bash

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


if [ -z $1 ] ; then
  echo 'no file specified'
  echo $'enter file\n'
else
  vlog $PROJECT_ROOT_DIR/$1
fi
