# Dockefille for building olivar with dependancies

## [Olivar Gitlab Repository](https://gitlab.com/treangenlab/olivar.git)


## Packages and Dependencies installed in compile-image

### Python modules from requirements.txt file

- certifi==2020.4.5.1
- chardet==3.0.4
- docopt==0.6.2
- idna==2.9
- pipdeptree==0.13.2
- pipreqs==0.4.10
- requests==2.23.0
- urllib3==1.25.9
- yarg==0.1.9
- biopython==1.77
- pandas==1.0.4
- jinja2==2.11.2
- pysam==0.15.4
- pyvcf==0.6.8`

### Items manually installed

- Parsnp -[https://github.com/marbl/parsnp](https://github.com/marbl/parsnp) - [Download](https://github.com/marbl/parsnp/releases/download/v1.2/parsnp-OSX64-v1.2.tar.gz)
- Primer3 - [http://sourceforge.net/projects/primer3/files/primer3](http://sourceforge.net/projects/primer3/files/primer3) - [Download](https://sourceforge.net/projects/primer3/files/primer3/2.4.0/primer3-2.4.0.tar.gz) - [Source](https://github.com/primer3-org/primer3.git)
- Blast - [https://blast.ncbi.nlm.nih.gov/Blast.cgi](https://blast.ncbi.nlm.nih.gov/Blast.cgi) - [Download](https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/)
- Samtools - [https://github.com/samtools/samtools](https://github.com/samtools/samtools) - [Source](https://github.com/samtools/samtools.git)
- HTSlib - https://github.com/samtools/htslib - [Source](https://github.com/samtools/htslib.git)

## Packages and Dependencies installed in build-image (2nd pass)

- MAFFT - https://mafft.cbrc.jp/alignment/software/mafft_7.450-1_amd64.deb

## Packages not yet installed
- Minimap2 -
- Bowtie2
- Lofreq