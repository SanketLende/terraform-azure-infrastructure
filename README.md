# terraform-azure-infrastructure

To create a project that involves **Infrastructure Automation using Terraform** for provisioning **Azure VMs, Load Balancers, Networking**, and integrating **Terraform with Azure DevOps Pipelines**, follow these steps. I'll also provide a **repository name** and the required **Terraform code** for automation.

---

### **Project Overview:**
- **Technology Stack**:
  - **Terraform** for Infrastructure as Code (IaC).
  - **Azure** for Cloud Resources (VMs, Load Balancers, Networking).
  - **Azure DevOps Pipelines** for CI/CD of Terraform deployments.
  - **Azure RBAC (Role-Based Access Control)** for security.
  - **Azure Policy** for governance and compliance.

### **Repository Name Suggestion**:
- **Repo Name**: `terraform-azure-infrastructure`

---

### **Steps to Create the Project:**

---

### **1. Create a Repository**

#### Step 1: Initialize the Git Repository
1. Create a new repository on **GitHub** or **Azure Repos**.
   - **Repo name**: `terraform-azure-infrastructure`
2. Initialize a Git repository locally:
   ```bash
   mkdir terraform-azure-infrastructure
   cd terraform-azure-infrastructure
   git init
   ```

#### Step 2: Push to the Remote Repository
1. Add your remote repository URL:
   ```bash
   git remote add origin <your-repo-url>
   git branch -M main
   git push -u origin main
   ```

---

### **2. Set Up Terraform for Azure Resources**

#### Step 1: Install Terraform

1. Download and install Terraform from the official website: [Terraform Downloads](https://www.terraform.io/downloads).

2. Verify the installation by running:
   ```bash
   terraform -v
   ```

#### Step 2: Configure Azure Provider in Terraform

1. Create a new directory for Terraform configuration files in your project:
   ```bash
   mkdir terraform
   cd terraform
   ```

2. **Create a `main.tf` file** to configure the **Azure Provider** and initialize the resources:
   
   ```hcl
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
   ```

---

### **3. Integrate Terraform with Azure DevOps**

#### Step 1: Set Up Azure DevOps Pipeline

1. Go to **Azure DevOps** and create a new project.
2. Inside the project, navigate to **Pipelines** and select **Create Pipeline**.
3. Select **GitHub** as the source and connect your repository (`terraform-azure-infrastructure`).

#### Step 2: Add Terraform Pipeline YAML Configuration

In your Azure DevOps repository, create a `azure-pipelines.yml` file to automate the deployment using Terraform.

```yaml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  terraformVersion: '1.2.0'

steps:
- task: UseTerraform@0
  inputs:
    version: $(terraformVersion)

- task: TerraformInstaller@0
  inputs:
    terraformVersion: $(terraformVersion)

- script: |
    terraform init
    terraform plan -out=tfplan
  displayName: 'Terraform Init & Plan'

- script: |
    terraform apply -auto-approve tfplan
  displayName: 'Terraform Apply'
```

#### Step 3: Commit and Push the `azure-pipelines.yml` file

```bash
git add azure-pipelines.yml
git commit -m "Add Terraform DevOps pipeline"
git push origin main
```

Azure DevOps will automatically trigger the pipeline, run `terraform init`, `terraform plan`, and `terraform apply` to provision the Azure resources.

---

### **4. Implement Security Policies for RBAC and Azure Policy**

#### Step 1: Implement RBAC in Terraform

Add **RBAC** (Role-Based Access Control) in the `main.tf` configuration file. For example:

```hcl
# RBAC for a user
resource "azurerm_role_assignment" "example" {
  principal_id   = "<user-or-service-principal-id>"
  role_definition_name = "Contributor"
  scope           = azurerm_resource_group.example.id
}
```

This grants a user or service principal the **Contributor** role for the **resource group**.

#### Step 2: Implement Azure Policy

You can define **Azure Policy** to enforce certain rules. Example:

```hcl
# Azure Policy for VM Sizes
resource "azurerm_policy_definition" "example" {
  name         = "allowed-vm-sizes"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed VM Sizes"
  description = "This policy restricts VM sizes to a list of allowed sizes."

  policy_rule = <<POLICY_RULE
{
  "if": {
    "field": "type",
    "equals": "Microsoft.Compute/virtualMachines"
  },
  "then": {
    "effect": "deny",
    "field": "Microsoft.Compute/virtualMachines/size",
    "notIn": [
      "Standard_B1s",
      "Standard_B2s"
    ]
  }
}
POLICY_RULE
}
```

This policy restricts the sizes of virtual machines that can be deployed to only **Standard_B1s** and **Standard_B2s**.

---

### **5. Final Project Structure**

Your project folder structure should look like this:

```
terraform-azure-infrastructure/
│
├── terraform/                        # Terraform configuration files
│   ├── main.tf                       # Main Terraform code for infrastructure
│   ├── variables.tf                  # Variables for flexibility
│   ├── outputs.tf                    # Output values (e.g., IPs, VM names)
├── azure-pipelines.yml               # Azure DevOps pipeline configuration
├── .gitignore                        # Git ignore file
├── README.md                         # Project documentation (optional)
```

---

### **6. Final Steps:**
1. **Test Locally**:
   - Before running the Terraform code on Azure, you can test it locally using the `terraform plan` and `terraform apply` commands.
   
2. **Commit Changes**:
   - Make sure you commit and push all the changes to your repository.
   
3. **Monitor and Manage**:
   - After the resources are provisioned, monitor your infrastructure through the **Azure Portal**.
   - Check **Terraform Cloud** or **Azure DevOps** pipelines for logs and pipeline status.

---

### **Summary of Steps:**
1. **Set up a Git repository** (`terraform-azure-infrastructure`).
2. **Configure Terraform** to provision Azure resources like VMs, Load Balancers, and networking.
3. **Integrate Terraform with Azure DevOps Pipelines** for CI/CD.
4. **Implement RBAC** and **Azure Policy** for security and compliance.
5. **Deploy the infrastructure** via **Azure DevOps Pipelines**.

This setup will automate the provisioning of infrastructure on Azure, using **Terraform** and **Azure DevOps** to ensure scalability, security, and proper governance. If you have any specific questions or need further adjustments, feel free to ask!
