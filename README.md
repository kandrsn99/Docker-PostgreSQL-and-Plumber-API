# Docker-PostgreSQL-and-Plumbing

This is a sample of a PostgreSQL database that is launchable with Docker. Docker makes it easy to deploy executables on a server host with a Plumber API.

You may read about the summarized documentation of Docker here: https://github.com/kandrsn99/Docker-PostgreSQL-and-Plumber-API/blob/main/Docker%20Command%20Line%20Interface.pdf

It shall be noted here you will need to install the Docker Engine on your local machine. You may do this through the instructions on the following webpage: https://docs.docker.com/engine/install/

In order to install this repository from the command line you will need to get the 'git' package on your linux machine.

Any Operating System utilizing 'APT' package manager
> sudo apt-get git

Any Operating System utilizing 'YUM' package manager
> sudo yum install git

Any Operating System utilizing 'DNF' package manager
> sudo dnf install git

Next, utilize the git function on your local machine command line interface to download this repository.
> git clone https://github.com/kandrsn99/Docker-PostgreSQL-and-Plumber-API.git

Subsequently, change into the directory containing your downloaded repository. 
> cd 'name of file-path'

You will need to change some variables prior to composing. Check your docker-compose.yml file and those labelled 'environment' which need to be declared for your database. You will do this with your operating systems text editor. It is typically 'nano' or 'vim' depending on the machines operating system.

Upon entering the directory, the docker compose file should allow you to build the database.
> docker compose build postgresql_proxy\
> docker compose up postgresql_proxy -d

## NOTE: Any reference to docker-compose.yml environment variables that you name is required for the commands. You will substitute those values manually that you initialized.
## NOTE: Any time you docker compose build you are recreating the same database that was supposed to be initialized on start up.

Now, we may mosey into the running container and run commands in the PostgreSQL environment.
> docker exec -it running_postgresql bash\
> psql -U POSTGRES_USER (environment variable reference) POSTGRES_DB (environment variable reference)

Please note that you must enter the running container if you wish to change the port with which the PostgreSQL environment will run.
> docker exec -it running_postgresql bash\
> cd var/lib/postgresql/data

At which point you will open the postgres.conf file located in that directory with the text editor in that system. You may learn more about postgres.conf here at https://www.postgresql.org/docs/14/runtime-config-connection.html#RUNTIME-CONFIG-CONNECTION-SETTINGS
> #port = 5432\
> port = NUMBER (your favorite port)

And of course, change the docker-compose.yml and run a restart.
> docker compose down\
> docker compose up

Before we start the plumber API, we need the host name or internet protocol address of our PostgreSQL environment.

> docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' running_postgresql

Now, that we have the address we shall use it to connect the Plumber API to the database by modifying the script in /plumber_app/my_app/ and using 'nano' or any other text editor to change the appropriately labeled variables. Remember to add your secure socket layer certificates and edit the nginx.conf file in the appropriate directories before spooling up the rest of your containers.

Do note that you must retrieve an SSL (secure socket layer) certificate to have HTTPs working for your domain name. The NGINX configuration file is meant to be easy to follow and understand. Read it and make sure the certificates are stored in the correct locations with the proper naming schema for NGINX. An easy way to create SSL certificate may be done with openSSL, https://openssl.org/, from the command line or otherwise downloaded from the DNS provider. 

It is highly recommended that you use Cloudflare as they are the leading provider of a register for hosting a DNS. You may review their documentation here https://developers.cloudflare.com/learning-paths/get-started/ at your leisure.

And of course, we spool both containers up for nginx and plumber proxies
> docker compose build plumber_proxy\
> docker compose up plumber_proxy -d\
> docker compose build nginx_proxy\
> docker compose up nginx_proxy -d

You may read about the official PostgreSQL docker image documentation here https://hub.docker.com/_/postgres/ and the official rocker image https://rocker-project.org/images/versioned/rstudio.html which was modified for this repository.
