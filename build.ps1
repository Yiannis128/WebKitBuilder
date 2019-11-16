#This program scans through and down the directory it is placed in.
#It copies all the files it finds into a folder called "Build".
#It preserves the directory structure of the files. So if a file is
#inside ./Resources/cat.png it will be coppied into ./Build/Resources/cat.png
#It has a list of extentions it is looking for. If it finds a file with
#that extention it will scan through it. It looks for a tag with a specific
#format, once it finds that it looks for the file that the tag describes which
#is located inside the ./Imports/ folder. It then replaces the tag with the
#content of the file and then places the content in the Build folder.

#Author: Yiannis Charalambous

#This method scans through the directory pointed to by $directoryInfo.
#The method then gets all the files and checks their extention.
#If they have an extention of $PARSED_EXTENTIONS then they
#will be passed to the ParseFile method which will parse and return
#the results.
#The files will regardless if parsed or not be saved to the $Build folder.
function BuildDirectoryRecursive
{
  param ([System.IO.DirectoryInfo] $directoryInfo)
  process
  {
    Write-Output "Scanning Directory: $($directoryInfo.FullName)`n";

    #Get all sub directories.
    $children = Get-ChildItem -Path $directoryInfo.FullName;

    foreach($childItem in $children)
    {
      #Determine if the child item is a directory or a file.
      if($childItem -is [System.IO.DirectoryInfo])
      {
        $dirInfo = [System.IO.DirectoryInfo]$childItem;

        #Check if this is an allowed directory.
        if(!([string[]]$IGNORE_DIRECTORIES).Contains($dirInfo.Name))
        {
          #Scan this directory too.
          BuildDirectoryRecursive $dirInfo;
        }
      }
      elseif($childItem -is [System.IO.FileInfo]) #The childItem is a file.
      {
        $fileInfo = [System.IO.FileInfo]$childItem;

        #Check if this is an allowed file. If not then it will not be copied.
        if(!([string[]]$IGNORE_FILES).Contains($fileInfo.Name))
        {
          $fileContent = Get-Content -Path $fileInfo.FullName;

          #Check if this file is parsable.
          if(([string[]]$PARSED_EXTENTIONS).Contains($fileInfo.Extension))
          {
            Write-Output "Parsing file: $($fileInfo.FullName)";

            $parsedFileContent = ParseFile $fileContent;

            $buildFileInfo = GetTransformedRelativeDirectoryInBuildFolder $fileInfo;

            Write-Output "Saving file: $($fileInfo.FullName)";

            SaveFile $buildFileInfo $parsedFileContent;
          }
          else #File will just be copied, not parsed.
          {
            $buildFilePath =  GetTransformedRelativeDirectoryInBuildFolder $fileInfo;
            $buildFileInfo = New-Object -TypeName "System.IO.FileInfo" -ArgumentList $buildFilePath;

            Write-Output "Saving file: $($fileInfo.FullName)";

            CopyFile $fileInfo $buildFileInfo;
          }
        }
      }
    }
  }
}

#Method that when passed a directory that is a child of the base directory of this
#script, will return the same directory structure, but now inside the build folder.
#IE: ./Resources/cat.png --> ./Build/Resources/cat.png
function GetTransformedRelativeDirectoryInBuildFolder
{
  param ([System.IO.FileInfo] $itemPath)
  process
  {
    $relativePath = Resolve-Path -Relative -Path $itemPath.FullName;
    
    $dirSep = GetDirSeparator;

    return "$($PSScriptRoot)$($dirSep)$($BuildLocation)$($dirSep)$($relativePath)";
  }
}

function ParseTag
{
  param([string] $tag)
  process
  {
    $parsedResult = [regex]::match($tag , $REPLACE_TAG).Groups[1].Value;

    #The $parsedResult currently is surrounded by brackets that need removal.
    $parsedResult = $parsedResult.Remove(0,1);
    $parsedResult = $parsedResult.Remove($parsedResult.Length - 1, 1);

    return $parsedResult;
  }
}

#Scans through the file line by line. Tries to find a tag which is described by $TAG_START
#and ends with $TAG_END. In between there exists a file name that describes a file that
#should reside inside the ./Imports folder, the method then replaces the tag with the content
#of that file and then returns the file content. 
function ParseFile
{
  param ([string[]] $fileContent)
  process
  {
    $fileContentList = New-Object -TypeName "System.Collections.ArrayList";
    $fileContentList.InsertRange(0, $fileContent);

    #Parse file line by line.
    for($index = 0; $index -lt $fileContentList.Count; $index++)
    {
      $line = $fileContentList[$index];

      if($line -match $REPLACE_TAG)
      {
        #Get the file name using the text inside the tag.
        $fileName = ParseTag $line;

        #Remove this line from the content of the file.
        $fileContentList.Remove($line);
        
        $dirSep = GetDirSeparator;
        
        $replaceContent = [string[]](Get-Content -Path "$($ReplaceResourcesPath)$($dirSep)$($fileName)");

        $fileContentList.InsertRange($index, $replaceContent);
      } 
    }

    return $fileContentList.ToArray();
  }
}

function CopyFile
{
  param ([System.IO.FileInfo] $sourceFileInfo, [System.IO.FileInfo] $fileInfo)
  process
  {
    if(!(Test-Path -Path $fileInfo.Directory)) #See if the directory of the file exists.
    {
      #If it does not exist then powershell creates it recursivly.
      New-Item -Path $fileInfo.Directory -ItemType "Directory" | Out-Null;
    }

    Write-Output "To: $($fileInfo.FullName)`n";

    #Write the content to the file.
    Copy-Item -Path $sourceFileInfo -Destination $fileInfo;
  }
}

#Saves a file to the location pointed to by $fileInfo.
#Contents of the file are stored in $content.
function SaveFile
{
  param ([System.IO.FileInfo] $fileInfo, [string] $content)
  process
  {
    if(!(Test-Path -Path $fileInfo.Directory)) #See if the directory of the file exists.
    {
      #If it does not exist then powershell creates it recursivly.
      New-Item -Path $fileInfo.Directory -ItemType "Directory" | Out-Null;
    }

    #Check if the file exists already, if it does not then create it.
    if(!(Test-Path -Path $fileInfo.FullName))
    {
      New-Item -ItemType "File" -Path $fileInfo.FullName | Out-Null;
    }

    Write-Output "To: $($fileInfo.FullName)`n";

    #Write the content to the file.
    Set-Content -Path $fileInfo.FullName -Value $content | Out-Null;
  }
}

#Gets the respective directory separator of the current OS.
function GetDirSeparator
{
  param()
  process
  {
    if($IsLinux -or $IsMacOs)
    {
      return "/";
    }
    else
    {
      return "\";
    }
  }
}

#Global Variables

$PROGRAM_NAME = "Web Builder";
$AUTHOR = "Yiannis";

$Version = "1.0";

$REPLACE_TAG = "@(.*)@";

$ReplaceResourcesPath = "Imports";

$IGNORE_DIRECTORIES = "Build", $ReplaceResourcesPath, ".git", ".vscode";
$IGNORE_FILES = "README.md", "build.ps1", "clean.ps1", ".gitignore";

$PARSED_EXTENTIONS = ".html", ".css";

$BuildLocation = "Build"

#Program

Write-Output "`n$PROGRAM_NAME V$Version - $AUTHOR`n";

$startingDirectory = New-Object -TypeName "System.IO.DirectoryInfo" $PSScriptRoot;

BuildDirectoryRecursive $startingDirectory;

Write-Output "Build Finished.";