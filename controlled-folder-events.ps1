# controlled-folder-events.ps1
# Author: Praful
# 20171108 This script lists the apps blocked today by the Windows 10 Controlled Folder feature.
#
# 20180607 Add memory events (id = 1127) for Windows 10 v1803
#          Refactor into functions
#          Add -action switch. Usage -action [blocked|allowed|add]. Defaults to blocked. If "add" specified,
#          you have the option to specify a file containing file paths. If nothing follows "add", blocked files
#          are added.



# To add exception:
#   Add-MpPreference  -ControlledFolderAccessAllowedApplications "c:\apps\test.exe"
#
# To save allowed apps:
#   $prefs=Get-MpPreference
#   $prefs.ControlledFolderAccessAllowedApplications
#   $prefs.ControlledFolderAccessAllowedApplications | out-file allowed-apps.txt
#
# To add exceptions for all apps in file allowed-apps.txt:
#   Get-Content .\allowed-apps.txt |ForEach-Object {Add-MpPreference -ControlledFolderAccessAllowedApplications $_}

# https://stackoverflow.com/questions/2157554/how-to-handle-command-line-arguments-in-powershell
param([string]$action="blocked", [string]$allowedapps="")

$trace = $false

function Get-Process-Paths($events)  
{
  
  if ($trace) {Write-Host "Get-Process-Paths. Events = $($events.count)"}

  $processes = [System.Collections.ArrayList]@()

  foreach($entry in $events) {
    if ($entry -eq $null) {continue}

    $event_xml = [xml]$entry.ToXml()
    # $event_xml.Event.EventData.Data will display event

    # Need to use some XML magic to extract Process Name (the full path program) from the EventData
    $process_name = $event_xml.SelectSingleNode("//*[@Name='Process Name']")."#text"

    $index_ignore = $processes.add($process_name)
  }

  # Output list of blocked apps, sorting and removing duplicates
  # $processes |sort -uniq
  $processes |Get-Unique 
}

function Get-Controller-Folder-Events($id){
  if ($trace) {Write-Host "Get-Controller-Folder-Events. id = $id"}

  #TODO allow date to be entered as parameter to script
  $startdate = [datetime]::today
  # $startdate = Get-Date -Year 2018 -Month 6 -Day 15

  Get-WinEvent -erroraction "silentlyContinue" -FilterHashtable @{logname='Microsoft-Windows-Windows Defender/Operational';id=$id;starttime=$startdate}


  if ($events -ne $null -And $events.GetType() -is [System.Diagnostics.Eventing.Reader.EventLogRecord]){
    $events_array = [System.Collections.ArrayList]@()  
    $events_array.add($events)
    $events_array
  }
  else {
    $events
  }
}

function Get-Blocked{
  Get-Controller-Folder-Events(1123)
  Get-Controller-Folder-Events(1127)
}

switch ($action) {
    "blocked" {
      if ($trace) {Write-Host "Showing blocked:"}
      Get-Process-Paths(Get-Blocked) | Get-Unique
    }

    "allowed" {
      if ($trace) {Write-Host "Showing allowed:"}
      $prefs=Get-MpPreference
      $prefs.ControlledFolderAccessAllowedApplications
    }

    "add" {
      Write-Host "Adding new blocked events to allowed programs. Input file = $allowedapps"
    
      if ($allowedapps -eq ""){
        Get-Process-Paths(Get-Blocked) | ForEach-Object {Add-MpPreference -ControlledFolderAccessAllowedApplications $_}
      }
      else{
        Get-Content $allowedapps |ForEach-Object {Add-MpPreference -ControlledFolderAccessAllowedApplications $_}
      }
   }
}


