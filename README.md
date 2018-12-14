This Script will set a base level SecureScore on 365 Tenant based on the available licensing SKUs.


You must install the Sharepoint Online Client SDK as a pre-requisite: 

https://www.microsoft.com/en-ca/download/details.aspx?id=42038


The following changes will be applied to the tenant account:

All Tenants 
- Enable mailbox auditing for all mailboxes - 10 Points
- Set 365 account passwords to never expire - 10 Points
- Allow anonymous guest sharing links for sites and docs - 1 Point
- Set Expiry time in days for external sharing links  -  2 Points
- Create DLP policies - 20 Points
- Provision Onedrive Sites for all users - 10 Points
- Setup Versioning on Sharepoint Online Document Libraries - 2 Points
- Enable IRM Protection on Sharepoint Document Libraries - 5 Points
- Enable 365 Audit Data Recording - 15 Points [not scored]
- Disable Anonymous Calendar Sharing  - 10 Points [not scored]
- Create transport rule for client auto forwarding block - 20 Points [not scored]

ATP Licensed Tenants Only
- Enable Advanced Threat Protection safe links policy - 15 Points
- Enable Advanced Threat Protection safe attachments policy - 15 Points


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Executing the script will prompt once for Office 365 Global Admin credentials. Those credentials will then be used to access EAC, MSOnline, and SPOnline services

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DLP Policies are created using Australian Financial, Medical, and Privacy act templates. Swap out template names for desired policies
