# Script to add user to an AzureAD role
#
# You can find a list of available roles in the following Microsoft article
# https://docs.microsoft.com/en-us/azure/active-directory/active-directory-assign-admin-roles-azure-portal
#
# Built from the code example on the following Mircosoft page
# https://docs.microsoft.com/en-us/powershell/module/azuread/add-azureaddirectoryrolemember?view=azureadps-2.0
#

# User UPN to assign role to
$roleUser = ''

# Role Name to Assign
$roleName = ''


# Import AzureAD module and Connect
Import-Module AzureAD
Connect-AzureAD

# Fetch user to assign to role
$roleMember = Get-AzureADUser -ObjectId $roleUser

# Fetch User Account Administrator role instance
$role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq $roleName}

# If role instance does not exist, instantiate it based on the role template
if ($role -eq $null) {
    # Instantiate an instance of the role template
    $roleTemplate = Get-AzureADDirectoryRoleTemplate | Where-Object {$_.displayName -eq $roleName}
    Enable-AzureADDirectoryRole -RoleTemplateId $roleTemplate.ObjectId

    # Fetch User Account Administrator role instance again
    $role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq $roleName}
}

# Add user to role
Add-AzureADDirectoryRoleMember -ObjectId $role.ObjectId -RefObjectId $roleMember.ObjectId

# Fetch role membership for role to confirm
Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | Get-AzureADUser
