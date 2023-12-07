resource "kubernetes_config_map" "postgresql-conf" {
  for_each = local.namespaces
  provider = kubernetes.kubernetes-raw
  metadata {
    name = "postgresql-conf"
    namespace = each.value
  }

  data = {
    "postgresql.conf" = "${file("./dependencies/postgresql/postgresql.conf")}"
  }

}

resource "kubernetes_secret" "credential-c1" {
  provider = kubernetes.kubernetes-raw
  metadata {
    name = "credential"
    namespace = local.namespaces.zone_ns
  }

  data = {
    "plain-users.json" = "${file("./secrets/creds-kafka-sasl-users.json")}"
    "plain.txt" = "${file("./secrets/creds-client-kafka-sasl-user.txt")}"
    "basic.txt" = "${file("./secrets/creds-basic-user.txt")}"
  }

  type = "kubernetes.io/generic"
  depends_on = [ helm_release.confluent-operator ]
}

resource "kubernetes_secret" "password-encoder-secret-c1" {
  provider = kubernetes.kubernetes-raw
  metadata {
    name = "password-encoder-secret"
    namespace = local.namespaces.zone_ns
  }

  data = {
    "password-encoder.txt" = "${file("./secrets/passwordencoder.txt")}"
  }

  type = "kubernetes.io/generic"
  depends_on = [ helm_release.confluent-operator ]
}

resource "kubernetes_secret" "credential-c2" {
  provider = kubernetes.kubernetes-raw
  metadata {
    name = "credential"
    namespace = local.namespaces.station_ns
  }

  data = {
    "plain-users.json" = "${file("./secrets/creds-kafka-sasl-users.json")}"
    "plain.txt" = "${file("./secrets/creds-client-kafka-sasl-user.txt")}"
    "basic.txt" = "${file("./secrets/creds-basic-user.txt")}"
  }

  type = "kubernetes.io/generic"
  depends_on = [ helm_release.confluent-operator ]
}

resource "kubernetes_secret" "password-encoder-secret-c2" {
  provider = kubernetes.kubernetes-raw
  metadata {
    name = "password-encoder-secret"
    namespace = local.namespaces.station_ns

  }

  data = {
    "password-encoder.txt" = "${file("./secrets/passwordencoder.txt")}"
  }

  type = "kubernetes.io/generic"
  depends_on = [ helm_release.confluent-operator ]
}

resource "kubernetes_secret" "credential-c3" {
  provider = kubernetes.kubernetes-raw
  metadata {
    name = "credential"
    namespace = local.namespaces.zone_dr_ns
  }

  data = {
    "plain-users.json" = "${file("./secrets/creds-kafka-sasl-users.json")}"
    "plain.txt" = "${file("./secrets/creds-client-kafka-sasl-user.txt")}"
    "basic.txt" = "${file("./secrets/creds-basic-user.txt")}"
  }

  type = "kubernetes.io/generic"
  depends_on = [ helm_release.confluent-operator ]
}

resource "kubernetes_secret" "password-encoder-secret-c3" {
  provider = kubernetes.kubernetes-raw
  metadata {
    name = "password-encoder-secret"
    namespace = local.namespaces.zone_dr_ns

  }

  data = {
    "password-encoder.txt" = "${file("./secrets/passwordencoder.txt")}"
  }

  type = "kubernetes.io/generic"
  depends_on = [ helm_release.confluent-operator ]
}