Function New-ClassDefinition {
    [cmdletbinding()]
    Param(
        [Parameter(ValueFromPipelineByPropertyName, Mandatory, HelpMessage = "Enter the DSC Resource name")]
        [string]$Name,
        [Parameter(ValueFromPipelineByPropertyName, Mandatory, HelpMessage = "Enter the DSC module name for the resource")]
        [object]$Module
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        #initialize a collection of strings for the output. This could be the contents
        #of a new .psm1 file.
        $code = [System.Collections.Generic.list[string]]::New()
        $code.Add("[DSCResource()]")
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Converting DSC Resource $Name"
        #get the resource
        Try {
            Write-Verbose "Getting the most current version of DSC Resource $name"
            $resource = Get-DscResource -Name $name -Module $module -ErrorAction stop |
                Sort-Object version -Descending | Select-Object -First 1
        }
        Catch {
            Throw $_
        }
        #get mof path
        $mofPath = Get-SchemaMofPath -name $Name -module $module
        if ($mofPath) {
            $parsedMof = Convert-SchemaMofProperty $mofpath
            $code.Add("Class $($parsedMof.ClassName) {")
            $code.AddRange([string[]]$($parsedMof.Properties))
        }
        else {
            Throw "Failed to find a valid schema.mof for DSC resource $name"
        }

        #get Methods
        #parse module file to get method code
        $getFun = Get-DSCResourceFunction -Path $resource.path -Name Get-TargetResource
        $code.Add("[$($parsedMof.ClassName)] Get() {")
        $code.Add("# TODO :Insert RETURN keyword")
        $code.Add("# TODO: Need to change non-property variables to script scope")

        $method = $getFun.Body
        foreach ($prop in $resource.properties) {
            $method = Convert-VariableReference -VariableName $prop.name -CodeBlock $method
        }
        $code.Add($($method))
        $code.Add("} #close Get method`n")

        $setFun = Get-DSCResourceFunction -Path $resource.path -Name Set-TargetResource
        $code.Add("[void] Set() {")

        $method = $setFun.Body
        foreach ($prop in $resource.properties) {
            $method = Convert-VariableReference -VariableName $prop.name -CodeBlock $method
        }
        $code.Add($($method))
        $code.Add("} #close Set method`n")

        $testFun = Get-DSCResourceFunction -Path $resource.path -Name Test-TargetResource
        $code.Add("[Bool] Test() {")
        $method = $testFun.Body
        foreach ($prop in $resource.properties) {
            $method = Convert-VariableReference -VariableName $prop.name -CodeBlock $method
        }
        $code.Add($($method))
        $code.Add("} #close Test method`n")
        #close the definition
        $code.Add("} #close class`n")
        $code
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close New-ClassDefinition