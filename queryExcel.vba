let
    source1  = Excel.CurrentWorkbook(){[Name="tborg_t1Exv"]}[Content],
    source2  = Excel.CurrentWorkbook(){[Name="tborg_t2Exv"]}[Content],
    source4  = Excel.CurrentWorkbook(){[Name="tborg_t4Exv"]}[Content],
    source5  = Excel.CurrentWorkbook(){[Name="tborg_t5Exv"]}[Content],
    source6  = Excel.CurrentWorkbook(){[Name="tborg_t6Exv"]}[Content],
    source7  = Excel.CurrentWorkbook(){[Name="tborg_t7Exv"]}[Content],
    source8  = Excel.CurrentWorkbook(){[Name="tborg_t8Exv"]}[Content],
    source10 = Excel.CurrentWorkbook(){[Name="tborg_t10Exv"]}[Content],
    source11 = Excel.CurrentWorkbook(){[Name="tborg_t11Exv"]}[Content],
    source15 = Excel.CurrentWorkbook(){[Name="tborg_t15Exv"]}[Content],
    source16 = Excel.CurrentWorkbook(){[Name="tborg_t16Exv"]}[Content],
    source18 = Excel.CurrentWorkbook(){[Name="tborg_t18Exv"]}[Content],

    rst1  = Table.UnpivotOtherColumns(source1,  {"IFREQUIRE", "DESCRIPTION", "UNIT", "POSITION", "ITEM", "CATEGORY", "TUNNEL"}, "ROCK", "AMOUNT"),
    rst2  = Table.UnpivotOtherColumns(source2,  {"IFREQUIRE", "DESCRIPTION", "UNIT", "POSITION", "ITEM", "CATEGORY", "TUNNEL"}, "ROCK", "AMOUNT"),
    rst4  = Table.UnpivotOtherColumns(source4,  {"IFREQUIRE", "DESCRIPTION", "UNIT", "POSITION", "ITEM", "CATEGORY", "TUNNEL"}, "ROCK", "AMOUNT"),
    rst5  = Table.UnpivotOtherColumns(source5,  {"IFREQUIRE", "DESCRIPTION", "UNIT", "POSITION", "ITEM", "CATEGORY", "TUNNEL"}, "ROCK", "AMOUNT"),
    rst6  = Table.UnpivotOtherColumns(source6,  {"IFREQUIRE", "DESCRIPTION", "UNIT", "POSITION", "ITEM", "CATEGORY", "TUNNEL"}, "ROCK", "AMOUNT"),
    rst7  = Table.UnpivotOtherColumns(source7,  {"IFREQUIRE", "DESCRIPTION", "UNIT", "POSITION", "ITEM", "CATEGORY", "TUNNEL"}, "ROCK", "AMOUNT"),
    rst8  = Table.UnpivotOtherColumns(source8,  {"IFREQUIRE", "DESCRIPTION", "UNIT", "POSITION", "ITEM", "CATEGORY", "TUNNEL"}, "ROCK", "AMOUNT"),
    rst10 = Table.UnpivotOtherColumns(source10, {"IFREQUIRE", "DESCRIPTION", "UNIT", "POSITION", "ITEM", "CATEGORY", "TUNNEL"}, "ROCK", "AMOUNT"),
    rst11 = Table.UnpivotOtherColumns(source11, {"IFREQUIRE", "DESCRIPTION", "UNIT", "POSITION", "ITEM", "CATEGORY", "TUNNEL"}, "ROCK", "AMOUNT"),
    rst15 = Table.UnpivotOtherColumns(source15, {"IFREQUIRE", "DESCRIPTION", "UNIT", "POSITION", "ITEM", "CATEGORY", "TUNNEL"}, "ROCK", "AMOUNT"),
    rst16 = Table.UnpivotOtherColumns(source16, {"IFREQUIRE", "DESCRIPTION", "UNIT", "POSITION", "ITEM", "CATEGORY", "TUNNEL"}, "ROCK", "AMOUNT"),
    rst18 = Table.UnpivotOtherColumns(source18, {"IFREQUIRE", "DESCRIPTION", "UNIT", "POSITION", "ITEM", "CATEGORY", "TUNNEL"}, "ROCK", "AMOUNT"),
    
    combined = Table.Combine({rst1, rst2,rst4,rst5,rst6,rst7,rst8,rst10,rst11,rst15,rst16,rst18}),
    result1 = Table.TransformColumnTypes(combined,{{"TUNNEL", Int64.Type}, {"CATEGORY", type text}, {"ITEM", type text}, {"POSITION", type text}, {"UNIT", type text}, {"DESCRIPTION", type any}, {"IFREQUIRE", type text}, {"ROCK", type text},{"AMOUNT",type number}})
    result = Table.SelectRows(result1,(r) => r[Manager] = r[Buddy] )




