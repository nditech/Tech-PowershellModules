function Invoke-AWSAssumeRole {
    param (
        [Parameter(Mandatory=$true)]
        [String]
        $AWSProfile,
        $MFAProfile,
        $MFARole

    )

    $AWSCreds = "$env:USERPROFILE\.aws\credentials"
    $Credentials = Get-Content -Path $env:USERPROFILE\.aws\credentials

    do{
        $MFACode = Read-Host "Please enter a valid 6 digit MFA Code:"
        }
        while($MFACode.Length -ne 6)
    
    $global:sessionInfo = aws sts assume-role --role-arn $($MFARole) --role-session-name Backupify --serial-number $($MFAProfile) --token-code $($MFACode) --duration-seconds 43200
    
    $sessionHash = $sessionInfo | ConvertFrom-Json
    
    $AccessKey = $sessionHash.Credentials.AccessKeyId
    $SecretKey = $sessionHash.Credentials.SecretAccessKey
    $Token = $sessionHash.Credentials.SessionToken
    
    $Credentials[11] = "aws_access_key_id = $AccessKey"
    $Credentials[12] = "aws_secret_access_key = $SecretKey"
    $Credentials[13] = "aws_session_token = $Token"
    
    $Credentials | Set-Content -Path $AWSCreds

    }

Export-ModuleMember -Function Invoke-AWSAssumeRole