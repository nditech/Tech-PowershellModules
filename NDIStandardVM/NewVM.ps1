function New-NDIVM{

<#
    .SYNOPSIS
      Creates Virtual Machines (VM) pre-configured to NDI Windows Server Deployment Policies
      
    .DESCRIPTION
      The New-NDIVM function deploys a new Virtual Machine (VM) and adds the VM to failover cluster
      "VMCluster.ndi.org.  The VM will have two Virtual Hard Disk (VHD).  The first VHD is 128GB and
      holds the Operating System, the second VHD is 32GB and stores application data.  VHD's are prov-
      isioned dynamically.
      
      New-NDIVM takes up to 4 inputs: (1)VMName - Name of the VM, (2)VMSwitch - The virtual network adapter
      the VM will use. Defaults to "VSS-HVC-NIC4-General", (3)AppVHDName - Name for the 32GB Application VHD.
      Defaults to "Applications", (4)ThreadCount - Number of threads assigned to the VM. Defaults to 2 threads.  
       
    .EXAMPLE
     New-NDIVM -VMName "TestVM" -AppVHDName "TestAppDisk" -ThreadCount 4
     
     The above command will create a Virtual Machine named TestVM, attach a 32GB VHD named TestAppDisk, and
     assign the VM 4 processing threads.
#>

    Param(
    [parameter(Mandatory=$true)]
    [String]
    $VMName
    ,

    [ValidateSet(“VSS-HVC-NIC3-PXE”,”VSS-HVC-NIC4-General”)]
    [String]
    $VMSwitch = "VSS-HVC-NIC4-General"
    ,

    [String]
    $AppVHDName = "Applications"
    ,

    [int64]
    [ValidateRange(2,4)]
    $ThreadCount = 2
    )



$VMPath = "C:\ClusterStorage\Volume1\Hyper-V"
$VHDPathOS = "C:\ClusterStorage\Volume1\Hyper-V\$VMName\Virtual Hard Disks\$VMName.vhdx"
$VHDPathAPP = "C:\ClusterStorage\Volume1\Hyper-V\$VMName\Virtual Hard Disks\$AppVHDName.vhdx"

New-VM -Name $VMName -Path $VMPath -MemoryStartupBytes 8GB -NewVHDPath $VHDPathOS -NewVHDSizeBytes 128GB -SwitchName VSS-HVC-NIC4-General -Generation 2

Set-VMProcessor $VMName -Count $ThreadCount

New-VHD -Path $VHDPathAPP -SizeBytes 32GB -Dynamic
Add-VMHardDiskDrive -VMName $VMName -Path $VHDPathAPP

Get-VM -Name $VMName | Add-ClusterVirtualMachineRole

}
