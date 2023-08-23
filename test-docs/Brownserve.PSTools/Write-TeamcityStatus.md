---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version: https://api.slack.com/messaging/composing/layouts
schema: 2.0.0
---

# Write-TeamcityStatus

## SYNOPSIS
Writes a status message to StdOut

## SYNTAX

```
Write-TeamcityStatus [-Message] <String> [<CommonParameters>]
```

## DESCRIPTION
Writes a status message to StdOut.
These messages are picked up by Teamcity and used in the build output screen

## EXAMPLES

### EXAMPLE 1
```
Write-TeamcityStatus "Hello, world!"
```

Will output "##teamcity\[buildStatus text='Hello, world!
- {build.status.text}'\]" to StdOut

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES
Messages cannot contain newlines otherwise it will break Teamcity so they are stripped out.

## RELATED LINKS
