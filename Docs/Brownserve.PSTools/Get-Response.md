---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-Response

## SYNOPSIS

Prompts a user for a response.

## SYNTAX

```text
Get-Response [-Prompt] <String> [-ResponseType] <String> [-Mandatory]
 [<CommonParameters>]
```

## DESCRIPTION

Prompts a user for a response and returns an expected output, 
this is useful in interactive script where data needs to be given in the correct format.

## EXAMPLES

### EXAMPLE 1: Strings

```powershell
Get-Response -Prompt "What is your name?" -ResponseType "string"
```

This would display `What is your name?` on the screen, whatever the user enters will be returned as a string.

### EXAMPLE 2: Booleans

```powershell
Get-Response -Prompt "Do you like pineapple on pizza?" -ResponseType "bool"
```

This would display `Do you like pineapple on pizza? [y]es/[n]o:` on the screen
If the user enters 'yes' then $true will be returned, if they enter 'no' then $false will be returned

### EXAMPLE 3: Arrays

```powershell
Get-Response -Prompt "What do you like on your pizza?" -ResponseType "array" -Mandatory
```

This would display "What do you like on your pizza? [if specifying more than one separate with a comma]" to the screen.
The resulting comma separated list will be split into an array.
This has been marked as mandatory so the user must provide input or they will be prompted until they do

## PARAMETERS

### -Mandatory

Make the response mandatory (applies to string and arrays only)

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

### -Prompt

The prompt to post on screen

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

### -ResponseType

The type of value to return

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: string, bool, array

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
