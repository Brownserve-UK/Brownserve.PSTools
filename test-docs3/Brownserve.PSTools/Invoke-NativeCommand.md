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
 [[-ExitCodes] <Array>] [-PassThru] [-SuppressOutput] [-LogOutput] [-LogOutputPath <String>]
 [-LogOutputPrefix <String>] [-LogOutputSuffix <String>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will call a native process (e.g \`ping\`) and will allow for writing the commands output to host while also returning the output after the command completes successfully if desired.
This is useful when you want to monitor a commands output while also capturing it for processing later on.
If you only want the output of the command and not the stream output you can pass the \`-SuppressOutput\` parameter.
As many native commands can write verbose/logging information to stderr this cmdlet attempts to be clever about only returning truly terminating errors, it does so by inspecting the exit code and only raising an exception if the exit code is invalid.

## EXAMPLES

### Example 1: Standard usage
```
$Ping = Invoke-NativeCommand `
    -FilePath 'ping' `
    -ArgumentList @('192.168.1.1') `
    -PassThru
```

In this example the \`ping\` command would be run with the argument \`192.168.1.1\`, as the \`PassThru\` parameter has been provided the command's output would returned and stored in the \`$Ping\` variable as well as being streamed to host

### Example 2: Suppressing output
```
Invoke-NativeCommand `
    -FilePath 'ping' `
    -ArgumentList @('192.168.1.1') `
    -SuppressOutput
```

In this example the \`ping\` command would be run with the argument \`192.168.1.1\`, as \`-SuppressOutput\` has been specified no output would be written to host and as \`-PassThru\` has not been provided no output would be returned effectively making this command silent.

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

### -LogOutput
If set will log the output of the command to disk

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogOutputPath
The path to where the output should be logged (must be a directory)

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

### -LogOutputPrefix
An optional prefix to add to the log file(s), if none is set then the name of the command being run is used

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

### -LogOutputSuffix
The file extension to use for the log file (defaults to .log)

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

### -PassThru
Pass this parameter if you want the cmdlet to return a PowerShell object of the native commands output stream

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SuppressOutput
If specified will stop the command outputting to host, useful when running very verbose commands that can quickly fill up build logs etc.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

