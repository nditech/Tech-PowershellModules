function Select-UserProfile{

    $ProfileListPath = 'Registry::HKey_Local_Machine\Software\Microsoft\Windows NT\CurrentVersion\ProfileList\*'
    $Profile = Get-ItemProperty -path $ProfileListPath

    Foreach ($Profile in $Profiles) {

        $objUser = New-Object System.Security.Principal.SecurityIdentifier($Profile.PSChildName)
        $Profile.SID = $objUser
        $objName = $objUser.Translate([System.Security.Principal.NTAccount])
        $Profile.PSChildName = $objName.value

    }

$UserProfiles = $Profile.ProfileImagePath -like "*Users*"

$global:SelectedProfile = $UserProfiles | Out-GridView -PassThru -Title 'Select User to Backup or Restore'
$global:Username = Split-Path $SelectedProfile -Leaf

$global:Folders = "Desktop", "Downloads", "Favorites", "Documents",
"Music", "Pictures", "Videos", "AppData\Local\Mozilla",
"AppData\Local\Google", "AppData\Roaming\Mozilla"

}

Export-ModuleMember -Function Select-UserProfile