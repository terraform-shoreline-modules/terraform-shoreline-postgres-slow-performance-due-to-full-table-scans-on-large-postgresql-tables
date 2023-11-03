#!/bin/bash



# Define variables

DB_NAME=${DATABASE_NAME}

TABLE_NAME=${TABLE_NAME}

INDEX_NAME=${INDEX_NAME}



# Check if index exists

index_status=$(psql -U postgres -d $DB_NAME -tAc "SELECT EXISTS(SELECT 1 FROM pg_indexes WHERE tablename = '$TABLE_NAME' AND indexname = '$INDEX_NAME')")

if [ "$index_status" = "f" ]; then

  # If index does not exist, create it

  psql -U postgres -d $DB_NAME -c "CREATE INDEX $INDEX_NAME ON $TABLE_NAME (${COLUMN_NAME})"

  echo "Index $INDEX_NAME created on table $TABLE_NAME"

else

  echo "Index $INDEX_NAME already exists on table $TABLE_NAME"

fi