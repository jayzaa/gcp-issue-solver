 [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Google\Chrome\Application", "User");
$backupDir = "C:\tmp"
$hostsFilePath = "C:\Windows\System32\drivers\etc\hosts"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH_mm_ss"

$backupFilePath = Join-Path $backupDir "backup_hosts_$timestamp.txt"


$targetUrl = "https://cloud.uipath.com"


## Make Copy of Hosts file / create necessary objects
if (!(Test-Path -Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory | Out-Null
    Write-Output "Created directory: $backupDir"
}

try {
    Copy-Item -Path $hostsFilePath -Destination $backupFilePath -Force
    Write-Output "Hosts file backed up to: $backupFilePath"
}
catch {
    Write-Output "Failed to backup hosts file: $($_.Exception.Message)"
    exit;
}

Write-Output "Performing Access: $targetUrl"

$hostname = ([Uri]$targetUrl).Host
$output = ping $hostname -n 1 | Out-String
if ($output -match "\[(\d{1,3}(?:\.\d{1,3}){3})\]") {
    $ip = $matches[1]
    Write-Output "IP Address from ping: $ip"
} else {
    Write-Output "No IP address found in ping output."
    exit 1
}

#Get IP List from DNS
$target = $hostname

$nslookupOutput = nslookup $target 2>$null | Out-String
$pattern = "Name:\s+" + [regex]::Escape($target)
$parts = $nslookupOutput -split $pattern

if ($parts.Count -lt 2) {
    Write-Error "Could not locate the $hostname block in nslookup output."
    exit 1
}

$dnsBlock = $parts[1]

$ipv4Addresses = [regex]::Matches($dnsBlock, "\b(?:\d{1,3}\.){3}\d{1,3}\b") | ForEach-Object { $_.Value }

$iplist = $ipv4Addresses
#Write-Output $iplist

#Active Chrome Headless
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

$outputFile = "$env:TEMP\chrome_output.txt"
Start-Process -FilePath $chromePath `
              -ArgumentList '--headless', '--dump-dom', '--disable-gpu', $targetUrl `
              -NoNewWindow -Wait `
              -RedirectStandardOutput $outputFile
$output = Get-Content $outputFile -Raw


### This statement is using for detect "connection error" through Cloudflare returned information
if ($output -match ".error-footer") {
    Write-Output "Down with ip: $ip, This IP or website had been broken"
    $replacement = $iplist | Where-Object { $_ -ne $ip }
    Write-Output "Will Replace with $replacement"
    $ip = $replacement
    Write-Output "IP Replaced to $ip"
    ## Append to host file
    ##Parser
    $pattern = "\b" + [regex]::Escape($target) + "\b"

    try {
        $newHostsContent = $hostsContent | Where-Object { $_ -notmatch $pattern }
        $entry = "$ip`t$target"
        $newHostsContent += $entry
        $newHostsContent | Set-Content $hostsFilePath -Force
        Write-Output "Updated hosts file with override entry: $entry"
    }
    catch {
        Write-Output "Failed to update hosts file: $($_.Exception.Message)"
    }

    ## Put Google Metadata If not found
    $google_metadata = "169.254.169.254 metadata.google.internal metadata"
    try {
        if (-not (Get-Content $hostsFilePath | Select-String -SimpleMatch $google_metadata)) {
            Add-Content -Path $hostsFilePath -Value $google_metadata
            Write-Output "Added Google Metadata."
        } else {
            Write-Output "Google Metadata Already there.No need to put from Google side"
        }
    }
    catch {
        Write-Output "Failed to update Google hosts file: $($_.Exception.Message)"
    }
    Write-Output "Website Down, Script had been effected to hosts file C:\Windows\System32\drivers\etc\hosts"
} 
else {
    Write-Output "OK, Exit with ip: $ip, This website looks good."
    $stateFile = Join-Path $backupDir "last_working_ip.txt"
    try {
        Set-Content -Path $stateFile -Value $ip -Force
        Write-Output "Stored working IP ($ip) in state file: $stateFile"
    }
    catch {
        Write-Output "Failed to store working IP: $($_.Exception.Message)"
    }
    
    ## Put Google Metadata If not found
    $google_metadata = "169.254.169.254 metadata.google.internal metadata"
    try {
        if (-not (Get-Content $hostsFilePath | Select-String -SimpleMatch $google_metadata)) {
            Add-Content -Path $hostsFilePath -Value $google_metadata
            Write-Output "Added Google Metadata."
        } else {
            Write-Output "Google Metadata Already there. No Action from Google side"
        }
    }
    catch {
        Write-Output "Failed to update Google hosts file: $($_.Exception.Message)"
    }
    Write-Output "Website looks good, no change had been made"
}

 
