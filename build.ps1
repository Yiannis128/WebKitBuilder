#This script copies all of the content of the project (except for files in .vscode and Templates folder).
#It scans through each file and searches for tags in the form of ${TAG_ID} and then replaces the ${TAG_ID}
#with a file in the templates folder in the form of TAG_ID.html. It then copies the 'build' files into
#the Builds folder keeping the integrity of the directory layout intact.

#Author: Yiannis Charalambous.

#Global Variables
#The files/folder base names that will be ignored by the web kit builder. (Not coppied into ./Build)
$IGNORE_ITEMS = "Imports", "Build", ".vscode", "build", "clean";
#The allowed extentions that will be parsed for the symbol replacement.
$ALLOWED_EXT = ".html", ".css";

$VersionNumber = "0.1";

#This function scans for folders and recurses into them. If an item is found, then the scanFile method is
#called on it.
function scanDirectory 
{
  param ([System.IO.DirectoryInfo] $relativePath)
  
  process
  {
    Write-Output("Scanning Directory: $relativePath");

    $childItems = Get-ChildItem -Path $relativePath;

    foreach ($childItem in $childItems) 
    {
      #BaseName is a custom object that has property BaseName. We need the value of BaseName
      $itemName = (($childItem | Select-Object BaseName)."BaseName");

      #Make sure child item is not part of ignored list array.
      if(!$IGNORE_ITEMS.Contains($itemName))
      {
        #Check if item is directory or file.
        if($childItem -is [System.IO.DirectoryInfo]) #This means this is a directory.
        {
          scanDirectory($childItem.FullName)
        }
        else #This means it is a file.
        {
          parseFile($childItem.FullName);
        }
      }
    }
  }
}

#Parse file scans through a file for the tag ${TAG_ID}. Once it finds it, it replaces it with
#the contents of the file Templates/TagID.html
#If it does not find one, it reports an error.
function parseFile 
{
  param ([System.IO.FileInfo] $fileName)
  process
  {
    $START_SYMBOL = "@(";
    $END_SYMBOL = ")@";
    
    $PATTERN = "*" + $START_SYMBOL + "*" + $END_SYMBOL + "*"; #Used with -like
    $REGEX_PATTERN = ".*" + $START_SYMBOL + ".*" + $END_SYMBOL +".*"; #Used with Select-String idk why they don't work with one.

    if(!$ALLOWED_EXT.Contains($fileName.Extension))
    {
      Write-Output("Skipping file: " + $fileName.FullName);

      $fullPath = New-Object -TypeName "System.IO.FileInfo" (getBuildPathFromAbsolutePath $fileName (getDirStepChar));
      
      createEmptyDirAtBuildDir $fullPath;

      Copy-Item -Path $fileName.FullName -Destination $fullPath.FullName;

      Write-Output("Skipped file copied to: " + $fullPath.FullName + "`n");
      return;
    }

    #Get contents of the file.
    $fileContent = Get-Content -Path $fileName;
    
    Write-Output("Processing File: " + $fileName.FullName + " : " + $fileContent.Length);

    #Loop through each line of the file.
    for ($lineIndex = 0; $lineIndex -lt $fileContent.Length; $lineIndex++) 
    {
      #Check if there is substring of form ${TAG_ID}
      if($fileContent[$lineIndex].ToString() -like $PATTERN)
      {
        $importContent = Select-String -InputObject $fileContent[$lineIndex] -Pattern $REGEX_PATTERN;

        #TODO: Replace @(*)@ with the file content.
        $importContent = ([string]$importContent).Replace($START_SYMBOL, "");
        $importContent = $importContent.Replace($END_SYMBOL, "");
        $importContent = $importContent.Replace(" ", "");

        $fileContent[$lineIndex] = $fileContent[$lineIndex] -replace $REGEX_PATTERN, $importContent;
      }
    }

    $newFileContent = "";
    
    foreach($line in $fileContent)
    {
      $newFileContent += ($line + "`n");
    }

    saveFile $fileName $newFileContent;
  }
}

#Saves the $oldFileInfo file, into the Build directory with the new file content.
function saveFile 
{
  param ([System.IO.FileInfo]$oldFileInfo, [string]$fileContent)
  process
  {    
    #Determine the directory separator of this OS.
    $dirSep = getDirStepChar;

    $fullPath = New-Object -TypeName "System.IO.FileInfo" (getBuildPathFromAbsolutePath $oldFileInfo $dirSep);
    
    createEmptyDirAtBuildDir $fullPath;

    #Set the content of the file.
    Set-Content -Path $fullPath.FullName $fileContent
  }
}

#Creates the relative Build directory path of the specified $file.
function createEmptyDirAtBuildDir
{
  param([System.IO.FileInfo] $file)
  process
  {
    Write-Output("Saving File In: " + $file.FullName + "`n");

    #See if the file exists and if it does remove it.
    if(Test-Path -Path $file.FullName)
    {
      Remove-Item $file.FullName;
    }
    elseif(!(Test-Path -Path $file.Directory)) #See if the directory of the file exists.
    {
      #If it does not exist then powershell creates it recursivly.
      New-Item -Path $file.Directory -ItemType "Directory";
    }
  }
}

#This function gets the full path to the Build location that a source
#file will be placed in.
function getBuildPathFromAbsolutePath
{
  param([string] $path, [string] $dirSep)
  process
  {
    $relativePath = Resolve-Path -Path $path -Relative;

    #Remove first 2 characters from relative path since they are ./
    #$relativePath = ([string]$relativePath).Remove(0, 2);

    $fullPath = $PSScriptRoot + $dirSep + "Build" + $dirSep + $relativePath;

    return $fullPath;
  }
}

#Returns the character of the directory separator for the current OS.
function getDirStepChar
{
  param()
  process
  {
    if($IsLinux)
    {
      return "/";
    }
    else 
    {
      return "\";  
    }
  }
}

Write-Output("`nStarting Web Compiler V$VersionNumber - Yiannis Charalambous `n");
$currentDir = New-Object -TypeName System.IO.DirectoryInfo -ArgumentList "$PSScriptRoot";
scanDirectory([System.IO.DirectoryInfo]$currentDir.FullName);