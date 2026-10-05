# ==========================================
# 2. NETWORK INFORMATION
# ==========================================

# Get-NetAdapter               -> Adapter / MAC / Status
# Get-NetIPAddress             -> IPv4
# Get-NetRoute                 -> Gateway
# Get-NetIPInterface           -> DHCP
# Get-DnsClientServerAddress   -> DNS
# Resolve-DnsName              -> Dns Resolution


$networkInfo =[PSCustomObject]@{
            AdapterName = $null
            AdapterTest = $null
            Status = $null
            MacAddress = $null
            InterfaceIndex = $null
            IPv4 = $null
            IPv4Test = $null
            Gateway = $null
            GatewayTest = $null
            DHCP = $null
            DNS = $null
            DNSResolution = $null
            DNSError = $null
            Tcp443 = $null
            OverallStatus = $null           
            }

$activeAdapter = Get-NetAdapter | Where-Object Status -eq "Up" 

if($null -eq $activeAdapter){
    $networkInfo.AdapterTest = "FAIL"
}else{
        $networkInfo.AdapterName = $activeAdapter.Name
        $networkInfo.AdapterTest = "PASS"
        $networkInfo.Status = $activeAdapter.Status
        $networkInfo.MacAddress = $activeAdapter.MacAddress
        $networkInfo.InterfaceIndex = $activeAdapter.InterfaceIndex

        $ipAddress = Get-NetIpaddress |
            Where-Object {
                $_.InterfaceIndex -eq $activeAdapter.InterfaceIndex -and
                $_.AddressFamily -eq "IPv4"
            }

        if($null -eq $ipAddress) {
            $networkInfo.IPv4Test = "FAIL"
        }else{
            $networkInfo.IPv4 = $ipAddress.IPAddress
            $networkInfo.IPv4Test = "PASS"
        }
        
        $getGateway = Get-NetRoute -AddressFamily IPv4 |
            Where-Object {
                $_.DestinationPrefix -eq "0.0.0.0/0" -and 
                $_.InterfaceIndex -eq $activeAdapter.InterfaceIndex
            } 
                
        if($null -eq $getGateway){
            $networkInfo.Gateway = $null
            $networkInfo.GatewayTest = $null
        }else{
            $networkInfo.Gateway = $getGateway.NextHop
            $gatewayTest = Test-NetConnection $networkInfo.Gateway -InformationLevel Quiet
            $networkInfo.GatewayTest = $gatewayTest
        }
        
        $getDHCP = Get-NetIPInterface |
            Where-Object {
                $_.InterfaceIndex -eq $activeAdapter.InterfaceIndex -and 
                $_.AddressFamily -eq "IPv4"
            }
        if($null -eq $getDHCP){
            $networkInfo.DHCP = $null
        }else{
            $networkInfo.DHCP = $getDHCP.DHCP
        }

        $getDNS = Get-DnsClientServerAddress |
            Where-Object {
                $_.InterfaceIndex -eq $activeAdapter.InterfaceIndex -and
                $_.AddressFamily -eq "2"
            }

        if($null -eq $getDNS){
            $networkInfo.DNS = $null
        }else{
            $networkInfo.DNS = $getDNS.ServerAddresses
        }

        try {
            $null = Resolve-DnsName google.com -ErrorAction Stop
            $networkInfo.DNSResolution = "PASS"
        }
        catch {
            $networkInfo.DNSResolution = "FAIL"
            $networkInfo.DNSError = $_.Exception.Message
        }

        $tcp443Test = Test-NetConnection google.com -Port 443 -InformationLevel Quiet
        $networkInfo.Tcp443 = $tcp443Test

}

if (($networkInfo.AdapterTest -eq "PASS") -and 
    ($null -ne $networkInfo.IPv4) -and 
    ($networkInfo.GatewayTest -eq $True) -and 
    ($networkInfo.DNSResolution -eq "PASS") -and
    ($networkInfo.Tcp443 -eq $True)) {
        $networkInfo.OverallStatus = "PASS"
}else{
        $networkInfo.OverallStatus = "FAIL"
}



