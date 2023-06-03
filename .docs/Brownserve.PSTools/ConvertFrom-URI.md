---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# ConvertFrom-URI

## SYNOPSIS
Converts a given URI into a PowerShell object

## SYNTAX

```
ConvertFrom-URI [-InputObject] <String[]> [-AsHashtable] [<CommonParameters>]
```

## DESCRIPTION
Converts a given URI into a PowerShell object, splitting out things like the subdomain, hostname and path.

## EXAMPLES

### Example 1: Single URL
```powershell
ConvertFrom-URI -InputObject 'https://www.example.com/'

Hostname  : example
Subdomain : www
Domain    : com
Protocol  : https
URI       : https://www.example.com/
```

This would extract all the relevant paths from the URI into an object

### Example 2: Multiple URL's
```powershell
@('https://www.example.com/','https://www.example.com:8080/myApp') | ConvertFrom-URI

Hostname  : example
Subdomain : www
Domain    : com
Protocol  : https
URI       : https://www.example.com/

Hostname  : example
Subdomain : www
Domain    : com
Path      : myApp
Protocol  : https
Port      : 8080
URI       : https://www.example.com:8080/myApp
```

This examples shows piping in an array of URI's and converting them.
The Second URI has a path and protocol so those get set too.

### Example 2: AsHashtable
```powershell
'https://www.example.com/' | ConvertFrom-URI -AsHashtable

Name                           Value
----                           -----
Hostname                       example
Subdomain                      www
Domain                         com
Protocol                       https
URI                            https://www.example.com/
```

This examples shows piping in a URI and converting them using the `-AsHashtable` parameter.
This results in a hashtable being returned instead of a PowerShell object.

## PARAMETERS

### -AsHashtable
Returns a hashtable instead of a custom object.

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

### -InputObject
The URI to be converted

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
