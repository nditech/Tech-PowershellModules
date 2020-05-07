function Restore-UserProfile {

    param (
        # Parameter help description
        [Parameter()]
        [string]
        $Destination = "C:\Backup"
    )

    $CurrentUser = $Env:USERNAME
    $CurrentProfile = $Env:USERPROFILEF
    
    write-host -ForegroundColor green "Restoring data to local machine for $CurrentUser"

        foreach ($Folder in $Folders){	

            $LocalFolder = $CurrentProfile + "\" + $Folder
            $BackupFolder = $Destination + "\" + $Username + "\" + $Folder
            write-host -ForegroundColor cyan "  $Folder..."
            Copy-Item -ErrorAction SilentlyContinue -Recurse -Force $BackupFolder $CurrentProfile
                   
                if ($Folder -eq "AppData\Local\Mozilla") { rename-item -ErrorAction SilentlyContinue $LocalFolder "$LocalFolder.old" }
                if ($Folder -eq "AppData\Roaming\Mozilla") { rename-item -ErrorAction SilentlyContinue $LocalFolder "$LocalFolder.old" }
                if ($Folder -eq "AppData\Local\Google") { rename-item -ErrorAction SilentlyContinue $LocalFolder "$LocalFolder.old" }
               
            }

        rename-item "$Destination\$Username" "$Destination\$Username.restored"
        write-host -ForegroundColor green "Restore Complete!"
    
}

#Export-ModuleMember -Function Restore-UserProfile