#convert schema.mof brute force
Function Convert-Mof {
    [CmdletBinding()]
    Param(
        [parameter(
            Position = 0,
            Mandatory,
            ValueFromPipelineByPropertyName,
            HelpMessage = "The path to the file to convert"
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

<#
[ClassVersion("1.0.0.0"), FriendlyName("myPSDailyJob")]
class myPSDailyJob : OMI_BaseResource
{
    [Required, ValueMap{"Absent","Present"}, Values{"Absent","Present"}] String Ensure;
    [Key] String Name;
    [Required] boolean Enabled;
    [Required] string At;
    [Required] string Action;
    [Write] uint32 Interval;
    [Read] string Demo;
};

[ClassVersion("1.0.0"), FriendlyName("RSAT")]
class CompanyRSAT : OMI_BaseResource
{
  [Key, Description("Specify the RSAT name like Rsat.ServerManager.Tools~~~~0.0.1.0")] string Name;
  [Write, Description("Specify the feature state"), ValueMap{"Installed", "NotPresent"},Values{"Installed", "NotInstalled"}] string State;
  [Read] string DisplayName;
};

/*
see https://docs.microsoft.com/en-us/PowerShell/scripting/dsc/resources/authoringresourcemof?view=PowerShell-5.1
for guidance on defining the MOF
*/

[ClassVersion("1.0.0.0"), FriendlyName("xHotfix")]
class MSFT_xWindowsUpdate : OMI_BaseResource
{
    // We can have multiple versions of an update for a single ID, the indentifier is in the file,
    // Therefore the file path should be the key
    [key, Description("Specifies the path that contains the msu file for the hotfix installation.")] String Path;
    [required, Description("Specifies the Hotfix ID.")] String Id;
    [Write, Description("Specifies the location of the log that contains information from the installation.")] String Log;
    [Write, Description("Specifies whether the hotfix needs to be installed or uninstalled."), ValueMap{"Present","Absent"}, Values{"Present","Absent"}] String Ensure;
    [write, Description("Specifies the credential to use to authenticate to a UNC share if the path is on a UNC share."),EmbeddedInstance("MSFT_Credential")] string Credential;
};



#>
