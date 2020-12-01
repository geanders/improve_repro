#!/bin/sh 
# project_mkdir.sh
# Create an initial project directory structure for "project_name",
# and start version control with an initial gitignore file. 

if [ $# = 0 ]; then
  echo  
  echo  "  Usage: project_mkdir.sh project_name project_gitignore"
  echo  
exit 0
fi

PROJECT_DIR=$HOME"/W/"
timestamp=`date +%Y%b%d`  

# Project name and gitignore file
proj_name=$1
proj_gitignore=$2

# Project directory 
proj_dir_name=$PROJECT_DIR$proj_name  

  mkdir -p  $proj_dir_name/bin
  mkdir -p  $proj_dir_name/data
  mkdir -p  $proj_dir_name/doc/manuscript
  mkdir -p  $proj_dir_name/doc/notes
  mkdir -p  $proj_dir_name/results
  mkdir -p  $proj_dir_name/src/C/mcsim/sim/
  mkdir -p  $proj_dir_name/src/C/nsga
  mkdir -p  $proj_dir_name/src/R
  mkdir -p  $proj_dir_name/src/sql
  mkdir -p  $proj_dir_name/src/gnuplot
  mkdir -p  $proj_dir_name/src/shell

# Project description text file
  touch $proj_dir_name/"$proj_name"_"$timestamp.txt"

# Initialize a git repository for version control
  git init $proj_dir_name

# Copy an initial gitignore file to project directory
  cp $proj_gitignore $proj_dir_name/.gitignore
