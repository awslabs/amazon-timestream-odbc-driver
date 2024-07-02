# OLE DB Setup and Support

The [OLE DB to ODBC bridge](https://learn.microsoft.com/en-us/sql/ado/guide/appendixes/microsoft-ole-db-provider-for-odbc?view=sql-server-ver15) can be used with the Amazon Timestream ODBC driver.

## PowerShell Example

Given that the driver has been installed and a DSN has been configured, OLE DB can be used with the driver by running the following PowerShell script, on Windows:

```powershell
$connectionString = "DSN=Timestream DSN;"

$query = "SELECT * FROM my_db.my_table LIMIT 10"

$connection = New-Object -ComObject ADODB.Connection
$connection.Open($connectionString)

$command = New-Object -ComObject ADODB.Command
$command.ActiveConnection = $connection
$command.CommandText = $query

$recordset = $command.Execute()

if ($recordset) {
	while (!$recordset.EOF) {
		$rowData = ""
		for ($i = 0; $i -lt $recordset.Fields.Count; $i++) {
			$field = $recordset.Fields.Item($i)
			$fieldValue = $field.Value
			if ($fieldValue -is [System.DBNull]) {
				$fieldValue = "-"
			}
			$rowData += "$($field.Name): $($fieldValue)"
			if ($i -lt $recordset.Fields.Count - 1) {
				$rowData += " | "
			}
		}
		Write-Output $rowData
		Write-Output ""
    	$recordset.MoveNext()
	}
	$recordset.Close()
}

$connection.Close()
```

The script executes a query using ADODB (indirectly OLE DB) and loops through the results, printing each column separated by `|` with its name and the `-` character to represent null values. Replace "Timestream DSN" with your DSN and replace the query with a valid query.

## Excel Example

OLE DB with the Amazon Timestream ODBC driver can be used with Excel by using the Power Pivot add-in. See [this Microsoft guide](https://support.microsoft.com/en-us/office/start-the-power-pivot-add-in-for-excel-a891a66d-36e3-43fc-81e8-fc4798f39ea8) for how to install the Power Pivot add-in.

Once Power Pivot is installed, in Excel:
1. Go to **Data** and click on **Manage Data Model** to open a new window for Power Pivot.
2. In Power Pivot, choose **From Other Sources** and then select **Others(OLEDB/ODBC)** and choose **Next**.
3. Finally, choose **Build** for your connection string and select **Microsoft OLE DB Provider for ODBC Drivers** and select your Timestream DSN.
