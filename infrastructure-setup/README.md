# Instructions for setting environment up using terraform

## Environment Variables

The file set_env contains a couple of environment variables that need to be set. Before starting terraform source this file (`. set_env`). The following variables need to be adapted.

### General

`TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)`

### OCI

`TF_VAR_oci_tenancy_ocid="ocid1.tenancy.oc1.."`

`TF_VAR_oci_user_ocid="ocid1.user.oc1.."`

`TF_VAR_oci_compartment_ocid="ocid1.compartment.oc1.."`

`TF_VAR_oci_fingerprint= ...`

`TF_VAR_oci_private_key_path=.oci/oci_api_key.pem`

### Azure

`TF_VAR_arm_client_id= ...`

`TF_VAR_arm_client_secret= ...`

`TF_VAR_arm_tenant_id= ...`

`TF_VAR_arm_subscription_id= ...`

`TF_VAR_arm_expressroute_sku="..."` default value "Standard". Use "Ultraperformance" to see FastPath feature enabled.

### Interconnect Region

`TF_VAR_oci_region=uk-london-1`

`TF_VAR_oci_base_image= ...`

`TF_VAR_oci_remote_base_image= ...`

`TF_VAR_oci_azure_provider_ocid= ...`

`TF_VAR_arm_region="UK South"


### 


