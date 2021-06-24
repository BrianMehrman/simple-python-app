#!/bin/bash
echo "Before getopt"
for i
do
  echo $i
done
args=`getopt d:d $*`
set -- $args
echo "After getopt"
for i
do
  echo "-->$i"
done
 