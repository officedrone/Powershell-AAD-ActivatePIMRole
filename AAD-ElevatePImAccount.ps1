
#Install-Module AzureADPreview <- Uncomment if you'd be deploying this script to machines that may not have AzureADPreview module installed.

Write-host "Connecting to AzureAD"
Write-host "-------------------------------"

#Connect to AAD & assign connection details to $ConnectionDetails variable
$ConnectionDetails = Connect-AzureAD

#Extract user UPn and assign to separate variable, then convert to string
$UserDetails = Get-AzureADUser -ObjectId $ConnectionDetails.Account
$UserObjectID = $Userdetails.ObjectID
$UserObjectID.tostring() > $null

#Extract teannt details and assign to separate variable, then convert to string
$TenantID = $ConnectionDetails.TenantID
$TenantID.tostring() > $null

#initialize definition name array
$RoleDefinitionName=@()

#Get all roles available to the user that are eligable for activation
$roles = Get-AzureADMSPrivilegedRoleAssignment -ProviderId "aadRoles" -ResourceId $TenantID -Filter "subjectId eq '$UserObjectID' and assignmentState eq 'Eligible'"

#If $roles variable is not empty then run the code block before
If($roles){
    #Initialize count variable
    $roleCount = 1
    Write-host "-------------------------------"
    Write-Host "Evaluating user roles available for activation"
    Write-host "-------------------------------"
    Write-host ""
    Write-host ""
    #Process each role 
    foreach ($role in $roles)
    {
      #Assign role definition ID to separate variable and convert to srting
      $RoleDefinitionID = $role.RoleDefinitionID
      $RoleDefinitionID.tostring() > $null

      #Get role definition for the specific role we are processing
      $RoleDefinition = Get-AzureADMSPrivilegedRoleDefinition -ProviderId "aadRoles" -ResourceID "$TenantId" -Id $RoleDefinitionID

      #Add role definition name to the global array

      $RoleDefinitionName += $RoleDefinition.DisplayName
      #Present option and display option name - 1 (as arrays start at 0 and it makes no sense to present option 0 to the user)
      Write-Host "Option " $roleCount " : " $RoleDefinitionName[$roleCount-1]
      Write-host "-------------------------------"

      #Increase cout
      $roleCount++

    }


    #Prompt user to select from the options presented above (should add input validation in next iterations)
    $Answer = Read-Host -Prompt 'Please select option number'

    #Prompt user for the reason why they are elevating their role
    $Reason = Read-Host -Prompt 'Please enter a reason for credential elevation'

    #Prompt user for how long they'd like to elevate their role
    $Timespan = Read-Host -Prompt 'Number of hours for elevation (Up to 8 hours)'


    #Create Schedule object for activation based on user input
    $schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
    $schedule.Type = "Once"
    $schedule.StartDateTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    $schedule.endDateTime = (Get-date).AddHours($Timespan).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ") #Set end date to now + X hours based on user input


    #Activate the role using tenant ID, role-1 (array starts at 0, our options start at 1), for the specified user ID using
    #the appropriate schedule and reason provided by the user
    Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId 'aadRoles' -ResourceId $TenantID -RoleDefinitionId $Roles[$Answer-1].RoleDefinitionID -SubjectId $UserObjectID -Type 'UserAdd' -AssignmentState 'Active' -Schedule $schedule -Reason $Reason


  }

  #If $Roles variable is empty then run the code block below
  else {
    Write-Host "No eligable roles available"
  }
  
