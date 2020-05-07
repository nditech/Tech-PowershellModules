function Backup-UserProfile {

    param (
        # Parameter help description
        [Parameter()]
        [string]
        $Destination = "C:\Backup"
    )

    $global:Folders = "Desktop", "Downloads", "Favorites", "Documents",
               "Music", "Pictures", "Videos", "AppData\Local\Mozilla",
               "AppData\Local\Google", "AppData\Roaming\Mozilla"

    write-host -ForegroundColor Green "Backing up data from local machine for $Username"
        
        foreach ($Folder in $Folders){

            $LocalFolder = $SelectedProfile + "\" + $Folder
            $BackupFolder = $Destination + "\" + $username + "\" + $Folder
            $FolderSize = (Get-ChildItem -ErrorAction silentlyContinue $LocalFolder -Recurse -Force | Measure-Object -ErrorAction silentlyContinue -Property Length -Sum ).Sum / 1MB
            $FolderSizeRounded = [System.Math]::Round($FolderSize)
            write-host -ForegroundColor cyan "  $Folder... ($FolderSizeRounded MB)"
            Copy-Item -ErrorAction silentlyContinue -recurse $LocalFolder $BackupFolder
        }

}

Export-ModuleMember -Function Backup-UserProfile