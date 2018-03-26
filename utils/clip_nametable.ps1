cls
$path = "input"
$result = "output"
$attRows = 3

$rows = $attRows * 4

[System.IO.File]::Delete($result)
$file = [System.IO.File]::ReadAllBytes($path)
$newBytes = @()

for ($i = 0; $i -lt 32 * $rows; $i++)
{
    $newBytes += $file[$i]
}

for ($i = 960; $i -lt 960 + 8 * $attRows; $i++)
{
    $newBytes += $file[$i]
}

[System.IO.File]::WriteAllBytes($result, $newBytes)