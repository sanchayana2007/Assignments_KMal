# GCP authentication file
variable "gcp_auth_file" {
  type        = string
  default     = "../seismic-elf-261104-c47aa69e86d6.json"
  description = "GCP authentication file"
}
# define GCP region
variable "gcp_region" {
  type        = string
  default = "us-central1" 
  description = "GCP region"
}
# define GCP project name
variable "gcp_project" {
  type        = string
  default = "seismic-elf-261104"
   description = "GCP project name"
}

# define GCP zone
variable "gcp_zone" {
  type        = string
  default = "us-central1-a" 
  description = "GCP zone"
}

# define GCP zone
variable "service" {
  type        = string
  default = "compute.googleapis.com" 
  description = "GCP zone"
}


variable "var_env" {
        default = "dev"
    }
variable "var_company" { 
        default = "Sanchez.xyz"
    }
variable "private_subnet" {
        default = "192.168.1.0/16"
    }
variable "public_subnet" {
        default = "10.10.2.0/24"
    }
