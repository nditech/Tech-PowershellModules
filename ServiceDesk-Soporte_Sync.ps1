Import-Module -Name ActiveDirectory
Import-Module -Name AzureAD

$AzureADCreds = Get-StoredCredential -Target AzureAD

Connect-AzureAD -Credential $AzureADCreds

$ServiceDesk = Get-AzureADGroupMember -ObjectId 70f13d84-4909-4929-9d11-d00c2bc0d84f -All $true
$Soporte = Get-ADGroupMember -Identity 'Soporte' | %{ get-aduser $_.SamAccountName | select objectGUID, name, userPrincipalName }

foreach ($user in $Soporte){
    
    if($ServiceDesk.UserPrincipalName -notcontains $user.userPrincipalName){

        $UserObjectID = Get-AzureADUser -ObjectId $user.userPrincipalName
        Add-AzureADGroupMember -ObjectId 70f13d84-4909-4929-9d11-d00c2bc0d84f -RefObjectId $UserObjectID.ObjectId
    
    }
}

Start-Sleep -Seconds 60

$ServiceDesk = Get-AzureADGroupMember -ObjectId 70f13d84-4909-4929-9d11-d00c2bc0d84f -All $true

foreach ($user in $ServiceDesk){

    if($Soporte.userPrincipalName -notcontains $user.userPrincipalName){

    $UserObjectID = Get-AzureADUser -ObjectId $user.userPrincipalName
    Remove-AzureADGroupMember -ObjectId 70f13d84-4909-4929-9d11-d00c2bc0d84f -MemberId $UserObjectID.ObjectId

    }
}