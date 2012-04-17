#!/bin/bash

# Filter for gzipped files. Uses `file` to guess the file type

PATH="$HOME/bin:$PATH:/usr/local/bin:$HOME/bin:." ; export PATH
progname="gzip2txt.sh"


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
type=$(gunzip -c "$infile" | file -)

# Troff
troff=$(echo $type | grep -ci "troff")
if [ $troff -gt 0 ]; then
    # Is a troff file, so use the hyperestraier troff filter
    /usr/share/hyperestraier/filter/estfxmantotxt "$infile" "$outfile"
    exit $?
fi

# The last check, check if it's plain ascii, if not, exit here
ascii=$(echo $type | grep -ci "ascii")
if [ $ascii -lt 1 ]; then
    echo "Not a text file"
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
    gunzip -c "$infile" >> "$outfile"
  else
    gunzip -c
  fi
}


# limit the resource
ulimit -v 262144 -t 10 2> "/dev/null"


# output the result
cat "$infile" 2> "/dev/null" | output


# exit normally
exit 0
