resource "oci_core_cpe" "azure_cpe" {
  display_name   = "azure-cpe"
  compartment_id = var.oci_compartment_ocid
  ip_address     = azurerm_public_ip.vpn_vng_ip.ip_address
}

resource "oci_core_drg" "vpn_drg" {
  compartment_id = var.oci_compartment_ocid
  display_name   = "vpn-drg"
}

resource "oci_core_drg_attachment" "vpn_drg_attachment" {
  drg_id       = oci_core_drg.vpn_drg.id
  vcn_id       = var.oci_vpn_vcn_id
  display_name = "vpn-drg-attachment"
}

resource "oci_core_ipsec" "vpn_ipsec_connection" {
  compartment_id = var.oci_compartment_ocid
  display_name   = "azure-ipsec-connection"
  cpe_id         = oci_core_cpe.azure_cpe.id
  drg_id         = oci_core_drg.vpn_drg.id
  static_routes  = [var.arm_vpn_subnet_cidr]
}

data "oci_core_ipsec_connection_tunnels" "azure_ipsec_tunnels" {
  ipsec_id = oci_core_ipsec.vpn_ipsec_connection.id
}

data "oci_core_ipsec_config" "azure_ipsec_connection_device_config" {
  ipsec_id = oci_core_ipsec.vpn_ipsec_connection.id
}

resource "oci_core_ipsec_connection_tunnel_management" "vpn_ipsec_connection_tunnel" {
  ipsec_id    = oci_core_ipsec.vpn_ipsec_connection.id
  tunnel_id   = data.oci_core_ipsec_connection_tunnels.azure_ipsec_tunnels.ip_sec_connection_tunnels[0].id
  routing     = "STATIC"
  ike_version = "V2"
}

resource "azurerm_public_ip" "vpn_vng_ip" {
  name                = "vpn-vng-ip"
  location            = var.arm_resource_group_location
  resource_group_name = var.arm_resource_group_name
  allocation_method   = "Dynamic"
}

data "azurerm_public_ip" "vpn_vng_ip" {
  name                = azurerm_public_ip.vpn_vng_ip.name
  resource_group_name = var.arm_resource_group_name
}

resource "azurerm_virtual_network_gateway" "vpn_vng" {
  name                = "vpn-vng"
  location            = var.arm_resource_group_location
  resource_group_name = var.arm_resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = "Standard"

  ip_configuration {
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.arm_vpn_gw_subnet_id
    public_ip_address_id          = azurerm_public_ip.vpn_vng_ip.id
  }
}

resource "azurerm_local_network_gateway" "oci_vpn_lng" {
  name                = "oci-vpn-local-network-gateway"
  location            = var.arm_resource_group_location
  resource_group_name = var.arm_resource_group_name
  gateway_address     = data.oci_core_ipsec_connection_tunnels.azure_ipsec_tunnels.ip_sec_connection_tunnels[0].vpn_ip
  address_space       = [var.oci_vpn_subnet_cidr]
}

resource "azurerm_virtual_network_gateway_connection" "oci_vpn_vng_conn" {
  name                       = "oci-vpn-local-network-gateway"
  location                   = var.arm_resource_group_location
  resource_group_name        = var.arm_resource_group_name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_vng.id
  local_network_gateway_id   = azurerm_local_network_gateway.oci_vpn_lng.id
  shared_key                 = data.oci_core_ipsec_config.azure_ipsec_connection_device_config.tunnels[0].shared_secret
}

