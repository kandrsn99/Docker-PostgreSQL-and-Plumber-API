# Docker-PostgreSQL

This is a sample of a PostgreSQL database that is launchable with Docker. Docker makes it easy to deploy executables on a server host.

You may read about the summarized documentation of Docker here: https://github.com/kandrsn99/Docker-PostgreSQL-and-Initialized-Table/blob/main/Docker%20Command%20Line%20Interface.pdf

It shall be noted here you will need to install the Docker Engine on your local machine. You may do this through the instructions on the following webpage: https://docs.docker.com/engine/install/

In order to install this repository from the command line you will need to get the 'git' package on your linux machine.

Any Operating System utilizing 'APT' package manager
> sudo apt-get git

Any Operating System utilizing 'YUM' package manager
> sudo yum install git

Any Operating System utilizing 'DNF' package manager
> sudo dnf install git

Next, utilize the git function on your local machine command line interface to download this repository.
> git clone https://github.com/kandrsn99/Docker-PostgreSQL-and-Initialized-Table.git

Subsequently, change into the directory containing your downloaded repository. 
> cd 'name of file-path'

You will need to change some variables prior to composing. Check your docker-compose.yml file and those labelled 'environment' which need to be declared for your database. You will do this with your operating systems text editor. It is typically 'nano' or 'vim' depending on the machines operating system.

Upon entering the directory. The docker compose file should allow you to build the database.
> docker compose build\
> docker compose up -d

## NOTE: Any reference to docker-compose.yml environment variables that you name is required for the commands. You will substitute those values manually that you initialized.
## NOTE: Any time you docker compose build you are recreating the same database that was supposed to be initialized on start up.

Now, we may mosey into the running container and run commands in the PostgreSQL environment.
> docker exec -it running_postgresql bash\
> psql -U POSTGRES_USER (environment variable reference) POSTGRES_DB (environment variable reference)

Otherwise, we may do this on a nice graphica interface with pgadmin on the local host. You will access it via http://localhost:5050 or htttp://address:5050 and begin adding a new server. 
> Add Server Name: POSTGRES_DB (environment variable reference)

Then we need the host name or internet protocol address of our PostgreSQL environment.

> docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' running_postgresql

Now that we have the address we shall use it to connect.

> Add Host/Address: running_postgresql address\
> Add Server User: POSTGRES_USER (environment variable reference)\
> Add Server Password: POSTGRES_PASSWORD (environment variable reference)\
> Add Port: postgresql_port (environment port reference 5432 in this case)

Please note that you must enter the running container if you wish to change the port with which the PostgreSQL environment will run.
> docker exec -it running_postgresql bash\
> cd var/lib/postgresql/data

At which point you will open the postgres.conf file located in that directory with the text editor in that system. You may learn more about postgres.conf here at https://www.postgresql.org/docs/14/runtime-config-connection.html#RUNTIME-CONFIG-CONNECTION-SETTINGS
> #port = 5432\
> port = NUMBER (your favorite port)

And of course, change the docker-compose.yml and run a restart.
> docker compose down\
> docker compose up

You may read about the official PostgreSQL docker image documentation here https://hub.docker.com/_/postgres/ and the official pgadmin docker image https://hub.docker.com/r/dpage/pgadmin4/ which was modified for this repository.
