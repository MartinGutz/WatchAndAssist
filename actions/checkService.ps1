Param(
    $Target,
    $Services,
    $LogLoc
)

$ServicesArray = $Services.Split(',')

Add-Content "$(Get-Date) Services Checked " -Path "$LogLoc\log.txt"
Add-Content "$(Get-Date) Target $Target " -Path "$LogLoc\log.txt"
Add-Content "$(Get-Date) Services $Services " -Path "$LogLoc\log.txt"

foreach($service in $ServicesArray){
    $result = (Get-Service -ComputerName $Target -Name $service).Status
    $result = "Checked the service $service on $Target at $(Get-Date) and found it was $result"

    $db = 'databases\requests.db'
    $sql = "INSERT INTO results (timedate,action,target,result) VALUES( datetime('now'), 'checkService','$Target','$result');"
    $sql | sqlite3.exe $db
}


