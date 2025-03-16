# Getting latest image of rocker shiny for containerization.
FROM rocker/tidyverse:latest
# Install all dependencies for plumber
RUN install2.r --error --deps TRUE \
    plumber \
    RPostgreSQL \
    pool \
    ggplot2 \
    DBI \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
# Copy everything over where it is supposed to go for the website R Shiny.
COPY my_app/ /srv/plumber-server/
# Expose the proper port.
EXPOSE 8000
# Run script for plumber server
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb('/srv/plumber-server/plumber.R'); pr$run(host='0.0.0.0', port=8000)"]
