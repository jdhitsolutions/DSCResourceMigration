

Function Get-SchemaMofPath {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,HelpMessage = "Enter the DSC Resource name")]
        [String]$Name,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,HelpMessage = "Enter the DSC module name for the resource")]
        [object]$Module,
        [Parameter(HelpMessage = "Get the contents of the file instead of only the path.")]
        [Switch]$Content
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Getting Schema MOF path for $Name from $Module"
        Try {
            if ($PSBoundParameters.ContainsKey("Content")) {
                [void]($PSBoundParameters.Remove("Content"))
            }
            #only get the first result.
            $resource = Get-DscResource @PSBoundParameters -ErrorAction Stop | Select-Object -First 1
            if ($resource) {

                Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Splitting $($resource.path)"
                $parent = Split-Path $resource.Path
                Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Creating a mof path for $($resource.ResourceType)"
                $MofPath = Join-Path $parent -child "$($resource.ResourceType).schema.mof"
                if ((Test-Path -path $MofPath) -AND $Content) {
                    Get-Content -path $MofPath
                }
                elseif (Test-Path -path $MofPath) {
                    $MofPath
                }
                else {
                    Write-Warning "Failed to find a schema.mof file. Expected to find $MofPath"
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
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"

    } #end

} #close Get-SchemaMofPath
