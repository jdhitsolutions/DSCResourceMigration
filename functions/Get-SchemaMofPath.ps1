

Function Get-SchemaMofPath {
    [cmdletbinding()]
    Param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,HelpMessage = "Enter the DSC Resource name")]
        [string]$Name,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,HelpMessage = "Enter the DSC module name for the resource")]
        [object]$Module,
        [Parameter(HelpMessage = "Get the contents of the file instead of only the path.")]
        [switch]$Content
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting Schema MOF path for $Name from $Module"
        Try {
            if ($psboundparameters.ContainsKey("Content")) {
                [void]($psboundparameters.Remove("Content"))
            }
            #only get the first result.
            $resource = Get-DscResource @psboundparameters -ErrorAction Stop | Select-Object -First 1
            if ($resource) {

                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Splitting $($resource.path)"
                $parent = Split-Path $resource.Path
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Creating a mof path for $($resource.ResourceType)"
                $mofPath = Join-Path $parent -child "$($resource.ResourceType).schema.mof"
                if ((Test-Path -path $mofPath) -AND $Content) {
                    Get-Content -path $mofPath
                }
                elseif (Test-Path -path $mofPath) {
                    $mofPath
                }
                else {
                    Write-Warning "Failed to find a schema.mof file. Expected to find $mofpath"
                }
            }
            else {
                Throw "Failed to find a matching DSC Resource."
            }
        }
        Catch {
            Throw $_
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close Get-SchemaMofPath