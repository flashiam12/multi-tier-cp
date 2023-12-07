data "kubectl_filename_list" "cfk-crds" {
    pattern = "${path.module}/dependencies/confluent-for-kubernetes/crds/*.yaml"
}

resource "kubectl_manifest" "cfk-crds" {
  count     = length(data.kubectl_filename_list.cfk-crds.matches)
  yaml_body = file(element(data.kubectl_filename_list.cfk-crds.matches, count.index))
  depends_on = [ kubernetes_namespace_v1.cris ]
}

resource "helm_release" "confluent-operator" {
  name       = "confluent-operator"
  chart      = "${path.module}/dependencies/confluent-for-kubernetes"
  namespace = local.namespaces.cfk_ns
  cleanup_on_fail = true
  create_namespace = false
  wait = true
  values = [file("${path.module}/dependencies/confluent-for-kubernetes/values.yaml")]
  set {
    name = "namespaced"
    value = "false"
  }
  depends_on = [
    kubectl_manifest.cfk-crds
  ]
}

data "kubectl_file_documents" "cfk-permissions" {
    content = file("${path.module}/dependencies/confluent-for-kubernetes/cfk-permission.yaml")
}

resource "kubectl_manifest" "cfk-permissions" {
  for_each  = data.kubectl_file_documents.cfk-permissions.manifests
  yaml_body = each.value
  depends_on = [
    helm_release.confluent-operator
  ]
}

