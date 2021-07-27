$db = 'requests.db'
$getCommandSQL = "SELECT action,target,htmldescription FROM actions;"
$getCommandSQL | sqlite3.exe $db | Set-Variable -Name "result"

foreach($row in $result)
{
    $values = $row.Split('|')
    Add-Content -Value "<a href='/watcher/request.jsp?action=$($values[0])&target=$($values[1])'>$($values[0]) $($values[1])</a> - $($values[2]) </br>" -Path .\main.jsp
}