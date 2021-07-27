#$database = 'C:\Users\Administrator\Desktop\thewatcher\databases\requests.db'

$db = 'C:\Users\Administrator\Desktop\thewatcher\databases\requests.db'
$sql = "SELECT MAX(timedate), action, target FROM requests WHERE timedate >= Datetime('now', '-1 minutes') GROUP BY action, target;"
$cooldown = ""
Write-Host "Cooldown: $cooldown"
while($true)
{
    Start-Sleep -Seconds 2 
    Clear-Host
    $Results = ""
    Clear-Variable -Name "Results"
    $sql | C:\Users\Administrator\Desktop\thewatcher\sqllite\sqlite3.exe $db | Set-Variable -Name "Results"
    foreach($row in $Results)
    {
        Start-Sleep -Seconds 1
        Write-Host "ROW: $row"
        Clear-Variable -Name "cooldown"
        $values = $row.Split('|')
        $getCommandSQL = "SELECT command,cooldown,additionalParameters FROM actions WHERE action = '$($values[1])' AND target = '$($values[2])';"
        $action = $values[1]
        Write-Host "ACTION: $action"
        $target = $values[2]
        Write-Host "Command SQL: $getCommandSQL"
        $command = ""
        Clear-Variable -Name "command"
        Clear-Variable -Name "commandResult"
        $getCommandSQL | C:\Users\Administrator\Desktop\thewatcher\sqllite\sqlite3.exe $db | Set-Variable -Name "commandResult"
        Write-Host "Command Result: $commandResult"
        if(!$commandResult){
            Write-Host "The request is not defined on the database"
        }else{
            # Time to grab and run the command
            $commandData = $commandResult.Split('|')
            $cooldown = $commandData[1]
            Write-Host "Cooldown: $cooldown"
            $additionalParameters = $commandData[2]
            $checkLatestTimeSQL = ""
            $latestTimeRan = ""
            Clear-Variable -Name "latestTimeRan"
            Clear-Variable -Name "checkLatestTimeSQL"
            $checkLatestTimeSQL = "SELECT timedate FROM results WHERE action = '$($values[1])' AND target = '$($values[2])' order by timedate desc limit 1;"
            Write-Host "Latest Time SQL: $checkLatestTimeSQL"
            $checkLatestTimeSQL | C:\Users\Administrator\Desktop\thewatcher\sqllite\sqlite3.exe $db | Set-Variable -Name "latestTimeRan"
        
            Write-Host "Latest Time from SQL: $latestTimeRan and count: $($latestTimeRan.Count)"

            if($latestTimeRan.Count -lt 1)
            {
                $latestTimeRan = (Get-Date)
            }else
            {
                $latestTimeRan = [datetime]::ParseExact($latestTimeRan,'yyyy-MM-dd HH:mm:ss',$null)
            }

            Write-Host "LastTime Ran: $latestTimeRan"

            $coolDownTimeAdjusted = $(($latestTimeRan).AddSeconds($cooldown))
            Write-Host "Cooldown: $coolDownTimeAdjusted (Only run if this is past current time)"
            $currentTime = $((Get-Date).AddHours(7))
            Write-Host "Current Date: $currentTime"

            $command = "powershell -File $($commandData[0]) -Target $target -Action $action $additionalParameters"
            Write-Host "Command: $command"

            if($coolDownTimeAdjusted -lt $currentTime){
                Write-Host "Running Command"
                Invoke-Expression $command
            }else{
                Write-Host "Not running the command because of cooldown"
            }
        }
    }
}