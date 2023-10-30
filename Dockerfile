
FROM jupyter/scipy-notebook:python-3.10
USER root

ENV SPARK_VERSION="3.0.0"
ENV AUT_VERSION="0.91.0"
ENV GRAPHFRAMES_VERSION="0.8.2"
ENV GRAPHFRAMES_SCALA_VERSION="2.12"

ENV PYTHON_VERION="3.10"
ENV JAVA_VERSION="11"
ENV JAVA_HOME="/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64"


#------------------------------------------
# APPS_HOME folder
#------------------------------------------
ENV APPS_HOME="/content/apps"
RUN mkdir -p ${APPS_HOME}


#------------------------------------------
# JAVA & TOOLS
#------------------------------------------
RUN apt-get -y update \
 && apt-get install --no-install-recommends -y \
    zip   \
    "openjdk-${JAVA_VERSION}-jdk-headless" \
 && apt-get clean  \
 && rm -rf /var/lib/apt/lists/*


#------------------------------------------
# PySPARK
#------------------------------------------
ENV SPARK_HOME="/opt/conda/lib/python${PYTHON_VERION}/site-packages/pyspark"
RUN pip install "pyspark==${SPARK_VERSION}" \
                findspark


#------------------------------------------
# ARCHIVES UNLEASHED TOOLKIT
#------------------------------------------
RUN wget "https://github.com/archivesunleashed/aut/releases/download/aut-${AUT_VERSION}/aut-${AUT_VERSION}.zip" \
 && wget "https://github.com/archivesunleashed/aut/releases/download/aut-${AUT_VERSION}/aut-${AUT_VERSION}-fatjar.jar" \
 && mv aut-* ${APPS_HOME}


#------------------------------------------
# GRAPHFRAMES lib
#------------------------------------------
RUN GRAPHFRAMES_SPARK_VERSION="${GRAPHFRAMES_VERSION}-spark${SPARK_VERSION:0:-2}-s_${GRAPHFRAMES_SCALA_VERSION}" \
  && wget "https://repos.spark-packages.org/graphframes/graphframes/${GRAPHFRAMES_SPARK_VERSION}/graphframes-${GRAPHFRAMES_SPARK_VERSION}.jar" \
  && jar -xf   "graphframes-${GRAPHFRAMES_SPARK_VERSION}.jar" graphframes \
  && zip -r    "graphframes-${GRAPHFRAMES_SPARK_VERSION}.zip" graphframes \
  && rm -r graphframes \
  && mv graphframes-* ${APPS_HOME}


#------------------------------------------
# JUPYTER config
#------------------------------------------
RUN echo 'c.NotebookApp.allow_origin = "https://colab.research.google.com"'   >> /home/jovyan/.jupyter/jupyter_notebook_config.py \
 && echo 'c.NotebookApp.port_retries = 0'     >> /home/jovyan/.jupyter/jupyter_notebook_config.py \
 && echo 'c.NotebookApp.open_browser = False' >> /home/jovyan/.jupyter/jupyter_notebook_config.py \
 && echo 'c.NotebookApp.base_url     = "/"'   >> /home/jovyan/.jupyter/jupyter_notebook_config.py \
 && echo 'c.NotebookApp.ip           = "*"'   >> /home/jovyan/.jupyter/jupyter_notebook_config.py \
 && echo 'c.NotebookApp.root_dir     = "/content"' >> /home/jovyan/.jupyter/jupyter_notebook_config.py 
 

#------------------------------------------
# GOOGLE CLOUD TOOLS 
#------------------------------------------
RUN apt-get -y update \
 && apt-get install --no-install-recommends -y \
    curl \
    apt-transport-https \
    ca-certificates \
    gnupg \
 && echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
 && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -  \
 && apt-get update && apt-get install -y \
    google-cloud-cli \
 && apt-get clean  \
 && rm -rf /var/lib/apt/lists/*


#------------------------------------------
# PYTHON libs
#------------------------------------------
RUN pip install -U pip setuptools wheel \
 && pip install -U spacy \
 && python -m spacy download en_core_web_sm

RUN pip install \
        tldextract  \
        plotly==5.17.0 \
        ipycytoscape
