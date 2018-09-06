This Script will set a base level SecureScore on 365 Tenant based on the available licensing SKUs.

The following changes will be applied:

BUSINESS PREMIUM OR ENTERPRISE CLIENT
- Enable mailbox auditing for all mailboxes - 10 Points
- Create transport rule for client auto forwarding rule block - 20 Points
- Set 365 account passwords to never expire - 10 Points
- Allow anonymous guest sharing links for sites and docs - 1 Point
- Set Expiry time in days for external sharing links  -  2 Points
- Create DLP policies - 20 Points
- Enable 365 Audit Data Recording - 15 Points [not scored]
- Disable Anonymous Calendar Sharing  - 10 Points [not scored]


ATP CLIENTS ONLY (+ 30 Points Additional)
- Enable Advanced Threat Protection safe links policy - 15 Points
- Enable Advanced Threat Protection safe attachments policy - 15 Points


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Executing the script will prompt once for Office 365 Global Admin credentials. Those credentials will then be used to access EAC, MSOnline, and SPOnline services

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DLP Policies are created using Australian Financial, Medical, and Privacy act templates. Swap out template names for desired policies
