# ==========================================
# 2. NETWORK INFORMATION
# ==========================================

$networkInfo =[PSCustomObject]@{
            AdapterName = $null
            Status = $null
            MacAddress = $null
            InterfaceIndex = $null
            IPv4 = $null
            Gateway = $null
            DHCP = $null
            DNS = $null       
            }

$defaultRoute = Get-NetRoute -AddressFamily IPv4 |
    Where-Object DestinationPrefix -eq "0.0.0.0/0"

$connectedInterface = Get-NetIPInterface -AddressFamily IPv4 | 
    Where-Object ConnectionState -eq "Connected"

$activeAdapter = $null
$activeInterface = $null

if($null -eq $defaultRoute){
}else {
    $activeInterface = $connectedInterface |
        Where-Object InterfaceIndex -in $defaultRoute.InterfaceIndex

    if($null -ne $activeInterface){
        $activeAdapter = Get-NetAdapter |
            Where-Object InterfaceIndex -eq $activeInterface.InterfaceIndex
    }
}
            
if($null -eq $activeAdapter){    
}else{
    $networkInfo.AdapterName = $activeAdapter.Name
    $networkInfo.Status = $activeAdapter.Status
    $networkInfo.MacAddress = $activeAdapter.MacAddress
    $networkInfo.InterfaceIndex = $activeAdapter.InterfaceIndex        

    $ipAddress = Get-NetIpaddress |
        Where-Object {
            $_.InterfaceIndex -eq $activeAdapter.InterfaceIndex -and
            $_.AddressFamily -eq "IPv4"
        }

    if($null -eq $ipAddress) {            
    }else{
        $networkInfo.IPv4 = $ipAddress.IPAddress        
    }

    $getGateway = $defaultRoute |
        Where-Object InterfaceIndex -eq $activeAdapter.InterfaceIndex
                
    if($null -eq $getGateway){
        $networkInfo.Gateway = $null                
    }else{
        $networkInfo.Gateway = $getGateway.NextHop         
    }
    
    $getDNS = Get-DnsClientServerAddress |
                 Where-Object {
                    $_.InterfaceIndex -eq $activeAdapter.InterfaceIndex -and
                    $_.AddressFamily -eq "2"
                }

    $networkInfo.DNS = $getDNS.ServerAddresses 

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