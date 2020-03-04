#!/bin/sh
docker build -t edgestream_sdk_tutorial .
docker run -it --rm -v $PWD/_build:/usr/local/work/_build -w /usr/local/work edgestream_sdk_tutorial make html
open _build/html/index.html
