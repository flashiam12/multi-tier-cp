terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.9.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    http = {
      source = "hashicorp/http"
      version = "3.4.0"
    }
  }
}

provider "http" {
  # Configuration options
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "kind-cris"
  }
}

provider "kubernetes" {
  alias = "kubernetes-raw"
  config_path    = "~/.kube/config"
  config_context = "kind-cris"
}

provider "kubectl" {
  config_path    = "~/.kube/config"
  config_context = "kind-cris"
}

locals {
  namespaces = {
    station_ns = "station"
    cfk_ns = "confluent"
    zone_ns = "zone"
    zone_dr_ns = "zone-dr"
    zone_dw_ns = "zone-dw"
  }
}

resource "kubernetes_namespace_v1" "cris" {
  provider = kubernetes.kubernetes-raw
  for_each = local.namespaces
  metadata {
    name = each.value
    labels = {
      "name" = each.value
      "purpose" = each.key
    }
  }
}

# data "kubectl_file_documents" "metal-lb" {
#     content = file("${path.module}/workloads/metallb-native.yaml")
# }

# resource "kubectl_manifest" "metal-lb" {
#   for_each  = data.kubectl_file_documents.metal-lb.manifests
#   yaml_body = each.value
# }

# data "kubectl_file_documents" "metal-lb-config" {
#     content = file("${path.module}/workloads/metallb-config.yaml")
# }

# resource "kubectl_manifest" "metal-lb-config" {
#   for_each  = data.kubectl_file_documents.metal-lb-config.manifests
#   yaml_body = each.value
#   depends_on = [ kubectl_manifest.metal-lb ]
# }