$dir = "D:\Recordings"
while ($true) {
    if (Test-Path "$dir\current.mp3") {
        $ts = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        $new = "$dir\blklist_$ts.mp3"
        Move-Item "$dir\current.mp3" $new -Force
        Write-Host "Saved $new"
    }
    Start-Sleep -Seconds 10
}
