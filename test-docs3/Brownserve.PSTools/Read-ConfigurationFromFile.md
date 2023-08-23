---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Read-ConfigurationFromFile

## SYNOPSIS
Reads values from a configuration file

## SYNTAX

```
Read-ConfigurationFromFile [-ConfigurationFile] <String> [-AsHashtable] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet allows us to read a JSON configuration file and extract the values.
The purpose of this is to allow us to create cmdlets that perform a complex set of tasks which require equally complex parameter types and abstract the default values for these parameters into easy to read/write JSON objects.

## EXAMPLES

### Example 1
```
Read-ConfigurationFromFile -ConfigurationFile 'C:\myRepo\.config\SpecialConfig.json'
```

Would read the given configuration file and return a PSObject of the values

## PARAMETERS

### -AsHashtable
Returns a hashtable instead of a PowerShell object, this is especially useful when you want to iterate over the values.

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

### -ConfigurationFile
The configuration file to be read.

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
