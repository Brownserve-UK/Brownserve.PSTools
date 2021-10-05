---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Send-SlackNotification

## SYNOPSIS
Sends a notification to a given Slack webhook

## SYNTAX

```
Send-SlackNotification [-Message] <String> [-Webhook] <String> [-Colour <String>] [-Push <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Sends a notification to a given Slack webhook

## EXAMPLES

### Example 1
```powershell
PS C:\> Send-SlackNotification -Message "This is a test" -Webhook "https://mywebhook"
```

Would send the message "This is a test" to the given Slack webhook

## PARAMETERS

### -Colour
The colour (if any) to use for the notification

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Message
The message to be sent

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Push
The optional push message to be displayed

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Webhook
The webhook to send to

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
