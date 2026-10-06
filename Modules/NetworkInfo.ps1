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
            Status = $null
            MacAddress = $null
            InterfaceIndex = $null
            IPv4 = $null
            Gateway = $null
            DHCP = $null
            DNS = $null
            DNSResolution = $null
            DNSError = $null
            Tcp443 = $null
            AdapterTest = $null
            GatewayTest = $null
            IPv4Test = $null
            OverallStatus = $null           
            }

$defaultRoute = Get-NetRoute -AddressFamily IPv4 |
    Where-Object DestinationPrefix -eq "0.0.0.0/0"

$activeAdapter = $null

if($null -eq $defaultRoute){

}else {
    $activeAdapter = Get-NetAdapter |
        Where-Object InterfaceIndex -eq $defaultRoute.InterfaceIndex
}

            
if($null -eq $activeAdapter){
    $networkInfo.AdapterTest = "FAIL"
    $networkInfo.IPv4Test = "NOT TESTED"
    $networkInfo.GatewayTest = "NOT TESTED"
    $networkInfo.DNSResolution = "NOT TESTED"
    $networkInfo.Tcp443 = "NOT TESTED"
}else{
        $networkInfo.AdapterName = $activeAdapter.Name
        $networkInfo.Status = $activeAdapter.Status
        $networkInfo.MacAddress = $activeAdapter.MacAddress
        $networkInfo.InterfaceIndex = $activeAdapter.InterfaceIndex
        $networkInfo.AdapterTest = "PASS"

        $ipAddress = Get-NetIpaddress |
            Where-Object {
                $_.InterfaceIndex -eq $activeAdapter.InterfaceIndex -and
                $_.AddressFamily -eq "IPv4"
            }

        if($null -eq $ipAddress) {
            $networkInfo.IPv4Test = "FAIL"
            $networkInfo.GatewayTest = "NOT TESTED"
            $networkInfo.DNSResolution = "NOT TESTED"
            $networkInfo.Tcp443 = "NOT TESTED"
        }else{
            $networkInfo.IPv4 = $ipAddress.IPAddress
            $networkInfo.IPv4Test = "PASS"

            $getGateway = $defaultRoute 
                
            if($null -eq $getGateway){
                $networkInfo.Gateway = $null
                $networkInfo.GatewayTest = "NOT TESTED"
                $networkInfo.DNSResolution = "NOT TESTED"
                $networkInfo.Tcp443 = "NOT TESTED"
            }else{
                $networkInfo.Gateway = $getGateway.NextHop
                $gatewayTest = Test-NetConnection $networkInfo.Gateway -InformationLevel Quiet

                if($gatewayTest){
                    $networkInfo.GatewayTest = "PASS"
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
                    if($tcp443Test){
                        $networkInfo.Tcp443 = "PASS"
                    }else {
                        $networkInfo.Tcp443 = "FAIL"
                    }
                }else{
                    $networkInfo.GatewayTest = "FAIL"
                    $networkInfo.DNSResolution = "NOT TESTED"
                    $networkInfo.Tcp443 = "NOT TESTED"
                }
            }       
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
        
}

if (($networkInfo.AdapterTest -eq "PASS") -and 
    ($networkInfo.IPv4Test -eq "PASS") -and 
    ($networkInfo.GatewayTest -eq "PASS") -and 
    ($networkInfo.DNSResolution -eq "PASS") -and
    ($networkInfo.Tcp443 -eq "PASS")) {
        $networkInfo.OverallStatus = "PASS"
}else{
        $networkInfo.OverallStatus = "FAIL"
}



