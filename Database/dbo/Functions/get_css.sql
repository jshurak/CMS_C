CREATE FUNCTION [dbo].[get_css] ()
RETURNS varchar(max)
AS
BEGIN
	DECLARE @header VARCHAR(MAX)
	SET @header = 
	N'<style type="text/css">
	#box-table
	{
	font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
	font-size: 12px;
	text-align: center;
	border-collapse: collapse;
	border-top: 7px solid #9baff1;
	border-bottom: 7px solid #9baff1;
	}
	#box-table th
	{
	font-size: 13px;
	font-weight: normal;
	background: #b9c9fe;
	border-right: 2px solid #9baff1;
	border-left: 2px solid #9baff1;
	border-bottom: 2px solid #9baff1;
	color: #039;
	}
	#box-table td
	{
	border-right: 1px solid #aabcfe;
	border-left: 1px solid #aabcfe;
	border-bottom: 1px solid #aabcfe;
	color: #669;
	text-align: left;
	}
	tr:nth-child(odd)	 { background-color:#eee; }
	tr:nth-child(even)	 { background-color:#fff; }	
	</style>'
RETURN (@header)
END
