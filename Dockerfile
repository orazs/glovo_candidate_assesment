FROM rocker/shiny-verse

 
# Install dependency libraries
RUN apt-get update && apt-get install -y  \
                ghostscript \
                libgsl-dev \
                lmodern \
                pandoc-citeproc \
                qpdf \
                texinfo \
                && rm -rf /var/lib/apt/lists/*
	

# install needed R packages
RUN    R -e "install.packages(c('rmarkdown','rpart.plot','Hmisc', 'flexdashboard','data.table','plotly', 'tidyverse','shiny', 'vistime'),  repo='http://cran.r-project.org')"

# make directory and copy Rmarkdown flexdashboard file in it
RUN mkdir -p /bin
RUN mkdir -p /bin/data
RUN mkdir -p /bin/assets

COPY data/glovo.csv  /bin/data/glovo.csv
COPY data/model.RData  /bin/data/model.RData
COPY demo.Rmd   /bin/demo.Rmd
COPY assets/logo.png   /bin/assets/logo.png
COPY assets/style.css   /bin/assets/style.css

# make all app files readable (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /bin

# expose port on Docker container
EXPOSE 1000

# run flexdashboard as localhost and on exposed port in Docker container
CMD ["R", "-e", "rmarkdown::run('/bin/demo.Rmd', shiny_args = list(port = 1000, host = '0.0.0.0'))"]