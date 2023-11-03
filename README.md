
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Slow Performance due to Full Table Scans on Large PostgreSQL Tables
---

This incident type refers to situations where PostgreSQL queries are performing full table scans on large tables, leading to slow performance. This occurs when the database management system has to scan the entire table to locate the required data, which can be a time-consuming process. The issue can arise due to a variety of reasons, such as missing or outdated indexes, complex queries, or inefficient query design. To resolve the issue, optimizing the queries on large tables is necessary.

### Parameters
```shell
export USERNAME="PLACEHOLDER"

export TABLE_NAME="PLACEHOLDER"

export QUERY="PLACEHOLDER"

export DATABASE_NAME="PLACEHOLDER"

export COLUMN_NAME="PLACEHOLDER"

export INDEX_NAME="PLACEHOLDER"

export PARTITION_INTERVAL="PLACEHOLDER"
```

## Debug

### Check PostgreSQL version
```shell
psql -U ${USERNAME} -c "SELECT version();"
```

### Get list of all tables in the database
```shell
psql -U ${USERNAME} -c "\dt"
```

### Check table size
```shell
psql -U ${USERNAME} -c "SELECT pg_size_pretty(pg_total_relation_size('${TABLE_NAME}'))"
```

### Check if table has an index
```shell
psql -U ${USERNAME} -c "SELECT indexname, indexdef FROM pg_indexes WHERE tablename='${TABLE_NAME}'"
```

### Check query plan for a specific query
```shell
psql -U ${USERNAME} -c "EXPLAIN ANALYZE ${QUERY};"
```

### Check for long running queries
```shell
psql -U ${USERNAME} -c "SELECT pid, age(clock_timestamp(), query_start), usename, query FROM pg_stat_activity WHERE datname='${DATABASE_NAME}' AND state='active' ORDER BY query_start desc;"
```

## Repair

### Adding appropriate indexes to the large tables can help the database management system locate the required data more efficiently, thereby avoiding full table scans.
```shell
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


```

### Partitioning large tables into smaller ones based on specific criteria, such as date or region, can help to reduce the amount of data scanned.
```shell
bash

#!/bin/bash



# Set variables

DB_NAME=${DATABASE_NAME}

TABLE_NAME=${TABLE_NAME}

PARTITION_COLUMN=${COLUMN_NAME}

PARTITION_INTERVAL=${PARTITION_INTERVAL}



# Create new partitions

psql -d $DB_NAME -c "CREATE TABLE ${TABLE_NAME}_new PARTITION OF ${TABLE_NAME} FOR VALUES FROM ('2000-01-01') TO ('${PARTITION_INTERVAL}');"

psql -d $DB_NAME -c "CREATE TABLE ${TABLE_NAME}_old PARTITION OF ${TABLE_NAME} FOR VALUES FROM ('${PARTITION_INTERVAL}') TO (MAXVALUE);"



# Move data from old table to new partition

psql -d $DB_NAME -c "INSERT INTO ${TABLE_NAME}_new SELECT * FROM ${TABLE_NAME} WHERE ${PARTITION_COLUMN} >= '2000-01-01' AND ${PARTITION_COLUMN} < '${PARTITION_INTERVAL}';"



# Drop old table

psql -d $DB_NAME -c "DROP TABLE ${TABLE_NAME};"



# Rename new table to old table name

psql -d $DB_NAME -c "ALTER TABLE ${TABLE_NAME}_new RENAME TO ${TABLE_NAME};"


```