Get-Service -Name "google-cloud*" | ForEach-Object {
    Set-Service -Name $_.Name -StartupType Disabled
    Stop-Service -Name $_.Name -Force
}