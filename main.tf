resource "google_compute_forwarding_rule" "forwarding_rule_java_hello" {
  name                  = "forwarding-rule-java-hello"
  region                = "europe-west3"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_region_target_https_proxy.target_proxy_java_hello.id
  #network               = 
  #subnetwork            =   
  network_tier          = "PREMIUM"
}

resource "google_compute_region_target_https_proxy" "target_proxy_java_hello" {
    project           = "banktestproject-398221"
    name              = "https-proxy-java-hello"
    region            = "europe-west3"
    url_map           = google_compute_region_url_map.url_map_java_hello.id
    ssl_certificates  = [google_compute_ssl_certificate.ssl_certificate_java_hello.id]
}

resource "google_compute_ssl_certificate" "ssl_certificate_java_hello" {
    project     = "banktestproject-398221"
    name        = "ssl-certificate-java-hello"
    private_key = file("/Users/amitpatil/MyWork/javaprogramm/helloworld/ca-key.pem")
    certificate = file("/Users/amitpatil/MyWork/javaprogramm/helloworld/ca.pem")
}

resource "google_compute_region_url_map" "url_map_java_hello" {
    project         = "banktestproject-398221"
    name            = "java-helloworld-regional-url-map"
    region          = "europe-west3"
    default_service = google_compute_region_backend_service.backend_java_hello.self_link

    host_rule {
      hosts         = ["*"]
      path_matcher  = "path-matcher"
    }   

    path_matcher {
      name = "path-matcher"
      default_service = google_compute_region_backend_service.backend_java_hello.self_link
    }
}

resource "google_compute_http_health_check" "health_check" {
    project             = "banktestproject-398221"
    name                = "my-http-health-check"
    request_path        = "/"
    check_interval_sec  = 10
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
}

resource "google_compute_region_backend_service" "backend_java_hello" {
    project               = "banktestproject-398221"
    name                  = "backend-java-hello-service"
    region                = "europe-west3"
   # health_checks         = [google_compute_http_health_check.health_check.id] 
    protocol              = "HTTPS"
    load_balancing_scheme = "INTERNAL_MANAGED"
    backend {
      group = google_compute_region_network_endpoint_group.cloudrun_neg.id
      balancing_mode  = "UTILIZATION"
    }
  
}


resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
    project               = "banktestproject-398221"
    name                  = "cloudrun-neg"
    network_endpoint_type = "SERVERLESS"
    region                = "europe-west3"
    cloud_run {
      service = "java-helloworld"
    }
  
}