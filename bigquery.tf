/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_bigquery_dataset" "telemetry_dataset" {
  depends_on = [
    google_project_service.gcp_services
  ]
  project       = local.project_id
  dataset_id    = "telemetry"
  friendly_name = "telemetry"
  location      = local.project_default_region
}


resource "google_bigquery_table" "telemetry_raw_table" {
  depends_on = [
    google_bigquery_dataset.telemetry_dataset
  ]
  project             = local.project_id
  dataset_id          = google_bigquery_dataset.telemetry_dataset.dataset_id
  table_id            = "telemetry"
  deletion_protection = false

  time_partitioning {
    type  = "DAY"
    field = "timeStamp"
  }

  clustering = [
    "source", "category"
  ]

  schema = <<EOF
[
  {
    "description": "",
    "type": "STRING",
    "name": "source",
    "mode": "NULLABLE"
  },
  {
    "description": "",
    "type": "STRING",
    "name": "category",
    "mode": "NULLABLE"
  },
  {
    "description": "",
    "type": "STRING",
    "name": "id",
    "mode": "NULLABLE"
  },
  {
    "description": "",
    "type": "STRING",
    "name": "projectId",
    "mode": "NULLABLE"
  },
  {
    "description": "",
    "type": "TIMESTAMP",
    "name": "timeStamp",
    "mode": "NULLABLE"
  },
  {
    "description": "",
    "type": "RECORD",
    "name": "payload",
    "mode": "NULLABLE",
    "fields": [
      {
        "name": "pageName",
        "type": "STRING",
        "mode": "NULLABLE"
      }
    ]
  }
]
EOF
}


resource "google_bigquery_table" "telemetry_view" {
  depends_on = [
    google_bigquery_dataset.telemetry_dataset,
    google_bigquery_table.telemetry_raw_table
  ]

  project    = local.project_id
  dataset_id = google_bigquery_dataset.telemetry_dataset.dataset_id
  table_id   = "telemetry_view"

  view {
    query          = <<EOF
SELECT * FROM `${local.project_id}.${google_bigquery_dataset.telemetry_dataset.dataset_id}.${google_bigquery_table.telemetry_raw_table.table_id}`
EOF
    use_legacy_sql = false
  }
}
