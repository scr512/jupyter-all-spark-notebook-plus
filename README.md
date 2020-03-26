# jupyter-all-spark-notebook-plus

# Docker image that builds/extends `jupyter/all-spark-notebook` to include things I find useful.

## What's added?
These are the configuration changes made to Jupyter:

---

* Everything from the source image `jupyter/all-spark-notebook` 
* Custom CSS to make the Jupyter Notebook UI correctly full-screen.
* Exasol client libraries
* MySQL client libaries
* Jupyter extensions
	* Hide code
	* QGrid
	* NBExtension

Example of the `Dockerfile` being used here to extend the base image.
```dockerfile
FROM jupyter/all-spark-notebook

MAINTAINER Jason Davis <scr512@gmail.com>

# Setup environment
WORKDIR /tmp

# Gotta get back to root
USER root

# Install needed ODBC and ZLIB libraries
RUN apt-get update; \
        apt-get install -y unixodbc unixodbc-dev zlib1g-dev libmysqlclient-dev 

# Grab Exasol libraries
RUN wget https://www.exasol.com/support/secure/attachment/79656/EXASOL_ODBC-6.0.15.tar.gz; \
	tar xvzf EXASOL_ODBC-6.0.15.tar.gz; \
	cp /tmp/EXASOL_ODBC-6.0.15/lib/linux/x86_64/* /usr/local/lib
ADD ./etc/odbcinst.ini /etc/odbcinst.ini

# Back to jovyan
USER jovyan

# Install things we like
RUN conda update conda
RUN conda install -c conda-forge -y \ 
	qgrid \
	jupyter_contrib_nbextensions \ 
	jupyter_nbextensions_configurator \
	hide_code \
	mysql \
	sqlalchemy \
	hdfs3 \
	pyexasol
RUN pip install \ 
        mysql-connector \
        sqlalchemy-exasol

# Enable Jupyter extensions
RUN jupyter contrib nbextension install --user; \
	jupyter nbextensions_configurator enable --user; \
	jupyter nbextension install --py hide_code; \
	jupyter nbextension enable --py hide_code; \
	jupyter serverextension enable --py hide_code; \
	jupyter nbextension install --sys-prefix --py hide_code; \
	jupyter nbextension enable --sys-prefix --py hide_code; \
	jupyter serverextension enable --sys-prefix --py hide_code; \
	jupyter nbextension enable --py --sys-prefix qgrid; \
	jupyter nbextension enable --py --sys-prefix widgetsnbextension

# Configure Jupyter to not have the stupid boarders
ADD ./jupyter/custom.css /home/jovyan/.jupyter/custom/custom.css

WORKDIR /home/jovyan

# Back to jovyan
USER jovyan
```
## Run
This will start a new Jupyter notebook environment listening on port 8888 with a default password of `jupyter`
```bash
docker run \
	-d \
	--restart=always \
	--name jupyter -v $(pwd):/home/jovyan/work \
	-p 8888:8888 \
	scr512/jupyter-all-spark-notebook-plus \
	start-notebook.sh --NotebookApp.password='sha1:f0c38ca1a943:b8c2f5b9c49dce6ad941776900950bae146e0f2b'
```
### Changing the default password
If you'd like to change this password, you can follow the documentation here:
https://jupyter-notebook.readthedocs.io/en/stable/public_server.html#preparing-a-hashed-password
