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

#Global Variables

$PROGRAM_NAME = "Web Builder";
$AUTHOR = "Yiannis";

$Version = "0.1";

$TAG_START = ".*@(";
$TAG_END = ".*)@.*";

$IGNORE_DIRECTORIES = "Build", "Import", ".git";
$IGNORE_FILES = "README.md", "build.ps1";
$IGNORE_ITEMS = $IGNORE_DIRECTORIES + $IGNORE_FILES; #Powershell allows list appending.

$PARSED_EXTENTIONS = ".html", ".css";

$BuildLocation = "Build" + (GetDirSeparator);

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

  }
}

#Method that when passed a directory that is a child of the base directory of this
#script, will return the same directory structure, but now inside the build folder.
#IE: ./Resources/cat.png --> ./Build/Resources/cat.png
function GetTransformedRelativeDirectoryInBuildFolder
{
  param ([System.IO.SystemInfo] $itemPath)
  process
  {

  }
}

#Scans through the file line by line. Tries to find a tag which is described by $TAG_START
#and ends with $TAG_END. In between there exists a file name that describes a file that
#should reside inside the ./Imports folder, the method then replaces the tag with the content
#of that file and then returns the file content. 
function ParseFile
{
  param ([string] $fileContent)
  process
  {

  }
}

#Saves a file to the location pointed to by $fileInfo.
#Contents of the file are stored in $content.
function SaveFile
{
  param ([System.IO.FileInfo] $fileInfo, [string] $content)
  process
  {

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

Write-Output "$PROGRAM_NAME V$Version - $AUTHOR";

$startingDirectory = New-Object -TypeName "System.IO.DirectoryInfo" $PSScriptRoot;

BuildDirectoryRecursive [System.IO.DirectoryInfo]$startingDirectory;