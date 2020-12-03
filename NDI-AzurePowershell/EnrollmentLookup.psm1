function Get-FieldEnrollment {

    <#
    .SYNOPSIS
      Returns the number of machines currently enrolled in each office along
      with administrators (if applicable)
      
    .DESCRIPTION
      The Get-FieldEnrollment function requires the "Path" parameter
      
      Requires the following modules:
      Install-Module -Name AzureAD
      Import-Module -Name AzureAD
       
    .EXAMPLE
      Get-FieldEnrollment -Path "C:\temp"
    #>

    param (
        [Parameter(Mandatory=$true)]
        [String]
        $Path
    )

Connect-AzureAD

$Output = @()
$FieldComputerGroups = Get-AzureADGroupMember -ObjectId (Get-AzureADGroup -Filter "DisplayName eq 'Field Computers'").ObjectID

foreach ($Group in $FieldComputerGroups){

    $AdminGroup = ($Group.DisplayName).Replace("Machines","Admins")

    if(Get-AzureADGroup -SearchString $AdminGroup){

        $AdminGroupID = (Get-AzureADGroup -SearchString $AdminGroup).ObjectId
        $Admin = (Get-AzureADGroupMember -ObjectId $AdminGroupID)

            }
    
    $FieldGroup = Get-AzureADGroupMember -ObjectId $Group.ObjectId

    $Field = [PSCustomObject]@{
        'Field Office'     = ($Group.DisplayName).Replace(" Machines","")
        'Enrolled Devices' = $FieldGroup.count
        'Administrator'    = (@($Admin.DisplayName) -join ", ")

            }

    $Output += $Field
    Clear-Variable -Name Admin
        }

    $Output | Export-Csv -NoTypeInformation -Path "$Path\Enrollments.csv"
    }

Export-ModuleMember -Function Get-FieldEnrollment