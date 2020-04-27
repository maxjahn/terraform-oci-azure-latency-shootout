##################################
# vpn network 

resource "oci_core_virtual_network" "vpn_vcn" {
  cidr_block     = var.oci_cidr_vpn_vcn
  dns_label      = "vpnvcn"
  compartment_id = var.oci_compartment_ocid
  display_name   = "vpn-vcn"
}

resource "oci_core_subnet" "vpn_subnet" {
  cidr_block        = var.oci_cidr_vpn_subnet
  compartment_id    = var.oci_compartment_ocid
  vcn_id            = oci_core_virtual_network.vpn_vcn.id
  display_name      = "vpn-subnet"
  dns_label         = "vpnsubnet"
  security_list_ids = [oci_core_security_list.vpn_sl.id]
}

resource "oci_core_internet_gateway" "vpn_igw" {
  display_name   = "vpn-internet-gateway"
  compartment_id = var.oci_compartment_ocid
  vcn_id         = oci_core_virtual_network.vpn_vcn.id
}

resource "oci_core_drg" "connect_drg" {
  compartment_id = var.oci_compartment_ocid
  display_name   = "connect-drg"
}

resource "oci_core_drg_attachment" "connect_drg_attachment" {
  drg_id       = oci_core_drg.connect_drg.id
  vcn_id       = oci_core_virtual_network.connect_vcn.id
  display_name = "vpn-drg-attachment"
}

resource "oci_core_default_route_table" "vpn_default_route_table" {
  manage_default_resource_id = oci_core_virtual_network.vpn_vcn.default_route_table_id

  route_rules {
    network_entity_id = oci_core_internet_gateway.vpn_igw.id
    destination       = "0.0.0.0/0"
  }

  route_rules {
    network_entity_id = module.vpn.oci_vpn_drg_id
    destination       = var.arm_cidr_vpn_vnet
  }
}

resource "oci_core_security_list" "vpn_sl" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = oci_core_virtual_network.vpn_vcn.id
  display_name   = "connect-security-list"

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "1"
  }

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"

    tcp_options {
      min = "22"
      max = "22"
    }
  }

  # azure
  ingress_security_rules {
    source      = var.arm_cidr_vpn_vnet
    description = "Azure VPN test VNet"
    protocol    = "6"

    tcp_options {
      min = "5000"
      max = "19800"
    }
  }
  ingress_security_rules {
    source      = var.arm_cidr_vpn_vnet
    description = "Azure VPN test VNet"
    protocol    = "17"

    udp_options {
      min = "5000"
      max = "19800"
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
}

resource "azurerm_virtual_network" "vpn_vnet" {
  name                = "vpn-network"
  resource_group_name = azurerm_resource_group.connect.name
  location            = azurerm_resource_group.connect.location
  address_space       = [var.arm_cidr_vpn_vnet]
}

resource "azurerm_subnet" "vpn_subnet" {
  name                 = "vpn-subnet"
  resource_group_name  = azurerm_resource_group.connect.name
  virtual_network_name = azurerm_virtual_network.vpn_vnet.name
  address_prefix       = var.arm_cidr_vpn_subnet
}

resource "azurerm_subnet" "vpn_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.connect.name
  virtual_network_name = azurerm_virtual_network.vpn_vnet.name
  address_prefix       = var.arm_cidr_vpn_gw_subnet
}

###############################
# general network

resource "oci_core_virtual_network" "connect_vcn" {
  cidr_block     = var.oci_cidr_vcn
  dns_label      = "connectvcn"
  compartment_id = var.oci_compartment_ocid
  display_name   = "connect-vcn"
}

resource "oci_core_subnet" "server_subnet" {
  cidr_block        = var.oci_cidr_server_subnet
  compartment_id    = var.oci_compartment_ocid
  vcn_id            = oci_core_virtual_network.connect_vcn.id
  display_name      = "server-subnet"
  dns_label         = "serversubbnet"
  security_list_ids = [oci_core_security_list.public_sl.id]
}

resource "oci_core_subnet" "client_subnet" {
  cidr_block        = var.oci_cidr_client_subnet
  compartment_id    = var.oci_compartment_ocid
  vcn_id            = oci_core_virtual_network.connect_vcn.id
  display_name      = "client-subnet"
  dns_label         = "clientsubnet"
  security_list_ids = [oci_core_security_list.client_sl.id]
}

resource "oci_core_internet_gateway" "connect_igw" {
  display_name   = "connect-internet-gateway"
  compartment_id = var.oci_compartment_ocid
  vcn_id         = oci_core_virtual_network.connect_vcn.id
}

