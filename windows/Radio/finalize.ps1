$dir = "D:\Recordings"
$cur = Join-Path $dir "current.mp3"

function Test-Locked($path) {
  try {
    $fs = [System.IO.File]::Open($path, 'Open', 'ReadWrite', 'None')
    $fs.Close()
    return $false
  } catch {
    return $true
  }
}

while ($true) {
  if (Test-Path $cur) {
    # Odota että Icecast ei enää kirjoita (source disconnect)
    if (-not (Test-Locked $cur)) {
      $ts = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
      $new = Join-Path $dir ("blklist_" + $ts + ".mp3")
      try {
        Move-Item $cur $new -Force
        Write-Host "Saved: $new"
      } catch {
        Write-Host "Move failed: $($_.Exception.Message)"
      }
    }
  }
  Start-Sleep -Seconds 5
}