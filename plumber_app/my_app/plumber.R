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
#* @apiDescription This API is written in the R language to interface with a sample PostgreSQL database and initialized table provided in CSV format.
#* @apiContact list(name = "https://github.com/kandrsn99/Docker-PostgreSQL-and-Plumber-API", url = "https://github.com/kandrsn99/Docker-PostgreSQL-and-Plumber-API")

#* Plot a Histogram of item in a table.
#* @response 200 Success
#* @serializer png
#* @get /plot
#* The purpose of this end-point is to get a plot from a specific column in a table upon get.
function(res) {
  # Create pooled connection
  conn <- pool::poolCheckout(pool)
  # Query
  query_statement <- "SELECT vehicle FROM employees"
  # Get information
  information <- dbGetQuery(conn, query_statement)
  # Return the connection
  pool::poolReturn(conn)
  # Error handling
  if (dbIsValid(conn) == FALSE) {
    res$status <- 500
    return(list(
      success = FALSE,
      error = "Connection: pooled connection isn't valid!"
    ))
  }
  # Make a plot
  plot <- ggplot(information, aes(x = vehicle)) +
    geom_histogram(stat = "count", fill = "blue", color = "black") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(title = "Histogram of Car Models",
         x = "Car Model",
         y = "Count")
  # Full Send (has to be print for graphs believe it or not)
  print(plot)
}
#* Return entry based on name in a table.
#* @response 200 Success
#* @response 400 Bad Request
#* @param query:str* search term
#* @post /name
#* The purpose of this end-point is to get a specific entry in a table upon post.
function(query, res) {
  # Create a pooled connection
  conn <- pool::poolCheckout(pool)
  # Error handling
  if (dbIsValid(conn) == FALSE) {
    res$status <- 500
    return(list(
      success = FALSE,
      error = "Connection: pooled connection isn't valid!"
    ))
  }
  # Prepare and execute the query using parameterized query
  query_statement <- "SELECT * FROM employees WHERE first_name = $1 OR last_name = $1;"
  # Get information
  information <- dbGetQuery(conn, query_statement, params = list(query))
  # Return the connection
  pool::poolReturn(conn)
  # Error handling
  if(nrow(information) == 0) {
    # Code
    res$status <- 400
    # Return
    return(list(
      success = FALSE,
      error = "Bad Request: 'query' must be a a valid name."
    ))
  }
  # Full send
  return(information)
}
#* Post an entry in a table.
#* @response 200 Success
#* @response 400 Bad Request
#* @param first:str* first
#* @param last:str* last
#* @param vehicle:str* vehicle
#* @post /first/last/vehicle
#* The purpose of this end-point is to create an entry in a table upon post.
function(first, last, vehicle, res) {
  # Create a pooled connection
  conn <- pool::poolCheckout(pool)
  # Error handling
  if (dbIsValid(conn) == FALSE) {
    res$status <- 500
    return(list(
      success = FALSE,
      error = "Connection: pooled connection isn't valid!"
    ))
  }
  # Prepare and execute the query
  query <- "INSERT INTO employees (first_name, last_name, vehicle) VALUES ($1, $2, $3);"
  # Send off
  result <- dbSendStatement(conn, query)
  # Safely quote to prevent SQL injection and execute.
  dbBind(result, list(first, last, vehicle))
  # Check if we changed anything
  rows_affected <- dbGetRowsAffected(result)
  # Error handling
  if (rows_affected > 0) {
    # Pass parameters correctly by freeing up the object.
    dbClearResult(result)
    # Return the connection
    pool::poolReturn(conn)
    # Code
    res$status <- 200
    # Return
    return(list(
      success = TRUE,
      message = paste("Record with ", first, " updated.")
    ))
  } else {
    # Pass parameters correctly by freeing up the object.
    dbClearResult(result)
    # Return the connection
    pool::poolReturn(conn)
    res$status <- 400
    return(list(
      success = FALSE,
      error = "Bad Request: 'query' must be a a valid name."
    ))
  }
}
#* Put an an entry in a table.
#* @response 200 Updated
#* @response 400 Bad Request
#* @param first:str* first
#* @param last:str* last
#* @param new_value:str* Car Model
#* @put /first/last/vehicle
#* The purpose of ths end-point is to update an entry in a table upon put.
function(first, last, new_value, res) {
  # Create a pooled connection
  conn <- pool::poolCheckout(pool)
  # Error handling
  if (dbIsValid(conn) == FALSE) {
    # Code
    res$status <- 500
    # Return
    return(list(
      success = FALSE,
      error = "Connection: pooled connection isn't valid!"
    ))
  }
  # Prepare and execute the query
  query <- "UPDATE employees SET vehicle = $3 WHERE first_name = $1 AND last_name = $2;"
  # Send off
  result <- dbSendStatement(conn, query)
  # Safely quote to prevent SQL injection and execute.
  dbBind(result, list(first, last, new_value))
  # Check if we changed anything
  rows_affected <- dbGetRowsAffected(result)
  # Error handling
  if (rows_affected > 0) {
    # Pass parameters correctly by freeing up the object.
    dbClearResult(result)
    # Return the connection
    pool::poolReturn(conn)
    # Code
    res$status <- 200
    # Return
    return(list(
        success = TRUE,
        message = paste0("Record with ", first, " updated.")
        ))
  } else {
    # Pass parameters correctly by freeing up the object.
    dbClearResult(result)
    # Return the connection
    pool::poolReturn(conn)
    # Code
    res$status <- 400
    # Return
    return(list(
      success = FALSE,
      error = "Bad Request: first and last name must be a a valid."
    ))
  }
}
#* Delete an entry in a table.
#* @response 200 Deleted
#* @response 400 Bad Request
#* @param first:str* first
#* @param last:str* last
#* @delete /first/last
#* The purpose of this end-point is to delete an entry in a table upon delete.
function(first, last, res) {
  # Create a pooled connection
  conn <- pool::poolCheckout(pool)
  # Error handling
  if (dbIsValid(conn) == FALSE) {
    # Code
    res$status <- 500
    # Return
    return(list(
      success = FALSE,
      error = "Connection: pooled connection isn't valid!"
    ))
  }
  # Prepare and execute the query
  query <- "DELETE FROM employees WHERE first_name = $1 AND last_name = $2;"
  # Send off
  result <- dbSendStatement(conn, query)
  # Safely quote to prevent SQL injection and execute.
  dbBind(result, list(first, last))
  # Check if we changed anything
  rows_affected <- dbGetRowsAffected(result)
  # Error handling
  if (rows_affected > 0) {
    # Pass parameters correctly by freeing up the object.
    dbClearResult(result)
    # Return the connection
    pool::poolReturn(conn)
    # Code
    res$status <- 200
    # Return
    return(list(
      success = TRUE,
      message = paste0("Record with ", first, " deleted")
    ))
  } else {
    # Pass parameters correctly by freeing up the object.
    dbClearResult(result)
    # Return the connection
    pool::poolReturn(conn)
    res$status <- 400
    return(list(
      success = FALSE,
      error = "Bad Request: first and last name must be valid."
    ))
  }
}

#* Return data of a table.
#* @get /information
#* @response 200 Success
#* The purpose of this end-point is to get all data from the table upon get.
function(res) {
  # Create a pooled connection
  conn <- pool::poolCheckout(pool)
  # Error handling
  if (dbIsValid(conn) == FALSE) {
    # Code
    res$status <- 500
    # Return
    return(list(
      success = FALSE,
      error = "Connection: pooled connection isn't valid!"
    ))
  }
  # Query
  query_statement <- "SELECT * FROM employees ORDER BY employee_id;"
  # Get information
  information <- dbGetQuery(conn, query_statement)
  # Return the connection
  pool::poolReturn(conn)
  # Full send
  return(information)
}
# Programmatically alter your API
#* @plumber
function(pr) {
  pr %>%
    # Overwrite the default serializer to return unboxed JSON
    pr_set_serializer(serializer_unboxed_json())
}
