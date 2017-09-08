# Script Name: getSystemInformation.ps
# Desc: powershell script to run commands for getting a variety of system information
# Author: Morgan Keiser
# Date: 08.30.2017
# Last Revision: 09.08.2017

# functions are used for separating sections and organization, not for any functionality
# Note: not all 'functions' give functionality, but are listed with comments for intent

# current time, timezone of PC, PC uptime
function get_time{
  Write-Output "-------------------------------------------------------------------"
  Write-Output "-------------------Get Time----------------------------------------"
  Write-Output "-------------------------------------------------------------------"
  $time = (Get-Date -DisplayHint Time) # prints current date and time
  # Write-Output Time Zone: (Get-Timezone) # prints the list of timezone affiliated information, even though I just want the Id information
  $timezone = Get-Timezone | select Id # get just the Time Zone Name, not whole listing
  $ostime = Get-WmiObject win32_operatingsystem # get operating system to init use of functions
  $Uptime = (Get-Date) - ($ostime.ConvertToDateTime($ostime.lastbootuptime)) # subtract last boot time from current time
  $DisplayToScreen = "Time  "+"TimeZone " + "Uptime  " + "`r`n" + $time+ " " + $timezone +" "+$Uptime.Days + "d " + $Uptime.Hours + "h " + $Uptime.Minutes + "m" #set display
  Write-Output $DisplayToScreen # prints the output to the screen, as a makeshift table
}

# Get numerical include major, minor, build, and revision, Get typical name (Windows10...)
function windows_version{
  Write-Output "-------------------------------------------------------------------"
  Write-Output "-------------------Get Windows Version-----------------------------"
  Write-Output "-------------------------------------------------------------------"
  #"Build:`r`n------"
  [system.environment]::OSVersion.version # prints major, minor, build, revision, with labelled segments
  #"`r`nTypical Name:`r`n-------------"
  [system.environment]::OSVersion.VersionString | format-table # this is the command for the typical name (MS Win 10)
}

# CPU brand and type, Ram amount, HDD amount, ■ List hard drives ■ List mounted filesystems
function system_hardware_specs{
  Write-Output "-------------------------------------------------------------------"
  Write-Output "-------------------Get System Hardware Specs-----------------------"
  Write-Output "-------------------------------------------------------------------"
  Get-WmiObject win32_processor | Select-Object -Property Caption # gets the brand, model, and type of processor
  Get-WmiObject -Class Win32_physicalmemoryarray | select Memorydevices #gets the amount of RAM
  Get-WmiObject -Class win32_diskdrive | Select-Object -Property DeviceID, Size, Caption # gets the description of physical drive, the drive size in bytes, and the device type
  Get-PSDrive -PSProvider "filesystem" # lists the harddrives' filesystems (e.g. name, Used GB, free GB, and the root on the filesystem)
}

# Get IP address of DC, Get hostname of DC, Get DNS servers for domain
function get_domain_controller_info{
  Write-Output "-------------------------------------------------------------------"
  Write-Output "-------------------Get Domain Controller Info----------------------"
  Write-Output "-------------------------------------------------------------------"
  Get-ADDomainController | select IPv4Address, hostname # get the ip address and the hostname of the domain controller
}

# get hostname and domain
function hostname_and_domain{
  Write-Output "-------------------------------------------------------------------"
  Write-Output "-------------------Get Hostname and Domain------------------------"
  Write-Output "-------------------------------------------------------------------"
  Get-WmiObject -Class win32_computersystem | select Domain, Name # prints table for domain name and hostname of computer
}

# Local users include SID of user, user account creation date,last login Domain users
# include: SID of user, user account creation date, last log in, System users
# include: SID ofuser, user account creation date, last log in, Service users, Get user login history
function list_users{
  Write-Output "-------------------------------------------------------------------"
  Write-Output "-------------------List Users--------------------------------------"
  Write-Output "-------------------------------------------------------------------"
  Get-ChildItem -Path "c:\Users" # lists the rwx priv of user for C drive, their creation time, and the name
  Get-WmiObject win32_useraccount |select Name, SID # print table of user names and SIDs, includes the Administrator and the Default Account users
}

# Services, Programs ■Registry location ■Command ■User runs as
function what_starts_on_boot{
  Write-Output "-------------------------------------------------------------------"
  Write-Output "-------------------List Start on Boot------------------------------"
  Write-Output "-------------------------------------------------------------------"
  Get-CimInstance -Class win32_startupcommand | format-table # gets the command, run for what user on Boot
}

