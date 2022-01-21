for ($i = 0; $i -lt 9; $i++) {
    if ($i -ne 4 -and $i -ne 0) {
        Get-ChildItem "L:\Channels\ch$i" | Foreach-Object {
            if((dir $_.FullName | measure).Count -lt 48)
            {
                Write-Host "Missing Files: " ( dir $_.FullName | measure).Count "Files in " $_.FullName
            } 
        }
    }
}