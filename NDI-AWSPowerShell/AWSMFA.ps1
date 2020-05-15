function Invoke-MFASession {
    param (
        [Parameter(Mandatory=$true)]
        [String]$AWSProfile,
        [Parameter(Mandatory=$false)]
        [Long]$Duration_Hours = 1

    )
    $Duration_Seconds = $Duration_Hours * 3600
    Set-AWSCredential -ProfileName $AWSProfile

    do{
        $MFAToken = Read-Host "Please enter a valid 6 digit MFA Code:"
        }
        while($MFAToken.Length -ne 6)

    $global:MFASession = Get-STSSessionToken -SerialNumber (Get-IAMMFADevice).SerialNumber -TokenCode $MFAToken -DurationInSeconds $Duration_Seconds

    }

function Get-MFASession {
        
    $MFASession
    
}

function Set-MFASession {
        
    Set-AWSCredential -Credential $MFASession -Scope Global
    
}

Export-ModuleMember -Function Set-MFASession
Export-ModuleMember -Function Get-MFASession
Export-ModuleMember -Function Invoke-MFASession