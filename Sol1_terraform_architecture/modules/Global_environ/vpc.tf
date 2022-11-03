resource "google_compute_network" "vpc" {
  name          =  format("%s","var.company}-${var.env}-vpc")
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}
resource "google_compute_firewall" "allow-internal" {
  name    = "${var.company}-fw-allow-internal"
  network = google_compute_network.vpc.name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  source_ranges = [
    var.var_private_subnet,
  
    var.var_public_subnet,
   
  ]
}
resource "google_compute_firewall" "allow-http" {
  name    = "${var.company}-fw-allow-http"
  network = google_compute_network.vpc.name
allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http"] 
}
resource "google_compute_firewall" "allow-bastion" {
  name    = "${var.company}-fw-allow-bastion"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh"]
  }