in
    result



let
    testPQ = Excel.CurrentWorkbook(){[Name="Append1"]}[Content],
    modified = Table.TransformColumnTypes(testPQ,{{"TUNNEL", Int64.Type}, {"CATEGORY", type text}, {"ITEM", type text}, {"POSITION", type text}, {"UNIT", type text}, {"DESCRIPTION", type text}, {"IFREQUIRE", type any}, {"ROCK", type text}, {"AMOUNT", type number}}),
	Transformed = Table.ReplaceValue(modified,each [ITEM],each if [ITEM] = "Excavation" then "Exv-"&[ROCK] else [ITEM],Replacer.ReplaceValue,{"ITEM"})

	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    #"Replaced Value" = Table.ReplaceValue(#"Replaced OTH",each [Gender],each if [Surname] = "Manly" then "Male" else [Gender],Replacer.ReplaceValue,{"Gender"})
in
    Transformed



// learn M language
let
	//Load data from Excel worksheet
	Source = Excel.CurrentWorkbook(){[Name="TiedRanksInput"]}[Content],
	//Declare function to calculate the rank
	Rank = (SalesValue) => Table.RowCount(Table.SelectRows(Source, each [Sales]>SalesValue)) +1,
	//Go back to the original input table
	Custom1 = Source,
	//Add new custom column to show the rank values
	InsertedCustom = Table.AddColumn(Custom1, "Rank", each Rank([Sales]))
in
	InsertedCustom


let
	//Load data from the Excel worksheet
	Source = Excel.CurrentWorkbook(){[Name="DistinctCustomersInput"]}[Content],
	//Set the data type of the Date column to date
	ChangedType = Table.TransformColumnTypes(Source,{{"Date", type date}}),
	//Remove all duplicate combinations of Date and Customer
	//REMOVE: FROM FIRST: IF ALREADY HAVE THEN DELETE ELSE PASS
	DuplicatesRemoved = Table.Distinct(ChangedType, {"Date", "Customer"}),
	//Find the count of rows per date
	GroupedRows = Table.Group(DuplicatesRemoved, {"Date"},
	{{"Distinct Customers", each Table.RowCount(_), type number}})
in
	GroupedRows

// MANIPULATE COLUMNS, NOT PERTICAL
let
	//Load data from the Excel worksheet
	Source = Excel.CurrentWorkbook(){[Name="ListData"]}[Content],
	//Add index column
	InsertedIndex = Table.AddIndexColumn(Source,"Index"),
	//Calculate row type as a number
	InsertedCustom = Table.AddColumn(InsertedIndex, "RowType", each Number.Mod([Index],3)),
	//Convert the row type number to a text value
	InsertedCustom1 = Table.AddColumn(InsertedCustom, "RowTypeText",
	each if [RowType]=0 then "Name"
	else if [RowType]=1 then "Gender"
	else "Country"),
	//Identify each customer record
	InsertedCustom2 = Table.AddColumn(InsertedCustom1, "CustomerID",
	each Number.IntegerDivide([Index], 3)),
	//Remove columns not needed for output
	RemovedColumns = Table.RemoveColumns(InsertedCustom2,{"Index", "RowType"}),
	//Pivot the table
	Custom1 = Table.Pivot(RemovedColumns, {"Name", "Gender", "Country"}, "RowTypeText", "Data")
