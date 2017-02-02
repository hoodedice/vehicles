Vehicles = {
	DEBUG = true,
	STOP_THRESHOLD = 0.05,
	path = minetest.get_modpath(minetest.get_current_modname()),
}



dofile(Vehicles.path .. "/physics.lua")
dofile(Vehicles.path .. "/api.lua")

Vehicles.register_vehicle("vehicles_api:test", {
	mesh = "car_001.obj",
	textures = {"textur_yellow.png"},
	collisionbox = {-0.6, 0.0, -1.85, 1.4, 1.25, 1.25},
	seats = 1
})
