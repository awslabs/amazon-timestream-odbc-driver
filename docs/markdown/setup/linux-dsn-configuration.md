# Linux - Configuring a DSN

## Adding a Driver Entry

### Manually editing the odbcinst.ini file ###
If odbcinst.ini does not contain Amazon Timestream ODBC Driver info, please add a driver entry following the steps below. The odbcinst.ini could be found or created under /etc/unixODBC if /etc/unixODBC exists. Otherwise find or create under /etc.

Use a text editor from the Unix shell to edit the odbcinst.ini file such as vi.

**To create a System Driver Entry run:**
`sudo vi /etc/odbcinst.ini`
or
`sudo vi /etc/unixODBC/odbcinst.ini`

**To add the driver entries:**
1. Add `Amazon Timestream ODBC Driver` in the `[ODBC Drivers]` section.
2. Add the `[Amazon Timestream ODBC Driver]` section.

#### Sample odbcinst.ini file for 32-bit Linux
```
[ODBC Drivers]
Amazon Timestream ODBC Driver  = Installed

[Amazon Timestream ODBC Driver]
Driver = /usr/lib/timestream-odbc32/libtimestream-odbc.so
Setup  = /usr/lib/timestream-odbc32/libtimestream-odbc.so
```

#### Sample odbcinst.ini file for 64-bit Linux
```
[ODBC Drivers]
Amazon Timestream ODBC Driver  = Installed

[Amazon Timestream ODBC Driver]
Driver = /usr/lib64/timestream-odbc64/libtimestream-odbc.so
Setup  = /usr/lib64/timestream-odbc64/libtimestream-odbc.so
```

### Manually editing the odbc.ini file ###
Use a text editor from the Unix shell to edit the odbc.ini file such as vi. See [Configuration Options](./configuration_options.md) for more details on the individual entries.

**To create a System DSN Entry run:**

`sudo vi /etc/odbc.ini`

**To create a User DSN Entry run:**

`vi ~/.odbc.ini`

#### <a name="odbc_data_source"></a>Sample odbc.ini file
```
[ODBC Data Sources]
timestream-iam             = Amazon Timestream ODBC Driver
timestream-aad             = Amazon Timestream ODBC Driver
timestream-okta            = Amazon Timestream ODBC Driver
timestream-aws-profile     = Amazon Timestream ODBC Driver

[timestream-aws-profile]
Driver    = Amazon Timestream ODBC Driver
Region    = us-east-2
Auth      = AWS_PROFILE
ProfileName = default

[timestream-aad]
Driver           = Amazon Timestream ODBC Driver
Region           = us-east-1
Auth             = AAD
AADApplicationID = 
AADClientSecret  = 
RoleARN          = 
AADTenant        = 
IdpARN           = 
IdpUserName      = 
IdpPassword      = 

[timestream-okta]
Driver            = Amazon Timestream ODBC Driver
Region            = us-east-1
Auth              = OKTA
IdpHost           = 
OktaApplicationID = 
RoleARN           = 
IdpARN            = 
IdpUserName       = 
IdpPassword       = 

[timestream-iam]
Driver         = Amazon Timestream ODBC Driver
Region         = us-east-1
LogLevel       = 0
Auth           = IAM
UID            = 
PWD            = 
SessionToken   = 
```

## Testing Connections

### Testing Timestream ODBC Driver for Linux
Use [isql](https://www.systutorials.com/docs/linux/man/1-isql/#:~:text=isql%20is%20a%20command%20line,with%20built%2Din%20Unicode%20support) to test the connections and run a sample query. For example, to connect to the timestream-aws-profile DSN, 
* Type `isql timestream-aws-profile` to make a connection and enter interactive mode.

* Once the SQL prompt appears type a sample query such as `SELECT * FROM sampleDB.IoT`. 
* Type `help table_name` to get all columns of the table using SQLColumns. No database name should be prefixed before the table name.
* Type `help catalog schema table type` to get the table info using SQLTables.
* Type `help help` to get all help options.
* Type `quit` to exit interactive mode.
