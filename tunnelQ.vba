let
    getItemIDF = (finalTb as table,tunnelID,iptItem,iptPos)=>
    let
        selectTN = Table.SelectRows(finalTb, each ([TID] = tunnelID)),
        optPos = if iptPos = null then "error"
                else if Text.Contains(iptPos,"PASSP") then "PP"
                else if Text.Contains(iptPos,"PASSV") then "VC"
                else if Text.Contains(iptPos,"PB") then "Bay"
                else "MAIN",
        selectPOS = Table.SelectRows(selectTN, each Text.Contains(if [POSITION] = null then "-" else [POSITION],optPos)),
        selectITEM = Table.SelectRows(selectPOS, each Text.Contains([ITEM],iptItem))
    in
        selectPOS,
    
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
    result = Table.TransformColumnTypes(combined,{{"TUNNEL", Int64.Type}, {"CATEGORY", type text}, {"ITEM", type text}, {"POSITION", type text}, {"UNIT", type text}, {"DESCRIPTION", type any}, {"IFREQUIRE", type text}, {"ROCK", type text},{"AMOUNT",type number}}),
    


    add1 = Table.AddColumn(result,"itemIDF",each getItemIDF(tbtn_part1,_[TUNNEL],_[ITEM],_[ROCK]))


in
    add1




let
    isPass = (rockStr) =>Text.Contains(rockStr,"PP "),
    testPQ = Excel.CurrentWorkbook(){[Name="Append1"]}[Content],
    modified = Table.TransformColumnTypes(testPQ,{{"TUNNEL", Int64.Type}, {"CATEGORY", type text}, {"ITEM", type text}, {"POSITION", type text}, {"UNIT", type text}, {"DESCRIPTION", type text}, {"IFREQUIRE", type any}, {"ROCK", type text}, {"AMOUNT", type number}}),
    Transformed = Table.ReplaceValue(modified,each [ITEM],each if [ITEM] = "Excavation" then "Exv-"&[ROCK] else [ITEM],Replacer.ReplaceValue,{"ITEM"}),
    已添加自定义 = Table.AddColumn(Transformed, "IDFER", each Number.ToText([TUNNEL])&"_"&[POSITION]&"_"&[ITEM]),
    已添加自定义1 = Table.AddColumn(已添加自定义, "lenIDF", each "T"&Number.ToText([TUNNEL])&[ROCK]),
    合并的查询 = Table.NestedJoin(已添加自定义1,{"lenIDF"},queryTLbR,{"lenIDF"},"queryTLbR",JoinKind.LeftOuter),
    #"展开的“queryTLbR”" = Table.ExpandTableColumn(合并的查询, "queryTLbR", {"EXCAVATION"}, {"queryTLbR.EXCAVATION"}),
    已添加自定义2 = Table.AddColumn(#"展开的“queryTLbR”", "TOTAL", each [AMOUNT]*[queryTLbR.EXCAVATION]),
    已添加自定义3 = Table.AddColumn(已添加自定义2, "自定义", each isPass([ROCK])),
    筛选的行 = Table.SelectRows(已添加自定义3, each ([自定义] = true))

    
in
    筛选的行



let
    calAmtByMile = (mile,totalmile,totalAMT) => mile/totalmile*totalAMT,
    calAmt
    calAmtFun = (iptItem,iptPos,iptTid,totalAMT,iptAmtTb as table)=>
    let
        bymile = if iptItem = "BYMILE" then calAmtByMile(100,1000,1000) 
                    else if ((iptPos = null) and (not (iptItem = null))) then 666
                    else if (not (iptPos = null) and (not (iptItem = null))) then 666
                    else 999
    in
        bymile
    ,

    tunnelTbPart1o = Excel.CurrentWorkbook(){[Name="tbtn_part1"]}[Content],
    tunnelTbPart1 = Table.TransformColumnTypes(tunnelTbPart1o,{{"UNIID", Int64.Type}, {"TID", Int64.Type}, {"ID", type any}, {"WORK", type text}, {"Description of works#(lf)（设计清单）", type text}, {"UNIT", type text}, {"AMT", type number}, {"UNITP", type number}, {"PRICE", type number}, {"ITEM", type text}, {"POSITION", type any}}),
    fillin = Table.AddColumn(tunnelTbPart1,"thisAMT",each calAmtFun([ITEM],[POSITION],[TID],[AMT],Append1))

in
    fillin
