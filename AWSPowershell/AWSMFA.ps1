function Invoke-AWSAssumeRole {
    param (
        [Parameter(Mandatory=$true)]
        [String]
        $AWSProfile,
        $MFAProfile,
        $MFARole
    )

do{
    $MFACode = Read-Host "Please enter a valid 6 digit MFA Code:"
    }
    while($MFACode.Length -ne 6)

Initialize-AWSDefaults -ProfileName $AWSProfile
$global:sessionCreds = (Use-STSRole -RoleArn $MFARole -SerialNumber $MFAProfile -TokenCode $MFACode -DurationInSeconds 43200 -RoleSessionName "AssumedRole").Credentials

}

Export-ModuleMember -Function Invoke-AWSAssumeRole