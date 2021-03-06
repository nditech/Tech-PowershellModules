<h1 align="center">
  <a href="https://www.ndi.org/"><img src="https://www.ndi.org/sites/all/themes/ndi/images/NDI_logo_svg.svg" alt="NDI Logo" width="200"></a>
</h1>

<h1 align="center">
  NDI Tech's Powershell Modules
</h1>

## Documentation

### Table of Contents

1. [Intro](#intro)
2. [Getting Started](#getting-started)
3. [Demo](#demo)

## Intro

A place to get custom powershell modules written for use within NDI.

**[⬆ back to top](#documentation)**

## Getting Started

InstallFromGitHub is a powershell module that allows users to install powershell modules directly from Github.
Installing this module is required to run the "Install-GitHubModule" function within powershell locally.

To install this module run the following command in a powershell prompt

 - `Invoke-Expression ('$Module="InstallFromGitHub";$User="nditech";$Repo="Tech-PowershellModules";'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/PsModuleInstall/InstallFromGithub/master/install.ps1'))`
 
The command above, along with the InstallFromGitHub module, makes use of [stadub's script](https://github.com/PsModuleInstall/FromGithub)

Once InstallFromGitHub is installed, additional modules can be installed from within powershell by running
 - `Install-GitHubModule -User nditech -Repo Tech-PowershellModules -Module [Name of Module]`

## Demo

Running the following command will install the AWSPowershell module into the Documents/WindowsPowerShell/Modules directory
 - `Install-GitHubModule -User nditech -Repo Tech-PowershellModules -Module AWSPowershell`

**[⬆ back to top](#documentation)**

## Author(s)

* <b>Jeremy Henson</b>
* <b>Viet Nguyen</b> 

> Note: I stole this template from Viet

**[⬆ back to top](#documentation)**
