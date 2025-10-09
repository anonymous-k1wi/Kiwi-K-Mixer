--	 |  / _)         _)       |  /     \  | _)                 
--	 . <   | \ \  \ / | ____| . <     |\/ |  | \ \ /   -_)   _|
--	_|\_\ _|  \_/\_/ _|      _|\_\   _|  _| _|  _\_\ \___| _|  
---------------------------------------------------------------
-- Kiwi-K Model Editor
-- This script updates a robot mix, allowing for 
-- the user to change mix settings.  

-- page tracking variables
local page = 0
local page_field = 0
local field_count = 4
local is_editing = false

-- input weights
local fb_weight = 100
local lr_weight = 30

-- mix weights
local l_1_mix_weight = 100
local l_2_mix_weight = 100

local r_1_mix_weight = 100
local r_2_mix_weight = -100

-- invert tracking variables
local lr_invert = false
local l_motor_invert = false
local r_motor_invert = false

-- servo variables
local has_servo = false
local servo_center = 0

-- determine if model has servo
local function servoFind()
	local info = model.getInput(3, 0)
	if info and info.source then
		-- set to true and increase count
		has_servo = true
		field_count = 5
	end
end

-- resign negative values read from model
function resignInt(weight)
  if weight > 100 then
    return weight - 1024
  else
    return weight
  end
end

-- read model settings to change
local function readModel()
	-- get fb weight
	local info_fb = model.getInput(1, 0)
	if info_fb and info_fb.weight then
		fb_weight = info_fb.weight
	end
	
	-- get lr weight (absolute), determine negation
	local info_lr = model.getInput(2, 0)
	if info_lr and info_lr.weight then
		lr_weight = resignInt(info_lr.weight)
		if lr_weight < 0 then
			lr_invert = true
		end
		lr_weight = math.abs(lr_weight)
	end
	
	-- left motor mix settings
	local info_l = model.getMix(1, 0)
	if info_l and info_l.weight then
		l_1_mix_weight = resignInt(info_l.weight)
		if l_1_mix_weight < 0 then
			l_motor_invert = true
		end
	end
	local info_l = model.getMix(1, 1)
	if info_l and info_l.weight then
		l_2_mix_weight = resignInt(info_l.weight)
	end	
	
	-- right motor mix settings
	local info_r = model.getMix(2, 0)
	if info_r and info_r.weight then
		r_1_mix_weight = resignInt(info_r.weight)
		if r_1_mix_weight < 0 then
			r_motor_invert = true
		end
	end
	local info_r = model.getMix(2, 1)
	if info_r and info_r.weight then
		r_2_mix_weight = resignInt(info_r.weight)
	end	
		
	-- if servo exists, get center safety value	
	if has_servo then
		local info_servo = model.getCustomFunction(3)
		if info_servo and info_servo.value then
			servo_center = info_servo.value
		end
	end			
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

local function init()
	-- read model settings
    servoFind()
    readModel()
end

------------------- PAGES -------------------
-- Intro Page
local function drawIntroPage(event)
	-- draw user warning
	lcd.clear()
	lcd.drawScreenTitle("Kiwi-K Mixer", 0, 0)
	lcd.drawText(6, 11, "WARNING!", MIDSIZE, BLINK)
	lcd.drawText(6, 27, "Set up model with Kiwi-K", SMLSIZE)
	lcd.drawText(6, 37, "before updating settings!", SMLSIZE)
	lcd.drawText(6, 47, "Use page to continue. >>", SMLSIZE)
	
	-- if user continues, move to next page
	if event == EVT_VIRTUAL_NEXT_PAGE then
    	page = 1
    end
    
	return 0
end

