# Add files properly
ADD ./schema.sql /docker-entrypoint-initdb.d
# Make sure proper port is open for PostgreSQL environment
EXPOSE 5432
# Make sure proper port is open for pgadmin environment
EXPOSE 5050
# Run the sql script to create a table
RUN chmod a+r /docker-entrypoint-initdb.d/*
