function Open-DSCResourceMigration {
    [CmdletBinding()]
    Param()

    Set-Location $PSScriptRoot\..
    Get-ChildItem *migrate*.ps1
}