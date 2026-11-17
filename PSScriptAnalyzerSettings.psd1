# PSScriptAnalyzer settings, used by script/test-skin.ps1 (locally and in CI).
@{
    Severity     = @('Error', 'Warning')
    ExcludeRules = @(
        # script/*.ps1 are interactive dev helpers; Write-Host is the right tool there.
        'PSAvoidUsingWriteHost'
    )
}
