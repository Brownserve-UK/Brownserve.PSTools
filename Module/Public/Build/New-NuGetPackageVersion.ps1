function New-NuGetPackageVersion
{
  [CmdletBinding()]
  param(
    # A three or four digit version number of the form Major.Minor.Patch.Revision.
    [Parameter(
      Mandatory = $true,
      Position = 0,
      ValueFromPipelineByPropertyName = $true
    )]
    [version]
    $Version,

    # The name of the current branch, this is used to suffix non production releases (eg feature releases etc)
    [Parameter(
      Mandatory = $true,
      Position = 0
    )]
    [string]
    $BranchName,

    # If set to true this denotes that this is a production release
    [Parameter(
      Mandatory = $false,
      Position = 0
    )]
    [switch]
    $Prerelease
  )

  # Just return the version if we're on a production release
  if ($false -eq $Prerelease)
  {
    return [string]$Version
  }

  # Otherwise establish the pre-release suffix from the branch name.
  $PreReleaseSuffix = $BranchName

  # Remove invalid characters from the suffix.
  $PreReleaseSuffix = $PreReleaseSuffix -replace '[/]', '-'
  $PreReleaseSuffix = $PreReleaseSuffix -replace '[^0-9A-Za-z-]', ''

  # Shorten the suffix if necessary, to satisfy NuGet's 20 character limit.
  if ($PreReleaseSuffix.Length -gt 20)
  {
    $PreReleaseSuffix = $PreReleaseSuffix.SubString(0, 20)
  }

  # And finally compose the full NuGet package version - this supports 3 part version numbers
  return "$Version-$PreReleaseSuffix"
}
