# This module takes data from a CSV that Backupify sends of decomissioned users in Gsuite.  (The CSV has three main fields: UID, G-Data type (GMAIL| Docs|Contacts | Calandar ); the URL to retreive the Backupify data ) The module then formats the folder structure for S3 and uploads the data to the S3 bucket specified. 

function Backup-AWS {
    param (
        [Parameter(Mandatory=$true)]
        [String[]]
        $BackupifyList, #this is the csv that backupify sends us with the accounts in gSuite of old(?) ndi staff who'se accounts will get pushed to a S3 bucket.
        $BucketName # this is the S3 bucket to push the backup files to for the users in the BackupifyList variable (CSV)
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

        $output = "C:\Backupify\$filename"

        $ProgressPreference = 'SilentlyContinue'

        if(Test-Path $output){

        Write-Host "File already exist."
            
            }

         Else{
                 
            Invoke-WebRequest -Uri $url -OutFile $output
            
            }

        Write-Output "Time taken to download $($filename): $((Get-Date).Subtract($start_time).Minutes) Minutes(s)"

        $Key = "$Root/$Folder/$filename"

        Write-S3Object -BucketName $BucketName -File $output -Key $Key -ProfileName CachedMFA
		
		Write-Output "Time taken to upload $($filename): $((Get-Date).Subtract($start_time).Minutes) Minutes(s)"

        Remove-Item $output

    }

}

Export-ModuleMember -Function Backup-AWS