---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# ConvertTo-HTTPSRepoURL

## SYNOPSIS
Converts a git SSH URI into the HTTPS equivalent

## SYNTAX

```
ConvertTo-HTTPSRepoURL [-InputObject] <GitURI[]> [<CommonParameters>]
```

## DESCRIPTION
This cmdlet attempts to convert a git SSH URI into the HTTPS equivalent.
This is done by using a regular expression to capture the constituent parts of the URI and rearranging them into a typical URL.

## EXAMPLES

### Example 1: Convert a GitHub SSH URI
```
'git@github.com:Brownserve-UK/Brownserve.PSTools.git' | ConvertTo-HTTPSRepoURL
```

This would return \`https://github.com/Brownserve-UK/Brownserve.PSTools.git\`

### Example 2: Convert a GitLab SSH URI
```
'git@gitlab.com:Brownserve-UK/Brownserve.PSTools.git' | ConvertTo-HTTPSRepoURL
```

This would return \`https://gitlab.com/Brownserve-UK/Brownserve.PSTools.git\`

## PARAMETERS

### -InputObject
The URI to be converted

```yaml
Type: GitURI[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### GitURI[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

