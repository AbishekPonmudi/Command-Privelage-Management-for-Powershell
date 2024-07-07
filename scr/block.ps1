function powershell {
    param(
        [Parameter(ValueFromRemainingArguments)]
        $Args
    )

    $command = "powershell.exe $Args"

    # Check if the command contains "-noprofile"
    if ($Args -match "-noprofile") {
        Write-Host "Execution of 'powershell -noprofile' is not allowed."
    } else {
        # Run the command
        Invoke-Expression $command
    }
}
