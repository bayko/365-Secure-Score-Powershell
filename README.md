
## [**Office365 Secure-Score**](https://docs.microsoft.com/en-us/microsoft-365/security/mtp/microsoft-secure-score?view=o365-worldwide)

This Script will set a base level SecureScore on 365 Tenant based on the available licensing SKUs.

> You must install the Sharepoint Online Client SDK as a pre-requisite: 
> https://www.microsoft.com/en-ca/download/details.aspx?id=42038


The following changes will be applied to the tenant account:

- Enable mailbox auditing for all mailboxes
- Set 365 account passwords to never expire
- Allow anonymous guest sharing links for sites and docs
- Set Expiry time in days for external sharing links
- Create DLP policies
- Provision Onedrive Sites for all users
- Setup Versioning on Sharepoint Online Document Libraries
- Enable IRM Protection on Sharepoint Document Libraries
- Enable 365 Audit Data Recording
- Disable Anonymous Calendar Sharing
- Create transport rule for client auto forwarding block
- Disable Users ability to consent to 3rd party app access

ATP Licensed Tenants Only
- Enable Advanced Threat Protection safe links policy
- Enable Advanced Threat Protection safe attachments policy


>Executing the script will prompt once for Office 365 Global Admin credentials. Those credentials will then be used to access EAC, MSOnline, AzureAD, and SPOnline services


DLP Policy is created using **Canada Financial Data** template. Swap out template names for desired policies
