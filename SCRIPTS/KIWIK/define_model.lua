--	 |  / _)         _)       |  /     \  | _)                 
--	 . <   | \ \  \ / | ____| . <     |\/ |  | \ \ /   -_)   _|
--	_|\_\ _|  \_/\_/ _|      _|\_\   _|  _| _|  _\_\ \___| _|  
---------------------------------------------------------------
-- Kiwi-K Model Generator
-- This script builds a new mix for a robot
-- based on user inputs.

--  Definition of Pages ---
local INTRO_PAGE  		= 0	-- provides user warning
local QUERY_PAGE  		= 1	-- queries user for robot weapons
local WIRING_PAGE		= 2	-- provides user with wiring instructions
-- optional pages, dependent on QUERY_PAGE results
local WEAPON_RADIO_PAGE = 3	-- gathers TX input for robot weapon
local SERVO_RADIO_PAGE  = 4	-- gathers TX input + safety pos. for robot servo 
local SAFETY_RADIO_PAGE = 5	-- gathers TX input for robot safety
---------------------------
local DRIVE_RADIO_PAGE  = 6	-- gathers fb and lb TX inputs for driving
local EXIT_PAGE   		= 7	-- page prompts to exit (and save if all fields filled)

local page_count = 4  	-- excludes optional pages, updated in "updatePageCount()"
local page = INTRO_PAGE -- page location variable
local page_field = 0	-- tracks position on page fields
local page_index = 1	-- page number for drawing screen titles
local is_editing = false	-- tracks editing of page fields

-- Source List Variables
local source_list = {}
local index_list = {}
local value_list = {}
-- Switches List Variables
local switch_list = {}
local switch_index_list = {}
local switch_value_list = {}
-- General List Variables
local last_moved = 0

-- Robot Settings
local has_motor = false
local has_servo = false

-- Mix Settings
local motor_list_index		= 0
local servo_list_index		= 0
local servo_center_pos		= 0
local safety_list_index		= 0
local fb_list_index			= 0
local lr_list_index			= 0

-- Default Mix Weights
-- fb = forwards/backwards (straight movement)
-- lr = left/right (turning movement)
local fb_weight = 100
local lr_weight = 30

-- update page count if motor or servo exists
local function updatePageCount()
	-- both exist, increase page_count by 3
	if has_motor and has_servo then
		page_count = 7
	-- one exists, increase page_count by 2
	elseif has_motor or has_servo then
		page_count = 6
	-- otherwise, set page_count to default (4)
	else
		page_count = 4
	end
end

-- clear model flight modes inputs, and mixes
local function cleanModel()
	model.deleteFlightModes()
	model.deleteInputs()
	model.deleteMixes()
end

-- make list of sources for input fields
local function buildSourceList()
	local index = 1
	--  for each existing source
	for sourceIndex, sourceName in sources() do
		if sourceName then
			local sourceValue = getSourceValue(sourceIndex)
			-- if source exists and is named and has number value 
			if sourceValue ~= nil and type(sourceValue) == "number" then		
		 		-- add to list of sources for inputs
		 		source_list[index] = sourceName
				value_list[index]  = sourceValue
				index_list[index]  = sourceIndex
				index = index + 1
			end
		end
	end
end

-- make list of switches for input fields, excluding "Act"
-- "Act" is not a physical switch but is recognized as switch in software
local function buildSwitchList()
	local index = 1
	-- for each existing switch
	for switchIndex, switchName in switches() do
		if switchName and switchName ~= "Act" then
			local switchValue = getSwitchValue(switchIndex)
			local fieldInfo = getFieldInfo(switchIndex)
			-- if switch exists and is not "Act" and has name and values
			if switchValue ~= nil and fieldInfo and fieldInfo.name ~= "Act" then
		 		-- add switch to list of switches
		 		switch_list[index] = switchName
		 		switch_value_list[index]  = switchValue
				switch_index_list[index]  = switchIndex
				index = index + 1
			end
		end
	end
end

-- reset elements between page changes
local function pageChangeReset()
	last_moved = 0
	is_editing = false
	page_field = 0
end

-- update last moved TX input
local function getLastTXInput()
	-- read each input value in list
	for i = 1, #value_list do
		-- read old and current inputs
		local old_value = value_list[i] or 0
		local new_value = getSourceValue(index_list[i])
		-- update old value
		value_list[i] = new_value
		-- if threshold crossed, update last_moved
		if (math.abs(new_value - old_value) > 10) then
			last_moved = i
			return(true)
		end
	end
	return(false)
