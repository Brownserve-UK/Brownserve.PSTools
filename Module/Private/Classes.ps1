<#
.DESCRIPTION
    Special private classes for the module.
    Previously the module used to have a lot of private classes spread across various files, this is an attempt to consolidate them into one file.
#>


## GitHub related classes
enum GitHubPullRequestState
{
    Open
    Closed
    All
}