---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version: https://api.slack.com/messaging/composing/layouts
schema: 2.0.0
---

# Write-TeamcityBuildProblem

## SYNOPSIS
Writes a Teamcity build problem to StdOut and the same message to StdErr.

## SYNTAX

```
Write-TeamcityBuildProblem [-Message] <String> [-TerminatingError] [<CommonParameters>]
```

## DESCRIPTION
Writes a Teamcity build problem to StdOut and the same message to StdErr.
The StdOut message is picked up by Teamcity and used to build a list of build problems at the end of the build.
The same message (sans the encapsulating Teamcity fluff) is also output onto StdErr (or thrown as an exception if preferred)

## EXAMPLES

### EXAMPLE 1: Raise a standard error
```
Write-TeamcityBuildProblem -Message "Too many cats"
```

This would output ##teamcity\[buildProblem description='Too many cats'\] to StdOut and 'Too many cats' to StdErr

### EXAMPLE 2: Raise a terminating error
```
Write-TeamcityBuildProblem -Message "Not enough cats" -TerminatingError $true
```

This would output ##teamcity\[buildProblem description='Not enough cats'\] to StdOut and would throw an exception of "Not enough cats"

## PARAMETERS

### -Message
The message you want displayed in TeamCity

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TerminatingError
If set to true this will throw an exception instead of writing to StdErr.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES
Messages cannot contain newlines otherwise it will break Teamcity so they are stripped out.
The Teamcity status is written first as this should be non-terminating whereas StdErr might be, depending on the ErrorActionPreference parameter

## RELATED LINKS
