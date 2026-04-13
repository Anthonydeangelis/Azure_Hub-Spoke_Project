
# Building a Secure Hub-and-Spoke Network

## The Goal
I didn't just want to connect two networks; I wanted to build an environment that mirrors how real companies handle security. My goal was to create a "Hub-and-Spoke" system where every bit of data moving between the Spokes is forced to pass through a central Hub. This creates a single "choke point" where a security team could monitor or block suspicious activity.

##  How I Built It (My Step-by-Step)

### Step 1: Laying the Foundation
I started by writing modular Bicep templates. I didn't want one giant file that was impossible to read, so I broke it down into separate "blueprints" for the networks, the servers, and the peering connections. 

**The Challenge:** After the first deployment, I realized that Spoke A couldn't talk to Spoke B. In Azure, just because both Spokes are connected to the Hub doesn't mean they can see each other. They were isolated.



### Step 2: Creating the UDR
To fix the isolation, I had to "teach" the network how to find the other side. 
* I went back into my code and created a **Route Table** module. 
* I defined a rule that told the traffic: *"If you are trying to reach the other Spoke, don't try to go there directly. Go to the Hub VM's IP address instead."*
* This turned my Hub VM into a "Traffic Controller."

### Step 3: Enabling IP Fowarding
Azure is secure by default, so it normally blocks VMs from passing traffic that isn't meant for them. I had to edit my **Network Interface (NIC)** code to enable `IP Forwarding`. This was the final "permission" needed to let the Hub VM act as a bridge.

### Step 4: Associating the Subnets 
After deploying the route table I tried sending data from SpokeA to SpokeB using IP Flow Verify but it did not work and I realized I forgot to associate the RT to subnets. Once I associated the Spoke subnets with my new Route Tables, the traffic finally knew which path to take.





---

## The Commands I Ran
I used the Azure CLI to manage this project. Using the CLI allowed me to redeploy my edits instantly and verify my work without clicking through a hundred menus.

### 1. Creating the Project Space
I started by creating a Resource Group to keep all my work organized.
```powershell
az group create --name Azure-Hub-Spoke-RG --location eastus2
```

### 2. Deploying & Updating the Code
Every time I made a fix to my Bicep files (like adding the Route Table or fixing the Subnet association), I ran this command to push the updates to Azure:
```powershell
az deployment group create `
  --resource-group Azure-HubSpoke-Project `
  --template-file main.bicep `
  --parameters parameters/main.bicepparam
```

### 3. Verification
I used this command to double-check my Hub VM's IP address to make sure my "Next Hop" in the Route Table was pointing to the right place:
```powershell
az vm list-ip-addresses -g Azure-HubSpoke-Project --output table
```

---

## Why This Matters for Security

In a real-world scenario, I could now install a packet sniffer or an Intrusion Detection System (IDS) on that Hub VM. Because I successfully routed the Spoke traffic through it, I would be able to see every single connection attempt, making it much easier to catch a hacker trying to move laterally through the network.



---

### Key Skills Demonstrated:
* **Infrastructure as Code (IaC):** Using Bicep for repeatable deployments.
* **Network Engineering:** Understanding UDRs, Subnet Association, and IP Forwarding.
* **Security Analysis:** Implementing a Zero-Trust "choke point" architecture.
* **Systems Troubleshooting:** Identifying and fixing routing gaps in a cloud environment.
