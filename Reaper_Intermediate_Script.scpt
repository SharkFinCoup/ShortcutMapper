set wholeText to the clipboard --wholeText is the variable
set AppleScript's text item delimiters to {"<TR><TD>"} --When creating a list, each item will be separated by this delimiter
set wholeList to every text item of wholeText --and here is that list
set returnLine to ""
set returnSection to "{" & (ASCII character 10) & (ASCII character 34) & "Ignore" & (ASCII character 34) & ": {" & (ASCII character 10)
--asci 8 is Line feed or new line. 34 = Quotation mark. 
--This sets the first set of commands from the HTML reaper file to an Ignor catagory because they're modifyiers only
(* 
{
"Ignore": {

*)

repeat with n from 2 to count wholeList --we ignore the first 2 items on the list
	
	set eachLineItem to (item n of wholeList)
	set eachLineText to contents of eachLineItem -- there are text items and list items. We need to pull the text before we can manipulate it.
	--This next section is only to determin if the HTML part we're looking at is a Section or a Line
	if eachLineText contains "COLSPAN" then
		if eachLineText contains "<h3>Section:" then --This IF section separates the Larger "Sections" in the HTML
			
			set AppleScript's text item delimiters to {"h3>"} -- So this becomes 3 items <TR><TD COLSPAN=2><h3>Section: Main</h3></TD></TR>
			--There'll be 3 items in the sectionList
			set sectionList to every text item of eachLineText
			set sectionTextOne to (item 2 of sectionList as string) -- e.g. "Section: Main</"
			--display dialog sectionTextOne
			set sectionTextOne to text 1 thru -3 of sectionTextOne -- remove the last 2 charaters "/>" to leave e.g. "Main"
			set sectionTextOne to "}," & (ASCII character 10) & (ASCII character 34) & sectionTextOne & (ASCII character 34) & ": {"
			set returnSection to returnSection & sectionTextOne & (ASCII character 10)
		end if
		
		
	else if eachLineText contains "<BR>" then --ignore these lines in the HTML - there's nothing there
		
	else if eachLineText contains "<B>Key</B></TD><TD><B>Action</B>" then --ignore these lines in the HTML - there's nothing there, just a subheading
		
	else -- then it must be <TR><TD>Some Keyboard Shortcut</TD><TD>Some Command</TD></TR>
		set AppleScript's text item delimiters to {"</TD><TD>"}
		
		set LineSectionList to every text item of eachLineText -- each line will be split in two
		-- We need to swap them around - Shift+3 Do Something should be Do Something Shift+3
		--partOne and item 2 of LineSectionList are both the COMMAND 
		-- partTwo and item 1 of LineSectionList are both the KEYBOARD SHORTCUT
		set partOne to (item 2 of LineSectionList as string)
		set AppleScript's text item delimiters to {"</TD></TR>"}
		
		if returnSection ends with "{" & (ASCII character 10) then
			set partOne to text item 1 of partOne as string -- Now we've deleted "</TD></TR>"
			set partOne to (ASCII character 34) & partOne & (ASCII character 34) & ":" --Wrap it in Quotation marks etc
		else
			set partOne to text item 1 of partOne as string -- Now we've deleted "</TD></TR>"
			set partOne to (ASCII character 10) & "," & (ASCII character 34) & partOne & (ASCII character 34) & ":" --Wrap it in Quotation marks etc
		end if
		
		set partTwo to (item 1 of LineSectionList as string)
		
		
		-- Here we need to change Reapers way of reporting some keys e.g. @ should be Shift+2
		--START OF REPLACEMENT SECTION
		set partTwo to findAndReplace("|", "Shift+" & (ASCII character 92), partTwo) -- | = \
		set partTwo to findAndReplace("!", "Shift+1", partTwo) -- ! = Shift+1
		set partTwo to findAndReplace("@", "Shift+2", partTwo) -- @ = Shift+2
		set partTwo to findAndReplace("£", "Shift+3", partTwo) -- £ = Shift+3
		set partTwo to findAndReplace("$", "Shift+4", partTwo) -- $ = Shift+4
		set partTwo to findAndReplace("{", "Shift+[", partTwo)
		set partTwo to findAndReplace("}", "Shift+]", partTwo)
		set partTwo to findAndReplace(":", "Shift+;", partTwo)
		set partTwo to findAndReplace((ASCII character 34), "Shift+'", partTwo)
		set partTwo to findAndReplace("<", "Shift+,", partTwo)
		set partTwo to findAndReplace(">", "Shift+.", partTwo)
		set partTwo to findAndReplace("?", "Shift+/", partTwo)
		set partTwo to findAndReplace("~", "Shift+`", partTwo)
		set partTwo to findAndReplace("PrintScreen", "F13", partTwo) --correct another Reaper anomoly
		
		set partTwo to findAndReplace("NumPad ", "NumPad_", partTwo) -- This makes sure the exporter uses the numPad.
		-- without it, NumPad and TopRow numbers are the same. Or numpad just not recognised.
		
		
		if partTwo does not contain "F" then --We don't want to change the numbers in F1-F13
			set partTwo to findAndReplace("0", "ZERO", partTwo) -- But all numbers work better with export.py when written
			set partTwo to findAndReplace("1", "ONE", partTwo)
			set partTwo to findAndReplace("2", "TWO", partTwo)
			set partTwo to findAndReplace("3", "THREE", partTwo)
			set partTwo to findAndReplace("4", "FOUR", partTwo)
			set partTwo to findAndReplace("5", "FIVE", partTwo)
			set partTwo to findAndReplace("6", "SIX", partTwo)
			set partTwo to findAndReplace("7", "SEVEN", partTwo)
			set partTwo to findAndReplace("8", "EIGHT", partTwo)
			set partTwo to findAndReplace("9", "NINE", partTwo)
		end if
		
		set partOne to findAndReplace("Markers:", "", partOne)
		set partOne to findAndReplace("Item edit:", "", partOne)
		set partOne to findAndReplace("Transport:", "", partOne)
		set partOne to findAndReplace("Track:", "", partOne)
		set partOne to findAndReplace("SWS/S&M:", "", partOne)
		set partOne to findAndReplace("Take:", "", partOne)
		set partOne to findAndReplace("Edit:", "", partOne)
		set partOne to findAndReplace("Item Navigation:", "", partOne)
		set partOne to findAndReplace("Item:", "", partOne)
		set partOne to findAndReplace("SWS:", "", partOne)
		set partOne to findAndReplace("Custom:", "", partOne)
		set partOne to findAndReplace("Xenakios/", "", partOne)
		set partOne to findAndReplace("Regions:", "", partOne)
		
		
		
		
		set partTwo to findAndReplace((ASCII character 92), (ASCII character 92) & (ASCII character 92), partTwo) -- Always and another so...\ = \\
		--END OF REPLACEMENT SECTION
		
		set partTwo to "[" & (ASCII character 34) & (ASCII character 34) & ", " & (ASCII character 34) & partTwo & (ASCII character 34) & "]"
		-- That adds the part for windows which we ignore - it's left blank ""
		-- The comma is a necessary component of a json list file
		
		
		set returnLine to (ASCII character 9) & (partOne & " " & partTwo)
		set testString to (ASCII character 34) & (ASCII character 34) & ": " & "["
		
		
		if returnLine contains testString then
			
		else
			set returnSection to returnSection & returnLine
		end if
	end if
	
end repeat

set returnSection to returnSection & "}" & (ASCII character 10) & "}"
set the clipboard to returnSection

on findAndReplace(tofind, toreplace, TheString)
	set ditd to text item delimiters
	set text item delimiters to tofind
	set textItems to text items of TheString
	set text item delimiters to toreplace
	if (class of TheString is string) then
		set res to textItems as string
	else -- if (class of TheString is Unicode text) then
		set res to textItems as Unicode text
	end if
	set text item delimiters to ditd
	return res
end findAndReplace

