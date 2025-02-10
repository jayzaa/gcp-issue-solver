# Google Cloud OPS Agent Management on Windows

This guide provides instructions on how to manage the Google Cloud OPS Agent service on Windows using provided scripts.

## Prerequisites

- Must be executed with **Administrator Privileges**.
- **No system restart is required** after execution.
- The OPS Agent should be installed on the system before running these commands.

## Provided Scripts

### Disable OPS Agent
**Script:** `disable-ops-agent.ps1`

This PowerShell script disables and turns off the OPS Agent service immediately.

```powershell
Get-Service -Name "google-cloud*" | ForEach-Object {
    Set-Service -Name $_.Name -StartupType Disabled
    Stop-Service -Name $_.Name -Force
}
```

### Enable OPS Agent
**Script:** `enable-ops-agent.ps1`

This PowerShell script enables and turns on the OPS Agent service immediately.

```powershell
Get-Service -Name "google-cloud*" | ForEach-Object {
    Set-Service -Name $_.Name -StartupType Automatic
    Start-Service -Name $_.Name
}
```

### Install OPS Agent
**Script:** `install-ops-agent.bat`

This batch script installs the latest version of Google OPS Agent from Google's repository.
** Preloaded GooGet must be installed first **

```batch
googet -noconfirm install google-cloud-ops-agent
```

### Remove OPS Agent
**Script:** `remove-ops-agent.bat`

This batch script removes the Google OPS Agent from the server.

```batch
googet -noconfirm remove google-cloud-ops-agent
```

## Running the Scripts with Administrator Privileges

To ensure the scripts execute properly, **run PowerShell or Command Prompt as Administrator**:

1. Click on the **Start** menu and search for `PowerShell` or `cmd`.
2. Right-click on **Windows PowerShell** or **Command Prompt** and select **Run as administrator**.
3. Navigate to the directory containing the scripts and execute the required script.

Example:
```powershell
.\disable-ops-agent.ps1
```
```batch
install-ops-agent.bat
```

## Notes
- These scripts do **not require a system restart**.
- If the OPS Agent service is not installed, related scripts may return an error.
- If managing OPS Agent remotely, use `Invoke-Command` with appropriate credentials.

## Troubleshooting

If the service does not start or stop as expected:
1. Verify the agent is installed by running:
   ```powershell
   Get-Service -Name google-cloud-ops-agent
   ```
2. Check for errors in the Event Viewer (`eventvwr.msc` → Windows Logs → Application).
3. Ensure you are running the commands with **Administrator Privileges**.
4. If issues persist, try reinstalling the OPS Agent using [Google Cloud documentation](https://cloud.google.com/ops-agent/docs).

## Additional References
For more information, refer to the official Google Cloud OPS Agent documentation:
- [OPS Agent Management](https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent)
- [Google Cloud OPS Agent Overview](https://cloud.google.com/ops-agent/docs)
