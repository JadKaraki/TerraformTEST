
# VARIABLES 

variable "resource_group" {
  description = "The name of the resource group in which the virtual networks are created"
  default     = "myrg"
}

variable "location" {
  description = "The location/region where the virtual networks are created."
  default     = "westeurope"
}

variable "sql_admin" {
  description = "The administrator username of the SQL Server."
}

variable "sql_password" {
  description = "The administrator password of the SQL Server."
}



# RESOURCES TO BE DEPLOYED
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "${var.resource_group}-vnet1"
  location            = "${var.location}"
  address_space       = ["10.0.0.0/24"]
  resource_group_name = "${azurerm_resource_group.rg.name}"

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.0.0/24"
  }
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "${var.resource_group}-vnet2"
  location            = "${var.location}"
  address_space       = ["192.168.0.0/24"]
  resource_group_name = "${azurerm_resource_group.rg.name}"

  subnet {
    name           = "subnet1"
    address_prefix = "192.168.0.0/24"
  }
}

resource "azurerm_virtual_network_peering" "peer1" {
  name                         = "vNet1-to-vNet2"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  virtual_network_name         = "${azurerm_virtual_network.vnet1.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.vnet2.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "peer2" {
  name                         = "vNet2-to-vNet1"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  virtual_network_name         = "${azurerm_virtual_network.vnet2.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.vnet1.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_sql_database" "db" {
  name                             = "mysqldatabase"
  resource_group_name              = "${azurerm_resource_group.rg.name}"
  location                         = "${var.location}"
  edition                          = "Basic"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  create_mode                      = "Default"
  requested_service_objective_name = "Basic"
  server_name                      = "${azurerm_sql_server.server.name}"
}

resource "azurerm_sql_server" "server" {
  name                         = "${var.resource_group}-sqlsvr"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  location                     = "${var.location}"
  version                      = "12.0"
  administrator_login          = "${var.sql_admin}"
  administrator_login_password = "${var.sql_password}"

}

resource "azurerm_sql_firewall_rule" "fw" {
  name                = "firewallrules"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  server_name         = "${azurerm_sql_server.server.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}