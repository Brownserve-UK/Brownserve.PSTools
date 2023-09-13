---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Set-TeamcityBuildNumber

## SYNOPSIS

Sets the build number in Teamcity.

## SYNTAX

```text
Set-TeamcityBuildNumber [-BuildNumber] <String> [-AppendCurrentBuildNumber] [<CommonParameters>]
```

## DESCRIPTION

Sets the build number in Teamcity by outputting a Teamcity service message to host.
If the 'AppendCurrentBuildNumber' switch is passed the current build number is appended to the new build number

## EXAMPLES

### EXAMPLE 1

```powershell
Set-TeamcityBuildNumber -BuildNumber '1.0.0'
```

This would output the message ##teamcity[buildNumber '1.0.0'] which would set the Teamcity build number to 1.0.0

### EXAMPLE 2

```powershell
Set-TeamcityBuildNumber -BuildNumber '1.0.0' AppendCurrentBuildNumber
```

Assuming the current Teamcity build number is 69 this would output the message ##teamcity[buildNumber '1.0.0_69']
Which would set the Teamcity build number to 1.0.0_69

## PARAMETERS

### -AppendCurrentBuildNumber

If set this will append the current Teamcity build number

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

### -BuildNumber

The build number to be set

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

## RELATED LINKS