end

-- update last moved TX switch
local function getLastTXSwitch()
	-- read each input value in list
	for i = 1, #switch_value_list do
		-- read old and current inputs
		local old_value = switch_value_list[i] or false
		local new_value = getSwitchValue(switch_index_list[i])
		-- update old value
		switch_value_list[i] = new_value	
		-- if became true, update last_moved
		if not old_value and new_value then
			last_moved = i
			return(true)
		end
	end
	return(false)
end

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

-- manually draw check mark from pixels at offset
local function drawCheck(x_offset, y_offset)
	lcd.drawPoint(x_offset+5, y_offset+1)
	lcd.drawPoint(x_offset+4, y_offset+2)
	lcd.drawPoint(x_offset+5, y_offset+2)
	lcd.drawPoint(x_offset+1, y_offset+3)
	lcd.drawPoint(x_offset+3, y_offset+3)
	lcd.drawPoint(x_offset+4, y_offset+3)
	lcd.drawPoint(x_offset+1, y_offset+4)
	lcd.drawPoint(x_offset+2, y_offset+4)
	lcd.drawPoint(x_offset+3, y_offset+4)
	lcd.drawPoint(x_offset+2, y_offset+5)
end



------------------- PAGES -------------------
-- Intro Page
local function drawIntroPage(event)
	-- draw user warning
	lcd.clear()
	lcd.drawScreenTitle("Kiwi-K Mixer", 0, 0)
	lcd.drawText(6, 11, "WARNING!", MIDSIZE, BLINK)
	lcd.drawText(6, 27, "Setup will erase existing", SMLSIZE)
	lcd.drawText(6, 37, "model inputs and mix. Use", SMLSIZE)
	lcd.drawText(6, 47, "page keys to navigate. >>", SMLSIZE)
	
	-- if user continues, move to next page
	if event == EVT_VIRTUAL_NEXT_PAGE then
    	page = QUERY_PAGE
    	cleanModel()
    	pageChangeReset()
    end
    
	return 0
end

-- Query Page
local function drawQueryPage(event)
	-- draw common elements
	lcd.clear()
	lcd.drawScreenTitle("Kiwi-K Define Robot", page_index, page_count)
	lcd.drawText(6, 11, "DEFINE ROBOT", MIDSIZE)
	lcd.drawText(6, 30, "Has motor")
	lcd.drawText(6, 45, "Has servo")

	-- define position of check boxes
	local motor_box_x = 64
	local motor_box_y = 30
	local servo_box_x = 64  
	local servo_box_y = 45
	
	-- draw check boxes for robot definition	
	if page_field == 0 then  -- if selected field is index 0
		lcd.drawFilledRectangle(motor_box_x, motor_box_y, 7, 7)
		lcd.drawRectangle(servo_box_x, servo_box_y, 7, 7)
		-- draw check if either has_motor or has_servo
		if has_motor then
			drawCheck(motor_box_x, motor_box_y)
		end
		if has_servo then
			drawCheck(servo_box_x, servo_box_y)
		end
	else	-- if selected field is index 1
		lcd.drawRectangle(motor_box_x, motor_box_y, 7, 7)
		lcd.drawFilledRectangle(servo_box_x, servo_box_y, 7, 7)	
		-- draw check if either has_motor or has_servo
		if has_motor then
			drawCheck(motor_box_x, motor_box_y)
		end
		if has_servo then
			drawCheck(servo_box_x, servo_box_y)
		end
	end
	
	-- handle event
	if event == EVT_VIRTUAL_ENTER then
		-- toggle appropriate variable for robot
    	if page_field == 0 then
    		has_motor = not has_motor
    	else
    		has_servo = not has_servo
	    end
	    
	-- page navigation
	elseif event == EVT_VIRTUAL_NEXT_PAGE then
		-- move to wiring page
		page = WIRING_PAGE
		page_index = page_index + 1
		pageChangeReset()
	elseif event == EVT_VIRTUAL_PREV_PAGE then
		-- move to exit page
		page = EXIT_PAGE
		page_index = page_count
		pageChangeReset()
	else
		-- otherwise check for page changes
		page_field = fieldIncDec(event, page_field, 1)
	end
			
	return 0
end

