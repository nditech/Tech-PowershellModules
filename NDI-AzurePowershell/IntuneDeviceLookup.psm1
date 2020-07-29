function Get-IntuneDevice {

    <#
    .SYNOPSIS
      Users a devices serial number to query Azure Active Directory/Intune for the last logged on user.
      
    .DESCRIPTION
      The Get-IntuneDevice function requires to parameters. (1) Serial Number and (2) Username. The username
      input is necessary to authenticate with MSGraph and Azure.
      
      Requires the following modules:
      Import-Module -Name MSGraphFunctions
      Import-Module -Name Microsoft.Graph.Intune
       
    .EXAMPLE
      Get-IntuneDevice -SerialNumber "XXXXXX" -Username "jdoe@ndi.org"
    #>

    param (
        [Parameter(Mandatory=$true)]
        [String[]]
        $SerialNumber,
        $Username
    )
    
    Connect-Graph -Username $Username
    $IntuneDevice = Get-GraphManagedDevice | Where-Object {$_.serialNumber -eq $SerialNumber}
    $IntuneUser = Get-GraphUsersLoggedOn -Id $IntuneDevice.id

    $customObj = [PSCustomObject]@{
        SystemName = $IntuneDevice.deviceName
        User = $IntuneUser.userDisplayName
        LastLogonDate = $IntuneUser.lastLogonDateTime
        SerialNumber = $IntuneDevice.serialNumber
    }

    $customObj | Format-Table -AutoSize
}