resource "oci_core_default_route_table" "default_route_table" {
  manage_default_resource_id = oci_core_virtual_network.connect_vcn.default_route_table_id

  route_rules {
    network_entity_id = oci_core_internet_gateway.connect_igw.id
    destination       = "0.0.0.0/0"
  }

  route_rules {
    network_entity_id = oci_core_drg.connect_drg.id
    destination       = var.arm_cidr_vnet
  }
}

resource "oci_core_security_list" "public_sl" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = oci_core_virtual_network.connect_vcn.id
  display_name   = "public-security-list"

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "1"
  }

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"

    tcp_options {
      min = "22"
      max = "22"
    }
  }

  # enable iperf server ports for iperf test clients 

  # oci 
  ingress_security_rules {
    source      = "${oci_core_instance.conn-client-node.public_ip}/32"
    description = "OCI test client VM"
    protocol    = "6"

    tcp_options {
      min = "5000"
      max = "19800"
    }
  }
  ingress_security_rules {
    source      = "${oci_core_instance.conn-client-node.public_ip}/32"
    description = "OCI test client VM"
    protocol    = "17"

    udp_options {
      min = "5000"
      max = "19800"
    }
  }

  ingress_security_rules {
    source      = var.oci_cidr_vcn
    description = "OCI test VCN"
    protocol    = "6"

    tcp_options {
      min = "5000"
      max = "19800"
    }
  }
  ingress_security_rules {
    source      = var.oci_cidr_vcn
    description = "OCI test VCN"
    protocol    = "17"

    udp_options {
      min = "5000"
      max = "19800"
    }
  }

  # azure
  ingress_security_rules {
    source = "${data.azurerm_public_ip.client_test.ip_address}/32"

    #source   = "${azurerm_public_ip.client_test_ip.ip_address}/32"
    description = "Azure test client VM"
    protocol    = "6"

    tcp_options {
      min = "5000"
      max = "19800"
    }
  }
  ingress_security_rules {
    #source   = "${azurerm_public_ip.client_test_ip.ip_address}/32"
    source      = "${data.azurerm_public_ip.client_test.ip_address}/32"
    description = "Azure test client VM"
    protocol    = "17"

    udp_options {
      min = "5000"
      max = "19800"
    }
  }

  # azure
  ingress_security_rules {
    source      = var.arm_cidr_vnet
    description = "Azure test VNet"
    protocol    = "6"

    tcp_options {
      min = "5000"
      max = "19800"
    }
  }
  ingress_security_rules {
    source      = var.arm_cidr_vnet
    description = "Azure test VNet"
    protocol    = "17"

    udp_options {
      min = "5000"
      max = "19800"
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
}

resource "oci_core_security_list" "client_sl" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = oci_core_virtual_network.connect_vcn.id
  display_name   = "public-security-list"

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "1"
  }

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"

    tcp_options {
      min = "22"
      max = "22"
    }
  }

  # enable iperf server ports for iperf test clients 

  ingress_security_rules {
    source      = var.oci_cidr_vcn
    description = "OCI test VCN"
    protocol    = "6"

    tcp_options {
      min = "5000"
      max = "19800"
    }
  }
  ingress_security_rules {
    source      = var.oci_cidr_vcn
    description = "OCI test VCN"
    protocol    = "17"

    udp_options {
      min = "5000"
      max = "19800"
    }
  }

  # azure
  ingress_security_rules {
    #source   = "${azurerm_public_ip.client_test_ip.ip_address}/32"
    source      = "${data.azurerm_public_ip.client_test.ip_address}/32"
    description = "Azure test client VM"
    protocol    = "6"

    tcp_options {
      min = "5000"
      max = "19800"
    }
  }
  ingress_security_rules {
    #source   = "${azurerm_public_ip.client_test_ip.ip_address}/32"
    source      = "${data.azurerm_public_ip.client_test.ip_address}/32"
    description = "Azure test client VM"
    protocol    = "17"

    udp_options {
      min = "5000"
      max = "19800"
    }
  }

  # azure
  ingress_security_rules {
    source      = var.arm_cidr_vnet
    description = "Azure test VNet"
    protocol    = "6"

    tcp_options {
      min = "5000"
      max = "19800"
    }
  }
  ingress_security_rules {
    source      = var.arm_cidr_vnet
    description = "Azure test VNet"
    protocol    = "17"

    udp_options {
      min = "5000"
      max = "19800"
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
}

resource "azurerm_resource_group" "connect" {
  name     = "connect"
  location = var.arm_region
}

resource "azurerm_virtual_network" "connect_vnet" {
  name                = "connect-network"
  resource_group_name = azurerm_resource_group.connect.name
  location            = azurerm_resource_group.connect.location
  address_space       = [var.arm_cidr_vnet]
}

resource "azurerm_subnet" "client_subnet" {
  name                 = "client-subnet"
  resource_group_name  = azurerm_resource_group.connect.name
  virtual_network_name = azurerm_virtual_network.connect_vnet.name
  address_prefix       = var.arm_cidr_client_subnet
}

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.connect.name
  virtual_network_name = azurerm_virtual_network.connect_vnet.name
  address_prefix       = var.arm_cidr_gw_subnet
}