-- Wiring Page
local function drawWiringPage(event)
	-- draw common elements
	lcd.clear()
	lcd.drawScreenTitle("Kiwi-K Wiring Setup", page_index, page_count)
	lcd.drawText(6, 11, "WIRING SETUP", MIDSIZE)
	lcd.drawText(4, 27, "Use the following RX setup:", SMLSIZE)
	lcd.drawLine(2, 36, 125, 36, SOLID, FORCE) 
	lcd.drawText(4, 40, "L DRIVE > CH2 | R DRIVE > CH3", SMLSIZE)

	-- give extra wiring instructions if has_servo or has_motor
	if has_motor and has_servo then
		lcd.drawText(2, 50, "W MOTOR > CH1 | W SERVO > CH4", SMLSIZE)
	elseif has_motor and not has_servo then
		lcd.drawText(2, 50, "W MOTOR > CH1", SMLSIZE)
	elseif has_servo and not has_motor then
		lcd.drawText(2, 50, "W SERVO > CH4", SMLSIZE)
	end
	
	-- handle events
	if event == EVT_VIRTUAL_NEXT_PAGE then
		page_index = page_index + 1
		pageChangeReset()
    	if has_motor then
    		-- if has_motor, move to weapon page
    		page = WEAPON_RADIO_PAGE
    	elseif has_servo then
    		-- if not has_motor, but has_servo, to servo page
    		page = SERVO_RADIO_PAGE	
    	else
    		-- otherwise move to drive page
    		page = DRIVE_RADIO_PAGE
    	end
    elseif event == EVT_VIRTUAL_PREV_PAGE then
    	-- move to query page
    	page_index = page_index - 1
    	page = QUERY_PAGE
    	pageChangeReset()
    end
    
	return 0
end

