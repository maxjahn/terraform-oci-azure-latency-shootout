output "oci_vpn_tunnel1_public_ip" {
    value = "${data.oci_core_ipsec_connection_tunnels.azure_ipsec_tunnels.ip_sec_connection_tunnels.0.vpn_ip}"
}

output "oci_vpn_tunnel2_public_ip" {
    value = "${data.oci_core_ipsec_connection_tunnels.azure_ipsec_tunnels.ip_sec_connection_tunnels.1.vpn_ip}"
}

output "oci_vpn_drg_id" {
    value = "${oci_core_drg.vpn_drg.id}"
}

output "azure_vpn_vng_ip" {
  value = "${azurerm_public_ip.vpn_vng_ip.ip_address}"
}






