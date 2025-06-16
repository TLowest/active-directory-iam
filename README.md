# Active Directory IAM

This home lab project demonstrates how to set up a secure Active Directory (AD)-based Identity and Access Management (IAM) environment using VirtualBox. It is designed for IT and cybersecurity professionals who want to gain hands-on experience with centralized identity, domain services, and IAM policies using Microsoft Server and Windows clients in a virtualized, isolated environment. 

> This Project was inspired by [Abdullahi Ali](https://medium.com/@aali23/how-to-build-an-active-directory-iam-home-lab-using-virtualbox-60b79b94b300) from [Medium.com](https://medium.com/)

While the original article provides a clear step-by-step guide, this version of the project showcases real-world troubleshoooting, enhancements, and security improvements encountered during implementaiton. It highlights specific issues that arose during the setup process and documents how they were resolved to strengthen understanding of Active Directory environements and IAM best practices. 

---

### 🧰 Tools & Technologies 
- VirtualBox : Hosts the Virtual Machines
- Windows Server 2019 : Hosts the Active Directory Domain Services (AD DS)
- Windows 10 : Domain-joined client for testing policies and permissions
- Active Directory Users and Computers (ADUC)
- Group Policy Management Console (GPMC)
- DNS and DHCP

---

### 🏗️ Instructions 

**1. Environment Setup (Host)**
- Install VirtualBox and download ISOs/create VMs for:
  - Windows Server 2019 Standard Evaluation (Desktop Experience) : Domain Controller (`DC01`)
    - *Standard Edition is fully sufficent for running AD DS with a full GUI interface.*
  - Windows 10 : Domain-joined Client (`Client01`)

> Note: Setting up domain environement (e.g., Windows Server 2019 as the Domain Controller and a Windows 10 client) requires manually configuring IPv4 settings for reliable internal communication and Active Directory functionality. This avoids reliance on external DNS and ensures accurate domain resolution.


**2. Active Directory Domain Controller Setup**

- On `DC01`:
  1. Set a static IP address

  2. Rename the computer (e.g., `DC01`)

  3. Install AD DS and DNS via `Server Manager`

  4. Promote the server to a Domain Controller:
      - Domain name: `mydomain.com`

  5. Reboot after promotion

**3. Configure DHCP**

The article suggests configuring DHCP on the domain controller. The reasoning includes:
  - Automatic IP assignment: Simplifies IP management
  - DNS Integration: Ensures dynamic updates to DNS for domain-joined machines
  - AD Authorization: Provides tighter integration with AD roles
  - Scalability: Easier to scale across more clients with automated IP provisioning

To support this, a DHCP Scope was configured to define the IP address range that the DHCP server is allowed to hand out, simplifying the domain join and management process. 

**4. Create Organizational Units and User Accounts**

- Use **ADUC** to create:
  - OUs: `Users`, `Admins`, `Workstations`
  - Users: `testuser`, `adminuser`

> You can also use a Powershell script to automate bulk user creation. For example, the script from [Josh Madakor's GitHub](https://github.com/joshmadakor1/AD_PS) creates over 1000 unique test users for realiztic IAM simulations.

**5. Join Client to Domain**

- On `Client01`:
  1. Set static IP in same subnet as `DC01`
  2. Rename computer (e.g., `Client01`)
  3. Join to `mydomain.com` domain
  4. Reboot and log in with a domain account 

> **Networking Issue Resolution:** if you encounter an issue where the Windows 10 VM still uses the NAT adapter's DNS server instead of the internal DNS, adjust interface metrics using PowerShell:
> ```Powershell
> # Set a lower metric for the internal adapter
> Set-NetIPInterface -InterfaceAlias "<InterfaceAlias-Internal-Adapter>" -InterfaceMetric 10
> # Set a higher metric for the NAT adapter
> Set-NetIPInterface -InterfaceAlias "<InterfaceAlias-NAT-Adapter>" -InterfaceMetric 50
> ```
> Feel free to check the interface names using `Get-NetIPInterface`.
>
> Then flush DNS cache and test:
> ```Powershell
> ipconfig /flushdns
> nslookup mydomain.com
> ```

**6. Configure Group Policy**

- Using **GPMC** on `DC01`:
  - Create new Group Policy Object (GPO)
  - Link to OU `Workstation`
  - Configure policies like:
    - Password Complexity
    - Account Lockout Policies
    - Disable USB storage
   
---

### IAM Security Best Practice Enhancements 

Implementing IAM security best practice enhancement scripts is essential to maintaining a secure, compliant, and scalable Active Directory environment.
These scripts automate critical tasks such as enforcing least privilege, auditing logon events, and backing up GPO configurations - each of which contributes to reducing risk, streamlining administrative workflows, and improving incident response capabilities. 

**Least Privilege Enforcement Script**

```Powershell
.\least_privilege_enforcer.ps1
```

**Audit Policy Baseline Configuration**

```Powershell
.\enable-LogonAuditing.ps1
```

**GPO Backup Script**

```Powershell
.\backup_GPOs.ps1
```

*Optional*: SIEM Forwarding Integration

> Install NXLog or Windows Event Forwarding (WEF) on DC to send logs to a SIEM like ELK or Splunk.

