---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Publish-TeamcityArtifact

## SYNOPSIS
Tells Teamcity to export a given file/folder as an artifact.

## SYNTAX

```
Publish-TeamcityArtifact [-ArtifactPath] <String> [[-TargetDirectory] <String>] [<CommonParameters>]
```

## DESCRIPTION
Tells Teamcity to export a given file/folder as an artifact.
This is achieved by piping a message to StdOut to tell Teamcity where to grab the files and (optionally) where to store them

## EXAMPLES

### EXAMPLE 1: Publish an artifact
```
Publish-TeamcityArtifact C:\Temp\MyFile.txt
```

Will export C:\Temp\MyFile.txt as an artifact in Teamcity

### EXAMPLE 2: Publish an artifact to a directory
```
Publish-TeamcityArtifact C:\Temp\MyFile.txt -TargetDirectory MyDir
```

Will export C:\Temp\MyFile.txt as an artifact in Teamcity to the MyDir folder

## PARAMETERS

### -ArtifactPath
The artifact you wish to publish

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

### -TargetDirectory
The target directory to publish the artifact to (optional)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
See https://www.jetbrains.com/help/teamcity/configuring-general-settings.html#Artifact+Paths for more information

## RELATED LINKS