-- Editor Page
local function drawEditorPage(event)
	-- draw common elements
	lcd.clear()
	lcd.drawScreenTitle("Kiwi-K Robot Editor", 0, 0)
	lcd.drawText(6, 10, "Invert L Motor")
	lcd.drawRectangle(104, 10, 7, 7)
	lcd.drawText(6, 19, "Invert R Motor")
	lcd.drawRectangle(104, 19, 7, 7)
	lcd.drawText(6, 28, "Invert Steering")
	lcd.drawRectangle(104, 28, 7, 7)
	lcd.drawText(6, 37, "Straight Speed")
	lcd.drawText(100, 37, fb_weight or '---')
	lcd.drawText(6, 46, "Steering Speed")
	lcd.drawText(100, 46, lr_weight or '---')
	
	-- draw servo elements if model has servo
  	if has_servo then
  		lcd.drawText(6, 55, "Servo Disarm Pos.")
  		lcd.drawText(100, 55, servo_center or '---')
  	end
  	  	
  	-- if elements are inverted, draw check
 	if l_motor_invert then
  		drawCheck(104, 10)
  	end
  	if r_motor_invert then
  		drawCheck(104, 19)
  	end    	
  	if lr_invert then
  		drawCheck(104, 28)
  	end 	
  	
  	-- field handler
  	if page_field == 0 then
  		-- draw selection box
  		lcd.drawRectangle(104, 10, 7, 7)
  		lcd.drawFilledRectangle(104, 10, 7, 7)
  		
  		if event == EVT_VIRTUAL_ENTER then
  			-- invert l motor mix
  			l_motor_invert = not l_motor_invert
  			l_1_mix_weight = -1*l_1_mix_weight
  			l_2_mix_weight = -1*l_2_mix_weight
			
			-- read exisiting mix values, update weight
			local l_1_table = model.getMix(1, 0)
  			l_1_table.weight = l_1_mix_weight
  			local l_2_table = model.getMix(1, 1)
  			l_2_table.weight = l_2_mix_weight
  			
  			-- delete mix lines
  			model.deleteMix(1, 1)
  			model.deleteMix(1, 0)
  			
  			-- write mix lines
	  		model.insertMix(1, 0, l_1_table)
			model.insertMix(1, 1, l_2_table)
		end
				 		
  	elseif page_field == 1 then
  		-- draw selection box
  		lcd.drawRectangle(104, 19, 7, 7)
  		lcd.drawFilledRectangle(104, 19, 7, 7)
  		
  		if event == EVT_VIRTUAL_ENTER then
  			-- invert r motor mix
  			r_motor_invert = not r_motor_invert
  			r_1_mix_weight = -1*r_1_mix_weight
  			r_2_mix_weight = -1*r_2_mix_weight
  			
  			-- read exisiting mix values, update weight
  			local r_1_table = model.getMix(2, 0)
  			r_1_table.weight = r_1_mix_weight
  			local r_2_table = model.getMix(2, 1)
  			r_2_table.weight = r_2_mix_weight
  			
  			-- delete mix lines
  			model.deleteMix(2, 1)
  			model.deleteMix(2, 0)
  			
  			-- write mix lines
	  		model.insertMix(2, 0, r_1_table)
			model.insertMix(2, 1, r_2_table)
		end
		
  	elseif page_field == 2 then
  		-- draw selection box
   		lcd.drawRectangle(104, 28, 7, 7)
  		lcd.drawFilledRectangle(104, 28, 7, 7)
  		
  		if event == EVT_VIRTUAL_ENTER then
  			-- toggle editing mode
  			lr_invert = not lr_invert
  			
  			-- read input settings
  			local lr_table = model.getInput(2, 0)
  			model.deleteInput(2, 0)
  			
  			-- invert weight settings
  			if lr_invert then
  				lr_table.weight = -1*lr_weight
  			else
  				lr_table.weight = lr_weight
  			end
  			
  			-- write input to model
  			model.insertInput(2, 0, lr_table)
		end

  	elseif page_field == 3 then
  		-- draw selection box, editing box
    	if is_editing then
	    	lcd.drawFilledRectangle(99, 36, 17, 9)
	    	-- edit fb_weight values
	    	if event == EVT_VIRTUAL_NEXT then
				if fb_weight < 100 then
					fb_weight = fb_weight + 1
				end
			elseif event == EVT_VIRTUAL_PREV then
				if fb_weight > 1 then
			   		fb_weight = fb_weight - 1
			   	end
			end
		else 
			lcd.drawRectangle(98, 35, 19, 11)   	
		end	
    	
    	if event == EVT_VIRTUAL_ENTER then
  			if is_editing then
  				-- when exiting edit mode, write settings back to model
  			  	local fb_table = model.getInput(1, 0)
	  			model.deleteInput(1, 0)
	  			fb_table.weight = fb_weight
	  			model.insertInput(1, 0, fb_table)
	  			is_editing = not is_editing
	  		else 
	  			-- toggle edit mode
	  			is_editing = not is_editing
	  		end
		end
  		
  	elseif page_field == 4 then
  		-- draw selection box, editing box
    	if is_editing then
	    	lcd.drawFilledRectangle(99, 45, 17, 9)
	    	-- edit lr_weight values
	    	if event == EVT_VIRTUAL_NEXT then
				if lr_weight < 100 then
					lr_weight = lr_weight + 1
				end
			elseif event == EVT_VIRTUAL_PREV then
				if lr_weight > 1 then
			   		lr_weight = lr_weight - 1
			   	end
			end
		else 
			lcd.drawRectangle(98, 44, 19, 11)   	
		end	
    	
    	if event == EVT_VIRTUAL_ENTER then
  			if is_editing then
  			  	-- when exiting edit mode, write settings back to model
  			  	local lr_table = model.getInput(2, 0)
	  			model.deleteInput(2, 0)
	  			if lr_invert then
	  				lr_table.weight = -1*lr_weight
	  			else
	  				lr_table.weight = lr_weight
	  			end
	  			model.insertInput(2, 0, lr_table)
	  			is_editing = not is_editing
	  		else 
	  			-- toggle edit mode
	  			is_editing = not is_editing
	  		end
		end

  	else
  		-- draw selection box, editing box
    	if is_editing then
	    	lcd.drawFilledRectangle(99, 54, 22, 9)
	    	-- edit servo_center values
	    	if event == EVT_VIRTUAL_NEXT then
				if servo_center < 100 then
					servo_center = servo_center + 1
				end
			elseif event == EVT_VIRTUAL_PREV then
				if servo_center > -100 then
			   		servo_center = servo_center - 1
			   	end
			end
		else 
			lcd.drawRectangle(98, 53, 24, 11)   	
		end	
    	
    	if event == EVT_VIRTUAL_ENTER then
  			if is_editing then
  			  	-- when exiting edit mode, write settings back to model
  			  	local servo_table = model.getCustomFunction(3)
	  			servo_table.value = servo_center
	  			model.setCustomFunction(3, servo_table)
	  			is_editing = not is_editing
	  		else
	  			-- toggle edit mode
	  			is_editing = not is_editing
	  		end
		end
  	end
  	
  	-- quit if exit event
	if event == EVT_VIRTUAL_EXIT then
		return 2
	end
	
	-- handle field changes if not editing
	if not is_editing then 
		page_field = fieldIncDec(event, page_field, field_count)
	end
	
	return 0
end

local function run(event)
	-- draw current page
	if page == 0 then
		drawIntroPage(event)
	else			
		drawEditorPage(event)
	end  
	
	return 0
end

return { run = run, init = init }