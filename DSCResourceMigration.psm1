
Get-ChildItem -Path $PSScriptRoot\functions |
ForEach-Object {
    . $_.FullName
}