data "template_file" "perf_client" {
  template = file("templates/perf_client.tpl")
  vars = {
    host_name = "$${HOSTNAME}"
  }
}

data "template_file" "perf_server" {
  template = file("templates/perf_server.tpl")
  vars     = {}
}

## testing clients
resource "azurerm_public_ip" "client_test_ip" {
  name                = "client-test-ip"
  location            = azurerm_resource_group.connect.location
  resource_group_name = azurerm_resource_group.connect.name
  allocation_method   = "Dynamic"
}

data "azurerm_public_ip" "client_test" {
  name                = azurerm_public_ip.client_test_ip.name
  resource_group_name = azurerm_resource_group.connect.name
}

resource "azurerm_network_interface" "client_nic" {
  name                = "client-nic"
  location            = azurerm_resource_group.connect.location
  resource_group_name = azurerm_resource_group.connect.name

  ip_configuration {
    name                          = "client-nic-config"
    subnet_id                     = azurerm_subnet.client_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.client_test_ip.id
  }
}

resource "azurerm_virtual_machine" "client_node" {
  name                  = "client-node"
  location              = azurerm_resource_group.connect.location
  resource_group_name   = azurerm_resource_group.connect.name
  network_interface_ids = [azurerm_network_interface.client_nic.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.arm_image_publisher
    offer     = var.arm_image_offer
    sku       = var.arm_image_sku
    version   = var.arm_image_version
  }

  storage_os_disk {
    name              = "client_osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "az-client"
    admin_username = "azure"
    admin_password = "Welcome-1234"
    custom_data    = data.template_file.perf_client.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = var.ssh_public_key
      path     = "/home/azure/.ssh/authorized_keys"
    }
  }
}

## testing servers
resource "azurerm_public_ip" "server_test_ip" {
  name                = "server-test-ip"
  location            = azurerm_resource_group.connect.location
  resource_group_name = azurerm_resource_group.connect.name
  allocation_method   = "Dynamic"
}

data "azurerm_public_ip" "server_test" {
  name                = azurerm_public_ip.server_test_ip.name
  resource_group_name = azurerm_resource_group.connect.name
}

resource "azurerm_network_interface" "server_nic" {
  name                = "server-nic"
  location            = azurerm_resource_group.connect.location
  resource_group_name = azurerm_resource_group.connect.name

  ip_configuration {
    name                          = "server-nic-config"
    subnet_id                     = azurerm_subnet.client_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.server_test_ip.id
  }
}

resource "azurerm_virtual_machine" "server_node" {
  name                  = "server-node"
  location              = azurerm_resource_group.connect.location
  resource_group_name   = azurerm_resource_group.connect.name
  network_interface_ids = [azurerm_network_interface.server_nic.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.arm_image_publisher
    offer     = var.arm_image_offer
    sku       = var.arm_image_sku
    version   = var.arm_image_version
  }

  storage_os_disk {
    name              = "server_osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "az-server"
    admin_username = "azure"
    admin_password = "Welcome-1234"
    custom_data    = data.template_file.perf_server.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = var.ssh_public_key
      path     = "/home/azure/.ssh/authorized_keys"
    }
  }
}

data "oci_identity_availability_domains" "connect_ads" {
  compartment_id = var.oci_compartment_ocid
}

### testing client 

resource "oci_core_instance" "conn-client-node" {
  availability_domain = data.oci_identity_availability_domains.connect_ads.availability_domains[0]["name"]
  compartment_id      = var.oci_compartment_ocid
  shape               = "VM.Standard2.1"

  create_vnic_details {
    subnet_id              = oci_core_subnet.client_subnet.id
    assign_public_ip       = true
    skip_source_dest_check = true
  }

  display_name = "oci-client"

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(data.template_file.perf_client.rendered)
  }

  source_details {
    source_id   = var.oci_base_image
    source_type = "image"
  }

  preserve_boot_volume = false
}

### testing server