-- Weapon Radio Page
local function drawWeaponRadioPage(event)
	-- draw common elements
	lcd.clear()
	lcd.drawScreenTitle("Kiwi-K Weapon Setup", page_index, page_count)
	lcd.drawText(6, 11, "WEAPON SETUP", MIDSIZE)
	lcd.drawText(6, 38, "Weapon Input")
	lcd.drawRectangle(80, 36, 27, 11)
	lcd.drawRectangle(78, 34, 31, 15)
	
	-- draw input if one is selected
	if motor_list_index == 0 then
		lcd.drawText(82, 38, "----")
	else
		lcd.drawText(82, 38, source_list[motor_list_index] or "----")
		drawCheck(113, 38)
	end
	
	-- handle events
	if event == EVT_VIRTUAL_ENTER then
		-- toggle editing mode
		is_editing = not is_editing
	elseif is_editing then
		-- handle events to get TX inputs
		lcd.drawRectangle(79, 35, 29, 13)
		if event == EVT_VIRTUAL_NEXT then
	    	motor_list_index = (motor_list_index + 1) % #source_list
	    elseif event == EVT_VIRTUAL_PREV then
	    	motor_list_index = (motor_list_index - 1 + #source_list) % #source_list
	    else
	    	if getLastTXInput() then
	    		motor_list_index = last_moved
	    	end
	    end
	 end
	    	
	-- page change events
	if event == EVT_VIRTUAL_NEXT_PAGE then
    	page_index = page_index + 1
    	pageChangeReset()
    	if has_servo then
    		-- if has_servo then move to servo page
    		page = SERVO_RADIO_PAGE
    	else
    		-- if not has_servo, move to safety page
    		page = SAFETY_RADIO_PAGE
    	end
    elseif event == EVT_VIRTUAL_PREV_PAGE then
    	-- move back to wiring page
    	page_index = page_index - 1
    	page = WIRING_PAGE
    	pageChangeReset()
    end    
	return 0
end

-- Servo Radio Page
local function drawServoRadioPage(event)
	-- draw common elements
	lcd.clear()
	lcd.drawScreenTitle("Kiwi-K Servo Setup", page_index, page_count)
	lcd.drawText(6, 11, "SERVO SETUP", MIDSIZE)
	lcd.drawText(7, 30, "Servo Input")
	lcd.drawText(9, 45, "Disarm Pos.")
	lcd.drawRectangle(80, 28, 27, 11)
	lcd.drawRectangle(80, 43, 27, 11)
	
	-- draw elements if servo input selected
	if servo_list_index == 0 then
		lcd.drawText(82, 30, "----")
		lcd.drawText(82, 45, "----")
	else
		lcd.drawText(82, 30, source_list[servo_list_index] or "----")
		lcd.drawText(82, 45, servo_center_pos or "----")
		drawCheck(113, 30)
		drawCheck(113, 45) 
	end
	
	-- draw selection box based on page_field
	if page_field == 0 then
		lcd.drawRectangle(78, 26, 31, 15)
	else
		lcd.drawRectangle(78, 41, 31, 15)
	end	
	
	-- handle events
	if event == EVT_VIRTUAL_ENTER then
		-- draw selection boxes with editing toggle
		if page_field == 0 then
			is_editing = not is_editing
		elseif page_field == 1 and servo_list_index ~= 0 then
			is_editing = not is_editing
		end
	elseif is_editing then
		-- handle input selection
		if page_field == 0 then
			lcd.drawRectangle(79, 27, 29, 13)
			if event == EVT_VIRTUAL_NEXT then
		    	servo_list_index = (servo_list_index + 1) % #source_list
		    elseif event == EVT_VIRTUAL_PREV then
		    	servo_list_index = (servo_list_index - 1 + #source_list) % #source_list
		    else
		    	if getLastTXInput() then
		    		servo_list_index = last_moved
		    	end
		    end
		else
			-- handle center pos. selection
			if servo_list_index ~= 0 then
				lcd.drawRectangle(79, 42, 29, 13)
				if event == EVT_VIRTUAL_NEXT then
			    	if servo_center_pos < 100 then
			    		servo_center_pos = servo_center_pos + 5
			    	end
			    elseif event == EVT_VIRTUAL_PREV then
			    	if servo_center_pos > -100 then
			    		servo_center_pos = servo_center_pos - 5
			    	end
			    end
			end
		end
	else
		page_field = fieldIncDec(event, page_field, 1)
	end
	
	-- handle page changes
	if event == EVT_VIRTUAL_NEXT_PAGE then
		-- move to safety page
    	page_index = page_index + 1
    	page = SAFETY_RADIO_PAGE
    	pageChangeReset()
    elseif event == EVT_VIRTUAL_PREV_PAGE then
    	page_index = page_index - 1
    	pageChangeReset()
    	if has_motor then
    		-- move to weapon page
    		page = WEAPON_RADIO_PAGE
    	else
    		-- move to wiring page
    		page = WIRING_PAGE
    	end
    end    
	return 0
end

-- Safety Radio Page
local function drawSafetyRadioPage(event)
	-- draw common elements
	lcd.clear()
	lcd.drawScreenTitle("Kiwi-K Safety Setup", page_index, page_count)
	lcd.drawText(6, 11, "SAFETY SETUP", MIDSIZE)
	lcd.drawText(6, 38, "Safety Input")
	lcd.drawText(6, 47, "(Disarmed Pos.)", SMLSIZE)
	lcd.drawRectangle(80, 36, 27, 11)
	lcd.drawRectangle(78, 34, 31, 15)
	
	-- draw selected safety switch if applicable
	if safety_list_index == 0 then
		lcd.drawText(82, 38, "----")
	else
		lcd.drawText(82, 38, switch_list[safety_list_index] or "----")
		drawCheck(113, 38)
	end
	
	-- handle events
	if event == EVT_VIRTUAL_ENTER then
		-- toggle editing mode
		is_editing = not is_editing
	elseif is_editing then
		-- handle switch input selection for safety
		lcd.drawRectangle(79, 35, 29, 13)
		if event == EVT_VIRTUAL_NEXT then
	    	safety_list_index = (safety_list_index + 1) % #switch_list
	    elseif event == EVT_VIRTUAL_PREV then
	    	safety_list_index = (safety_list_index - 1 + #switch_list) % #switch_list
	    else
	    	if getLastTXSwitch() then
	    		safety_list_index = last_moved
	    	end
	    end
	 end
	
	-- handle page changes
	if event == EVT_VIRTUAL_NEXT_PAGE then
		-- move to drive page
    	page_index = page_index + 1
    	page = DRIVE_RADIO_PAGE
    	pageChangeReset()
    elseif event == EVT_VIRTUAL_PREV_PAGE then
    	page_index = page_index - 1
    	pageChangeReset()
    	if has_servo then
    		-- move to servo page
    		page = SERVO_RADIO_PAGE
    	else
    		-- skip to weapon page
    		page = WEAPON_RADIO_PAGE
    	end
    end    
	return 0
end

-- Drive Radio Page
local function drawDriveRadioPage(event)
	-- draw common elements
	lcd.clear()
	lcd.drawScreenTitle("Kiwi-K Drive Setup", page_index, page_count)
	lcd.drawText(6, 11, "DRIVE SETUP", MIDSIZE)
	lcd.drawText(17, 30, "F/B Input")
	lcd.drawText(18, 45, "R/L Input")
	lcd.drawRectangle(80, 28, 27, 11)
	lcd.drawRectangle(80, 43, 27, 11)
	
	-- draw fb input if selected
	if fb_list_index == 0 then
		lcd.drawText(82, 30, "----")
	else
		lcd.drawText(82, 30, source_list[fb_list_index] or "----")
		drawCheck(113, 30)
	end
	
	-- draw lr input if selected
	if lr_list_index == 0 then
		lcd.drawText(82, 45, "----")
	else
		lcd.drawText(82, 45, source_list[lr_list_index] or "----")
		drawCheck(113, 45) 
	end
	
	-- draw selection boxes based on page_field
	if page_field == 0 then
		lcd.drawRectangle(78, 26, 31, 15)
	else
		lcd.drawRectangle(78, 41, 31, 15)
	end	
	
	-- handle events
	if event == EVT_VIRTUAL_ENTER then
		-- toggle editing mode
		is_editing = not is_editing
	elseif is_editing then
		if page_field == 0 then
			-- handle fb input selection
			lcd.drawRectangle(79, 27, 29, 13)
			if event == EVT_VIRTUAL_NEXT then
		    	fb_list_index = (fb_list_index + 1) % #source_list
		    elseif event == EVT_VIRTUAL_PREV then
		    	fb_list_index = (fb_list_index - 1 + #source_list) % #source_list
		    else
		    	if getLastTXInput() then
		    		fb_list_index = last_moved
		    	end
		    end
		else
			-- handle lr input selection
			lcd.drawRectangle(79, 42, 29, 13)
			if event == EVT_VIRTUAL_NEXT then
		    	lr_list_index = (lr_list_index + 1) % #source_list
		    elseif event == EVT_VIRTUAL_PREV then
		    	lr_list_index = (lr_list_index - 1 + #source_list) % #source_list
		    else
		    	if getLastTXInput() then
		    		lr_list_index = last_moved
		    	end
		    end
		end
	else
		-- handle field changes
		page_field = fieldIncDec(event, page_field, 1)
	end
	
	
	if event == EVT_VIRTUAL_NEXT_PAGE then
		-- move to exit page
		page_index = page_index + 1
    	page = EXIT_PAGE
    	pageChangeReset()
    elseif event == EVT_VIRTUAL_PREV_PAGE then	
    	page_index = page_index - 1
    	pageChangeReset()
    	if has_motor or has_servo then
    		-- move to safety page
    		page = SAFETY_RADIO_PAGE
    	else
    		-- otherwise skip to wiring page
    		page = WIRING_PAGE	
    	end
    end    
	return 0
end

-- Exit Page
local function drawExitPage(event)
	-- draw common elements
	lcd.clear()
	lcd.drawScreenTitle("Kiwi-K Finish Setup", page_index, page_count)
	lcd.drawText(6, 11, "FINISH SETUP", MIDSIZE)
	
	-- evaluate if all conditions to save are met (all fields filled)
	local can_save = true
	
	-- check drive inputs are provided
	if lr_list_index == 0 or fb_list_index == 0 then
		can_save = false
	end
	-- if motor exists, check inputs are filled
	if has_motor then
		if motor_list_index == 0 or safety_list_index == 0 then
			can_save = false
		end
	end
	-- if servo exists, check inputs are filled
	if has_servo then
		if servo_list_index == 0 or safety_list_index == 0 then
			can_save = false
		end
	end
	
	if can_save then
		-- if saving is possible, draw text
		lcd.drawText(6, 27, "All fields populated!", SMLSIZE)
		lcd.drawText(6, 37, "Save & Exit to make mix.", SMLSIZE)		
		lcd.drawText(30, 50, "Save and Exit")
		lcd.drawRectangle(28, 48, 73, 11)
		if event == EVT_VIRTUAL_ENTER then
			cleanModel()
			
			-- write inputs to model
			-- weapon input
			if has_motor then
				model.insertInput(0, 0, {name = "Wep", inputName = "Weapon",
				 						source = index_list[motor_list_index], 
				 						weight = 100, offset = 0, switch = 0,
				 						curveType = 0, curveValue = 0, 
				 						carryTrim = true, flightModes = 0})
			end
			-- fb input
			model.insertInput(1, 0, {name = "FB", inputName = "FB",
 						source = index_list[fb_list_index], 
 						weight = fb_weight, offset = 0, switch = 0,
 						curveType = 0, curveValue = 0, 
 						carryTrim = true, flightModes = 0})
 			-- lr input
			model.insertInput(2, 0, {name = "LR", inputName = "LR",
 						source = index_list[lr_list_index], 
 						weight = lr_weight, offset = 0, switch = 0,
 						curveType = 0, curveValue = 0, 
 						carryTrim = true, flightModes = 0})
 			--servo input		
			if has_servo then
				model.insertInput(3, 0, {name = "Ser", inputName = "Servo",
				 						source = index_list[servo_list_index], 
				 						weight = 100, offset = 0, switch = 0,
				 						curveType = 0, curveValue = 0, 
				 						carryTrim = true, flightModes = 0})
			end
			
			-- write mixes to model
			-- weapon mix
			if has_motor then
				model.insertMix(0, 0, {name = "Weapon", source = 1, 
				 						weight = 100, offset = 0, switch = 0, 
				 						multiplex = 2, flightModes = 0})
			end
			-- l motor mix
			model.insertMix(1, 0, {name = "FB", source = 2, 
				 					weight = 100, offset = 0, switch = 0, 
				 					multiplex = 2, flightModes = 0})
			model.insertMix(2, 0, {name = "FB", source = 2, 
				 					weight = 100, offset = 0, switch = 0, 
				 					multiplex = 2, flightModes = 0})
			-- r motor mix
			model.insertMix(1, 1, {name = "LR", source = 3, 
				 					weight = 100, offset = 0, switch = 0, 
				 					multiplex = 0, flightModes = 0})
			model.insertMix(2, 1, {name = "LR", source = 3, 
				 					weight = -100, offset = 0, switch = 0, 
				 					multiplex = 0, flightModes = 0})
			-- servo mix				 					
			if has_servo then
				model.insertMix(3, 0, {name = "Servo", source = 4, 
				 						weight = 100, offset = 0, switch = 0, 
				 						multiplex = 2, flightModes = 0})	 						
			end
			
			-- write safety overrides to model
			-- motor safety
			if has_motor then
				model.setCustomFunction(0, {switch = switch_index_list[safety_list_index],
										func = FUNC_OVERRIDE_CHANNEL, param = 0, 
										value = -100, active = 1})
			end
			-- servo safety
			if has_servo then
				model.setCustomFunction(3, {switch = switch_index_list[safety_list_index],
										func = FUNC_OVERRIDE_CHANNEL, param = 3, 
										value = servo_center_pos, active = 1})
			end			
			return 2
		end
	else
		-- if conditions not met, draw warning
		lcd.drawText(6, 27, "Populate all fields to", SMLSIZE)
		lcd.drawText(6, 37, "save and exit properly.", SMLSIZE)
		
		lcd.drawText(28, 50, "Exit (No Save)")
		lcd.drawRectangle(26, 48, 75, 11)
		-- exit without saving when conditions not met
		if event == EVT_VIRTUAL_ENTER then
			return 2
		end
	end
	
	-- handle page events
	if event == EVT_VIRTUAL_NEXT_PAGE then
		-- wrap to query page
    	page_index = 1
    	page = QUERY_PAGE
    	pageChangeReset()
    elseif event == EVT_VIRTUAL_PREV_PAGE then
    	-- move to drive page
    	page_index = page_index - 1
    	page = DRIVE_RADIO_PAGE
    	pageChangeReset()
    end    
	return 0
end



-- script start init
local function init()
	-- build lists on script start
    buildSourceList()
    buildSwitchList()
end

-- main run function
local function run(event)
	updatePageCount()
	
	-- draw current page
	if page == INTRO_PAGE then
		drawIntroPage(event)
	elseif page == QUERY_PAGE then
		drawQueryPage(event)
	elseif page == WIRING_PAGE then
		drawWiringPage(event)
	elseif page == WEAPON_RADIO_PAGE then
		drawWeaponRadioPage(event)
	elseif page == SERVO_RADIO_PAGE then
		drawServoRadioPage(event)
	elseif page == SAFETY_RADIO_PAGE then
		drawSafetyRadioPage(event)
	elseif page == DRIVE_RADIO_PAGE then
		drawDriveRadioPage(event)			
	elseif page == EXIT_PAGE then
		return drawExitPage(event)			
	end  	
	
  	return 0
end

return { run = run, init = init }