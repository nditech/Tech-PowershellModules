function Import-Ultipro{

    Param(
        [parameter(Mandatory=$true)]
        [String]
        $Path
    )

    Start-Transcript C:\Scripts\Powershell\Logs\UltiProAD.txt

    $UltiproReport = Import-Excel -Path $Path

    Foreach ($Employee in $UltiproReport){

        if($Employee."Employment Status Code" -eq "A"){

            $Username = ($Employee."Employee Email").Split('@')[0]
            $Supervisor = ($Employee."Supervisor Email").Split('@')[0]

            Set-ADUser -Identity $Username -EmployeeID $Employee."Employee Number" -Manager $Supervisor -Verbose

        }
    }

    Stop-Transcript

}

Export-ModuleMember -Function Import-Ultipro