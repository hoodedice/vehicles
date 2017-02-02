Vehicles = {
	DEBUG = true,
	STOP_THRESHOLD = 0.05,
	path = minetest.get_modpath(minetest.get_current_modname()),
}

dofile(Vehicles.path .. "/physics.lua")
dofile(Vehicles.path .. "/api.lua")
