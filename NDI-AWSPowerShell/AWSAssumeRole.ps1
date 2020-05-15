function Invoke-AWSAssumeRole {
    param (
        [Parameter(Mandatory=$true)]
        [String]$AWSProfile, $MFASerial, $RoleArn,
        [Long]$Duration_Hours

    )
    $Duration_Seconds = $Duration_Hours * 3600
    $AWSCreds = "$env:USERPROFILE\.aws\credentials"
    $Credentials = Get-Content -Path $env:USERPROFILE\.aws\credentials

    do{
        $MFAToken = Read-Host "Please enter a valid 6 digit MFA Code:"
        }
        while($MFAToken.Length -ne 6)
    
    $global:sessionInfo = aws sts assume-role --role-arn $($RoleArn) --role-session-name Backupify --serial-number $($MFASerial) --token-code $($MFAToken) --duration-seconds $Duration_Seconds
    
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