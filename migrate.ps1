$man = Get-ChildItem "$PSScriptRoot\bucket"

foreach ($m in $man) {
    if ($m.Basename -clike '[A-Z]*') { continue }
    $c = Get-Content $m.Fullname -Raw | ConvertFrom-Json
    $c.persist = $c.persist | Sort-Object
    $c | Add-Member -Type Noteproperty -value '$manifest.persist | ForEach-Object { if (-not (Test-Path "$persist_dir\$_")) { New-Item "$dir\$_" | Out-Null } }' -name 'pre_install'
    $c.PSObject.properties.remove('notes')

    $new = [pscustomobject] [ordered]@{}
    $sorted = 'version', 'description', 'homepage', 'license', 'architecture', 'url', 'hash', 'pre_install', 'bin', 'shortcuts', 'persist', 'checkver', 'autoupdate'
    $keys = $c.PSObject.Properties
    foreach ($k in $sorted) {
        if ($k -in $keys.Name) {
            $new | Add-Member -Type NoteProperty -Name $k -value $keys[$k].Value
        }
    }

    ConvertTo-Json $new -depth 8 | Out-File $m.Fullname -Encoding Ascii -Force
}
