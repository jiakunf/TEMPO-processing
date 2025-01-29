FROM jupyter/scipy-notebook:lab-4.0.4
USER root
WORKDIR /home

# Install the application dependencies

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -yq \
    graphviz \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir \
    datajoint

CMD ["python"]