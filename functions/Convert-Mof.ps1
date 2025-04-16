#convert schema.mof brute force
Function Convert-Mof {
    [CmdletBinding()]
    Param(
        [parameter(
            Position = 0,
            Mandatory,
            ValueFromPipelineByPropertyName,
            HelpMessage = "The path to the MOF file to convert"
        )]
        [ValidateScript({ Test-Path $_ })]
        [ValidatePattern("\.mof")]
        [String]$Path
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN] Starting $($MyInvocation.MyCommand)"
        $properties = [System.Collections.Generic.list[object]]::new()
    } #begin
    Process {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Processing $Path"
        $mof = Get-Content $Path
        #get class name
        [regex]$rxClass = '(?<=class\s)\w+'
        $name = $rxClass.match($mof).value
        #get friendly name
        [regex]$rxFriendly = '(?<=FriendlyName\(")\w+'
        $friendly = $rxFriendly.match($mof).value
        #get version
        [regex]$rxVersion = '(?<=ClassVersion\(.)(\d+(\.))+\d+?'
        $version = $rxVersion.match($mof).value
        #read mof for keys
        "Key", "Required", "Write", "Read" | ForEach-Object {
            # $properties.Add( $(Get-SchemaMofProperty -Path $path -type $_))
            Get-SchemaMofProperty -Path $path -type $_ | ForEach-Object { $properties.Add($_) }
        }

        [PSCustomObject]@{
            Name         = $name
            FriendlyName = $friendly
            Properties   = $properties
            ClassVersion = $version
        }

    } #process
    End {
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #end
}

