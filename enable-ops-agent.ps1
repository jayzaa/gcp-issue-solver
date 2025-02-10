Get-Service -Name "google-cloud*" | ForEach-Object {
    Set-Service -Name $_.Name -StartupType Automatic
    Start-Service -Name $_.Name
}