resource "oci_core_instance" "conn-server-node" {
  availability_domain = data.oci_identity_availability_domains.connect_ads.availability_domains[0]["name"]
  compartment_id      = var.oci_compartment_ocid
  shape               = "VM.Standard2.1"

  create_vnic_details {
    subnet_id              = oci_core_subnet.server_subnet.id
    assign_public_ip       = true
    skip_source_dest_check = true
  }

  display_name = "connect-server"

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(data.template_file.perf_server.rendered)
  }

  source_details {
    source_id   = var.oci_base_image
    source_type = "image"
  }

  preserve_boot_volume = false
}

### vpn testing server

resource "oci_core_instance" "vpn-server-node" {
  availability_domain = data.oci_identity_availability_domains.connect_ads.availability_domains[0]["name"]
  compartment_id      = var.oci_compartment_ocid
  shape               = "VM.Standard2.1"

  create_vnic_details {
    subnet_id              = oci_core_subnet.vpn_subnet.id
    assign_public_ip       = true
    skip_source_dest_check = true
  }

  display_name = "vpn-server"

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(data.template_file.perf_server.rendered)
  }

  source_details {
    source_id   = var.oci_base_image
    source_type = "image"
  }

  preserve_boot_volume = false
}

### vpn testing client

resource "azurerm_public_ip" "vpn_client_test_ip" {
  name                = "vpn_client-test-ip"
  location            = azurerm_resource_group.connect.location
  resource_group_name = azurerm_resource_group.connect.name
  allocation_method   = "Dynamic"
}

data "azurerm_public_ip" "vpn_client_test" {
  name                = azurerm_public_ip.vpn_client_test_ip.name
  resource_group_name = azurerm_resource_group.connect.name
}

resource "azurerm_network_interface" "vpn_client_nic" {
  name                = "vpn_client-nic"
  location            = azurerm_resource_group.connect.location
  resource_group_name = azurerm_resource_group.connect.name

  ip_configuration {
    name                          = "vpn_client-nic-config"
    subnet_id                     = azurerm_subnet.vpn_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vpn_client_test_ip.id
  }
}

resource "azurerm_virtual_machine" "vpn_client_node" {
  name                  = "vpn-client-node"
  location              = azurerm_resource_group.connect.location
  resource_group_name   = azurerm_resource_group.connect.name
  network_interface_ids = [azurerm_network_interface.vpn_client_nic.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.arm_image_publisher
    offer     = var.arm_image_offer
    sku       = var.arm_image_sku
    version   = var.arm_image_version
  }

  storage_os_disk {
    name              = "vpn_client_osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "az-vpn-client"
    admin_username = "azure"
    admin_password = "Welcome-1234"
    custom_data    = data.template_file.perf_server.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = var.ssh_public_key
      path     = "/home/azure/.ssh/authorized_keys"
    }
  }
}

## modules 

module "vpn" {
  source = "./modules/vpn"

  oci_compartment_ocid = var.oci_compartment_ocid

  oci_vpn_vcn_id      = oci_core_virtual_network.vpn_vcn.id
  oci_vpn_subnet_cidr = var.oci_cidr_vpn_subnet

  oci_azure_provider_ocid = var.oci_azure_provider_ocid

  arm_resource_group_location = azurerm_resource_group.connect.location
  arm_resource_group_name     = azurerm_resource_group.connect.name

  arm_cidr_vnet        = var.arm_cidr_vnet
  arm_vpn_subnet_cidr  = var.arm_cidr_vpn_subnet
  arm_vpn_gw_subnet_id = azurerm_subnet.vpn_gateway_subnet.id

  peering_net = var.peering_net
}

module "interconnect" {
  source = "./modules/interconnect"

  oci_compartment_ocid = var.oci_compartment_ocid
  oci_vcn_cidr         = var.oci_cidr_vcn
  oci_server_subnet_id = oci_core_subnet.server_subnet.id

  oci_drg_id = oci_core_drg.connect_drg.id
  oci_igw_id = oci_core_internet_gateway.connect_igw.id
  oci_vcn_id = oci_core_virtual_network.connect_vcn.id

  oci_azure_provider_ocid     = var.oci_azure_provider_ocid
  arm_resource_group_location = azurerm_resource_group.connect.location
  arm_resource_group_name     = azurerm_resource_group.connect.name

  arm_vnet_cidr        = var.arm_cidr_vnet
  arm_gw_subnet_id     = azurerm_subnet.gateway_subnet.id
  arm_expressroute_sku = var.arm_expressroute_sku

  peering_net = var.peering_net
}

