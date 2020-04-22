FROM alpine:latest

RUN apk add bash \
            graphviz \
            ghostscript \
            make \
            openjdk11-jre \
            ruby-full \
            texlive-full \
            ttf-dejavu \
            wget

# Project options
ARG project_name=shared-pancake
ARG tools_folder=tools
ARG pandoc_version=2.9.2.1
ARG plantuml_version=1.2020.6
ARG jq_version=1.6

# Environment variables
ENV JAVA_HOME /usr/bin/java
ENV PLANTUML /${project_name}/${tools_folder}/plantuml.jar

# Folders creation
RUN mkdir   ${project_name}
RUN mkdir   ${project_name}/${tools_folder}

# Pandoc
ARG pandoc_folder=pandoc-${pandoc_version}
ARG pandoc_package=${project_name}/${tools_folder}/${pandoc_folder}.tar.gz
RUN wget -O ${pandoc_package} "https://github.com/jgm/pandoc/releases/download/${pandoc_version}/${pandoc_folder}-linux-amd64.tar.gz" && \
    tar xvzf ${pandoc_package} ${pandoc_folder}/bin --strip-components=2 -C /usr/local/bin && \
    tar xvzf ${pandoc_package} ${pandoc_folder}/share --strip-components=2 -C /usr/local/share && \
    rm -rf ${pandoc_package}

# Plantuml
RUN wget -O $PLANTUML "https://sourceforge.net/projects/plantuml/files/${plantuml_version}/plantuml.${plantuml_version}.jar/download"

# Jq
RUN wget -O /usr/local/bin/jq "https://github.com/stedolan/jq/releases/download/jq-${jq_version}/jq-linux64" && \
    chmod +x /usr/local/bin/jq

# Copy tool
ADD Makefile    ${project_name}/Makefile
ADD script      ${project_name}/script
ADD markdown    ${project_name}/markdown
ADD example     ${project_name}/example

WORKDIR ${project_name}