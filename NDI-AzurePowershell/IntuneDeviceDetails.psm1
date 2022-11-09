function Get-LastLoggedOn {

    param (
        [Parameter(Mandatory=$true)]
        [String]
        $DeviceName,
        $Username
    )

    $MangedDevice = Get-IntuneManagedDevice | Where-Object {$_.deviceName -eq $DeviceName}
    $PrimaryUser = Get-GraphAzureADUser -Id $MangedDevice.userId
    $LoggedOnUser = Get-GraphUsersLoggedOn -id $MangedDevice.id

    $CustomObject = [PSCustomObject]@{
        'User'         = $LoggedOnUser[-1].userDisplayName
        'Email'        = $LoggedOnUser[-1].userPrincipalName
        'Device'       = $LoggedOnUser[-1].deviceName
        'Last Logon'   = $LoggedOnUser[-1].lastLogonDateTime
        'Primary User' = $PrimaryUser.displayName
    
        }

    $CustomObject | Format-Table -AutoSize

}

function Get-AllLastLoggedOn {

    param (
        [Parameter(Mandatory=$true)][String]$Username,
        [Parameter(Mandatory=$false)][String]$Path
    )

    $Output = @()
    $MangedDevices = Get-IntuneManagedDevice
    
    foreach($device in $MangedDevices){
        
        $LoggedOnUser = Get-GraphUsersLoggedOn -id $device.id
        $PrimaryUser = Get-GraphAzureADUser -Id $device.userId
        $CustomObject = [PSCustomObject]@{
            'User'         = $LoggedOnUser[-1].userDisplayName
            'Email'        = $LoggedOnUser[-1].userPrincipalName
            'Device'       = $LoggedOnUser[-1].deviceName
            'Last Logon'   = $LoggedOnUser[-1].lastLogonDateTime
            'Primary User' = $PrimaryUser.displayName

            }

        $Output += $CustomObject

    }

    if($Path){

        $Output | Export-Csv -NoTypeInformation -Path $Path

    }

    else {

        $Output | Format-Table -AutoSize

    }

}

Export-ModuleMember -Function Get-LastLoggedOn
Export-ModuleMember -Function Get-AllLastLoggedOn
