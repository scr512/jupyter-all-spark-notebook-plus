FROM jupyter/all-spark-notebook:584f43f06586
# Setup environment
WORKDIR /tmp

# Gotta get back to root
USER root

# Install needed ODBC, ZLIB and OpenLDAP libraries
RUN apt-get update; \
        apt-get install -y \
	unixodbc \
	unixodbc-dev \
	zlib1g-dev \
	libmysqlclient-dev \
	libldap-common \
	libldap2-dev \
	libsasl2-dev \
	cron 

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
	convertdate \
	lunarcalendar \
	holidays \
	pystan==2.19.1.1

RUN pip install \ 
        mysql-connector \
        sqlalchemy-exasol \
	openpyxl \
	python-ldap \
        Office365-REST-Python-Client==2.1.4 \
        pylint \
        fbprophet

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
	jupyter nbextension enable --py --sys-prefix widgetsnbextension; \
        ipython profile create && echo "c.InteractiveShellApp.extensions.append('sparkmonitor.kernelextension')" >>  $(ipython profile locate default)/ipython_kernel_config.py 

# Configure Jupyter to not have the stupid boarders
ADD ./jupyter/custom.css /home/jovyan/.jupyter/custom/custom.css

WORKDIR /home/jovyan

# Back to jovyan
USER jovyan
