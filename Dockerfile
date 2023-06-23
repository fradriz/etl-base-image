FROM python:3.7-slim-buster

ARG ENVIRONMENT=TEST
ARG SCALA_VERSION=2.12
ARG SPARK_HOME=/opt/spark
ARG SPARK_VERSION=3.1.3
ARG SPARK_XML_VERSION=0.12.0
ARG SPARK_EXCEL_VERSION=3.3.1_0.18.5
ARG HADOOP_VERSION_SHORT=3.2
ARG HADOOP_VERSION=3.2.0
ARG AWS_SDK_VERSION=1.11.375
ARG DELTA_LAKE_VERSION=1.0.0

# Installing OpenJDK8 from adoptopenjdk repo
RUN apt-get update -y && \
    apt-get install -y wget gnupg software-properties-common && \
    wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && \
    apt-get update -y && \
    apt-get install -y adoptopenjdk-8-hotspot

RUN apt-get update -y && apt-get install -y git

# Download and extract Spark (dlcn does not contain all the spark versions ..)
# RUN wget -qO- https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT}.tgz | tar zx -C /opt && \
# mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT} ${SPARK_HOME}

RUN wget -qO- https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT}.tgz | tar zx -C /opt && \
mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT} ${SPARK_HOME}


# Add hadoop-aws and aws-sdk
RUN wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar -P ${SPARK_HOME}/jars/ && \
    wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_VERSION}/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar -P ${SPARK_HOME}/jars/ && \
    wget https://repo1.maven.org/maven2/io/delta/delta-core_${SCALA_VERSION}/${DELTA_LAKE_VERSION}/delta-core_${SCALA_VERSION}-${DELTA_LAKE_VERSION}.jar -P ${SPARK_HOME}/jars/ && \
    wget https://repo1.maven.org/maven2/com/databricks/spark-xml_${SCALA_VERSION}/${SPARK_XML_VERSION}/spark-xml_${SCALA_VERSION}-${SPARK_XML_VERSION}.jar -P ${SPARK_HOME}/jars/ && \
    wget https://repo1.maven.org/maven2/com/crealytics/spark-excel_${SCALA_VERSION}/${SPARK_EXCEL_VERSION}/spark-excel_${SCALA_VERSION}-${SPARK_EXCEL_VERSION}.jar -P ${SPARK_HOME}/jars/

# Configure Spark to respect IAM role given to container
RUN if [[ "$ENVIRONMENT" = "DEV" ]] ; then echo spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.profile.ProfileCredentialsProvider > ${SPARK_HOME}/conf/spark-defaults.conf ; \
    else echo spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.EC2ContainerCredentialsProviderWrapper > ${SPARK_HOME}/conf/spark-defaults.conf ; fi

# Setting env variables in the container
ENV SPARK_HOME=${SPARK_HOME}
ENV PATH="${SPARK_HOME}/bin:${PATH}"
ENV PYSPARK_PYTHON=python3

# Storing repo files for future references
COPY . /usr/etl-base-image
