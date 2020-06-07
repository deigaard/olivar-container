#-----------------------------------------------
# - compile-image
#-----------------------------------------------

FROM python:3.7-slim AS compile-image

RUN apt-get update
RUN apt-get install -y --no-install-recommends build-essential gcc perl wget git autoconf zlib1g zlib1g-dev 

RUN python -m venv /opt/venv
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

RUN mkdir /opt/tools

RUN mkdir /opt/tools/bin

RUN cd /opt/tools \
      && wget https://github.com/marbl/parsnp/releases/download/v1.2/parsnp-Linux64-v1.2.tar.gz \
      && tar -xvf parsnp-Linux64-v1.2.tar.gz \
      && ln -s /opt/tools/Parsnp-Linux64-v1.2/parsnp /opt/tools/bin/parsnp

RUN cd /opt/tools \
      && /usr/bin/git clone https://github.com/primer3-org/primer3.git primer3 \
      && cd primer3/src \
      && make \
      && ln -s /opt/tools/primer3/src/primer3_core /opt/tools/bin \
      && ln -s /opt/tools/primer3/src/primer3_masker /opt/tools/bin

RUN cd /opt/tools \
      && wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.10.0+-src.tar.gz \
      && tar -xvf ncbi-blast-2.10.0+-src.tar.gz \
      && cd ncbi-blast-2.10.0+-src/c++ \
      && ./configure \
      && cd ReleaseMT/build \
      && make all_r \
      && ln -s /opt/tools/ncbi-blast-2.10.0+-src/c++/ReleaseMT/bin/run_with_lock /opt/tools/bin

RUN cd /opt/tools \
      && /usr/bin/git clone https://github.com/samtools/htslib.git \
      && cd htslib \
      && autoheader \
      && autoconf \
      && ./configure --prefix=/opt/tools \
      && make \
      && make install

RUN cd /opt/tools \
      && /usr/bin/git clone https://github.com/samtools/samtools.git \
      && cd samtools \
      && autoheader \
      && autoconf -Wno-synax \
      && ./configure --prefix=/opt/tools \
      && make \
      && make install

#COPY setup.py .
#COPY myapp/ .
#RUN pip install .

#-----------------------------------------------
# - build-image
#-----------------------------------------------

FROM python:3.7-slim AS build-image

RUN apt-get update \ 
      && apt-get install -y --no-install-recommends wget 

COPY --from=compile-image /opt/venv /opt/venv
COPY --from=compile-image /opt/tools/bin /opt/tools/bin

RUN mkdir /opt/tools
RUN mkdir /opt/work

RUN cd /opt/tools \
      && wget https://mafft.cbrc.jp/alignment/software/mafft_7.450-1_amd64.deb \
      && dpkg -i mafft_7.450-1_amd64.deb


# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:/opt/tools/bin:$PATH"
WORKDIR /root

CMD [ "/opt/venv/bin/python" ]