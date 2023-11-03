terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "slow_performance_due_to_full_table_scans_on_large_postgresql_tables" {
  source    = "./modules/slow_performance_due_to_full_table_scans_on_large_postgresql_tables"

  providers = {
    shoreline = shoreline
  }
}