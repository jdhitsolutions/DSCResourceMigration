
Get-ChildItem -Path $PSScriptroot\functions |
ForEach-Object {
    . $_.FullName
}