
$goToFolderConfigFilename = "goToFolder.config"

function Import-AliasFolderMap{

    if(test-path $goToFolderConfigFilename) {
        $aliasToFolderMap = @{}
        Import-Csv($goToFolderConfigFilename) |ForEach-Object {
            if($aliasToFolderMap.ContainsKey($_.alias)){
                Write-Warning "GoToFolder: The key $($_.alias) appears multiple times in $goToFolderConfigFilename"
            }
            if(-not (Test-Path $_.folder)) {
                Write-Warning "GoToFolder: $($_.folder) does not appear to be a valid path"
            }
            $aliasToFolderMap[$_.alias] = $_.folder
        }

        Write-Verbose "Alias Folder Map Read:"
        Write-Verbose $aliasToFolderMap
        return $aliasToFolderMap
    } else{
        Write-Verbose "Could not locate goToFolder.config"
        return $null
    }    
}

$goToFolder_aliasMap = Import-AliasFolderMap

function Set-LocationFromAlias() {
    Param($folderAlias)
    if($folderAlias)
    {
        
        $targetFolder = $goToFolder_aliasMap[$folderAlias]
        if($targetFolder) {
            if(Test-Path $targetFolder) {
                Set-Location $targetFolder
            } else {
                Write-Error "GoToFolder: $targetFolder does not appear to be a valid path"    
            }
        } else {
            Write-Warning "GoToFolder: $folderAlias is not a registered Alias"
            #TODO: consider reloading config here...
        }
    } else {
        $goToFolder_aliasMap = Import-AliasFolderMap
        Write-Host $goToFolder_aliasMap 
    }
}

Set-Alias -Name g -Value Set-LocationFromAlias