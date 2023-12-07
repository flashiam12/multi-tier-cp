resource "helm_release" "postgresql" {
  name       = "postgresql-station-client"
  repository = "${path.module}/dependencies"
  chart      = "postgresql"
  namespace = local.namespaces.station_ns
  create_namespace = false
  cleanup_on_fail = true
  wait = true
  values = [
    "${file("${path.module}/dependencies/postgresql/values.yaml")}"
  ]
  set {
    name = "global.postgresql.auth.postgresPassword"
    value = "crisdemo2023"
  }
  set {
    name = "global.postgresql.auth.username"
    value = "admin"
  }
  set {
    name = "global.postgresql.auth.password"
    value = "crisdemo2023"
  }
  set {
    name = "global.postgresql.auth.database"
    value = "unreserved"
  }
  set {
    name = "architecture"
    value = "standalone"
  }
  set {
    name = "global.postgresql.wal_level"
    value = "logical"
  }
  set {
    name = "primary.existingConfigmap"
    value = "postgresql-conf"
  }
  set {
    name = "global.postgresql.auth.secretKeys.replicationPasswordKey"
    value = "confluent"
  }
  depends_on = [ kubernetes_config_map.postgresql-conf ]
}

data "kubectl_file_documents" "cp-station-connect" {
    content = file("${path.module}/workloads/cp-connect-station.yaml")
}

resource "kubectl_manifest" "cp-station-connect" {
  for_each  = data.kubectl_file_documents.cp-station-connect.manifests
  yaml_body = each.value
  depends_on = [
    helm_release.confluent-operator,
    # kubectl_manifest.cp-zone-dr,
    kubectl_manifest.cp-zone-primary
  ]
}