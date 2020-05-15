function Set-MFASession {
    param (
        [Parameter(Mandatory=$true)]
        [String]$AWSProfile,
        [Long]$Duration_Hours

    )
    $Duration_Seconds = $Duration_Hours * 3600
    Set-AWSCredential -ProfileName $AWSProfile

    do{
        $MFAToken = Read-Host "Please enter a valid 6 digit MFA Code:"
        }
        while($MFAToken.Length -ne 6)

    $global:MFASession = Get-STSSessionToken -SerialNumber (Get-IAMMFADevice).SerialNumber -TokenCode $MFAToken -DurationInSeconds $Duration_Seconds
    Set-AWSCredential -Credential $MFASession -Scope Global

    }

function Get-MFASession {
        
    $MFASession
    
}

Export-ModuleMember -Function Get-MFASession
Export-ModuleMember -Function Set-MFASession