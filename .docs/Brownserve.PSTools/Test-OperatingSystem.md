---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Test-OperatingSystem

## SYNOPSIS
Quick way of terminating scripts when they are running on an incompatible OS.

## SYNTAX

```
Test-OperatingSystem [-SupportedOS] <OperatingSystemKernel[]> [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will test the current operating system and compare it against the list provided to the `-SupportedOS` parameter, if the current OS is not in the supported list a terminating error is thrown.  
This is useful for cases where you want to quickly terminate a PowerShell run when running on an unsupported OS

## EXAMPLES

### Example 1
```powershell
Test-OperatingSystem -SupportedOS 'linux','macos'
```

Will test the current OS and if it is Windows then a terminating error will be thrown. If it is macOS or Linux then no error will be raised.

## PARAMETERS

### -SupportedOS
The operating systems that your cmdlet/script is compatible with.

```yaml
Type: OperatingSystemKernel[]
Parameter Sets: (All)
Aliases:
Accepted values: Windows, Linux, macOS

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### OperatingSystemKernel[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
