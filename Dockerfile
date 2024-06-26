# This image includes Apache Spark 3.3.2
# Be aware of version compatibility issues if bumping it.
# For example, the latest version of Delta Lake doesn't work with Apache Spark 3.4
#
# To determine the version of Spark in the base image, see the relevant information
# on Docker Hub (https://hub.docker.com/r/jupyter/pyspark-notebook/tags?page=1&name=notebook)
#
# For example https://hub.docker.com/layers/jupyter/pyspark-notebook/notebook-6.5.3/images/sha256-661613756e04df5ec9f00e49fe202b25a0f992c05f575d9608820528fa1db369?context=explore 
# has `spark_version=3.3.2`
FROM jupyter/all-spark-notebook:notebook-6.5.3

ENV HADOOP_AWS_VERSION=3.3.1
ENV AWS_SDK_VERSION=1.11.901

USER root

RUN wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_VERSION}/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar -O ${SPARK_HOME}/jars/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar \
    && wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_VERSION}/hadoop-aws-${HADOOP_AWS_VERSION}.jar -O ${SPARK_HOME}/jars/hadoop-aws-${HADOOP_AWS_VERSION}.jar

USER $NB_UID

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt \
    && rm requirements.txt

# Set up iPython pretty tables and Spark SQL magic
RUN mkdir -p /home/jovyan/.ipython/profile_default/startup
COPY ipython/startup/00-prettytables.py /home/jovyan/.ipython/profile_default/startup
COPY ipython/startup/README /home/jovyan/.ipython/profile_default/startup

# Set environment vars so that pyspark is available outside of Jupyter
ENV PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.5-src.zip:$PYTHONPATH

# Disable the "Would you like to receive official Jupyter news?" popup
RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements"