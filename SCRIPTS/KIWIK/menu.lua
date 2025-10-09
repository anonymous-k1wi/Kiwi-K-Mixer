--	 |  / _)         _)       |  /     \  | _)                 
--	 . <   | \ \  \ / | ____| . <     |\/ |  | \ \ /   -_)   _|
--	_|\_\ _|  \_/\_/ _|      _|\_\   _|  _| _|  _\_\ \___| _|  
---------------------------------------------------------------
-- Kiwi-K Mixer Menu
-- This script builds the main menu before launching
-- the robot mix builder or robot mix editor.

-- selection variable
local page_field = 0	-- page field variable

-- detect and change page_field
local function fieldIncDec(event, value, max)
	-- if event should cause decrease
	if event == EVT_VIRTUAL_DEC or event == EVT_VIRTUAL_DEC_REPT then
		-- lower value (but not below zero)
		if value > 0 then
			value = value - 1
		end
	-- elseif event should cause increase
	elseif event == EVT_VIRTUAL_INC or event == EVT_VIRTUAL_INC_REPT then
		-- raise value (but not above max)
		if value < max then
			value = value + 1
		end
	end
	
	return value
end

-- main run function
local function run(event)
	-- draw common page elements 
	lcd.clear()
	lcd.drawScreenTitle("Kiwi-K Robot Mixer", 0, 0)
	lcd.drawText( 6, 16, "Setup New Robot", MIDSIZE)
	lcd.drawText( 6, 40, "Update Settings", MIDSIZE)

	-- draw selection boxes based on page_field
	if page_field == 0 then
	    lcd.drawFilledRectangle(2, 13, 124, 18)
	    lcd.drawRectangle(2, 37, 124, 18)
	elseif page_field == 1 then
	    lcd.drawFilledRectangle(2, 37, 124, 18)
	    lcd.drawRectangle(2, 13, 124, 18)
	end	
	
	-- handle user inputs
	if event == EVT_VIRTUAL_ENTER then
	    -- open script based on page_field
	    if page_field == 0 then
	      return "define_model.lua"
	    elseif page_field == 1 then
	      return "update_model.lua"
	    end
	else  
		-- otherwise check for page_field changes
		page_field = fieldIncDec(event, page_field, 1)
	end
	
	return 0
end

return { run=run }