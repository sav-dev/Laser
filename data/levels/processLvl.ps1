cls

# [System.Environment]::CurrentDirectory = ...

$nl = [System.Environment]::NewLine

# Read the passwords, validate
$passwords = [System.IO.File]::ReadAllLines("passwords.txt")
for ($i = 0; $i -lt $passwords.Length; $i++)
{
    if ($passwords[$i].Length -ne 4)
    {
        Write-Host "Password $i is invalid:" $passwords[$i]
        return
    }

    for ($j = $i + 1; $j -lt $passwords.Length; $j++)
    {
        if ($passwords[$i].Equals($passwords[$j]))
        {
            Write-Host "Passwords $i and $j are identical:" $passwords[$i]
            return
        }
    }
}

# Read the number of levels
$lvlFiles = Get-ChildItem ".\lvl"
$levelCount = $lvlFiles.Length

# Make sure there is enough passwords
if ($passwords.Length -lt $levelCount)
{
    $tooFew = $levelCount - $passwords.Length
    Write-Host "Not enough passwords ($tooFew missing)"
    return
}

$asmPaths = @()
$prefix = "data\levels\asm\"

# Process the files
foreach ($level in $lvlFiles)
{
    $input = $level.FullName
    $output = $input.Replace("lvl", "asm")

    if ([System.IO.File]::Exists($output))
    {
        [System.IO.File]::Delete($output)
    }

    tools\LSR_CL.exe $input $output

    $inputShort = $level.Name
    $outputShort = $inputShort.Replace("lvl", "asm")
    $asmPath = $prefix + $outputShort
    $asmPaths += $asmPath
    
}

# Read in the template
$template = [System.IO.File]::ReadAllText("levelsTemplate.asm")

# Create the level list
$index = 0
$levelList = ""
foreach ($path in $asmPaths)
{
    $indexAsString = $index.ToString("D2")
    $levelList += "  .byte LOW(level" + $indexAsString + "), HIGH(level" + $indexAsString + ")" + $nl
    $index++
}

# Create the password list
$passwordList = ""
for ($i = 0; $i -lt $asmPaths.Length; $i++)
{
    $indexAsString = $i.ToString("D2")
    $c0 = $passwords[$i][0]
    $c1 = $passwords[$i][1]
    $c2 = $passwords[$i][2]
    $c3 = $passwords[$i][3]
    $passwordList += "  .byte CHAR_" + $c0 + ", CHAR_" + $c1 + ", CHAR_" + $c2 + ", CHAR_" + $c3 + " ; level" + $indexAsString + ": " + $passwords[$i] + $nl
}

# Create the level path list
$index = 0
$levelPathList = ""
foreach ($path in $asmPaths)
{
    $indexAsString = $index.ToString("D2")
    $levelPathList += "level" + $indexAsString + ":" + $nl + "  .include `"" + $path + "`"" + $nl + $nl
    $index++
}

# Format
$formattedFile = [System.String]::Format($template, $levelCount.ToString("X2"), $levelList, $passwordList, $levelPathList)

# Write output
$output = "levels.asm"
if ([System.IO.File]::Exists($output))
{
    [System.IO.File]::Delete($output)
}

[System.IO.File]::WriteAllText($output, $formattedFile)