$buildFolder = "$($PSScriptRoot)\Build";
if(Test-Path -Path $buildFolder)
{
  Remove-Item -Path $buildFolder -Recurse 
  Write-Output "Cleaning...";
} 

Write-Output "Clean.";