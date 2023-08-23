---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# New-BrownserveTemporaryFile

## SYNOPSIS
Creates a temporary file in a known good location.

## SYNTAX

### default (Default)
```
New-BrownserveTemporaryFile [-FileName <String[]>] [-FileExtension <String>] [-FilePath <String>]
 [<CommonParameters>]
```

### Content
```
New-BrownserveTemporaryFile [-FileName <String[]>] [-FileExtension <String>] [-FilePath <String>]
 [-Content <String>] [<CommonParameters>]
```

### Skip
```
New-BrownserveTemporaryFile [-FileName <String[]>] [-FileExtension <String>] [-FilePath <String>]
 [-SkipCreation] [<CommonParameters>]
```

## DESCRIPTION
We often want to create temporary files commonly during builds but also during certain script executions.
This cmdlet allows us to create them in an easily identifiable format and place, by default it will create them in a repositories \`.tmp\` directory (if present) or system-wide temporary directory.
It also allows you to set the content of the temporary file directly if desired or skip creation entirely if some other process will create the file and instead simply return a known-good path to be used.

## EXAMPLES

### Example 1 - Create a named file with content
```
New-BrownserveTemporaryFile -FileName 'test' -FileExtension '.txt' -Content 'Hello, world!'
```

This would create a file called \`test.txt\` with the line \`Hello, world!\` inside of it.

### Example 2 - Create a random file
```
New-BrownserveTemporaryFile
```

This would create a file with a random name and a \`.tmp\` extension (e.g.
\`as3fdg.tmp\`)

### Example 3 - Return a valid path but do not create the file
```
New-BrownserveTemporaryFile -SkipCreation
```

This would return a path with a random file name and a \`.tmp\` extension (e.g.
\`as3fdg.tmp\`) but the file would not be created by this cmdlet.

## PARAMETERS

### -Content
An optional set of content to be written to the temporary file upon creation.
This can only be used when \`-SkipCreation\` is not used.

```yaml
Type: String
Parameter Sets: Content
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileExtension
The file extension to be used for this temporary file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: .tmp
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileName
An optional file name to be used when creating the file, if none is provided a random one will be used.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilePath
The path to where the temporary file should be stored.
If none is provided then the cmdlet will use the \`$BrownserveTempLocation\` directory which varies depending on the OS and the location this module was imported

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

### -SkipCreation
If passed this parameter will skip the creation of the temporary file and instead return only the path, useful when some other process will create the file.

```yaml
Type: SwitchParameter
Parameter Sets: Skip
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

## RELATED LINKS

