function New-ConcurTemplate{

    Param(
        [parameter(Mandatory=$true)]
        [String]
        $Path
    )

        $StartDate = (Get-Date).AddDays(-14).ToUniversaltime().ToString('yyyMMddHHmmss.Z')

        $Users = @()
        $StaffNew = @()
        $DCStaff = "OU=DC_Staff,OU=_NDI,DC=ndi,DC=org"

        $obj = [PSCustomObject]@{
        'FirstName' = "Employee First Name"; 'MiddleName' = "Middle Name"; 'LastName' = "Employee Last Name"; 'IsActive' = "Active"; 'EmployeeID' = "Employee ID"; 
        'LoginID' = "Logon ID"; 'Password' = "Password"; 'EmailPrimary' = "Email Address"; 'Locale' = "Locale"; 'CtryCode' = "Country of Residence"; 'CrnCode' = "Reimbursement Currency";
        'LedgerCode' = "Ledger"; 'Custom21Code' = "Expense Group ID"; 'TRAVEL_WIZARD_USER' = "Books Travel";
        }

        $StaffNew += $obj

        $Users = Get-ADUser -Filter "Created -gt '$StartDate'" -SearchBase $DCStaff -Properties *
        $Disabled = Get-ADUser -Filter "enabled -eq 'false' -and country -eq 'US' -and modified -gt '$StartDate'" -Properties *

        foreach ($User in $Users){

            if($User.Enabled -eq $True){
                $Active = "Y"
                }

                else{
                    $Active = "N"
                }

            if($User.EmployeeID -ne $null){
                $EmployeeID = $User.EmployeeID
                }

                else{
                    $EmployeeID = $User.EmailAddress
                }

            $obj = [PSCustomObject]@{
            'FirstName' = $User.GivenName; 'MiddleName' = ""; 'LastName' = $User.Surname; 'IsActive' = $Active; 'EmployeeID' = $EmployeeID; 
            'LoginID' = $User.EmailAddress; 'Password' = New-RandomPassword; 'EmailPrimary' = $User.EmailAddress; 'Locale' = "en_US"; 'CtryCode' = "US"; 'CrnCode' = "USD";
            'LedgerCode' = "CstPnt"; 'Custom21Code' = "NDI-US"; 'TRAVEL_WIZARD_USER' = "Y";
            }

            $StaffNew += $obj
            Clear-Variable -Name Active
            Clear-Variable -Name EmployeeID

        }

        foreach ($User in $Disabled){

            if($User.EmployeeID -ne $null){

                $obj = [PSCustomObject]@{
                'FirstName' = $User.GivenName; 'MiddleName' = ""; 'LastName' = $User.Surname; 'IsActive' = "N"; 'EmployeeID' = $User.EmployeeID; 
                'LoginID' = $User.EmailAddress; 'Password' = New-RandomPassword; 'EmailPrimary' = $User.EmailAddress; 'Locale' = "en_US"; 'CtryCode' = "US"; 'CrnCode' = "USD";
                'LedgerCode' = "CstPnt"; 'Custom21Code' = "NDI-US"; 'TRAVEL_WIZARD_USER' = "Y";
                }

                $StaffNew += $obj

            }
        }

        $StaffNew | Export-Excel -Path $Path -WorksheetName "Employees"

}

Export-ModuleMember -Function New-ConcurTemplate