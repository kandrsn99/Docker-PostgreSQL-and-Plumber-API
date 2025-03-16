#
# This is a Plumber API.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/

# Declare libraries
library(plumber)
library(RPostgreSQL)
library(DBI)
library(pool)
library(ggplot2)
# Declare Database Variables
dbname <- "NAME" # Same as your environment variable for the DB
host <- "ADDRESS" # Internal host IP for postgresql container
port <- 5432 # Internel host IP port for postgresql
user <- "NAME" # Same as your environment variable for the DB
password <- "PASSWORD" # Same as your environment variable for the DB
# Initialize pooling of database connections, reduce latency during high loads.
pool <- dbPool(
  # Establish the connection
  drv = RPostgres::Postgres(),
  dbname = dbname,
    host = host,
    port = port,
    user = user,
    password = password,
    minSize = 1, # Minimum number of connections
    maxSize = 1000 # Maximum number of connections
)

#* @apiTitle Plumber Example API
#* @apiDescription Plumber example description.

#* Plot a histogram of car models from the table.
#* @serializer png
#* @get /plot
function() {
  # Create a pooled connection
  conn <- pool::poolCheckout(pool)
  # Create query
  query_statement <- "SELECT vehicle FROM employees"
  # Get information
  information <- dbGetQuery(conn, query_statement)
  # Return connections
  pool::poolReturn(conn)
  # Make the plot
  plot <- ggplot(information, aes(x = vehicle)) +
    geom_histogram(stat = "count", fill = "blue", color = "black") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(title = "Histogram of Car Models",
         x = "Car Model",
         y = "Count")
  # Full send
  print(plot)
}
#* Return entry based on first name in the table.
#* @param first_name search term
#* @post /first_name
function(first_name) {
  # Create a pooled connection
  conn <- pool::poolCheckout(pool)
  # Create query
  query_statement <- "SELECT * FROM employees WHERE first_name = ?query"
  # Make sure we have no injection.
  query <- sqlInterpolate(conn, query_statement, query = first_name)
  # Get information
  information <- dbGetQuery(conn, query)
  # Return connections
  pool::poolReturn(conn)
  # Full send
  return(information)
}
#* Return entry based on last name in the table.
#* @param last_name search term
#* @post /last_name
function(last_name) {
  # Create a pooled connection
  conn <- pool::poolCheckout(pool)
  # Create query
  query_statement <- "SELECT * FROM employees WHERE last_name = ?query"
  # Make sure we have no injection
  query <- sqlInterpolate(conn, query_statement, query = last_name)
  # Get information
  information <- dbGetQuery(conn, query)
  # Return connection
  pool::poolReturn(conn)
  # Full send
  return(information)
}
#* Get table information.
#* Return last 10 lines of a table in the employees database.
#* @get /information
function() {
  # Create a pooled connection
  conn <- pool::poolCheckout(pool)
  # Create query
  query_statement <- "SELECT * FROM employees LIMIT 10"
  # Get information
  information <- dbGetQuery(conn, query_statement)
  # Return connections
  pool::poolReturn(conn)
  # Full sned
  return(information)
}

# Programmatically alter your API
#* @plumber
function(pr) {
  pr %>%
    # Overwrite the default serializer to return unboxed JSON
    pr_set_serializer(serializer_unboxed_json())
}
