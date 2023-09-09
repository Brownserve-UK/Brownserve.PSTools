---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Assert-Directory

## SYNOPSIS
Ensures that a directory is valid

## SYNTAX

```
Assert-Directory [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
Checks the given path to ensure it both exists and is a valid directory

## EXAMPLES

### Example 1
```powershell
New-Item -Path C:\temp\TestDir -ItemType Directory
Assert-Directory -Path C:\temp\TestDir
```

Would return no error

### Example 2
```powershell
New-Item -Path C:\temp\TestDir.txt -ItemType File
Assert-Directory -Path C:\temp\TestDir.txt
```

Would return an error as the file is not a directory

## PARAMETERS

### -Path
The path to be checked

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
