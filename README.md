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

A place to get custom powershell written for use within NDI.

**[⬆ back to top](#documentation)**

## Getting Started

InstallFromGitHub is a powershell module that allows users to install powershell modules directly from Github.
Installing this module is required to run the "Install-GitHubModule" function within powershell locally.

To install this module run the following command in a powershell prompt

 - Invoke-Expression ('$Module="InstallFromGitHub";$User="nditech";$Repo="Tech-PowershellModules";'+(new-objecttnet.webclient).DownloadString('https://raw.githubusercontent.com/PsModuleInstall/InstallFromGithub/master/install.ps1'))

Once InstallFromGitHub is installed, additional modules can be installed from within powershell by running
 - Intall-GitHubModule -User nditech -Repo Tech-PowershellModules -Module <Name of Module>

## Demo

Running the following command will install the AWSPowershell module into the Documents/WindowsPowerShell/Modules directory
 - Intall-GitHubModule -User nditech -Repo Tech-PowershellModules -Module AWSPowershell 

**[⬆ back to top](#documentation)**

## Author(s)

* <b>Jeremy Henson</b> 

> Note: I hope more members of the team will contribute to this repository.

**[⬆ back to top](#documentation)**
