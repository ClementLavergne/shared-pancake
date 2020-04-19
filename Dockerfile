FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y \
    graphviz \
    make \
    openjdk-11-jre \
    ruby \
    texlive-font-utils \
    texlive-latex-extra \
    texlive-xetex \
    wget

# Project options
ARG project_name=shared-pancake
ARG tools_folder=downloads
ARG pandoc_version=2.9.2.1
ARG plantuml_version=1.2020.6
ARG jq_version=1.6

# Environment variables
ENV JAVA_HOME /usr/bin/java
ENV PLANTUML /${project_name}/${tools_folder}/plantuml.jar

# Folders creation
RUN mkdir           ${project_name}
RUN mkdir           ${project_name}/${tools_folder}

# Download and install pandoc
RUN wget -O ${project_name}/${tools_folder}/pandoc.deb https://github.com/jgm/pandoc/releases/download/${pandoc_version}/pandoc-${pandoc_version}-1-amd64.deb && \
    dpkg -i ${project_name}/${tools_folder}/pandoc.deb && \
    rm ${project_name}/${tools_folder}/pandoc.deb

# Download plantuml
RUN wget -O $PLANTUML https://sourceforge.net/projects/plantuml/files/${plantuml_version}/plantuml.${plantuml_version}.jar/download

# Download and install jq
RUN wget -O /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-${jq_version}/jq-linux64 && \
    chmod +x /usr/local/bin/jq

# Copy tool
ADD Makefile        ${project_name}/Makefile
ADD script          ${project_name}/script
ADD markdown        ${project_name}/markdown
ADD example         ${project_name}/example

WORKDIR ${project_name}