# list of scheduled tasks
function scheduled_tasks{
  Write-Output "-------------------------------------------------------------------"
  Write-Output "-------------------Scheduled Tasks---------------------------------"
  Write-Output "-------------------------------------------------------------------"
  Get-ScheduledJob | format-table
}

# Get ARP table, MAC addresses for all interfaces, Routing table, IP address (IPv4 and IPv6) for all interfaces
# Get DHCP server, Get DNS server, Get gateway for all interfaces
# Show listening services: ■IP addr it’s binded to ■port service is listening on ■protocol ■service/process name
# Show established connections: ■remote IP address ■local/remote port ■Protocol ■timestamp of connection ■service/process name
# Get DNS cache
function network_things{{
  Write-Output "-------------------------------------------------------------------"
  Write-Output "-------------------Network Things----------------------------------"
  Write-Output "-------------------------------------------------------------------"
  Write-Output "ARP:"
  arp -a # lists the arp table for current ARP entries, the IP address, MAC address, and static/dynamic
  Write-Output "Routing:"
  route print # prints the routing table, the on-link IPv4/6 addresses
  Write-Output "DHCP and DNS Servers:"
  Get-WmiObject win32_networkadapterconfiguration | select DHCPServer # gets DHCP server address
  Get-DnsClientServerAddress |Select InterfaceAlias, AddressFamily, ServerAddresses # gets DNS interfact, IP type, and IP4/6 address
  Write-Output "Gateway:"
  Get-NetIPConfiguration # lists IPv4gateway and IPv6gateway as 6 and 7th elements
  Write-Output "Listening Services:"
  Get-NetTCPConnection -State Listen # gives local IP address, local port, remote address, remote port, the listening state, and the parent process that owns the state
  Write-Output "Established Connections:"
   Get-NetTCPConnection -State Established # gets the local IP address, the local port, remote ip, remote port (ssh), and it's in the established state
}

# network shares, printers, and wifi access profiles
function network_shares_printers{
  Write-Output "Printers:"
  Get-Printer |select Name, Type, DriverName, PortName, Shared, DeviceType | format-table # lists the printers and their drivers
  Write-Output "Network Shares:"
  Get-WmiObject -class Win32_Share # gets the name, path and description of the shares
  netsh wlan show profiles # command to list profiles with wifi user profiles
}
}

# list of installed software
function installed_software{
  Write-Output "-------------------------------------------------------------------"
  Write-Output "-------------------Installed Software------------------------------"
  Write-Output "-------------------------------------------------------------------"
  Get-WmiObject -class win32_product | select caption, version # lists the user-installed products and their versions
}

# Show process name, Show process ID, Show process parent ID, Show location of process on filesystem, Show process owner by username
function process_list{
  Write-Output "-------------------------------------------------------------------"
  Write-Output "-------------------Process List------------------------------------"
  Write-Output "-------------------------------------------------------------------"
  Get-WmiObject -class win32_process | select ProcessName, ProcessId, ParentProcessId, Path # this is the exe name, pid, ppid, and the path to the exe
}

# driver list: Driver name, Must show if driver is boot critical or not, The location of the driver on disk, Version of the driver
# date the driver was created, provider name
function driver_list{
  Write-Output "-------------------------------------------------------------------"
  Write-Output "-------------------Driver List-------------------------------------"
  Write-Output "-------------------------------------------------------------------"
  Get-WmiObject Win32_PnPSignedDriver| select devicename, driverversion # gets the driver name and version
}

# list of files in Downloads and Documents for each user directory
#function files_in_downloads_docs{
 Write-Output "-------------------------------------------------------------------"
 Write-Output "-------------------Files in Folders--------------------------------"
 Write-Output "-------------------------------------------------------------------"
#
#}

# list the last three processes that the computer did
#function last_three_processes{ # this is one of my own 1/3
#
#}

# list if the computer has fax capability
function find_fax{ # one of my own 2/3
  Get-CimInstance win32_pnpentity | where "Name" -match "Fax" |select-Object -Property Name, pnpdeviceid # prints output if there is fax capability--prints Fax and the device id
}

# list the images in the Pictures folder on the computer
#function list_images{ # one of my own 3/3

}
#| Export-Csv c:\powershellOutput.txt
