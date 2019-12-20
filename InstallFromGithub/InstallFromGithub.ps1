function Install-GitHubModule {
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $True, 
        HelpMessage = 'Github repo user name')]
        [string]$User,

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $True, 
        HelpMessage = 'Repository name')]
        [string]$Repo,

        [Parameter(Position = 2, Mandatory=$true, ValueFromPipelineByPropertyName = $True, 
        HelpMessage = 'Repository Folder(empty for root)')]
        [AllowEmptyString()]
        [string] $Module
    )
    
    Invoke-Expression ('$Module;$User;$Repo;'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/PsModuleInstall/InstallFromGithub/master/install.ps1'))

}
