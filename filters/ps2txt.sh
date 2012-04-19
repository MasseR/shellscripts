#!/bin/bash

PATH="$HOME/bin:$PATH:/usr/local/bin:$HOME/bin:." ; export PATH
progname="ps2txt.sh"


# check arguments
if [ $# -lt 1 ]
then
  printf '%s: usage: %s infile [outfile]\n' "$progname" "$progname" 1>&2
  exit 1
fi
infile="$1"
outfile="$2"
if [ -n "$ESTORIGFILE" ] && [ -f "$ESTORIGFILE" ]
then
  infile="$ESTORIGFILE"
fi


# check the input
if [ "!" -f "$infile" ]
then
  printf '%s: %s: no such file\n' "$progname" "$infile" 1>&2
  exit 1
fi


# initialize the output file
if [ -n "$outfile" ]
then
  rm -f "$outfile"
fi


# function to output
output(){
  if [ -n "$outfile" ]
  then
    cat >> "$outfile"
  else
    cat
  fi
}


# limit the resource
ulimit -v 262144 -t 10 2> "/dev/null"


# output the result
pstotext "$infile" - 2> "/dev/null" | output


# exit normally
exit 0

