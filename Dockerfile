### Single-cell analysis pipeline for "Integrated analysis and regulation of cellular diversity"
# Installed tools: Seurat, Monocle3, scater, scImpute, velocyto, scanpy, sleepwalk, liger, RCA, scBio, SCENIC, singleCellHaystack, scmap, scran, slingshot, scVelo
# ArchR

# splatter is an R script and cannot be installed by command
# https://github.com/MarioniLab/MNN2017/
# pyscenic

FROM rnakato/r_python:r40u18
LABEL maintainer "Ryuichiro Nakato <rnakato@iam.u-tokyo.ac.jp>"

USER root
WORKDIR /opt

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    emacs25-el \
    libgsl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Python
RUN conda install -y -c bioconda samtools scanpy kallisto \
    && conda install -y louvain leidenalg \
    && conda install -y -c statiskit libboost \
    && pip install -U velocyto scvelo

RUN R -e "install.packages(c('sleepwalk','bit64','zoo','scBio','Seurat'), repos='https://cran.ism.ac.jp/')"

# R for jupyterbook
RUN R -e "install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'))" \
    && R -e "devtools::install_github('IRkernel/IRkernel')" \
    && R -e " IRkernel::installspec()"

RUN R -e "BiocManager::install(c('limma','scater','pcaMethods','WGCNA','preprocessCore', 'RCA', 'scmap', 'mixtools', 'stringi', 'rbokeh', 'DT', 'NMF', 'pheatmap', 'R2HTML', 'doMC', 'doRNG', 'scran', 'slingshot','DropletUtils','SingleR', 'monocle', 'scTensor'))"

RUN R -e "devtools::install_github(c('Vivianstats/scImpute', 'alexisvdb/singleCellHaystack'))"
RUN R -e "devtools::install_github(c('aertslab/SCopeLoomR', 'velocyto-team/velocyto.R'))"

# Monocle3
RUN R -e "BiocManager::install(c('BiocGenerics', 'DelayedArray', 'DelayedMatrixStats', 'limma', 'S4Vectors', 'SingleCellExperiment', 'SummarizedExperiment', 'batchelor'))" \
    && R -e "devtools::install_github('cole-trapnell-lab/leidenbase')" \
    && R -e "devtools::install_github('cole-trapnell-lab/monocle3', ref='develop')" \
    && R -e "BiocManager::install(c('org.Mm.eg.db', 'org.Hs.eg.db', 'org.Dm.eg.db', 'org.Ce.eg.db'))" \
    && R -e "devtools::install_github('cole-trapnell-lab/garnett', ref='monocle3')"

# kallisto, bustools
RUN git clone https://github.com/BUStools/bustools.git \
    && cd bustools \
    && mkdir build \
    && cd build \
    && cmake .. && make && make install \
    && R -e "devtools::install_github(c('tidymodels/tidymodels','BUStools/BUSpaRse'))" \
    && rm -rf /opt/bustools

# liger (FFTW, FIt-SNE)
RUN wget http://www.fftw.org/fftw-3.3.8.tar.gz \
    && tar zxvf fftw-3.3.8.tar.gz \
    && rm fftw-3.3.8.tar.gz \
    && cd fftw-3.3.8 \
    && ./configure \
    && make \
    && make install \
    && git clone https://github.com/KlugerLab/FIt-SNE.git \
    && cd FIt-SNE/ \
    && g++ -std=c++11 -O3  src/sptree.cpp src/tsne.cpp src/nbodyfft.cpp  -o bin/fast_tsne -pthread -lfftw3 -lm \
    && cp bin/fast_tsne /usr/local/bin/
RUN R -e "devtools::install_github(c('MacoskoLab/liger'))"

# cellphoneDB
RUN python -m venv cpdb-venv \
    && . cpdb-venv/bin/activate \
    && pip install cellphonedb
ENV PATH $PATH:/opt/cpdb-venv/bin/

#### scATAC-seq ####
# ArchR
RUN R -e "devtools::install_github('GreenleafLab/ArchR', ref='master', repos = BiocManager::repositories())"
# cicero
RUN R -e "devtools::install_github('cole-trapnell-lab/cicero-release', ref = 'monocle3')"
# chromVAR
RUN R -e "BiocManager::install(c('chromVAR','JASPAR2016'))" \
    && R -e "devtools::install_github(c('GreenleafLab/chromVARmotifs','GreenleafLab/motifmatchr'))"

### Added after v1.1.0
RUN R -e "BiocManager::install(c('BSgenome.Hsapiens.UCSC.hg19', 'BSgenome.Hsapiens.UCSC.hg38', 'BSgenome.Mmusculus.UCSC.mm10', 'BSgenome.Scerevisiae.UCSC.sacCer3', 'BSgenome.Dmelanogaster.UCSC.dm6'))"
RUN pip install pybind11 hnswlib