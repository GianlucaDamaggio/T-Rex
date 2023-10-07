FROM ubuntu

RUN apt update && \
apt -y upgrade

RUN apt-get update && \
apt-get -y install cmake protobuf-compiler && \
apt-get install -y git && \
apt-get install -y build-essential && \
apt-get -y install python3 && \
apt-get -y install python3-dev && \
apt install -y python3-distutils

# Software installation
WORKDIR /

# GUPPY
ENV GUPPY_VERSION=5.0.7
ADD https://cdn.oxfordnanoportal.com/software/analysis/ont-guppy-cpu_${GUPPY_VERSION}_linux64.tar.gz /
RUN mkdir /workdir && \
        cd /workdir && \
        tar -xzf /ont-guppy-cpu_${GUPPY_VERSION}_linux64.tar.gz && rm -f ont-guppy-cpu_${GUPPY_VERSION}_linux64.tar.gz

# ANACONDA
ENV MINICONDA_VERSION=23.5.2
ADD https://repo.anaconda.com/miniconda/Miniconda3-py39_${MINICONDA_VERSION}-0-Linux-x86_64.sh /
RUN /bin/bash /Miniconda3-py39_${MINICONDA_VERSION}-0-Linux-x86_64.sh -b -p /opt/conda && \
        rm /Miniconda3-py39_${MINICONDA_VERSION}-0-Linux-x86_64.sh && \
        ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
        echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
        echo "conda activate" >> ~/.bashrc
ENV PATH="/opt/conda/bin:${PATH}"
WORKDIR /workdir

# STRAGLR
ENV STRAGLR_VERSION=1.2.0
RUN cd /workdir && \
        git clone https://github.com/bcgsc/straglr.git && \
        cd straglr
RUN conda env create -n straglr --file=/workdir/straglr/environment.yaml
RUN apt-get -y install libbz2-dev
RUN pip install -t /opt/conda/envs/straglr/bin/ git+https://github.com/bcgsc/straglr.git@v${STRAGLR_VERSION}#egg=straglr  

# BLASTN
ADD https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.12.0/ncbi-blast-2.12.0+-x64-linux.tar.gz /
RUN tar -xzf /ncbi-blast-2.12.0+-x64-linux.tar.gz && rm -f ncbi-blast-2.12.0+-x64-linux.tar.gz

# SAMTOOLS
ENV SAMTOOLS_VERSION=1.18
RUN apt-get install -y libncurses-dev liblzma-dev
ADD https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 /workdir/
RUN tar -xvjf samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
        rm -f samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
        cd samtools-${SAMTOOLS_VERSION} && \
        ./configure && \
        make && \
        make install

ENV PATH="$PATH:/workdir/samtools-${SAMTOOLS_VERSION}"

# Make RUN commands use the new environment
RUN echo "conda activate straglr" >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

# R
RUN conda install -c conda-forge r-base=4.2.2
RUN conda update conda
RUN conda install -c conda-forge r-tidyverse r-optparse r-scales




