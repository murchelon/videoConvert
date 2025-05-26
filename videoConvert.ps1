<#
videoConvert
#>

param (
    
    # folder where the videos are or start folder to do a recursive convert
    [string] $videoFolderToConvert = 'D:\GITREP\Murch\videoConvert\videos para converter',
    
    # types of videos to convert
    [string[]] $convertFileTypes = @(
        'mov',
        'avi',
        'mpg',
        'mpeg',
        'webm',
        '3gp'
    ),

    # convert recursive? Convert all videos in any folder inside the start folder
    [bool] $isRecursive = $false

    )

$convertFileTypes = $convertFileTypes | ForEach-Object { $_.ToLower() }

$getChilderParams = @{
    Path = $videoFolderToConvert
    File = $true
}

if ($isRecursive)
{
    $getChilderParams.Recurse = $true
}


$files = Get-ChildItem @getChilderParams


$files_toConvert = $files | Where-Object {
    $file_ext = $_.Extension.TrimStart('.').ToLower()
    $convertFileTypes -contains $file_ext
}

Clear-Host

Write-Host ""
Write-Host "Starting conversion"
Write-Host ""

$files_toConvert | ForEach-Object {

    $input = $_.FullName
    $folder = $_.DirectoryName

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($input)

    # H.264
    $output264 = Join-Path $folder "$baseName`__converted_h264.mp4"
    if (-not (Test-Path $output264)) {

        Write-Host "Converting: $output264 "

        ffmpeg -i "$input" -loglevel error -hide_banner -c:v libx264 -crf 24 -preset slow -c:a aac -b:a 192k "$output264"
    } else {
        Write-Host "Skip: $output264 already exists."
    }  

    # # H.265
    # $output265 = Join-Path $folder "$baseName`__converted_h265.mp4"
    # if (-not (Test-Path $output265)) {
    #     ffmpeg -i "$input" -c:v libx265 -crf 24 -preset slow -c:a aac -b:a 192k "$output265"
    # } else {
    #     Write-Host "Pulando: $output265 já existe."
    # }  

    # # AV1 (SVT-AV1)
    # $outputAV1 = Join-Path $folder "$baseName`__converted_av1.mkv"
    # if (-not (Test-Path $outputAV1)) {
    #     ffmpeg -i "$input" -c:v libsvtav1 -crf 22 -preset 4 -c:a aac -b:a 192k "$outputAV1"
    # } else {
    #     Write-Host "Pulando: $outputAV1 já existe."
    # }  
    
}

Write-Host ""
Write-Host "Done."
Write-Host ""
