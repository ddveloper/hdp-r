#################################################
# -> mongo stuff
# function to get and save from the DB
#################################################
saveData <- function(data, id) {
  dbInsert <- tryCatch({
    db <- getDbConnection()
    if(!is.null(id)) {
      db$update(query = paste0('{ "_id" : {"$oid" : "',id,'"}}') , 
                update = paste0('{ "$set" : ',data,'}'))
    } else {
      db$insert(data)
    }
  },
  error = function(e) {
    print("ERROR inserting record!")
    print(e)
  })
}

loadModel <- function(modelId) {
  # Connect to the database
  model <- tryCatch({
    db <- getDbConnection()
    data <- db$find(query = paste0('{"_id" : {"$oid":"',modelId,'"}}'))
    data
  }, 
  error=function(e) {
    print(paste0("ERROR loading model!",modelId))
    print(e)
    #TODO this is going to blow up, still need to handle it
    ""
  })
  model
}

#load up all the models ids and names for the list
loadAllModels <- function() {
  allModels <- tryCatch({
    db <- getDbConnection()
    # Read all the entries
    data <- db$find(
      query = "{}",
      fields = '{ "modelName" : true }'
    )
    data
  }, error=function(e) {
    print("ERROR loading all models")
    print(e)
    ""
  })
  allModels
}

getDbConnection <- function() {
  collectionName <- "models"
  #local
  dataUri <- "mongodb://localhost/hdp"
  #for docker
  #dataUri <- "mongodb://hdpdb/hdp"
  db <- mongo(collection = collectionName,
              url = dataUri)
}

#################################################
# END mongo stuff
# if you want to use authentication with accounts, use this below
#  db <- mongo(collection = collectionName,
#              url = sprintf(
#                "mongodb://%s:%s@%s/%s",
#                options()$mongodb$username,
#                options()$mongodb$password,
#                options()$mongodb$host,
#                databaseName))
# AND put this up top:
#options(mongodb = list(
#  "host" = "localhost:27017",
#  "username" = "dev",
#  "password" = "Password1"
#))
#databaseName <- "hdp"
#
# I wanted to get ENV variables working in Docker, not sure why they don't:
#   #print(paste0("MONGO_URI:", Sys.getenv("MONGO_URI")))
#################################################