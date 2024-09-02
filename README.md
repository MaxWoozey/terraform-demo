# Terraform-demo(Bonus)
The repository presents a `Terraform` demo. Via the project, a VPC containing several VMs was built, and the VMs can ping each other.

## Components

The repository contains the following files and directories:

```plaintext
terraform-demo/
├── main.tf           # Main Terraform configuration file that defines the infrastructure resources.
├── providers.tf      # Specifies the Terraform providers, such as Azure, AWS, or GCP.
├── variables.tf      # Contains variable definitions used throughout the Terraform configuration.
├── outputs.tf        # Defines the output variables that display information after deployment.
├── bonus.tfvars      # Example variable file for input parameters.
└── scripts/          # Directory containing custom scripts.
    └── ping-test.sh  # Shell script to perform ping tests between VMs.
```

## File Descriptions
- main.tf: The primary configuration file defines the infrastructure, including the VPC, subnets, network interfaces, and virtual machines. This file also includes network security group rules to allow ICMP (ping) traffic between VMs.
      - To assign different passwords to the admin users on each VM, a random_password resource was introduced:
  ![image](https://github.com/user-attachments/assets/eba064ea-d1ea-4cae-9bb9-fdacf45669fa)
  Later used in os_profile session:
  ![image](https://github.com/user-attachments/assets/89a217da-a5e1-4342-b617-3feaeb663f80)
- providers.tf: Specifies the Terraform providers used for this deployment, such as Azure, AWS, or GCP. The file contains configurations for authenticating with the chosen cloud provider.
- variables.tf: Contains variable definitions for customizing the deployment. These variables allow users to specify parameters like VM count, instance types, and network settings.
- outputs.tf: Defines the output variables that will display after the Terraform deployment. It provides information like VM public IP addresses, network details, and ping test results
- bonus.tfvars: An example file containing input parameters for the Terraform configuration. Users can modify this file to customize their deployment settings.
- scripts/ping-test.sh: A shell script to perform round-robin ping tests between the deployed VMs. It collects the ping results and outputs them for verification.

## Setup and Usage
To deploy the infrastructure and test the setup, follow these steps:
### Prerequisites
- Install Terraform
- Set up the CLI for your chosen cloud provider (e.g., Azure CLI, AWS CLI, or Google Cloud SDK)
- Ensure your cloud account has the necessary permissions to create and manage resources
In this demo, I have chosen Azure as the provider.
### Steps
1. **Clone the Repository**:
  ```Bash
    git clone https://github.com/your-repo/terraform-demo.git
    cd terraform-demo
  ```
2. **Customize the variables**:
   `bonus.tfvars` provides the interface to change the variables, you can set up the prefix, virtual machine images, flavors, VM counts and locations.
3. **Initialize Terraform**:
   ```Bash
    terraform init
   ```
   ![image](https://github.com/user-attachments/assets/72a121b5-208c-45d1-89b8-76898629755a)

4. **Plan the Deployment**:
   By using -var-file=bonus.tfvars, you can apply the varaibles as you wish, otherwise, the system runs on the default values.
   ```Bash
     terraform plan -var-file=bonus.tfvars
   ```
   A plan step by step will be listed, the following is the summary part:
   ![image](https://github.com/user-attachments/assets/639a60f2-1a9f-47c0-a432-c280b7e352d2)

6. **Apply the Configuration**:
  ```Bash
    terraform apply -var-file=bonus.tfvars
  ```
7. **Verify the Deployment**:
   The status can be checked via cli:
   ```Bash
     az login
     az resource list --resource-group <ResourceGroupName> -o table
   ```
   ![image](https://github.com/user-attachments/assets/f5735dbc-9f37-4d83-b398-d880d60aee50)

   In this demo, we can check the output to check whether the ping tests have succeeded.
    ```Bash
      terraform output -json
    ```


