Azure Secure Hub-and-Spoke Topology (Modular Bicep)
🎯 Project Objective
The goal of this project is to deploy a cost-optimized, secure Hub-and-Spoke network architecture in Azure using Infrastructure as Code (Bicep). This environment isolates workload Spokes from the internet while providing a single, hardened entry point (Jumpbox) in the Hub for administrative tasks.

🛠️ Technical Specifications
This project utilizes a data-driven deployment model. By using Bicep loops and arrays, the infrastructure is scalable and easy to manage.

1 x Hub VNet: Acts as the shared services layer. Contains the management jumpbox.

2 x Spoke VNets: Isolated networks for application workloads.

3 x B-Series VMs: Optimized for Azure Student Plan credits (Standard_B1s).

VNet Peering: Global peering configuration allowing Hub-to-Spoke communication while maintaining Spoke-to-Spoke isolation.

NSG Hardening: Each subnet is protected by a Network Security Group (NSG) with a "Default Deny" posture, whitelisting only internal VNet traffic.
