resource "azurerm_resource_group" "lab4" {
  name     = "${var.rg}"
  location = "${var.loc}"

  tags {
    environment = "training"
  }
}

resource "azurerm_storage_account" "lab4sa" {
  name                     = "jadlab4"
  resource_group_name      = "${azurerm_resource_group.lab4.name}"
  location                 = "${azurerm_resource_group.lab4.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}