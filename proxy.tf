# resource "kubernetes_config_map" "nginx" {
#   provider = kubernetes.kubernetes-raw

#   metadata {
#     name      = "nginx-config"
#     namespace = local.namespaces.cfk_ns
#   }

#   data = {
#     "nginx.conf" = "${file("${path.module}/secrets/proxy.conf")}"
#   }
# }

# resource "kubernetes_deployment" "nginx" {
#   provider = kubernetes.kubernetes-raw

#   depends_on = [kubernetes_config_map.nginx]

#   metadata {
#     name      = "proxy"
#     namespace = local.namespaces.cfk_ns
#     labels = {
#       app = "nginx-proxy"
#     }
#   }

#   spec {
#     replicas = 1

#     selector {
#       match_labels = {
#         app = "nginx-proxy"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app                      = "nginx-proxy"
#           "app.kubernetes.io/name" = "nginx-proxy"
#         }
#       }

#       spec {
#         container {
#           image = "nginx:1.21.6"
#           name  = "nginx"

#           volume_mount {
#             name       = "config"
#             mount_path = "/etc/nginx/nginx.conf"
#             sub_path   = "nginx.conf"
#             read_only  = true
#           }
#             port {
#                 name            = "kafka"
#                 container_port  = 9092
#                 host_port       = 9092
#             }
#             port {
#                 name            = "https"
#                 host_port       = 443
#                 container_port  =  443
#             }
#             port {
#                 name            = "connect"
#                 container_port  = 8083
#                 host_port       = 8083
#             }
#             port {
#                 name            = "schema"
#                 container_port  = 8081
#                 host_port       = 8081
#             }
#             port {
#                 name            = "ksql"
#                 container_port  =  8088
#                 host_port       = 8088
#             }
#             port {
#                 name            = "c3"
#                 container_port  = 9021
#                 host_port       = 9021
#             }
#         }

#         volume {
#           name = "config"
#           config_map {
#             name = "nginx-config"
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "internal_nginx" {
#   provider = kubernetes.kubernetes-raw

#   spec {

#     selector = {
#       "app.kubernetes.io/name" = "nginx-proxy"
#     }
#     session_affinity = "ClientIP"
#     port {
#       name        = "kafka"
#       port        = 9092
#       target_port = 9092
#     }
#     port {
#       name        = "https"
#       port        = 443
#       target_port = 443
#     }
#     port {
#       name        = "connect"
#       port        = 8083
#       target_port = 8083
#     }
#     port {
#       name        = "schema"
#       port        = 8081
#       target_port = 8081
#     }
#     port {
#       name        = "ksql"
#       port        = 8088
#       target_port = 8088
#     }
#     port {
#       name        = "c3"
#       port        = 9021
#       target_port = 9021
#     }

#     type = "LoadBalancer"

#   }

#   metadata {
#     name      = "nginx-internal"
#     namespace = local.namespaces.cfk_ns
#     # annotations = {
#     #     "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "ip"
#     #     "service.beta.kubernetes.io/aws-load-balancer-type": "external"
#     #     "service.beta.kubernetes.io/aws-load-balancer-scheme": "internal"
#     #     "service.beta.kubernetes.io/aws-load-balancer-name": "nginxproxy-sts-eks"
#     #     "service.beta.kubernetes.io/aws-load-balancer-subnets": join(",", data.aws_subnets.private.ids)
#     # }
#   }
# }

