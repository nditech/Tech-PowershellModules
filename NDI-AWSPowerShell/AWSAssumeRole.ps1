function Invoke-AWSAssumeRole {
    param (
        [Parameter(Mandatory=$true)]
        [String]$AWSProfile, $RoleArn,
        [Parameter(Mandatory=$false)]
        [Long]$Duration_Hours = 1

    )
    
    Set-AWSCredential -ProfileName $AWSProfile
    $Duration_Seconds = $Duration_Hours * 3600
    $MFASerial = (Get-IAMMFADevice).SerialNumber

    do{
        $MFAToken = Read-Host "Please enter a valid 6 digit MFA Code:"
        }
        while($MFAToken.Length -ne 6)
    
    $global:AssumedRole = aws sts assume-role --role-arn $($RoleArn) --role-session-name Backupify --serial-number $($MFASerial) --token-code $($MFAToken) --duration-seconds $Duration_Seconds

    $AssumedRoleHash = $AssumedRole | ConvertFrom-Json
    
    $global:AccessKey = $AssumedRoleHash.Credentials.AccessKeyId
    $global:SecretKey = $AssumedRoleHash.Credentials.SecretAccessKey
    $global:Token = $AssumedRoleHash.Credentials.SessionToken

}

function Set-AWSAssumeRole {

    Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey -SessionToken $Token -Scope Global

}

function Get-AWSAssumeRole {

    $AssumedRole

}

Export-ModuleMember -Function Invoke-AWSAssumeRole
Export-ModuleMember -Function Set-AWSAssumeRole
Export-ModuleMember -Function Get-AWSAssumeRole