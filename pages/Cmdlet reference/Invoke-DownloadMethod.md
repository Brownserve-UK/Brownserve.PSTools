---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Invoke-DownloadMethod

## SYNOPSIS

Downloads a file using the best method available depending on operating system.

## SYNTAX

```text
Invoke-DownloadMethod [-DownloadURI] <String> [-OutFile] <String>
 [<CommonParameters>]
```

## DESCRIPTION

Downloads a file using the best method available depending on operating system.
On Windows systems this will attempt to use BITSTransfer if this is available and running, otherwise WebRequest is used.

## EXAMPLES

### EXAMPLE 1

```powershell
Invoke-DownloadMethod `
    -DownloadURI 'https://example.com/myfile.zip' `
    -OutFile 'C:\MyFile.zip'
```

This would download the file at 'https://example.com/myfile.zip' to 'C:\MyFile.zip'

## PARAMETERS

### -DownloadURI

The download URI

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -OutFile

The place to store the download

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
