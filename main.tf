# main.tf

provider "azurerm" {
  features {}
}

# Define variables
variable "location" {
  default = "East US"
}

variable "vm_size" {
  default = "Standard_B1s"
}

# Create Resource Group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = var.location
}

# Create Virtual Network (VNet)
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

# Create Subnet
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Load Balancer
resource "azurerm_lb" "example" {
  name                = "example-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  frontend_ip_configuration {
    name                 = "example-fe-ip"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

# Create Public IP for Load Balancer
resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
  sku                  = "Basic"
}

# Create Virtual Machine
resource "azurerm_linux_virtual_machine" "example" {
  name                 = "example-vm"
  resource_group_name  = azurerm_resource_group.example.name
  location             = var.location
  size                 = var.vm_size
  admin_username       = "adminuser"
  admin_password       = "Password1234!"
  network_interface_ids = [azurerm_network_interface.example.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  tags = {
    environment = "dev"
  }
}

# Create Network Interface for the VM
resource "azurerm_network_interface" "example" {
  name                 = "example-nic"
  location             = var.location
  resource_group_name  = azurerm_resource_group.example.name
  ip_configuration {
    name                          = "example-ip-config"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Implement Role-Based Access Control (RBAC) for security
resource "azurerm_role_assignment" "example" {
  principal_id   = "<user-or-service-principal-id>"
  role_definition_name = "Contributor"
  scope           = azurerm_resource_group.example.id
}
