#-----------------------------------------------
# - compile-image
#-----------------------------------------------

FROM python:3.7-slim AS compile-image

RUN apt-get update
RUN apt-get install -y --no-install-recommends build-essential gcc perl wget libcurl4-openssl-dev git autoconf zlib1g zlib1g-dev libbz2-dev bzip2 liblzma-dev libncurses5-dev

RUN python -m venv /opt/venv
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

RUN mkdir /opt/tools

#RUN mkdir /opt/tools/bin

ENV PERL_MM_USE_DEFAULT=1
RUN cd /opt/tools \
      && cpan App::cpanminus \
      && cpanm Getopt::Std \
      && cpanm Data::Dumper \
      && cpanm Digest::MD5

#
# Install Parsnp binaries
#
RUN cd /opt/tools \
      && wget https://github.com/marbl/parsnp/releases/download/v1.2/parsnp-Linux64-v1.2.tar.gz \
      && tar -xvf parsnp-Linux64-v1.2.tar.gz \
      && cp /opt/tools/Parsnp-Linux64-v1.2/parsnp /usr/local/bin/parsnp

#
# Looking at potentially source install of Parsnp
#
#RUN cd /opt/tools \
#      && /usr/bin/git clone https://github.com/marbl/parsnp.git
#      && cd parsnp \
#      && cd muscle \
#      && ./autogen.sh \
#      && ./configure --prefix=/opt/tools CXXFLAGS='-fopenmp' \
#      && make \
#      && make install \
#      && cd .. \
#      && ./autogen.sh \
#      export ORIGIN=\$ORIGIN
#      && ./configure CXXFLAGS='-fopenmp' LDFLAGS='-Wl,-rpath,$$ORIGIN/../muscle/lib'
#      && make LDADD=-lMUSCLE-3.7 \
#      && make install

#
# Install Primer3 from source
#
RUN cd /opt/tools \
      && /usr/bin/git clone https://github.com/primer3-org/primer3.git primer3 \
      && cd primer3/src \
      && make \
      && cp /opt/tools/primer3/src/oligotm /usr/local/bin \
      && cp /opt/tools/primer3/src/primer3_core /usr/local/bin \
      && cp /opt/tools/primer3/src/primer3_masker /usr/local/bin

#
# Install Blast binaries (latest)
#

RUN cd /opt/tools \
      && wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.10.1+-x64-linux.tar.gz \
      && tar -xvf ncbi-blast-2.10.1+-x64-linux.tar.gz \
      && cd ncbi-blast-2.10.1+ \
      && cp -rn bin /usr/local

#
# Install Blast from source (check VERSION)
#
#RUN cd /opt/tools \
#      && wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.10.0+-src.tar.gz \
#      && tar -xvf ncbi-blast-2.10.0+-src.tar.gz \
#      && cd ncbi-blast-2.10.0+-src/c++ \
#      && ./configure \
#      && cd ReleaseMT/build \
#      && make all_r \
#      && cp /opt/tools/ncbi-blast-2.10.0+-src/c++/ReleaseMT/bin/run_with_lock /opt/tools/bin

#
# Install Samtools (needs htslib as well) from source
#
RUN cd /opt/tools \
      && /usr/bin/git clone https://github.com/samtools/htslib.git \
      && cd htslib \
      && autoheader \
      && autoconf \
      && ./configure --prefix=/usr/local \
      && make \
      && make install

RUN cd /opt/tools \
      && /usr/bin/git clone https://github.com/samtools/samtools.git \
      && cd samtools \
      && autoheader \
      && autoconf -Wno-synax \
      && ./configure --prefix=/usr/local \
      && make \
      && make install

#
# Install minimap2 from source
#
RUN cd /opt/tools \
      && /usr/bin/git clone https://github.com/lh3/minimap2 \
      && cd minimap2 \
      && make \
      && cp minimap2 /usr/local/bin

#
# Install Bowtie2 (needs libtbb-dev) from source
#
RUN apt-get install -y --no-install-recommends libtbb-dev
ENV DESTDIR /usr/local
RUN cd /opt/tools \
      && /usr/bin/git clone https://github.com/BenLangmead/bowtie2.git \
      && cd bowtie2 \
      && make \
      && make install

#
# Install Lofreq from source
#
RUN apt-get install -y --no-install-recommends libtool automake
RUN cd /opt/tools \
      && /usr/bin/git clone https://github.com/CSB5/lofreq.git \
      && cd lofreq \
      && ./bootstrap \
      && ./configure --prefix=/usr/local --with-htslib=/opt/tools/htslib \
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
      && apt-get install -y --no-install-recommends wget perl git

RUN mkdir /opt/tools

COPY --from=compile-image /opt/venv /opt/venv
#COPY --from=compile-image /opt/tools/bin /opt/tools/bin
COPY --from=compile-image /usr/local /usr/local

ENV PERL_MM_USE_DEFAULT=1
RUN cd /opt/tools \
      && cpan App::cpanminus \
      && cpanm Getopt::Std \
      && cpanm Data::Dumper \
      && cpanm Digest::MD5

RUN mkdir /opt/work

RUN cd /opt/tools \
      && wget https://mafft.cbrc.jp/alignment/software/mafft_7.450-1_amd64.deb \
      && dpkg -i mafft_7.450-1_amd64.deb


# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:/usr/local/bin:$PATH"
WORKDIR /root

CMD [ "/opt/venv/bin/python" ]
