output "kube_config" {
  value = azurerm_kubernetes_cluster.projet-cloud-cluser-aks.kube_config_raw

  sensitive = true
}