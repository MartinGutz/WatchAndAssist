Param(
    $Target,
    $Action,
    $LogLoc
)

Add-Content "$(Get-Date) Pinged the server $Target" -Path "$LogLoc\log.txt"

$result = Test-Connection -ComputerName $Target -Quiet
$result = "Pinged the server $Target at $(Get-Date) and found it was $result"

$db = 'databases\requests.db'
$sql = "INSERT INTO results (timedate,action,target,result) VALUES( datetime('now'), '$Action','$Target','$result');"
Add-Content -Value $sql -Path .\log.txt
$sql | sqlite3.exe $db