in
	Custom1

let
	
	//Append the LastYearCustomers table to the ThisYearCustomers table
	Source = Table.Combine({ThisYearCustomers,LastYearCustomers}),
	
	//Merge the two columns into one
	MergedColumns = Table.CombineColumns(
	Source,
	{"Customers This Year",
	"Customers Last Year"},
	Combiner.CombineTextByDelimiter("", QuoteStyle.None),"Merged"),
	
	//Remove duplicate customers
	DuplicatesRemoved = Table.Distinct(MergedColumns),
	
	//Rename the only column in the table to Customer
	RenamedColumns = Table.RenameColumns(DuplicatesRemoved,{{"Merged", "Customer"}}),
	
	//Merge this query with the ThisYearCustomers table
	Merge = Table.NestedJoin(
	RenamedColumns,
	{"Customer"},
	ThisYearCustomers,
	{"Customers This Year"},
	"NewColumn"),

	//Aggregate the resulting column of tables by Count (Not Blank)
	#"Aggregate NewColumn" = Table.AggregateTableColumn(
	Merge,
	"NewColumn",
	{{"Customers This Year",
	List.NonNullCount,
	"Count (Not Blank) of NewColumn.Customers This Year"}}),

	//Rename the new column to ThisYear
	RenamedColumns1 = Table.RenameColumns(
	#"Aggregate NewColumn",
	{{"Count (Not Blank) of NewColumn.Customers This Year",
	"ThisYear"}}),

	//Merge this query with the LastYearCustomers table
	Merge1 = Table.NestedJoin(
	RenamedColumns1,
	{"Customer"},
	LastYearCustomers,
	{"Customers Last Year"},
	"NewColumn"),

	//Aggregate the resulting column of tables by Count (Not Blank)
	#"Aggregate NewColumn1" = Table.AggregateTableColumn(
	Merge1,
	"NewColumn",
	{{"Customers Last Year",
	List.NonNullCount,
	"Count (Not Blank) of NewColumn.Customers Last Year"}}),

	//Rename the new column to LastYear
	RenamedColumns2 = Table.RenameColumns(
	#"Aggregate NewColumn1",
	{{"Count (Not Blank) of NewColumn.Customers Last Year",
	"LastYear"}}),
	
	//Use the ThisYear and LastYear columns to classify each customer
	InsertedCustom = Table.AddColumn(
	RenamedColumns2,
	"Classification",
	each
	if [ThisYear]=1 and [LastYear]=1 then "Returning"
	else if [ThisYear]=1 and [LastYear]=0 then "New"
	else "Lost"),

	//Remove unwanted columns
	RemovedColumns = Table.RemoveColumns(InsertedCustom,{"ThisYear", "LastYear"})

in
	RemovedColumns

