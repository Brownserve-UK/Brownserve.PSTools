---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version: https://api.slack.com/messaging/composing/layouts
schema: 2.0.0
---

# Test-Administrator

## SYNOPSIS
A simple function for testing if a user is running with administrator/root privileges or not.

## SYNTAX

```
Test-Administrator [<CommonParameters>]
```

## DESCRIPTION
This cmdlet performs a test to see if the current user is running as administrator/root and returns \`$true\` if so, otherwise \`$false\` is returned.

## EXAMPLES

### Example 1
```
PS C:\> Test-Administrator
```

Would return \`$true\` if the user is running as an administrator and \`$false\` if not.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

