resource "shoreline_notebook" "slow_performance_due_to_full_table_scans_on_large_postgresql_tables" {
  name       = "slow_performance_due_to_full_table_scans_on_large_postgresql_tables"
  data       = file("${path.module}/data/slow_performance_due_to_full_table_scans_on_large_postgresql_tables.json")
  depends_on = [shoreline_action.invoke_create_index_script,shoreline_action.invoke_partition_script]
}

resource "shoreline_file" "create_index_script" {
  name             = "create_index_script"
  input_file       = "${path.module}/data/create_index_script.sh"
  md5              = filemd5("${path.module}/data/create_index_script.sh")
  description      = "Adding appropriate indexes to the large tables can help the database management system locate the required data more efficiently, thereby avoiding full table scans."
  destination_path = "/tmp/create_index_script.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "partition_script" {
  name             = "partition_script"
  input_file       = "${path.module}/data/partition_script.sh"
  md5              = filemd5("${path.module}/data/partition_script.sh")
  description      = "Partitioning large tables into smaller ones based on specific criteria, such as date or region, can help to reduce the amount of data scanned."
  destination_path = "/tmp/partition_script.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_create_index_script" {
  name        = "invoke_create_index_script"
  description = "Adding appropriate indexes to the large tables can help the database management system locate the required data more efficiently, thereby avoiding full table scans."
  command     = "`chmod +x /tmp/create_index_script.sh && /tmp/create_index_script.sh`"
  params      = ["DATABASE_NAME","TABLE_NAME","COLUMN_NAME","INDEX_NAME"]
  file_deps   = ["create_index_script"]
  enabled     = true
  depends_on  = [shoreline_file.create_index_script]
}

resource "shoreline_action" "invoke_partition_script" {
  name        = "invoke_partition_script"
  description = "Partitioning large tables into smaller ones based on specific criteria, such as date or region, can help to reduce the amount of data scanned."
  command     = "`chmod +x /tmp/partition_script.sh && /tmp/partition_script.sh`"
  params      = ["PARTITION_INTERVAL","DATABASE_NAME","TABLE_NAME","COLUMN_NAME"]
  file_deps   = ["partition_script"]
  enabled     = true
  depends_on  = [shoreline_file.partition_script]
}

