<#
.SYNOPSIS
    Formats a markdown file to ensure it follows the markdownlint rules.
.DESCRIPTION
    Formats a markdown file to ensure it follows the markdownlint rules.
#>
function Format-Markdown
{
    [CmdletBinding()]
    param
    (
        # The path to the markdown file to format.
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        # The language to use for code blocks.
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $CodeBlockLanguage = 'text',

        # The conversion to use for emphasis-as-headers.
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateSet('Header', 'List')]
        $EmphasisAsHeaderConversion = 'Header',

        # Special hidden parameter to pass in markdown from the pipeline.
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [array]
        $Markdown
    )
    begin
    {
        $Return = @()
    }
    process
    {
        $LineCount = 0
        $Metadata = $false
        $CodeBlockStart = $null
        $CodeBlockEnd = $null
        # We store the header level so we can ensure we don't jump more than one header level at a time.
        [int]$CurrentHeaderLevel = 0
        # Assume the start of the document is line 0, this may change later on.
        $StartOfDocument = 0
        if (!$Markdown)
        {
            $Markdown = Get-Content -Path $Path
        }
        # Go through each line and format it.
        foreach ($Line in $Markdown)
        {
            $AddToReturn = $true
            Write-Verbose "Processing line $LineCount"

            <#
                Use regex to parse the line.
                This isn't the prettiest and here be dragons.
                At the moment we're quite liberal with what we match as it's easier to write simpler regex and then
                try to catch the edge cases later.
                For example writing regex to match all possible list types might accidentally catch a horizontal rule
                so instead of trying to filter that out in the regex we just check for it later with more specific
                regex and move on if it's a match.
                We also don't fully support every case in markdownlint yet, PR's are very much welcome.
            #>
            switch -Regex ($Line)
            {
                # Match any horizontal rules or metadata
                '^---'
                {
                    # Ignore anything in a code block.
                    if (!$CodeBlockStart)
                    {
                        <#
                        Ensure that any metadata is only at the start of the file.
                        We don't perform any formatting on the metadata itself as most tools don't seem to care about it.
                    #>
                        # If the line count is 0 then we are at the start of the file.
                        if ($LineCount -eq 0)
                        {
                            $Metadata = $true
                        }
                        else
                        {
                            # If the metadata variable is set to true then we have already seen metadata's start
                            # this line is probably the end of the metadata.
                            if ($Metadata -eq $true)
                            {
                                Write-Debug "Metadata runs between lines 0 and $($LineCount)"
                                # Set the start of the document to the line after the metadata.
                                $StartOfDocument = $LineCount + 1
                                # Set back to false so we don't keep looking for metadata - it should only be at the start of the file.
                                $Metadata = $false
                            }
                            else
                            {
                                # If the previous line was blank then this line is probably actually a horizontal rule.
                                if ($Markdown[$LineCount - 1] -eq '')
                                {
                                    # Do nothing
                                }
                                else
                                {
                                    # Just warn, this requires manual intervention.
                                    Write-Warning "Metadata should only be at the start of the file. Some potential metadata was found starting at line $($LineCount)"
                                }
                            }
                        }
                    }
                }
                # Match any "title: " metadata lines
                '^title\: .*'
                {
                    if (!$CodeBlockStart)
                    {
                        <#
                            Ensure the metadata does not include a title.
                            (we enforce the use of the first heading as the title instead)
                        #>
                        if ($Metadata -eq $true)
                        {
                            Write-Warning 'Do not use title in metadata. Use the first heading instead.'
                        }
                    }
                }
                # Match any headings
                '^#{1,6}'
                {
                    if (!$CodeBlockStart)
                    {
                        $Header = $Matches[0]
                        # Ensure we're not jumping more than one header level at a time.
                        if ($Header.Length -gt ($CurrentHeaderLevel + 1))
                        {
                            Write-Debug "Header level mismatch on line $LineCount.`nExpected: $($CurrentHeaderLevel + 1)`nGot: $($Header.Length)"
                            $Line = $Line -replace '^#{1,6}', ('#' * ($CurrentHeaderLevel + 1))
                            $CurrentHeaderLevel++
                        }
                        else
                        {
                            # We might be going back up a header level so ensure we set the current header level correctly.
                            $CurrentHeaderLevel = $Header.Length
                        }

                        # Ensure there is a space between the last hash and the heading text.
                        if ($Line -notmatch '^#{1,6} ')
                        {
                            Write-Debug "Adding space after header on line $LineCount"
                            $Line = $Line -replace '^#{1,6}', '$0 '
                        }

                        # Special case for the first header aka the title.
                        if ($CurrentHeaderLevel -eq 1)
                        {
                            <#
                                The title should be on the first line of the document.
                                It would be nice to move it but I couldn't figure out how to do that while maintaining the
                                new lines around it.
                                So just warn the user and let them fix it for now.
                            #>
                            if ($LineCount -ne $StartOfDocument)
                            {
                                # Disabled for now as I couldn't figure out how to make this work with whitespace
                                # Write-Warning "Title appears on line $LineCount. It should be on line $StartOfDocument."
                            }
                            if (!$Title)
                            {
                                $Title = $Line
                            }
                            else
                            {
                                Write-Debug "Title already set on line $StartOfDocument. New title found on line $LineCount. Convert to heading."
                                # Always use ## to replace the title.
                                $Line = $Line -replace '^#{1,6}', '##'
                                $CurrentHeaderLevel = 2
                            }
                        }

                        # Ensure there are blank lines before and after the heading.
                        if ($Return[-1] -ne '')
                        {
                            Write-Debug "Adding blank line before header on line $LineCount"
                            $Return += ''
                        }
                        if ($Markdown[$LineCount + 1] -ne '')
                        {
                            Write-Debug "Adding blank line after header on line $LineCount"
                            $Return += $Line
                            $Line = ''
                        }
                    }
                }
                # Match whitespace at the end of a line
                '\s+$'
                {
                    if (!$CodeBlockStart)
                    {
                        # Ensure that there is no more than 2 spaces at the end of a line.
                        if ($Line -match '\s{3,}$')
                        {
                            Write-Debug "Removing whitespace at the end of line $LineCount"
                            $Line = $Line -replace '\s{3,}$', '  '
                        }
                    }
                }
                # Match any lists
                '^(\*|\-|\+|\d+\.)(?!\*)(.*)*$'
                {
                    if (!$CodeBlockStart)
                    {
                        Write-Debug "Checking if line $LineCount is a list."
                        # Ensure we've definitely got a list and not and not something that's been caught by the regex.
                        if ($Line -match '^---$')
                        {
                            # This is a horizontal rule/metadata header, not a list.
                            Write-Debug "Line $LineCount is a horizontal rule/metadata header."
                            continue
                        }
                        # Ensure we're not matching any emphasis
                        if ($Line -match '^(\*){1,}(\w)(.*)(\w)(\*){1,}$')
                        {
                            # This is emphasis, not a list.
                            Write-Debug "Line $LineCount is emphasis."
                            continue
                        }
                        Write-Verbose "Line $LineCount is a list."
                        # Ensure there is a space between the list marker and the list item text.
                        if ($Line -notmatch '^(\*|\-|\+|\d+\.) ')
                        {
                            Write-Debug "Adding space after list marker on line $LineCount"
                            $Line = $Line -replace '^(\*|\-|\+|\d+\.)', '$0 '
                        }
                        # Ensure there is no more than one space between the list marker and the list item text.
                        if ($Line -match '^(\*|\-|\+|\d+\.)(\s){2,}')
                        {
                            Write-Debug "Removing extra space after list marker on line $LineCount"
                            $Line = $Line -replace '^(\*|\-|\+|\d+\.)(\s){2,}', '$1 '
                        }
                        # Ensure there are blank lines before and after the list.
                        if (($Return[-1] -ne '') -and ($Return[-1] -notmatch '^(\*|\-|\+|\d+\.)(?!\*)(.*)*$'))
                        {
                            Write-Debug "Adding blank line before list on line $LineCount"
                            $Return += ''
                        }
                        if (($Markdown[$LineCount + 1] -ne '') -and ($Markdown[$LineCount + 1] -notmatch '^(\*|\-|\+|\d+\.)(?!\*)(.*)*$'))
                        {
                            Write-Debug "Adding blank line after list on line $LineCount"
                            $Return += $Line
                            $Line = ''
                        }
                    }
                }
                # Match any emphasis-as-headers
                '^(\*|_){1,}(\w{1,})((\*|_){1,}(\s)*)$'
                {
                    if (!$CodeBlockStart)
                    {
                        <#
                            We actually match more aggressively than most markdownlint rules.
                            This is because sometimes we have 
                        #>
                        switch ($EmphasisAsHeaderConversion)
                        {
                            <#
                                Let the user set what kind of replacement they want,
                                it's pretty hard to guess what they want.
                            #>
                            'Header'
                            {
                                if ($CurrentHeaderLevel -ge 6)
                                {
                                    throw "Cannot convert emphasis-as-headers to header.`nHeader level is too deep. The maximum header level is 6."
                                }
                                # Replace them with the correct header level (we increment the header level by 1)
                                Write-Debug "Converting emphasis-as-headers to header on line $LineCount"
                                $Line = $Line -replace '^(\*|_){1,}', ('#' * ($CurrentHeaderLevel + 1) + ' ')
                                $Line = $Line -replace '((\*|_){1,}(\s)*)', ''
                            }
                            'List'
                            {
                                Write-Debug "Converting emphasis-as-headers to list heading on line $LineCount"
                                $Line = $Line -replace '^(\*|_){1,}', '$0:'
                            }
                            Default {}
                        }
                    }
                }
                # Match any empty lines
                '^$'
                {
                    if (!$CodeBlockStart)
                    {
                        # Ensure there is only one blank line between content.
                        if ($Markdown[$LineCount - 1] -eq '')
                        {
                            Write-Debug "Removing blank line on line $LineCount"
                            $AddToReturn = $false
                        }
                    }
                }
                # Match code blocks
                '^```'
                {
                    if (!$CodeBlockStart)
                    {
                        Write-Debug "Code block found starting on line $LineCount"
                        $CodeBlockStart = $LineCount
                        $CodeBlockEnd = $null

                        # Ensure the code block has a language specified.
                        if ($Line -notmatch '^```(\w+){1,}$')
                        {
                            Write-Debug "Adding language '$CodeBlockLanguage' to code block on line $LineCount"
                            $Line = $Line -replace '^```', "``````$CodeBlockLanguage"
                        }
                        # Ensure there is a blank line before the code block.
                        if ($Return[-1] -ne '')
                        {
                            Write-Debug "Adding blank line before code block on line $LineCount"
                            $Return += ''
                        }
                    }
                    else
                    {
                        Write-Debug "Code block ends on line $LineCount"
                        $CodeBlockEnd = $LineCount
                        $CodeBlockStart = $null
                        # Ensure there is a blank line after the code block.
                        if ($Markdown[$LineCount + 1] -ne '')
                        {
                            Write-Debug "Adding blank line after code block on line $LineCount"
                            <#
                                We need to add the current line to the array and then set it to an empty string.
                                This ensures that the blank line is added after the code block.
                            #>
                            $Return += $Line
                            $Line = ''
                        }
                    }
                }
                default
                {}
            }
            if ($AddToReturn -eq $true)
            {
                $Return += $Line
                # Only increment the line count if we're not skipping a line.
                # This should keep the line count in sync with the return array.
            }
            else
            {
                Write-Verbose "Skipping line $LineCount"
            }
            $LineCount++
        }
        if ($CodeBlockStart -and !$CodeBlockEnd)
        {
            throw "Code block starting on line $CodeBlockStart does not have an end."
        }
        <#
            Out-String is horrible and adds a newline to the end of the string.
            There's no way to stop it from doing this. (https://github.com/PowerShell/PowerShell/issues/5108 and https://github.com/PowerShell/PowerShell/issues/14444)
            So we handle it ourselves.
        #>
        $Return = $Return | Out-String
        $Return = $Return.Trim()
        # Ensure there is a blank line at the end of the file.
        if ($Return[-1] -ne '')
        {
            Write-Verbose 'Adding blank line to end of file.'
            $Return += ''
        }
        else
        {
            # We shouldn't get here, but just in case.
            # Ensure there's only one blank line at the end of the file.
            if (($Return[-2] -eq '') -and ($Return[-1] -eq ''))
            {
                Write-Verbose 'Removing blank line from end of file.'
                $Return = $Return[0..($Return.Count - 2)]
            }
        }
    }
    end
    {
        if ($Return -ne $Markdown)
        {
            return $Return
        }
        else
        {
            Write-Verbose 'No changes made to markdown file.'
            return [string]$Markdown
        }
    }
}
