
$projectRoot = Split-Path -Path $PSScriptRoot -Parent

$reportFolder = Join-Path $projectRoot "Reports"

if (-not (Test-Path $reportFolder)) {
    New-Item -Path $reportFolder -ItemType Directory
}

$reportPath = Join-Path $reportFolder "NetworkDiagnostic.txt"

if (-not (Test-Path $reportPath)) {
    New-Item -Path $reportPath -ItemType File
}

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
"DNS Resolution  : $($networkInfo.DNSResolution)"
"DNS Error       : $($networkInfo.DNSError)"
"TCP 443         : $($networkInfo.Tcp443)"
"Adapter Test    : $($networkInfo.AdapterTest)"
"Gateway Test    : $($networkInfo.GatewayTest)"
"IPv4 Test       : $($networkInfo.IPv4Test)"
"Overall Status  : $($networkInfo.OverallStatus)"
""
)

Set-Content -Path $reportPath -Value $report