
#Delete all Empty Folders
#(gci "L:\NeedsReview\" -r | ? {$_.PSIsContainer -eq $True}) | ?{$_.GetFileSystemInfos().Count -eq 0} | remove-item

#Uncomment and run this command with the path that contains the .mp4 files
#Get-ChildItem -Path "L:\N862A6" -Recurse -Filter *.mp4 | Move-Item -Destination "L:\Temp"

#Replace this with imported folder name
$folderToSearch = "ReplaceThisWithFolderName"

$basePath = "L:\"
CD $basePath
#What file to loop through
$totalSearchedfileCount = 0
$duplicateCount = 0
$wrongNameFormatCount = 0
$filesMovedCount = 0
Get-ChildItem $basePath -Filter $folderToSearch | 
Foreach-Object {
    #Only get .mp4 files
    Get-ChildItem $_.FullName -Recurse -Filter *.mp4 | Foreach-Object {
        $fileNameSplit = $_.FullName.Split('_')
        $channel = $fileNameSplit[1]
        if ($channel -like "*ch*") {
            $dateStr = $fileNameSplit[3].substring(0, 14)
            $date = [datetime]::parseexact($dateStr, 'yyyyMMddHHmmss', $null)
            $fileName = $date.ToString("yyyy-MM-dd_HHmmss") + "_$channel"
            $dateFileName = $date.ToString("yyyy-MM-dd")
            $channelPath = "L:\Channels\$channel"
            if (!(Test-Path -Path $channelPath)) {
                New-Item -Path "L:\Channels\" -Name $channel -ItemType "directory"
                Write-Host "Created $channel"
            }
            else {
                $channelDatePath = "$channelPath\$dateFileName"
                if (!(Test-Path -Path $channelDatePath)) {
                    New-Item -Path "$channelPath\" -Name $dateFileName -ItemType "directory"
                    Write-Host "Created $channelPath\$dateFileName"
                }
                else {
                    if (!(Test-Path -Path $($channelDatePath + "/$fileName.mp4"))) {
                        Move-Item -Path $_.FullName -Destination $($channelDatePath + "/$fileName.mp4") -ErrorAction Stop
                        Write-Host $_.FullName ---> $($channelDatePath + "/$fileName.mp4")
                        $filesMovedCount++
                    }
                    else {
                        Write-Host "File already exists: " $_.FullName "--> $($channelDatePath + "/$fileName.mp4")"

                        ##Move Duplicates for file cleanup
                        # if (!(Test-Path -Path $("L:\NeedsReview\Duplicates\$($_.Name)"))) {
                        #     Move-Item -Path $_.FullName -Destination "L:\NeedsReview\Duplicates\" -ErrorAction Stop
                        # }
                        $duplicateCount++
                    }
                }
            }
        }
        else {
            Write-Host "!Error! Channel Name is not correct. " $_.FullName
            $wrongNameFormatCount++
        }
        $totalSearchedfileCount++
    }
}

Write-Host "Moved File Count = $filesMovedCount"
Write-Host "Duplicate File Count = $duplicateCount"
Write-Host "Wrong File Name Count = $wrongNameFormatCount"
Write-Host "TotalFile Count = $totalSearchedfileCount"
