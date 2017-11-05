#Powershell testing client for testing the get next item functionality from scratch table

$server = "LocalHost"
$database = "JunkDb"

#production code would use a stored procedure
$sql = "SET NOCOUNT ON
        declare @fkid int;
        BEGIN TRY
            BEGIN TRANSACTION

            update Scratch set @fkid = fkid, [Who] = 'UserNameA', [When] = GetUTCDate() Where id = (Select MIN(id) from scratch where [Who] IS NULL)

            	IF(@@ROWCOUNT=0) 
				BEGIN
					Set @fkid = NULL
				END

            COMMIT TRANSACTION
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION

            IF (ERROR_NUMBER() = 1205)
            BEGIN
                --ASSUMING 0 IS NOT A VALID ID THEN WE USE IT HERE WHEN THERE IS A DEADLOCK AND LET THE CLIENT DECIDE WHAT TO DO.
                SET @fkid = 0
            END
            ELSE
            BEGIN
                Declare @ErrorMessage nvarchar(4000);
				Declare @ErrorSeverity int;
				Declare @ErrorState int;
				Declare @ErrorNumber int;
                RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorNumber)
            END
        END CATCH
        Select @fkid"


function RunSQL($sql,$database,$server) {
$connection = New-Object System.Data.SqlClient.SQLConnection("Data Source=$server;Integrated Security=SSPI;Initial Catalog=$database")
$cmd = New-Object System.Data.SqlClient.SqlCommand($sql,$connection)
    $connection.Open()
    $next = $cmd.ExecuteScalar()
    $connection.Close()
    return $next
}

Try
{
    Write-Host "do-while"
    do {
    $next = RunSQL $sql $database $server

    if($next -eq 0) {
        Write-Host "SQL Deadlock"
        #if we recieved a zero then we know there was a deadlock on the server... for this example we will just go ahead and try again now... in production maybe you want to wait a few seconds.
    } elseif ([string]::IsNullOrEmpty($next)) {
        Write-Host "IsNullOrEmpty = Done"
    } else {
        #an actual production client would now have a valid ID so it can now go to work...
        Write-Host $next
    }

    } while (![string]::IsNullOrEmpty($next))

}
Catch
{
    Write-Host $_.Exception.Message
}
Finally
{
    Write-Host "Finally"
}















