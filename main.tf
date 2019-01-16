/*resource "azurerm_resource_group" "resource_group" {
  name                     = "container-instances"
  location                 = "westeurope"
}*/

data "azurerm_resource_group" "containers" {
  name                     = "containers"
}

resource "random_id" "randomId" {
  keepers                  = {
    # Generate a new ID only when a new resource group is defined
    resource_group         = "${data.azurerm_resource_group.containers.name}"
  }

  byte_length              = 8
}

resource "azurerm_storage_account" "aci-sa" {
  name                     = "acisa${random_id.randomId.hex}"
  resource_group_name      = "${data.azurerm_resource_group.containers.name}"
  location                 = "${data.azurerm_resource_group.containers.location}"
  account_tier             = "Standard"

  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "aci-share" {
  name                     = "aci-vsts-share"
  resource_group_name      = "${data.azurerm_resource_group.containers.name}"
  storage_account_name     = "${azurerm_storage_account.aci-sa.name}"

  quota                    = 50
}

data "azurerm_container_registry" "acr" {
  name                     = "paulmackinnonacr"
  resource_group_name      = "${data.azurerm_resource_group.containers.name}"
}

resource "azurerm_container_group" "aci-vsts" {
  name                     = "aci-agent"
  location                 = "${data.azurerm_resource_group.containers.location}"
  resource_group_name      = "${data.azurerm_resource_group.containers.name}"
  ip_address_type          = "public"
  os_type                  = "linux"

  image_registry_credential {
    "username"           = "${data.azurerm_container_registry.acr.admin_username}"
    "password"           = "${data.azurerm_container_registry.acr.admin_password}"
    "server"             = "${data.azurerm_container_registry.acr.login_server}"
  }

  container {
    name                   = "vsts-agent-test"
    image                  = "paulmackinnonacr.azurecr.io/aci-agent:v1"
    cpu                    = "0.5"
    memory                 = "1.5"
    port                   = "80"

    environment_variables {
      "VSTS_ACCOUNT"       = "${var.vsts-account}"
      "VSTS_TOKEN"         = "${var.vsts-token}"
      "VSTS_AGENT"         = "${var.vsts-agent}"
      "VSTS_POOL"          = "${var.vsts-pool}"
    }

    volume {
      name                 = "logs"
      mount_path           = "/aci/logs"
      read_only            = false
      share_name           = "${azurerm_storage_share.aci-share.name}"

      storage_account_name = "${azurerm_storage_account.aci-sa.name}"
      storage_account_key  = "${azurerm_storage_account.aci-sa.primary_access_key}"
    }
  }

  tags {
    environment            = "aci"
  }
}