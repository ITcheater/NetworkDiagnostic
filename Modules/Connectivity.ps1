# ==========================================
# 3. TEST CONNECTIVITY
# =========================================

$connectivity =[PSCustomObject]@{
            DNSResolution = $null
            DNSError = $null
            Tcp443 = $null
            AdapterTest = $null
            GatewayTest = $null
            IPv4Test = $null
            OverallStatus = $null           
            }
# Adapter Test

if($null -ne $networkInfo.AdapterName -and $networkInfo.Status -eq "Up"){
    $connectivity.AdapterTest = "PASS"
}else{
    $connectivity.AdapterTest = "FAIL"
}

# IP Test

if($null -ne $networkInfo.IPv4){
    $connectivity.IPv4Test = "PASS"
}else{
    $connectivity.IPv4Test = "FAIL"
}

# Gateway Test

if ($null -eq $networkInfo.Gateway) {
    $connectivity.GatewayTest = "NOT TESTED"
}elseif (Test-NetConnection $networkInfo.Gateway -InformationLevel Quiet) {
    $connectivity.GatewayTest = "PASS"
}else{
    $connectivity.GatewayTest = "FAIL"
}

# DNS Resolution Test

if($connectivity.GatewayTest -eq "PASS"){
    try {
        $null = Resolve-DnsName google.com -ErrorAction Stop
        $connectivity.DNSResolution = "PASS"
    }
    catch {
        $connectivity.DNSResolution = "FAIL"
        $connectivity.DNSError = $_.Exception.Message
    }
}
else{
    $connectivity.DNSResolution = "NOT TESTED"
}
# TCP 443 Test

if($connectivity.DNSResolution -eq "PASS"){
    $tcp443Test = Test-NetConnection google.com -Port 443 -InformationLevel Quiet
    if($tcp443Test){
        $connectivity.Tcp443 = "PASS"
    }else {
        $connectivity.Tcp443 = "FAIL"
    }
}else{
    $connectivity.Tcp443 = "NOT TESTED"
}

# Test connectivity

if (($connectivity.AdapterTest -eq "PASS") -and 
    ($connectivity.IPv4Test -eq "PASS") -and 
    ($connectivity.GatewayTest -eq "PASS") -and 
    ($connectivity.DNSResolution -eq "PASS") -and
    ($connectivity.Tcp443 -eq "PASS")) {
        $connectivity.OverallStatus = "PASS"
}else{
        $connectivity.OverallStatus = "FAIL"
}