# Deployment backup plan

Before a production update, store a timestamped backup outside the live resource directory.

Back up:

- The current Tarot resource directory, including card assets and NUI files.
- `server.cfg` and any permission configuration used by the resource.
- Framework, inventory, target, and item configuration used by the resource.
- The current version tag and deployment notes.

Example PowerShell outline:

```powershell
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
Copy-Item -Recurse -LiteralPath '<resource-path>' -Destination "<backup-root>\gnsh-tarot-$stamp"
```

Do not place credentials in the backup notes. Verify that the copied directory can be restored before deleting the previous release.
