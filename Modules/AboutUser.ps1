# ==========================================
# 1. USER INFORMATION
# ==========================================

$userInfo =[PSCustomObject]@{
            ComputerName = $null
            User = $null
            Date = $null
            Windows = $null
            }

$computerName = $env:COMPUTERNAME
$computerUser = whoami
$currentDate = Get-Date
$currentMSVersion = (Get-CimInstance Win32_OperatingSystem).Name.Split('|')[0]

$userInfo.ComputerName = $computerName
$userInfo.User = $computerUser
$userInfo.Date = $currentDate
$userInfo.Windows = $currentMSVersion