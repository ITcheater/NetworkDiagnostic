
$projectRoot = Split-Path -Path $PSScriptRoot -Parent

$reportFolder = Join-Path $projectRoot "Reports"

if (-not (Test-Path $reportFolder)) {
    New-Item -Path $reportFolder -ItemType Directory
}

$reportPath = Join-Path $reportFolder "NetworkDiagnostic.txt" 
$reportPathJson = Join-Path $reportFolder "NetworkDiagnostic.json" 

$report = @(
"========================================"
"       NETWORK DIAGNOSTIC TOOL"
"========================================"
""
"Computer        : $($userInfo.ComputerName)"
"User            : $($userInfo.User)"
"Date            : $($userInfo.Date)"
"Windows         : $($userInfo.Windows)"
""
"========================================"
"       NETWORK INFORMATION"
"========================================"
""
"Adapter         : $($networkInfo.AdapterName)"
"Status          : $($networkInfo.Status)"
"MAC             : $($networkInfo.MacAddress)"
"IPv4            : $($networkInfo.IPv4)"
"Gateway         : $($networkInfo.Gateway)"
"DHCP            : $($networkInfo.DHCP)"
"DNS             : $($networkInfo.DNS)"
""
"========================================"
"      CONNECTIVITY TEST"
"========================================"
""
"DNS Resolution  : $($connectivity.DNSResolution)"
"DNS Error       : $($connectivity.DNSError)"
"TCP 443         : $($connectivity.Tcp443)"
"Adapter Test    : $($connectivity.AdapterTest)"
"Gateway Test    : $($connectivity.GatewayTest)"
"IPv4 Test       : $($connectivity.IPv4Test)"
"Overall Status  : $($connectivity.OverallStatus)"
""
)

$reportJson=[PSCustomObject]@{
    UserInfo       = $userInfo
    Network        = $networkInfo
    Connectivity   = $connectivity
}

$jsonContent = $reportJson | ConvertTo-Json -Depth 3

Set-Content -Path $reportPath -Value $report
Set-Content -Path $reportPathJson -Value $jsonContent