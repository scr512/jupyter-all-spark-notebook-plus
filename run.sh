#!/bin/bash
docker run \
	-d \
	--restart=always \
	--name jupyter -v $(pwd):/home/jovyan/work \
	-p 8888:8888 \
	scr512/jupyter-all-spark-notebook-plus \
	start-notebook.sh --NotebookApp.password='sha1:f0c38ca1a943:b8c2f5b9c49dce6ad941776900950bae146e0f2b'
