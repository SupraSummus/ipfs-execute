#!/bin/sh
DIR=$(ipfs object new unixfs-dir)

while test ${#} -gt 0; do
  DIR=$(ipfs object patch add-link "$DIR" "$1" "$2")
  shift 2
done

echo $DIR
