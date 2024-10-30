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


# LB with https (http redirect to https)
resource "google_compute_target_http_proxy" "default" {
  project = var.project_id
  name    = "${var.project_id}-http-proxy"
  url_map = google_compute_url_map.https_redirect.self_link
}

resource "google_compute_target_https_proxy" "default" {
  project = var.project_id
  name    = "${var.project_id}-https-proxy"
  url_map = google_compute_url_map.default.self_link

  ssl_certificates = [
    google_compute_managed_ssl_certificate.default.self_link
  ]
}

resource "google_compute_managed_ssl_certificate" "default" {
  project = var.project_id
  name    = "${var.project_id}-cert"

  lifecycle {
    create_before_destroy = true
  }

  managed {
    domains = [var.domain]
  }
}

resource "google_compute_url_map" "https_redirect" {
  project = var.project_id
  name    = "${var.project_id}-https-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_global_forwarding_rule" "http" {
  project    = var.project_id
  name       = "${var.project_id}-http"
  target     = google_compute_target_http_proxy.default.self_link
  ip_address = google_compute_global_address.default.address
  port_range = "80"
}

resource "google_compute_global_forwarding_rule" "https" {
  project    = var.project_id
  name       = "${var.project_id}-https"
  target     = google_compute_target_https_proxy.default.self_link
  ip_address = google_compute_global_address.default.address
  port_range = "443"
}

resource "google_compute_global_address" "default" {
  project    = var.project_id
  name       = "${var.project_id}-address"
  ip_version = "IPV4"
}

resource "google_compute_url_map" "default" {
  depends_on = [
    google_compute_backend_service.run-backend-srv
  ]

  project         = var.project_id
  name            = "${var.project_id}-url-map"
  default_service = google_compute_backend_service.run-backend-srv.self_link
}