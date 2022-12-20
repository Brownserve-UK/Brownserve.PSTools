---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Start-SilentProcess

## SYNOPSIS
**This command is deprecated and will be removed in a future release, please use Invoke-NativeCommand instead.**  
Starts a process that redirects stdout and stderr to log files.

## SYNTAX

```
Start-SilentProcess [-FilePath] <String> [[-ArgumentList] <Array>] [[-WorkingDirectory] <String>]
 [-ExitCodes <Array>] [-RedirectOutputPath <String>] [-RedirectOutputPrefix <String>]
 [-RedirectOutputSuffix <String>] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
Starts a process that redirects stdout and stderr to log files which is useful for a number of reasons.
Firstly it allows programs to be run silently which is very handy in CI/CD deployments when you may often want to cut down on noise.

It also allows for easy extraction of error messages from the process as they will be stored in ".log" files.
Finally it also helps to get around this little bug: https://stackoverflow.com/a/66726535/10843454 when programs write verbose data to stderr.

By redirecting to a file it never touches PowerShell's error stream, meaning you can be very selective about what errors are actually thrown.

## EXAMPLES

### EXAMPLE 1: Call a program and argument
```powershell
Start-SilentProcess `
    -FilePath 'terraform' `
    -ArgumentList 'plan'
```

This would call "terraform plan", output streams are redirected to terraform_DateTime_SteamName.log files in the systems temp directory, if the app returns a non-zero exit code an exception would be thrown

### EXAMPLE 2: Call a program with arguments and set the accepted exit codes
```powershell
Start-SilentProcess `
    -FilePath 'terraform' `
    -ArgumentList 'plan'
    -ExitCodes = @(0,123)
```

This would call "terraform plan", output streams are redirected to terraform_DateTime_SteamName.log files in the present working directory, if the app returns an exit code other than '0' or '123' an exception would be thrown

### EXAMPLE 3: Call a program with arguments and redirect the output to a folder
```powershell
Start-SilentProcess `
    -FilePath 'terraform' `
    -ArgumentList 'plan' `
    -RedirectOutPutPath 'C:\logs'
```

This would call "terraform plan", output streams are redirected to terraform_DateTime_SteamName.log files in the C:\logs folder, if the app returns a non-zero exit code an exception would be thrown

### EXAMPLE 4: Set the redirect output folder and prefix/suffix
```powershell
Start-SilentProcess `
    -FilePath 'terraform' `
    -ArgumentList 'plan' `
    -RedirectOutputPrefix 'i_love_cats' `
    -RedirectOutputSuffix 'txt' `
    -RedirectOutPutPath 'C:\logs'
```

This would call "terraform plan", output streams are redirected to i_love_cats_DateTime_SteamName.txt in the C:\logs folder
If the app returns a non-zero exit code an exception would be thrown

### EXAMPLE 5: Return stdout on command completion
```powershell
Start-SilentProcess `
    -FilePath 'terraform' `
    -ArgumentList 'plan' `
    -PassThru
```

This would call "terraform plan", output streams are redirected to dated log files in the systems temp directory
If the app returns a non-zero exit code an exception would be thrown
Upon successful completion of the command it's output and locations to the stdout and stderr files would be returned as a PowerShell object

## PARAMETERS

### -ArgumentList
An optional list of arguments to be passed to it

```yaml
Type: Array
Parameter Sets: (All)
Aliases: Arguments

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ExitCodes
The exit codes expected from this process when it has been successful

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilePath
The path to the command to be run

```yaml
Type: String
Parameter Sets: (All)
Aliases: PSPath

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -PassThru
By default this cmdlet won't return any output from the invoked command, however if the PassThru parameter is set then the result of stdout is returned as an object at the end along with the locations of the stdout and stderr files.

This can be useful if you need the output from the command or when debugging.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RedirectOutputPath
The path to where the redirected output should be stored
Defaults to the contents of the global variable 'RepoLogDirectory' if available
If that isn't set then defaults to a temp directory

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RedirectOutputPrefix
The prefix to use on the redirected streams, defaults to the command run time

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RedirectOutputSuffix
The suffix for the redirected streams (defaults to log)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Log
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkingDirectory
If set will set the working directory for the called command, defaults to the current directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.Array
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
