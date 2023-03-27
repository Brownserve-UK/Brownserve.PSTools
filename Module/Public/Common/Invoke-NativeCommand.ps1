function Invoke-NativeCommand
{
    [CmdletBinding()]
    param
    (
        # The path to the command to run
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        [Alias('PSPath')]
        $FilePath,

        # An optional list of arguments to pass to the command
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [Alias('Arguments')]
        [array]
        $ArgumentList,

        # The working directory to run the command in
        [Parameter(
            Mandatory = $false,
            Position = 2
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $WorkingDirectory,

        # The allowed exit codes for the command
        [Parameter(
            Mandatory = $false,
            Position = 3
        )]
        [array]
        $ExitCodes = @(0),

        # If passed, will return the output of the command as a PowerShell object
        [Parameter()]
        [switch]
        $PassThru,
        
        # If set output will be suppressed
        [Parameter()]
        [switch]
        $SuppressOutput,

        # If set will instruct the output to be stored in a file on disk
        [Parameter()]
        [switch]
        $LogOutput,

        # The path to where the output should be stored
        # Defaults to a temp directory (will use repo based temp directory if it exists)
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogOutputPath = $script:BrownserveTempLocation,

        # The prefix to use on the logged output file, defaults to the command run time
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogOutputPrefix,

        # The suffix for the logged output file (defaults to log)
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogOutputSuffix = 'log'
    )
    
    begin
    {

    }
    
    process
    {
        # Start off by ensuring we can find the command and then get it's full path.
        # This is useful when using things like Set-Alias as the Start-Process command won't have access to these
        # as aliases are not passed through to the child process so instead we can use the full path to the alias
        try
        {
            $AbsoluteCommandPath = (Get-Command $FilePath -ErrorAction Stop).Definition
        }
        catch
        {
            throw "Could not find command $FilePath.`n$($_.Exception.Message)"
        }
        # Note: we use debug here as the ArgumentList may contain sensitive information (password etc)
        Write-Debug "Calling '$AbsoluteCommandPath' with arguments: '$($ArgumentList -join ' ')'"
        Write-Debug "Valid exit codes: $($ExitCodes -join ', ')"

        if ($LogOutput)
        {
            # Check the redirect stream path is valid
            try
            {
                $LogOutputPathCheck = Get-Item $LogOutputPath -Force
            }
            catch
            {
                throw "$LogOutputPath does not appear to be a valid directory."
            }

            if (!$LogOutputPathCheck.PSIsContainer)
            {
                throw "$LogOutputPath must be a directory"
            }
            Write-Verbose "Redirecting output to: $LogOutputPath"

            # If we don't have a redirect output prefix then create one
            if (-not $LogOutputPrefix)
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
                    $LogOutputPrefix = $FilePath
                }

                # We've got a path, do some work to extract just the name of the program from the file path
                if ($isPath)
                {
                    try
                    {
                        $LogOutputPrefix = $isPath | Get-Item | Select-Object -ExpandProperty Name -ErrorAction Stop
                    }
                    catch
                    {
                        # Don't throw, we'll still get a valid filename below anyways it'll just be missing a prefix
                        Write-Verbose 'Failed to auto-generate LogOutputPrefix'
                    }        
                }
            }

            # Define our redirected stream names
            $StdOutFileName = "$($LogOutputPrefix)_$(Get-Date -Format yyMMddhhmm)_stdout.$($LogOutputSuffix)"
            $StdErrFileName = "$($LogOutputPrefix)_$(Get-Date -Format yyMMddhhmm)_stderr.$($LogOutputSuffix)"

            # Set the paths
            $StdOutFilePath = Join-Path $LogOutputPath -ChildPath $StdOutFileName
            $StdErrFilePath = Join-Path $LogOutputPath -ChildPath $StdErrFileName
        }
        <# 
                We used to call start process to run the command but we no longer do for a number of reasons:
                - I don't like the idea of having two different methods of calling the command, it could lead to inconsistent results.
                - We always have to redirect and read from a file.
                - The redirected output merging wouldn't be line-by-line like running the command natively

                I'm leaving the code here for posterity and in case we need to revert back to this method in the future for
                some reason, but it currently has no way of being called.
                All being well I plan to remove it in a future release.
            #>
        if ($UseStartProcess -eq $true)
        {
            if ($LogOutput -ne $true)
            {
                throw 'LogOutput must be set to true when using Start-Process'
            }
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
            if ($PassThru -eq $true)
            {

                # Depending on the command there may or may not be any stderr/stdout output so don't fail if we can't grab them
                $ErrorStream = Get-Content $StdErrFilePath -Raw -ErrorAction SilentlyContinue
                $StdOutStream = Get-Content $StdOutFilePath -Raw -ErrorAction SilentlyContinue
                # If we've requested the output from this command then return it along with the paths to our StdOut and StdErr files should we need them
                try
                {
                    $OutputContent = $ErrorStream + $StdOutStream
                }
                catch
                {
                    Write-Error "Unable to get contents of $StdOutFilePath.`n$($_.Exception.Message)"
                }
            }
        }
        else
        {
            # Open an array to store potential error/stdout messages (more on this later)
            $StdOutStream = @()
            $ErrorStream = @()
            $OutputContent = @()
            $OtherContent = @()
            $AllOutput = @()
            if ($WorkingDirectory)
            {
                try
                {
                    Push-Location
                    Set-Location $WorkingDirectory -ErrorAction 'Stop'
                }
                catch
                {
                    throw "Failed to set working directory to '$WorkingDirectory'.`n$($_.Exception.Message)"
                }
            }
            # Call the command in a scriptblock so we can redirect the error stream and then iterate over it
            & { & $AbsoluteCommandPath $ArgumentList } 2>&1 | ForEach-Object {
                # If this line is in the error stream then we want to take certain actions
                if ($_ -is [System.Management.Automation.ErrorRecord])
                {
                    <# 
                        Some commands will return info/verbose messages to stderr, we don't want to terminate on these so we store the information in a variable
                        that we can use later on if we need to raise an error.
                        #>
                    $ErrorStream += $_
                    # We also add it to the AllOutput variable so we can be sure we've captured everything from this command in the order it was written
                    # (because we can't always assume the command will write to the correct stream...)
                    $AllOutput += ($_ | Out-String -NoNewline) # By default PowerShell returns an ErrorRecord object, so we convert to a string
                    if ($SuppressOutput -ne $true)
                    {
                        # Remove any lines that contain the object name, it's confusing
                        Write-Host ($_ -replace 'System.Management.Automation.RemoteException', '' ) -ErrorAction 'SilentlyContinue'
                    }
                }
                else
                {
                    $StdOutStream += $_
                    # Add to the AllOutput variable so we can be sure we return everything later on
                    $AllOutput += $_
                    if ($SuppressOutput -ne $true)
                    {
                        Write-Host $_ -ErrorAction 'SilentlyContinue'
                    }
                    
                }
            } | Tee-Object -Variable 'OtherContent' # Tee the output to a variable to capture anything that may be written by any other means (e.g. Write-Output etc)
            if ($WorkingDirectory)
            {
                Pop-Location
            }
            if ($LogOutput)
            {
                try
                {
                    New-Item $StdOutFilePath -Value ($StdOutStream | Out-String) -Force -ItemType File -ErrorAction 'Stop' | Out-Null
                }
                catch
                {
                    Write-Warning "Failed to tee StdOut to $StdOutStream.`n$($_.Exception.Message)"
                }
                try
                {
                    New-Item $StdErrFilePath -Value ($ErrorStream | Out-String) -Force -ItemType File -ErrorAction 'Stop' | Out-Null
                }
                catch
                {
                    Write-Warning "Failed to tee StdErr to $StdErrStream.`n$($_.Exception.Message)"
                }
            }
            # Only if the exit code is not in the expected list of exit codes do we raise an error (which can be caught by the -ErrorAction meta param)
            if ($LASTEXITCODE -notin $ExitCodes)
            {
                Write-Error "Command $FilePath exited with code $LASTEXITCODE.`n$ErrorStream"
            }
            # Combine any output together so we can return everything
            $OutputContent = $AllOutput + $OtherContent
        }
    }
    
    end
    {
        if ($PassThru)
        {
            $Return = @{}
            if ($OutputContent)
            {
                $Return.Add('OutputContent', $OutputContent)
            }
            if ($StdOutStream)
            {
                $Return.Add('StdOut', $StdOutStream)
            }
            if ($ErrorStream)
            {
                $Return.Add('StdErr', $ErrorStream)
            }
            if ($StdOutFilePath)
            {
                $Return.Add('StdOutFilePath', $StdOutFilePath)
            }
            if ($StdErrFilePath)
            {
                $Return.Add('StdErrFilePath', $StdErrFilePath)
            }
            if ($Return.GetEnumerator().Count -gt 0)
            {
                Return $Return
            }
            else
            {
                Return $null
            }
        }
    }
}