local toolName = "TNS|Kiwi-K Mixer|TNE"

local function init() 
end

local function run(event)    
    chdir("/SCRIPTS/KIWIK")
    return "/SCRIPTS/KIWIK/menu.lua"
end

return {init = init, run = run}
