output "oci_private_ip_client_node" {
  value = oci_core_instance.conn-client-node.private_ip
}

output "oci_public_ip_client_node" {
  value = oci_core_instance.conn-client-node.public_ip
}

output "oci_private_ip_server_node" {
  value = oci_core_instance.conn-server-node.private_ip
}

output "oci_public_ip_server_node" {
  value = oci_core_instance.conn-server-node.public_ip
}

output "oci_private_ip_vpn_server_node" {
  value = oci_core_instance.vpn-server-node.private_ip
}

output "oci_public_ip_vpn_server_node" {
  value = oci_core_instance.vpn-server-node.public_ip
}

output "azure_private_ip_client_node" {
  #value = "${azurerm_network_interface.client_nic.private_ip_address}"
  value = data.azurerm_public_ip.client_test.ip_address
}

output "azure_public_ip_client_node" {
  value = azurerm_public_ip.client_test_ip.ip_address
}

output "azure_private_ip_server_node" {
  value = azurerm_network_interface.server_nic.private_ip_address
}

output "azure_public_ip_server_node" {
  #value = "${azurerm_public_ip.server_test_ip.ip_address}"
  value = data.azurerm_public_ip.server_test.ip_address
}

output "azure_private_ip_vpn_client_node" {
  value = azurerm_network_interface.vpn_client_nic.private_ip_address
}

output "azure_public_ip_vpn_client_node" {
  #value = "${azurerm_public_ip.vpn_client_test_ip.ip_address}"
  value = data.azurerm_public_ip.vpn_client_test.ip_address
}

