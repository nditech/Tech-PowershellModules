Function New-RandomPassword { 

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

Export-ModuleMember -Function New-RandomPassword