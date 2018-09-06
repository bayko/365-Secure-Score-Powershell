This Script will set a base level SecureScore on 365 Tenant based on the available licensing SKUs.

The following changes will be applied:

BUSINESS PREMIUM OR ENTERPRISE CLIENT (+ 43 Points Total) (+25 Not Scored)
- Enable mailbox auditing for all mailboxes - 10 Points
- Create transport rule for client auto forwarding rule block - 20 Points
- Set 365 account passwords to never expire - 10 Points
- Allow anonymous guest sharing links for sites and docs - 1 Point
- Set Expiry time in days for external sharing links  -  2 Points
- Enable 365 Audit Data Recording - 15 Points [not scored]
- Disable Anonymous Calendar Sharing  - 10 Points [not scored]

ENTERPRISE CLIENTS ONLY (+ 20 Points Additional)
- Create DLP policies - 20 Points

ATP CLIENTS ONLY (+ 30 Points Additional)
- Enable Advanced Threat Protection safe links policy - 15 Points
- Enable Advanced Threat Protection safe attachments policy - 15 Points


Execution only requies 2 parameters for Office 365 Admin credentials.
