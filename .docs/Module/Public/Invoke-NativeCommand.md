---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Invoke-NativeCommand

## SYNOPSIS
Invokes a native command while gracefully handling the output and error streams.

## SYNTAX

```
Invoke-NativeCommand [-FilePath] <String> [[-ArgumentList] <Array>] [[-WorkingDirectory] <String>]
 [[-ExitCodes] <Array>] [-SuppressOutput] [-RedirectOutputPath <String>] [-RedirectOutputPrefix <String>]
 [-RedirectOutputSuffix <String>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will call a native process (e.g `ping`) and will allow for writing the commands output to host while also returning the output after the command completes successfully.  
This is useful when you want to monitor a commands output while also capturing it for processing later on.  
If you only want the output of the command and not the stream output you can pass the `-SuppressOutput` parameter.  
As many native commands can write verbose/logging information to stderr this cmdlet attempts to be clever about only returning truly terminating errors, it does so by inspecting the exit code and only raising an exception **if** the exit code is invalid.

## EXAMPLES

### Example 1: Standard usage
```powershell
$Ping = Invoke-NativeCommand `
    -FilePath 'ping' `
    -ArgumentList @('192.168.1.1')
```

In this example the `ping` command would be run with the argument `192.168.1.1`, it's output would returned and stored in the `$Ping` variable as well as being streamed to host

### Example 2: Suppressing output
```powershell
$Ping = Invoke-NativeCommand `
    -FilePath 'ping' `
    -ArgumentList @('192.168.1.1') `
    -SuppressOutput
```

In this example the `ping` command would be run with the argument `192.168.1.1`, it's output would returned and stored in the `$Ping` variable and as `-SuppressOutput` has been specified no output would be written to host.

## PARAMETERS

### -ArgumentList
An optional list of arguments to be passed to the command

```yaml
Type: Array
Parameter Sets: (All)
Aliases: Arguments

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ExitCodes
The exit codes expected from this command when it has been successful

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RedirectOutputPath
The path to where the redirected output should be stored
Defaults to the contents of the global variable 'RepoLogDirectory' if available
If that isn't set then defaults to a temp directory.  
**This is only used when `-SuppressOutput` is specified**

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
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SuppressOutput
If specified will suppress command output

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

### -WorkingDirectory
If set will set the working directory for the called command, defaults to the current directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
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
