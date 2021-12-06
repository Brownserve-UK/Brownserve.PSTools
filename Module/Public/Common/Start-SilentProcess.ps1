function Start-SilentProcess
{
    [CmdletBinding()]
    param
    (
        # The path to the command to be run
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $FilePath,
        
        # An optional list of arguments to be passed to it
        [Parameter(
            Mandatory = $false,
            Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("Arguments")]
        [array]
        $ArgumentList,
        
        # If set will set the working directory for the called command
        [Parameter(
            Mandatory = $false,
            Position = 2,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $WorkingDirectory,

        # The exit codes expected from this process when it has been successful
        [Parameter(
            Mandatory = $false
        )]
        [array]
        $ExitCodes = @(0),

        # The path to where the redirected output should be stored
        # Defaults to the contents of the environment variable 'RepoLogDirectory' if available
        # If that isn't set then defaults to a temp directory
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $RedirectOutputPath,

        # The prefix to use on the redirected streams, defaults to the command run time
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $RedirectOutputPrefix,

        # The suffix for the redirected streams (defaults to log)
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $RedirectOutputSuffix = "log",

        # By default this won't return any output from the called command
        # however if this param is set then the result of stdout is returned as an object at the end along with the locations of the stdout and stderr files
        # This can be useful if you need the output from the command or when debugging
        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $PassThru
    )
    Write-Warning "This command is deprecated and will be removed in a future release, please use 'Invoke-NativeCommand' instead"
    # Start off by ensuring we can find the command and then get it's full path.
    # This is useful when using things like Set-Alias as the Start-Process command won't have access to these
    # So instead we can pass in the full path to the command
    Write-Verbose "Finding absolute path to command $FilePath"
    try
    {
        $AbsoluteCommandPath = (Get-Command $FilePath -ErrorAction Stop).Definition
    }
    catch
    {
        throw "Could not find command $FilePath.`n$($_.Exception.Message)"
    }

    # Set redirected output to the repos log directory if it exists, otherwise to temp
    if (!$RedirectOutputPath)
    {
        if ($global:RepoLogDirectory)
        {
            $RedirectOutputPath = $global:RepoLogDirectory
        }
        else
        {
            # Determine our temp directory depending on flavour of PowerShell
            if ($PSVersionTable.PSEdition -eq 'Desktop')
            {
                $RedirectOutputPath = $env:TEMP
            }
            else
            {
                $RedirectOutputPath = (Get-PSDrive Temp).Root
            }
        }
    }

    # Check the redirect stream path is valid
    try
    {
        $RedirectOutputPathCheck = Get-Item $RedirectOutputPath -Force
    }
    catch
    {
        throw "$RedirectOutputPath does not appear to be a valid directory."
    }

    if (!$RedirectOutputPathCheck.PSIsContainer)
    {
        throw "$RedirectOutputPath must be a directory"
    }
    Write-Verbose "Redirecting output to: $RedirectOutputPath"

    # If we don't have a redirect output prefix then create one
    if (-not $RedirectOutputPrefix)
    {
        # See if the value in $FilePath is a path or just a command name.
        # If it's a path we don't want to use that as a prefix for our redirected output files as it could be stupidly long
        # If it's a command name then we can just straight up use that as our redirect name
        try
        {
            $isPath = Resolve-Path $FilePath -ErrorAction Stop
        }
        catch
        {
            $RedirectOutputPrefix = $FilePath
        }

        # We've got a path, do some work to extract just the name of the program from the file path
        if ($isPath)
        {
            try
            {
                $RedirectOutputPrefix = $isPath | Get-Item | Select-Object -ExpandProperty Name -ErrorAction Stop
            }
            catch
            {
                # Don't throw, we'll still get a valid filename below anyways it'll just be missing a prefix
                Write-Warning "Failed to auto-generate RedirectOutputPrefix"
            }        
        }
    }

    # Define our redirected stream names
    $StdOutFileName = "$($RedirectOutputPrefix)_$(Get-Date -Format yyMMddhhmm)_stdout.$($RedirectOutputSuffix)"
    $StdErrFileName = "$($RedirectOutputPrefix)_$(Get-Date -Format yyMMddhhmm)_stderr.$($RedirectOutputSuffix)"

    # Set the paths
    $StdOutFilePath = Join-Path $RedirectOutputPath -ChildPath $StdOutFileName
    $StdErrFilePath = Join-Path $RedirectOutputPath -ChildPath $StdErrFileName

    # Set the default calling params
    $ProcessParams = @{
        FilePath               = $AbsoluteCommandPath
        RedirectStandardError  = $StdErrFilePath
        RedirectStandardOutput = $StdOutFilePath
        PassThru               = $true
        NoNewWindow            = $true
        Wait                   = $true
    }

    # Add optional params if we have them
    if ($ArgumentList)
    {
        $ProcessParams.Add('ArgumentList', $ArgumentList)
    }
    if ($WorkingDirectory)
    {
        $ProcessParams.Add('WorkingDirectory', $WorkingDirectory)
    }
    
    # Run the process
    # We've changed these writes to use the debug stream instead, 
    # this way we can still capture this information when we want to debug a command but we avoid polluting the
    # verbose stream which is used in a lot of our builds.
    # This should fix #7 and stop us leaking passwords and such in our builds 😬
    Write-Debug "Calling '$AbsoluteCommandPath' with arguments: '$($ArgumentList -join ' ')'"
    Write-Debug "Valid exit codes: $($ExitCodes -join ', ')"
    try
    {
        $Process = Start-Process @ProcessParams
    }
    catch
    {
        # If we get a failure at this stage we won't have any stderr to grab so just return our exception
        throw $_.Exception.Message
    }

    # Check the exit code is expected, if not grab the contents of stderr (if we can) and return it
    if ($Process.ExitCode -notin $ExitCodes)
    {
        $ErrorContent = Get-Content $StdErrFilePath -Raw -ErrorAction SilentlyContinue
        # Write-Error is preferable to 'throw' as it gives much cleaner output, it also allows more control over how errors are handled
        Write-Error "$FilePath has returned a non-zero exit code: $($Process.ExitCode).`n$ErrorContent"
    }

    # If we've requested the output from this command then return it along with the paths to our StdOut and StdErr files should we need them
    if ($PassThru)
    {
        try
        {
            $OutputContent = Get-Content $StdOutFilePath
            Return [pscustomobject]@{
                StdOutFilePath = $StdOutFilePath
                StdErrFilePath = $StdErrFilePath
                OutputContent  = $OutputContent
            }
        }
        catch
        {
            Write-Error "Unable to get contents of $StdOutFilePath.`n$($_.Exception.Message)"
        }
    }
}