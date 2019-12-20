function Backup-AWS {
    param (
        [Parameter(Mandatory=$true)]
        [String[]]
        $BackupifyList,
        $BucketName
    )


$addresses = Import-CSV $BackupifyList
$Root = Get-Date -UFormat "%B_%Y"

foreach ($address in $addresses){

    $url = $address.archive_url
    $Folder = $address.service_type
    $Folder = $Folder -replace ".{7}$"


        $start_time = Get-Date

        $url -match 'backupify_export(.*?)zip'

        $filename = $matches[0]
        $filename = $filename.Replace('%40','@')

        $output = "D:\Backupify\Data\$filename"

        $ProgressPreference = 'SilentlyContinue'

        if(Test-Path $output){

        Write-Host "File already exist."
            
            }

         Else{
                 
        Invoke-WebRequest -Uri $url -OutFile $output
            
            }

        Write-Output "Time taken to download $($filename): $((Get-Date).Subtract($start_time).Minutes) Minutes(s)"

        $Key = "$Root/$Folder/$filename"

        Write-S3Object -BucketName $BucketName -File $output -Key $Key -Credential $sessionCreds
		
		Write-Output "Time taken to upload $($filename): $((Get-Date).Subtract($start_time).Minutes) Minutes(s)"


        Remove-Item $output

}

}
Export-ModuleMember -Function Backup-AWS