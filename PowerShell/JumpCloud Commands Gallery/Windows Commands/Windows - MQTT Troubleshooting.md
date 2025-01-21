#### Name

Windows - MQTT Troubleshooting Script | v1.0 JCCG

#### commandType

windows

#### Command

```
# Parameters
$BrokerAddress = "a1hrq03pdcca60-ats.iot.us-east-1.amazonaws.com"
$BrokerPort = 443

# Network Connectivity Checks
function Test-NetworkConnectivity {
    Write-Host "1. Network Connectivity Checks" -ForegroundColor Cyan
    
    # DNS Resolution
    Write-Host "   Checking DNS Resolution..." -ForegroundColor Gray
    try {
        $resolvedIP = (Resolve-DnsName $BrokerAddress -ErrorAction Stop)[0].IPAddress
        Write-Host "   DNS Resolution Successful: $resolvedIP" -ForegroundColor Green
    }
    catch {
        Write-Host "   DNS Resolution Failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }

    # Ping Test
    Write-Host "   Performing Ping Test..." -ForegroundColor Gray
    $pingResult = Test-Connection -ComputerName $BrokerAddress -Count 4 -Quiet
    if ($pingResult) {
        Write-Host "   Ping Successful" -ForegroundColor Green
    }
    else {
        Write-Host "   Ping Failed" -ForegroundColor Red
        return $false
    }

    # Port Connectivity
    Write-Host "   Checking Port Connectivity..." -ForegroundColor Gray
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    try {
        $tcpClient.Connect($BrokerAddress, $BrokerPort)
        if ($tcpClient.Connected) {
            Write-Host "   Port $BrokerPort is Open" -ForegroundColor Green
            $tcpClient.Close()
        }
    }
    catch {
        Write-Host "   Unable to Connect to Port ${BrokerPort}: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }

    return $true
}

# TCP Connection Test
function Test-TcpConnection {
    Write-Host "2. TCP Connection Test" -ForegroundColor Cyan
    
    try {
	$testNetConn = Test-Netconnection -Port ${BrokerPort} ${BrokerAddress} | Select-Object -Property TcpTestSucceeded -ExpandProperty TcpTestSucceeded
        if ($testNetConn) {
            Write-Host "   TCP Connection Successful" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "   TCP Connection Failed" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "   TCP Connection Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main Troubleshooting Function
function Start-MQTTTroubleshooting {
    Clear-Host
    Write-Host "MQTT Troubleshooting Script" -ForegroundColor Magenta
    Write-Host "===========================" -ForegroundColor Magenta
    
    # Perform Network Checks
    $networkCheckPassed = Test-NetworkConnectivity
    
    # If network checks pass, proceed with TCP connection test
    if ($networkCheckPassed) {
        $tcpConnectionPassed = Test-TcpConnection
        
        if ($tcpConnectionPassed) {
            Write-Host "`nTroubleshooting Complete: All Tests Passed" -ForegroundColor Green
        }
        else {
            Write-Host "`nTroubleshooting Complete: Some Tests Failed" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "`nTroubleshooting Stopped: Network Connectivity Issues Detected" -ForegroundColor Red
    }
}

# Run the troubleshooting script
Start-MQTTTroubleshooting
```

#### Description

This script helps diagnose common MQTT connectivity and communication issues by performing various network checks.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20MQTT%20troubleshooting.md"
```
