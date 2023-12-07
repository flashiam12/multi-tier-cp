resource "helm_release" "primary" {
  name       = "postgresql-zone-centralized"
  repository = "${path.module}/dependencies"
  chart      = "postgresql"
  namespace = local.namespaces.zone_ns
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

resource "helm_release" "disaster-recovery" {
  name       = "postgresql-zone-dr"
  repository = "${path.module}/dependencies"
  chart      = "postgresql"
  namespace = local.namespaces.zone_dr_ns
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

resource "helm_release" "data-warehouse" {
  name       = "clickhouse-dw"
  repository = "${path.module}/dependencies"
  chart      = "clickhouse"
  namespace = local.namespaces.zone_dw_ns
  create_namespace = false
  cleanup_on_fail = true
  wait = true
  values = [
    "${file("${path.module}/dependencies/clickhouse/values.yaml")}"
  ]
  set {
    name = "auth.username"
    value = "crisadmin"
  }
  set {
    name = "auth.password"
    value = "crisdemo2023"
  }
  set {
    name = "shards"
    value = "1"
  }
  set {
    name = "replicaCount"
    value = "1"
  }
  set {
    name = "zookeeper.replicaCount"
    value = "1"
  }
}

data "kubectl_file_documents" "cp-zone-primary" {
    content = file("${path.module}/workloads/cp-zone-primary.yaml")
}

resource "kubectl_manifest" "cp-zone-primary" {
  for_each  = data.kubectl_file_documents.cp-zone-primary.manifests
  yaml_body = each.value
  depends_on = [
    helm_release.confluent-operator,
    kubernetes_secret.credential-c1,
    kubernetes_secret.password-encoder-secret-c1
  ]
}

data "kubectl_file_documents" "cp-zone-dr" {
    content = file("${path.module}/workloads/cp-zone-dr.yaml")
}

resource "kubectl_manifest" "cp-zone-dr" {
  for_each  = data.kubectl_file_documents.cp-zone-dr.manifests
  yaml_body = each.value
  depends_on = [
    helm_release.confluent-operator,
    kubernetes_secret.credential-c2,
    kubernetes_secret.password-encoder-secret-c2
  ]
}

data "kubectl_file_documents" "cp-zone-c3" {
    content = file("${path.module}/workloads/cp-controlcenter.yaml")
}

resource "kubectl_manifest" "cp-zone-c3" {
  for_each  = data.kubectl_file_documents.cp-zone-c3.manifests
  yaml_body = each.value
  depends_on = [
    helm_release.confluent-operator,
    kubectl_manifest.cp-zone-dr,
    kubectl_manifest.cp-zone-primary,
    kubectl_manifest.cp-station-connect,
    kubectl_manifest.cp-zone-connect
  ]
}

data "kubectl_file_documents" "cp-zone-connect" {
    content = file("${path.module}/workloads/cp-connect-zone.yaml")
}

resource "kubectl_manifest" "cp-zone-connect" {
  for_each  = data.kubectl_file_documents.cp-zone-connect.manifests
  yaml_body = each.value
  depends_on = [
    helm_release.confluent-operator,
    kubectl_manifest.cp-zone-dr,
    kubectl_manifest.cp-zone-primary
  ]
}

data "kubectl_file_documents" "cp-zone-ksql" {
    content = file("${path.module}/workloads/cp-ksql-zone.yaml")
}

resource "kubectl_manifest" "cp-zone-ksql" {
  for_each  = data.kubectl_file_documents.cp-zone-ksql.manifests
  yaml_body = each.value
  depends_on = [
    helm_release.confluent-operator,
    kubectl_manifest.cp-zone-dr,
    kubectl_manifest.cp-zone-primary
  ]
}

