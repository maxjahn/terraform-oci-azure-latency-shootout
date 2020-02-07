variable "oci_tenancy_ocid" {}
variable "oci_user_ocid" {}
variable "oci_fingerprint" {}
variable "oci_private_key_path" {}
variable "oci_compartment_ocid" {}
variable "oci_region" {}

variable "oci_cidr_vcn" {}
variable "oci_cidr_client_subnet" {}
variable "oci_cidr_server_subnet" {}

variable "oci_cidr_vpn_vcn" {}
variable "oci_cidr_vpn_subnet" {}

variable "oci_azure_provider_ocid" {}

variable "oci_base_image" {}
variable "arm_subscription_id" {}
variable "arm_client_id" {}
variable "arm_client_secret" {}
variable "arm_tenant_id" {}
variable "arm_region" {}

variable "arm_image_publisher" {}
variable "arm_image_offer" {}
variable "arm_image_sku" {}
variable "arm_image_version" {}

variable "arm_expressroute_sku" {}

variable "arm_cidr_vnet" {}
variable "arm_cidr_client_subnet" {}
variable "arm_cidr_gw_subnet" {}

variable "arm_cidr_vpn_vnet" {}
variable "arm_cidr_vpn_subnet" {}
variable "arm_cidr_vpn_gw_subnet" {}

variable "ssh_public_key" {}
variable "peering_net" {}