// using date funciton
let
	//Create a list of 365 dates starting from January 1st 2014
	Source = List.Dates(#date(2014,1,1), 365, #duration(1,0,0,0) ),
	//Turn the list into a table
	TableFromList = Table.FromList(
	Source,
	Splitter.SplitByNothing(),
	null,
	null,
	ExtraValues.Error),
	//Rename the only column in the table to Date
	RenamedColumns = Table.RenameColumns(TableFromList,{{"Column1", "Date"}}),
	//Change the type of the column to Date
	ChangedType = Table.TransformColumnTypes(RenamedColumns,{{"Date", type date}}),
	//Duplicate the Date column
	DuplicatedColumn = Table.DuplicateColumn(ChangedType, "Date", "Copy of Date"),
	//Rename the duplicated column to Year
	RenamedColumns1 = Table.RenameColumns(DuplicatedColumn,{{"Copy of Date", "Year"}}),
	//Convert the dates in the Year column to years
	TransformedColumn = Table.TransformColumns(RenamedColumns1,{{"Year", Date.Year}}),
	//Add a custom column containing month names
	InsertedCustom = Table.AddColumn(TransformedColumn, "Month", each Date.ToText([Date], "MMMM")),
	//Add a custom column containing day names
	InsertedCustom1 = Table.AddColumn(InsertedCustom, "DayName", each Date.ToText([Date], "dddd")),
	//Add a custom column containing week numbers
	InsertedCustom2 = Table.AddColumn(InsertedCustom1, "Week", each Date.WeekOfYear([Date]))
in
	InsertedCustom2

let
	DateFunction = (StartDate as date, EndDate as date) as table =>
	let
		//Find the number of dates between the start date and end date
		NumberOfDays = Duration.Days(EndDate-StartDate)+1,
		//Create a list of dates starting from the start date
		Source = List.Dates(StartDate, NumberOfDays, #duration(1,0,0,0) ),
		//Turn the list into a table
		TableFromList = Table.FromList(
		Source,
		Splitter.SplitByNothing(),
		null,
		null,
		ExtraValues.Error),
		//Rename the only column in the table to Date
		RenamedColumns = Table.RenameColumns(TableFromList,{{"Column1", "Date"}}),
		//Change the type of the column to Date
		ChangedType = Table.TransformColumnTypes(RenamedColumns,{{"Date", type date}}),
		//Duplicate the Date column
		DuplicatedColumn = Table.DuplicateColumn(ChangedType, "Date", "Copy of Date"),
		//Rename the duplicated column to Year
		RenamedColumns1 = Table.RenameColumns(DuplicatedColumn,{{"Copy of Date", "Year"}}),
		//Convert the dates in the Year column to years
		TransformedColumn = Table.TransformColumns(RenamedColumns1,{{"Year", Date.Year}}),
		//Add a custom column containing month names
		InsertedCustom = Table.AddColumn(TransformedColumn, "Month", each Date.ToText([Date], "MMMM")),
		//Add a custom column containing day names
		InsertedCustom1 = Table.AddColumn(InsertedCustom, "DayName", each Date.ToText([Date], "dddd")),
		//Add a custom column containing week numbers
		InsertedCustom2 = Table.AddColumn(InsertedCustom1, "Week", each Date.WeekOfYear([Date]))
	in
		InsertedCustom2
in
	DateFunction

// important!!!
let
	//Load data from Excel
	Source = Excel.CurrentWorkbook(){[Name="StockPrice"]}[Content],
	//Set column data types
	ChangedType = Table.TransformColumnTypes(
	Source,
	{{"Time", type time},
	{"Stock Price", type number}}),
	//Is Stock Price greater than or equal to 50?
	InsertedCustom = Table.AddColumn(ChangedType, "Above50", each [Stock Price]>=50),
	//Aggregate time ranges
	GroupedRows = Table.Group(
	InsertedCustom,
	{"Above50"},
	{{"Start", each List.Min([Time]), type time},
	{"EndTemp", each List.Max([Time]), type time},
	{"Minutes", each Table.RowCount(_), type number}},GroupKind.Local),
	//Add one minute to the values in the EndTemp column
	InsertedCustom1 = Table.AddColumn(GroupedRows, "End", each [EndTemp] + #duration(0,0,1,0)),
	//Remove the EndTemp column
	RemovedColumns = Table.RemoveColumns(InsertedCustom1,{"EndTemp"}),
	//Move the End column in between Start and Minutes
	ReorderedColumns = Table.ReorderColumns(RemovedColumns,{"Above50", "Start", "End", "Minutes"}),
	//Filter to show only ranges where stock price is greater than or equal to 50
	FilteredRows = Table.SelectRows(ReorderedColumns, each ([Above50] = true)),
	//Sort by Minutes in descending order
	SortedRows = Table.Sort(FilteredRows,{{"Minutes", Order.Descending}}),
	//Keep first row of the table
	KeptFirstRows = Table.FirstN(SortedRows,1)
in
	KeptFirstRows

let
    源 = Xml.Tables(File.Contents("D:\PYPROJECT\pmu\test3.xml")),
    更改的类型 = Table.TransformColumnTypes(源,{{"Attribute:DATE", Int64.Type}, {"Attribute:LEVEL", Int64.Type}}),
    删除的列 = Table.RemoveColumns(更改的类型,{"Attribute:DATE", "Attribute:LEVEL"}),
    复制的列 = Table.DuplicateColumn(删除的列, "CostCenter", "CostCenter - 复制"),
    复制的列1 = Table.DuplicateColumn(复制的列, "CostCenter - 复制", "CostCenter - 复制 - 复制"),
    #"展开的“CostCenter”" = Table.ExpandTableColumn(复制的列1, "CostCenter", {"Attribute:ID"}, {"CostCenter.Attribute:ID"}),
    #"展开的“CostCenter - 复制”" = Table.ExpandTableColumn(#"展开的“CostCenter”", "CostCenter - 复制", {"SubCostCenter"}, {"CostCenter - 复制.SubCostCenter"}),
    复制的列2 = Table.DuplicateColumn(#"展开的“CostCenter - 复制”", "CostCenter - 复制.SubCostCenter", "CostCenter - 复制.SubCostCenter - 复制"),
    #"展开的“CostCenter - 复制.SubCostCenter”" = Table.ExpandTableColumn(复制的列2, "CostCenter - 复制.SubCostCenter", {"Attribute:ID"}, {"CostCenter - 复制.SubCostCenter.Attribute:ID"}),
    复制的列3 = Table.DuplicateColumn(#"展开的“CostCenter - 复制.SubCostCenter”", "CostCenter - 复制.SubCostCenter - 复制", "CostCenter - 复制.SubCostCenter - 复制 - 复制"),
    #"展开的“CostCenter - 复制.SubCostCenter - 复制”" = Table.ExpandTableColumn(复制的列3, "CostCenter - 复制.SubCostCenter - 复制", {"Attribute:TEXT"}, {"CostCenter - 复制.SubCostCenter - 复制.Attribute:TEXT"}),
    重排序的列 = Table.ReorderColumns(#"展开的“CostCenter - 复制.SubCostCenter - 复制”",{"CostCenter.Attribute:ID", "CostCenter - 复制.SubCostCenter.Attribute:ID", "CostCenter - 复制.SubCostCenter - 复制.Attribute:TEXT", "CostCenter - 复制.SubCostCenter - 复制 - 复制", "CostCenter - 复制 - 复制"}),
    复制的列4 = Table.DuplicateColumn(重排序的列, "CostCenter - 复制.SubCostCenter - 复制 - 复制", "CostCenter - 复制.SubCostCenter - 复制 - 复制 - 复制"),
    #"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制”" = Table.ExpandTableColumn(复制的列4, "CostCenter - 复制.SubCostCenter - 复制 - 复制", {"NODE"}, {"CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE"}),
    复制的列5 = Table.DuplicateColumn(#"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制”", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制"),
    删除的列1 = Table.RemoveColumns(复制的列5,{"CostCenter - 复制 - 复制", "CostCenter - 复制.SubCostCenter - 复制 - 复制 - 复制", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制"}),
    复制的列6 = Table.DuplicateColumn(删除的列1, "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制"),
    #"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE”" = Table.ExpandTableColumn(复制的列6, "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE", {"Attribute:ID"}, {"CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE.Attribute:ID"}),
    复制的列7 = Table.DuplicateColumn(#"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE”", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制"),
    #"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制”" = Table.ExpandTableColumn(复制的列7, "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制", {"Attribute:TEXT"}, {"CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制.Attribute:TEXT"}),
    复制的列8 = Table.DuplicateColumn(#"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制”", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制 - 复制"),
    #"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制”" = Table.ExpandTableColumn(复制的列8, "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制", {"NODE"}, {"CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE"}),
    #"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制 - 复制”" = Table.ExpandTableColumn(#"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制”", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制 - 复制", {"LEAF"}, {"CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF"}),
    复制的列9 = Table.DuplicateColumn(#"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制 - 复制”", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制"),
    重排序的列1 = Table.ReorderColumns(复制的列9,{"CostCenter.Attribute:ID", "CostCenter - 复制.SubCostCenter.Attribute:ID", "CostCenter - 复制.SubCostCenter - 复制.Attribute:TEXT", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE.Attribute:ID", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制.Attribute:TEXT", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF"}),
    #"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE”" = Table.ExpandTableColumn(重排序的列1, "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE", {"Attribute:ID"}, {"CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE.Attribute:ID"}),
    复制的列10 = Table.DuplicateColumn(#"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE”", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制"),
    #"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制”" = Table.ExpandTableColumn(复制的列10, "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制", {"Attribute:TEXT"}, {"CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制.Attribute:TEXT"}),
    重排序的列2 = Table.ReorderColumns(#"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制”",{"CostCenter.Attribute:ID", "CostCenter - 复制.SubCostCenter.Attribute:ID", "CostCenter - 复制.SubCostCenter - 复制.Attribute:TEXT", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE.Attribute:ID", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制.Attribute:TEXT", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE.Attribute:ID", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制.Attribute:TEXT", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF"}),
    复制的列11 = Table.DuplicateColumn(重排序的列2, "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制"),
    #"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制”" = Table.ExpandTableColumn(复制的列11, "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制", {"NODE"}, {"CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制.NODE"}),
    #"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制”" = Table.ExpandTableColumn(#"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制”", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制", {"LEAF"}, {"CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF"}),
    删除的列2 = Table.RemoveColumns(#"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制”",{"CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制.NODE", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF"}),
    复制的列12 = Table.DuplicateColumn(删除的列2, "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF "),
    #"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF”" = Table.ExpandTableColumn(复制的列12, "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF", {"Attribute:ID"}, {"CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF."}),
    复制的列13 = Table.DuplicateColumn(#"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF”", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF ", "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEA.1"),
    #"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF ”" = Table.ExpandTableColumn(复制的列13, "CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF ", {"Attribute:TEXT"}, {"CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEA.2"}),
    筛选的行 = Table.SelectRows(#"展开的“CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF ”", each ([#"CostCenter - 复制.SubCostCenter - 复制 - 复制.NODE - 复制 - 复制.NODE - 复制 - 复制 - 复制.LEAF."] = null))
in
    筛选的行


let
    //Define function taking two parameters - a table and an optional column number 
    Source = (TableToExpand as table, optional ColumnNumber as number) =>
    let
     //If the column number is missing, make it 0
     ActualColumnNumber = if (ColumnNumber=null) then 0 else ColumnNumber,
     //Find the column name relating to the column number
     ColumnName = Table.ColumnNames(TableToExpand){ActualColumnNumber},
     //Get a list containing all of the values in the column
     ColumnContents = Table.Column(TableToExpand, ColumnName),
     //Iterate over each value in the column and then
     //If the value is of type table get a list of all of the columns in the table
     //Then get a distinct list of all of these column names
     ColumnsToExpand = List.Distinct(List.Combine(List.Transform(ColumnContents, 
                        each if _ is table then Table.ColumnNames(_) else {}))),
     //Append the original column name to the front of each of these column names
     NewColumnNames = List.Transform(ColumnsToExpand, each ColumnName & "." & _),
     //Is there anything to expand in this column?
     CanExpandCurrentColumn = List.Count(ColumnsToExpand)>0,
     //If this column can be expanded, then expand it
     ExpandedTable = if CanExpandCurrentColumn 
                         then 
                         Table.ExpandTableColumn(TableToExpand, ColumnName, 
                                ColumnsToExpand, NewColumnNames) 
                         else 
                         TableToExpand,
     //If the column has been expanded then keep the column number the same, otherwise add one to it
     NextColumnNumber = if CanExpandCurrentColumn then ActualColumnNumber else ActualColumnNumber+1,
     //If the column number is now greater than the number of columns in the table
     //Then return the table as it is
     //Else call the ExpandAll function recursively with the expanded table
     OutputTable = if NextColumnNumber>(Table.ColumnCount(ExpandedTable)-1) 
                        then 
                        ExpandedTable 
                        else 
                        ExpandAll(ExpandedTable, NextColumnNumber)
    in
     OutputTable
in
    Source


