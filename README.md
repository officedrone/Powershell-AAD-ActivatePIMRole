# Powershell-AAD-ActivatePIMRole
Activate PIM role using AzureAD Powershell Module

## Requirements
- AzureADPreview Powershell Module must be installed before running the script
- At least one role enabled for PIM assigned to the user you are executing the script and authenticating to AAD as.

## Details

This quick'n dirty powershell script will perform the following tasks:
1. Ask a user to login to AAD using AzureAD powershell module
2. Evaluate the users' AAD roles that are enabled for PIM and require activation
4. Present a user with a list of the roles and ask whcih role they'd want to activate
5. Ask the user for duration and reason for activation
6. Activate the role using the above input required from the user.

## Output sample:

![image](https://user-images.githubusercontent.com/67024372/179539143-bf08cf2b-cd3b-4a12-8ff3-509e78ae653c.png)
