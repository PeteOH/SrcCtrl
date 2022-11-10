/// Data Load class.
/// <p>That will load data from a predefined SQL Gateway using the DATA LOAD IRIS utility 
/// assumes that ^CTRL.Code("sqlgateway") default=IRISDEV is configured to point
/// to the necessary namespace
Class CTRL.Data
{

ClassMethod ignoreTable(table) As %Boolean
{
	set retval = 0
	
	set ignoreList("dbo.ClientActivity") = 1
	set ignoreList("dbo.AuditLog") = 1
	set ignoreList("dbo.BG_LogTable") = 1
	set ignoreList("dbo.BG_SportDataHistory") = 1
	set ignoreList("dbo.SportImageCache") = 1
	
	set retval = $G(ignoreList(table),0)
	
	return retval
}

ClassMethod refreshData(schema As %String = "dbo") As %Status
{
    Set sc = $$$OK
    
    // get a list of the existing tables for the schema

    set jdbc = $G(^CTRL.Code("sqlgateway"),"IRISDEV")

	set sSQL = "SELECT Tables.TABLE_SCHEMA, Tables.TABLE_NAME, Tables.CLASSNAME "
    set sSQL = sSQL _ " FROM INFORMATION_SCHEMA.TABLES AS Tables where Tables.TABLE_SCHEMA = '"_schema_"'"
    set sSQL = sSQL _ " and Tables.TABLE_TYPE = 'BASE TABLE'"
	set stmt = ##class(%SQL.Statement).%New()
	set tsc = stmt.%Prepare(sSQL)
	
	set rs = stmt.%Execute()
	
	set wiz = ##class(%SQL.Migration.Import).%New()
	
	set tsc = wiz.Connect(jdbc,,1)
	
	while rs.%Next()
	{

        // LOAD DATA FROM JDBC CONNECTION jdbcConnection TABLE jdbcTable INTO table  
        // LOAD DATA FROM JDBC CONNECTION jdbcConnection TABLE jdbcTable INTO table (column,column2, ...)  
        // LOAD DATA FROM JDBC CONNECTION jdbcConnection TABLE jdbcTable INTO table ... VALUES (header,header2 ...) 

        set sTable = rs.%GetData(1)_"."_rs.%GetData(2)
		if '..ignoreTable(sTable)
		{
	        w !,"TABLE: " _ sTable

	        w ?40," Truncating... "
	        set sSQL = "TRUNCATE TABLE "_ sTable 
	        set rs1 = ##class(%SQL.Statement).%ExecDirect(,.sSQL)

	        w ?60," Loading Data..."
	        
	        //set sSQL = "LOAD %NOJOURN BULK DATA FROM JDBC CONNECTION " _ jdbc _ " TABLE "_ sTable _" INTO "_ sTable 
	        //set sSQL = "LOAD DATA FROM JDBC CONNECTION " _ jdbc _ " TABLE "_ sTable _" INTO "_ sTable 
	        //set rs2 = ##class(%SQL.Statement).%ExecDirect(,.sSQL)
	        
	        set wiz.Debug = 0
	        set wiz.DeferIndices = 1
	        set wiz.DeleteExistingData = 0
	        set wiz.NoJournal = 1
	        set wiz.NoCheck = 1
	        set wiz.NoTrigger = 1
	        set wiz.MaxErrors = 0
	        
	 		set tsc = wiz.CopyDataJ(rs.%GetData(1), rs.%GetData(2))
	        
	        //if (rs2.%SQLCODE=0)
	        if wiz.ErrorCount() = 0
	        {
	            //w " ROWS: " _ rs2.%ROWCOUNT
	            w ?80," building Indexes..."
	            DO $CLASSMETHOD(rs.%GetData(3),"%BuildIndices")
	            w " COMPLETE."
	        }
	        else
	        {
	            w ?90," ERRORED - " //_ rs2.%Message
	            do wiz.ShowAllErrors()
	            do wiz.ClearErrors()
	        }
		}        
		
	}

    Return sc
}

}
