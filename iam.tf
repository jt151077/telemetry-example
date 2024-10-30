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

locals {
  pub_sub_roles = [
    "roles/bigquery.metadataViewer",
    "roles/bigquery.dataEditor"
  ]
  
  run_roles = [
    "roles/artifactregistry.reader",
    "roles/logging.logWriter",
    "roles/pubsub.publisher"
  ]

  build_roles = [
    "roles/logging.logWriter",
    "roles/storage.admin",
    "roles/artifactregistry.writer",
    "roles/artifactregistry.reader",
    "roles/run.developer"
  ]
}

# Pub/Sub default service account roles
resource "google_project_iam_member" "pub-sub-role" {
  depends_on = [
    google_project_service.gcp_services
  ]
  for_each = toset(local.pub_sub_roles)
  project  = local.project_id
  role     = each.value
  member   = "serviceAccount:service-${local.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

# Cloud Run custom service account
resource "google_service_account" "cloudrun_service_account" {
  project    = local.project_id
  account_id = "cloudrun-sa"
}

# Cloud Run custom service account roles
resource "google_project_iam_member" "run-role" {
  depends_on = [
    google_project_service.gcp_services
  ]
  for_each = toset(local.run_roles)
  project  = local.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.cloudrun_service_account.email}"
}


# Cloud Build custom service account
resource "google_service_account" "cloudbuild_service_account" {
  project    = local.project_id
  account_id = "cloudbuild-sa"
}

# Cloud Run custom service account roles
resource "google_project_iam_member" "build-role" {
  depends_on = [
    google_project_service.gcp_services
  ]
  for_each = toset(local.build_roles)
  project  = local.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}


/*
# Allow unauthenticated invocations of Cloud Run service
resource "google_cloud_run_service_iam_binding" "unauthorised_access" {
  location = var.project_default_region
  project  = var.project_id
  service  = google_cloud_run_service.run.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}*/