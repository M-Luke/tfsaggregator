#Script will error if TFS/DevOps is not installed on the machine you are running it on! (AKA "HKLM:\SOFTWARE\Microsoft\TeamFoundationServer" is missing in registry)
$baseTFSRegistryPath = "HKLM:\SOFTWARE\Microsoft\TeamFoundationServer"

if (!(Test-Path $baseTFSRegistryPath)) {
	throw "TFS/DevOps server does not appear to be installed? (Not found in registry!)"
}

$highestTFSversion = "{0:N1}" -f (
	Get-ChildItem -Path $baseTFSRegistryPath |
		Split-Path -Leaf |
		Foreach-Object { $_ -as [double] } |
		Sort-Object -Descending |
		Select-Object -First 1)

$tfsRegistryInfo = Get-ItemProperty -Path "$baseTFSRegistryPath\$highestTFSversion"


if($tfsRegistryInfo.BuildNumber -gt $tfsRegistryInfo.PatchVersion){
	Write-Output "Installed TFS/DevOps Server - BuildNumber: $($tfsRegistryInfo.BuildNumber)`n`n"
}
else{
	Write-Output "Installed TFS/DevOps Server - BuildNumber: $($tfsRegistryInfo.BuildNumber) | PatchVersion: $($tfsRegistryInfo.PatchVersion)`n`n"
}


$pathToAssemblyFile = "$($tfsRegistryInfo.InstallPath)Application Tier\Web Services\bin\Plugins\TFSAggregator2.ServerPlugin.dll"
$dllOutput = [System.Reflection.Assembly]::LoadFile($pathToAssemblyFile).GetCustomAttributesData() | Where-Object { $_.AttributeType -in ([System.Reflection.AssemblyFileVersionAttribute],[System.Reflection.AssemblyConfigurationAttribute]) } | Select-Object ConstructorArguments

Write-Output "TFSAggregator2 Version:"
$dllOutput