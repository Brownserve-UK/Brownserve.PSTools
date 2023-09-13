---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-GitMerges

## SYNOPSIS

Returns a list of merge commits for a given GitHub repository

## SYNTAX

```text
Get-GitMerges [[-RepositoryPath] <String>] [[-HeadBranch] <String>] [[-ReferenceBranch] <String>]
 [[-FirstParentOnly] <Boolean>] [[-PrettyOptions] <String>] [-NoCommitHeader] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will call git-rev list to return a list of merges for a given branch.
A reference branch can also be specified to only git merges between those 2 branches.

## EXAMPLES

### Example 1: Get all merges

```powershell
Get-GitMerges -RepositoryPath "C:\myRepo"
```

This would return a list of all merge commit hashes to the repo located at `C:\myRepo`

### Example 1: Get merge titles between 2 branches

```powershell
Get-GitMerges -RepositoryPath "C:\myRepo" -HeadBranch "HEAD" -ReferenceBranch "my_branch" -PrettyOptions "%b" -NoCommitHeader
```

This would return a list of all merge commit titles to the repo located at `C:\myRepo` between branch `my_branch` and the head branch.

## PARAMETERS

### -FirstParentOnly

When finding commits to include, follow only the first parent commit upon seeing a merge commit. This option can give a better overview when viewing the evolution of a particular topic branch, because merges into a topic branch tend to be only about adjusting to updated upstream from time to time, and this option allows you to ignore the individual commits brought in to your history by such a merge.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: True
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -HeadBranch

The branch to search for merges in

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: HEAD
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NoCommitHeader

If set will omit the commit hash header.
This is only supported on git 2.33 and above.
It also requires the `-PrettyOptions` parameter to be set.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PrettyOptions

Any pretty options to pass see https://git-scm.com/docs/pretty-formats for more information

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ReferenceBranch

The feature branch

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RepositoryPath

The path to the repository

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $PWD
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
