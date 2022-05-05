#some alternatives

#this is WIP
$Name = "xHotFix"
Import-Module $psscriptroot\DSCResourceMigration.psd1 -Force
$resource = Get-DscResource -Name $name
#get all commands in the psm1 other than the Get/Set/Test functions
$ast = Get-AST -path $resource.path
$found = $ast.findall({ $args[0] -is [System.Management.Automation.Language.Ast] }, $true)
$h = $found | Group-Object { $_.GetType().Name } -AsHashTable -AsString

$other = $h["NamedBlockAST"][0].statements |
Where-Object { $_.name -notmatch "[(get)|(set)|(test)]-TargetResource" } |
Select-Object extent

$other | Where-Object { $_.extent.text -notmatch "Export-ModuleMember" } |
ForEach-Object {
    $_.Extent.text
}

#now convert mof to class