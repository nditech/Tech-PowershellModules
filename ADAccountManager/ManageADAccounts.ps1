<#
.SYNOPSIS
A script to automate the creation and management of Active Directory users based on an Excel spreadsheet.

.DESCRIPTION
This script takes in an Excel spreadsheet with details about employees' accounts. It then automatically creates, disables, or updates those accounts based on the input. In addition, it generates a log file that records the actions taken for each user.

.PARAMETER filePath
Specifies the path to the Excel file from which user data will be imported. This is a mandatory parameter.

.PARAMETER logPath
Specifies the path to the directory where the log file will be stored. If not specified, defaults to "C:\logs\".

.EXAMPLE
Invoke-UserProcessing -filePath "C:\Users\Administrator\Documents\user_data.xlsx"

Imports user data from the specified Excel file and processes user accounts accordingly. Logs are stored in the default log directory ("C:\logs\").

.EXAMPLE
Invoke-UserProcessing -filePath "C:\Users\Administrator\Documents\user_data.xlsx" -logPath "D:\AD_Logs\"

Imports user data from the specified Excel file and processes user accounts accordingly. Logs are stored in the specified log directory ("D:\AD_Logs\").

.INPUTS
The script accepts the path of an Excel spreadsheet as input.

.OUTPUTS
The script does not return any outputs. It does, however, generate a log file named "ADUserManagementLog.log" in the same directory as the script. This log file contains detailed information about the actions taken by the script.

.NOTES
Please note that the spreadsheet must have certain columns named exactly as follows:

In the "Comings" worksheet:
- "Full Name"
- "Email"
- "Password"
- "Team"
- "Title"
- "Manager"
- "Location"
- "Country"
- "Union"
- "Type"

In the "Goings" worksheet:
- "Email"

In the "Transfers" worksheet:
- "Full Name"
- "Email"
- "Team"
- "Title"
- "Manager"
- "Location"
- "Country"
- "Union"
- "Type"

Each "Union" column should contain one of the following values: "Union", "Non-Union", "Management". This determines which AD groups the user is added to.

Each "Type" column should contain one of the following values: "DC Staff", or leave it blank. This along with the "Team" value, can determine additional AD groups the user is added to.

The "Manager" column should contain the email of the manager. This is used to set the manager in AD.

.FUNCTIONALITY
This script uses the Active Directory module for Windows PowerShell. Please ensure that this module is installed and loaded before running the script.
#>

Function Invoke-UserProcessing {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]$filePath,
        [string]$logPath
    )
    # Default log path
    if ($null -eq $logPath) {
        $logPath = "C:\Scripts\Powershell\Logs\AD Account Managment\"
    }

    # Ensure the log path ends with a backslash
    if (-not $logPath.EndsWith("\")) {
        $logPath += "\"
    }

    # Define log file name
    $logFile = $logPath + "accountManagement_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".log"

    # Initialize the log
    if (-not (Test-Path $logFile)) {
        New-Item -Path $logFile -ItemType File | Out-Null
    }

    function Write-Log {
        param (
            [Parameter(Mandatory=$true)]
            [string] $logMessage
        )

        $timestamp = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
        $fullMessage = "$timestamp - $logMessage"

        # Write the log message to a file
        Add-Content -Path $logFile -Value $fullMessage

        # Output the log message to the console
        Write-Output $logMessage
    }

    Import-Module ActiveDirectory
    Import-Module ImportExcel

    Function Out-CleanString ($string) {
        return $string.Trim()
    }

    Function New-SecurePassword { 

        [CmdletBinding()]
        param(
            [Parameter(
                Position = 0,
                Mandatory = $false
            )]
            [ValidateRange(8,32)]
            [int]    $Length = 16,
    
            [switch] $ExcludeSpecialCharacters
    
        )
    
    
        BEGIN {
            $SpecialCharacters = @((33,35) + (36..38) + (42..44) + (60..64))
        }
    
        PROCESS {
            try {
                if (-not $ExcludeSpecialCharacters) {
                        $Password = -join ((48..57) + (65..90) + (97..122) + $SpecialCharacters | Get-Random -Count $Length | ForEach-Object {[char]$_})
                    } else {
                        $Password = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count $Length | ForEach-Object {[char]$_})
                }
    
            } catch {
                Write-Error $_.Exception.Message
            }
    
        }
    
        END {
            Write-Output $Password
        }
    
    }

    Function Import-ExcelData ($path, $worksheetName) {
        $rawData = Import-Excel -Path $path -WorksheetName $worksheetName

        $validData = @()
        foreach ($row in $rawData) {
            if ([string]::IsNullOrEmpty($row.'First Name') -or [string]::IsNullOrEmpty($row.'Last Name')) {
                break
            }

            $validData += $row
        }

        return $validData
    }

    Function Invoke-UserAccountCreation ($user) {
        $firstName = Out-CleanString $user.'First Name'
        $lastName = Out-CleanString $user.'Last Name'
        $SAM = (($firstName[0] + $lastName).Replace(" ", "")).ToLower()
        $upn = ($SAM + $domainName).ToLower()
        $supervisorEmail = $user.'Supervisor Email' -join ""
        $manager = (Get-ADUser -Server $domainController -Filter {mail -eq $supervisorEmail}).DistinguishedName
        $existingUser = $null
    
        try {
            $existingUser = Get-ADUser -Server $domainController -Identity $SAM -ErrorAction Stop
            # Check if existing user is disabled and if "rehire" is present in the Notes column
            if (($existingUser.Enabled -eq $false) -and ($user.Notes -like "*rehire*")) {
                # Re-enable the user
                Enable-ADAccount -Server $domainController -Identity $existingUser
                Write-Log "----------------------------------------------------"
                Write-Log "Rehired user $($user.'First Name') $($user.'Last Name')"
                Write-Log "----------------------------------------------------"
                return
            } else {
                $SAM = (($firstName.Substring(0,2) + $lastName).Replace(" ", "")).ToLower()
                $upn = ($SAM + $domainName).ToLower()
                $existingUser = Get-ADUser -Server $domainController -Identity $SAM -ErrorAction Stop
            }
        } catch {
            if($_.Exception -like "*Cannot find an object with identity:*") {
                Write-Log "----------------------------------------------------"
                Write-Log "No existing user found with SAM $SAM. Creating new user."
                Write-Log "----------------------------------------------------"
                New-UserAccount -SAM $SAM -UPN $upn -FirstName $firstName -LastName $lastName -User $user -Manager $manager
                return
            } else {
                # If there's a different error, re-throw it
                throw $_
            }
        }
    
        try {
            if($null -ne $existingUser) {
                Write-Log "----------------------------------------------------"
                Write-Log "User with SAM $SAM already exists."
                Write-Log "----------------------------------------------------"
                return
            } else {
                New-UserAccount -SAM $SAM -UPN $upn -FirstName $firstName -LastName $lastName -User $user -Manager $manager
            }
        } catch {
            Write-Log "----------------------------------------------------"
            Write-Log "Failed to create user $($firstName) $($lastName). Error: $($_.Exception.Message)"
            Write-Log "----------------------------------------------------"
        }
    }
    
    Function New-UserAccount ($SAM, $UPN, $firstName, $lastName, $user, $manager) {
        # Try to create the user
        $password = New-SecurePassword
        $passwordSecure = ConvertTo-SecureString -String $password -AsPlainText -Force
    
        New-ADUser -Server $domainController -SamAccountName $SAM -UserPrincipalName $upn -GivenName $firstName -Surname $lastName -Name ($firstName + " " + $lastName) -EmailAddress $upn -Description $user.'Job Title' -Title $user.'Job Title' -Department $user.Team -Enabled $true -Manager $manager -Country $user.'Country Code' -AccountPassword $passwordSecure -PassThru | Set-ADUser -Server $domainController -Office $user.'Office Assignment'
    
        sleep 10
    
        # After user creation, add them to the country group and move them to the correct OU
        $countryCode = $user.'Country Code' -join ""
        $countryGroup = Get-ADGroup -Server $domainController -Filter {Description -eq $countryCode} -SearchBase $ou
        if ($null -ne $countryGroup) {
            Add-ADGroupMember -Server $domainController -Identity $countryGroup -Members $SAM
    
            # Extract region from group name
            $region = ($countryGroup.Name -split '\(')[-1] -replace '\)', ''
                if($region -eq "DC") 
                    {$regionOU = "OU=DC_Staff,OU=_NDI,DC=ndi,DC=org"}
                else
                    {$regionOU = "OU=$region,OU=NDI Field,OU=_NDI,DC=ndi,DC=org"}
    
            # Move user to region OU
            Get-ADUser -Server $domainController -Identity $SAM | Move-ADObject -Server $domainController -TargetPath $regionOU
            Write-Log "----------------------------------------------------"
            Write-Log "User $($firstName) $($lastName) created successfully and moved to the $($region) organization unit."
            Write-Log "The Password for User $($firstName) $($lastName) is <--- $password --->"
            Write-Log "----------------------------------------------------"
        } else {
            Write-Log "----------------------------------------------------"
            Write-Log "No matching country group found for user $($user.'First Name') $($user.'Last Name') with Country Code $($user.'Country Code')"
            Write-Log "----------------------------------------------------"
        }
    }   

    Function Update-UserAccount ($user) {
        $firstName = Out-CleanString $user.'First Name'
        $lastName = Out-CleanString $user.'Last Name'
        $email = $user.'Email Address' -join ""
        $username = $email.Split("@")[0]
        $supervisorEmail = $user.'Supervisor Email' -join ""
        if (-not [string]::IsNullOrEmpty($supervisorEmail)) {
        $manager = (Get-ADUser -Server $domainController -Filter {mail -eq $supervisorEmail} -ErrorAction SilentlyContinue).DistinguishedName
        }
            else {
            # Handle case where supervisorEmail is null or empty
            $manager = $null
            Write-Log "----------------------------------------------------"
            Write-Log "Supervisor email for user $($user.'First Name') $($user.'Last Name') is empty or null."
            Write-Log "----------------------------------------------------"
        }

        Set-ADUser -Identity $username -Title $user.'Job Title' -Description $user.'Job Title' -Office $user.'Office Assignment' -Country $user.'Country Code' -Department $user.'Team' -Manager $manager
        Write-Log "----------------------------------------------------"
        Write-Log "User $($firstName) $($lastName) updated successfully."
        Write-Log "----------------------------------------------------"
    }

    Function Add-UserToGroups {
        param (
            [Parameter(Mandatory=$true)]
            [string] $userDN,
            
            [Parameter(Mandatory=$true)]
            [string] $unionStatus,
            
            [Parameter(Mandatory=$true)]
            [string] $department,
            
            [Parameter(Mandatory=$false)]
            [string] $type = $null
        )
        
        $groupMap = @{
            'Union' = 'UnionGroupDN';
            'Non-Union' = 'NonUnionGroupDN';
            'Management' = 'ManagementGroupDN';
        }
        
        $departmentGroupMap = @{
            'Accounting' = @('Accounting_Team', 'Department1GroupDN2');
            'Asia' = @('Asia_Team');
            'Central and East Europe' = @('CEE_Team');
            'Central and West Africa' = @('CEWA_Team');
            'Elections' = @('Elections_Team');
            'Eurasia' = @('Eurasia_Team');
            'Human Resources' = @('Human_Resources_Team');
            'Office Management' = @('Office_Management_Team');
            'Program Coordination' = @('Program_Coordination_Team');
            'Program Development' = @('Program_Development_Team');
            'Southern and East Africa' = @('SEA_Team');

            # Add more mappings as needed.
        }
    
        $typeDepartmentGroupMap = @{
            'DC Staff' = @{
                'Asia' = 'Asia_DC';
                'Central and East Europe' = 'CEE_DC';
                'Central and West Africa' = 'CEWA_DC';
                'Latin America and the Carribean' = @('LAC_DC')
                # Add more mappings as needed.
            }
            'Country Staff' = @{
                'Central and West Africa' = 'CEWA_Field';
                'Latin America and the Carribean' = @('LAC_Field')
                # Add more mappings as needed.
            }
            # Add more mappings as needed.
        }
        
        # Check if the unionStatus is valid.
        if ($groupMap.ContainsKey($unionStatus)) {
            # Get the corresponding group DN.
            $groupDN = $groupMap[$unionStatus]
            
            # Add user to the group.
            Add-ADGroupMember -Identity -Server $domainController $groupDN -Members $userDN -ErrorAction SilentlyContinue
        } else {
            Write-Host "Invalid union status: $unionStatus"
        }
        
        # Check if the department is valid.
        if ($departmentGroupMap.ContainsKey($department)) {
            # Get the corresponding group DNs.
            $groupDNs = $departmentGroupMap[$department]
            
            foreach ($groupDN in $groupDNs) {
                # Add user to the group.
                Add-ADGroupMember -Identity -Server $domainController $groupDN -Members $userDN -ErrorAction SilentlyContinue
            }
        } else {
            Write-Host "Invalid department: $department"
        }
    
        # Check if the type and department combination is valid.
        if ($null -ne $type -and $typeDepartmentGroupMap.ContainsKey($type) -and $typeDepartmentGroupMap[$type].ContainsKey($department)) {
            # Get the corresponding group DN.
            $groupDN = $typeDepartmentGroupMap[$type][$department]
            
            # Add user to the group.
            Add-ADGroupMember -Identity -Server $domainController $groupDN -Members $userDN -ErrorAction SilentlyContinue
        } elseif ($null -ne $type) {
            Write-Host "Invalid type: $type"
        }
    }
    
    
    Function Disable-UserAccount ($user) {
        $email = $user.'Email Address' -join ""
        $existingUser = Get-ADUser -Filter {mail -eq $email} -ErrorAction SilentlyContinue
        if ($null -ne $existingUser) {
            $endDate = [DateTime]::FromOADate($user.'End-Date').AddHours(24)
            Set-ADAccountExpiration -Identity $existingUser -DateTime $endDate
            Write-Log "----------------------------------------------------"
            Write-Log "User account $existingUser.Name has been set to expire on $endDate"
            Write-Log "----------------------------------------------------"
        }
    }

    $domainName = "@ndi.org"
    $ou = "OU=Offices,OU=NDI Security Groups,OU=_NDI,DC=ndi,DC=org"
    $domainController = "aws-dc2.ndi.org"

    # Import Data From Excel
    $rawComings = Import-ExcelData -path $filePath -worksheetName "Comings"
    $rawTransfers = Import-ExcelData -path $filePath -worksheetName "Transfers"
    $rawGoings = Import-ExcelData -path $filePath -worksheetName "Goings"

    # Select Data to pass through
    $selectedComings = $rawComings | Out-GridView -PassThru -Title "Please select users for creation"
    $selectedTransfers = $rawTransfers | Out-GridView -PassThru -Title "Please select users for updating"
    $selectedGoings = $rawGoings | Out-GridView -PassThru -Title "Please select users for disabling"

    foreach ($user in $selectedComings) {
        Invoke-UserAccountCreation -user $user
    }

    foreach ($user in $selectedTransfers) {
        Update-UserAccount -user $user
    }

    foreach ($user in $selectedGoings) {
        Disable-UserAccount -user $user
    }
}
