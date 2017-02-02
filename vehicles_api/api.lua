local Roles = {
	NONE = 0,
	PASSENGER = 1,
	DRIVER = 2
}

local vehicle = {
	initial_properties = {
		hp_max = 100,
		physical = true,
		visual = "mesh",
		mesh = nil,
		visual_size = {x = 1, y = 1},
		textures = nil,
		collisionbox = nil,
		stepheight = 0.6,
		-- automatic_face_movement_dir = 0.0
	},
	driver = nil,
	passengers = {},
	meta = {inventory = {}, fields = {}},
	force = vector.new(0, 0, 0),
	accelerator_pedal = 0.0,
	brake_pedal = 0.0,
	parking_brake = 0,
	clutch_pedal = 0.0,
	gear = 1,
	rpm = 0,
	hud = {
		debug = {
			speed = nil,
			brake_pedal = nil,
			accelerator_pedal = nil,
			parking_brake = nil,
			clutch_pedal = nil,
			gear = nil,
			rpm = nil
		}
	}
}

function Vehicles.register_vehicle(name, vehicle_definition)
	if Vehicles.validate_vehicle_definition(vehicle_definition) then
		local entity_definition = vehicle
		entity_definition.mesh = vehicle_definition.mesh
		entity_definition.textures = vehicle_definition.textures
		entity_definition.collisionbox = vehicle_definition.collisionbox

		minetest.register_entity(name, entity_definition)
	end
end

function Vehicles.validate_vehicle_definition(vehicle_definition)
	return true
end

function vehicle:get_weigth()
	return 850
end

function vehicle:clear_force()
	self.force = vector.new(0, 0, 0)
end

function vehicle:add_force(force)
	self.force = vector.add(self.force, force)
end

function vehicle:add_gravity()
	-- F_g = g * m
	self:add_force(vector.new(0, Gravity.EARTH * self:get_weigth(), 0))
end

function vehicle:apply_acceleration()
	-- F = m * a <=> a = F / m
	self.object:setacceleration(vector.divide(self.force, self:get_weigth()))
end

function vehicle:get_player_role(name)
	if self.driver == name then return Roles.DRIVER end

	for index, player in ipairs(self.passengers) do
		if true then return Roles.PASSENGER end
	end

	return Roles.NONE
end

function vehicle:get_passenger_count()
	return #self.passengers
end

function vehicle:has_driver()
	return self.driver ~= nil
end

function vehicle:get_driver()
	if self:has_driver() then
		return minetest.get_player_by_name(self.driver)
	end
end

function vehicle:debug_init(driver)
	if Vehicles.DEBUG then
		self.hud.debug.speed = driver:hud_add({
			hud_elem_type = "text",
			position = {x = 0.05, y = 0.8},
			name = "Speed",
			scale = {x = 1,y = 1},
			text = "foo",
			number = 0xFFFFFF,
			alignment = {x = 1, y = 0}
		})
		self.hud.debug.accelerator_pedal = driver:hud_add({
			hud_elem_type = "text",
			position = {x = 0.05, y = 0.78},
			name = "Accelerator Pedal",
			scale = {x = 0.2,y = 1},
			text = "foo",
			number = 0xFFFFFF,
			alignment = {x = 1, y = 0}
		})
		self.hud.debug.brake_pedal = driver:hud_add({
			hud_elem_type = "text",
			position = {x = 0.05, y = 0.76},
			name = "Brake Pedal",
			scale = {x = 0.2,y = 1},
			text = "foo",
			number = 0xFFFFFF,
			alignment = {x = 1, y = 0}
		})
		self.hud.debug.clutch_pedal = driver:hud_add({
			hud_elem_type = "text",
			position = {x = 0.05, y = 0.74},
			name = "Brake Pedal",
			scale = {x = 0.2,y = 1},
			text = "foo",
			number = 0xFFFFFF,
			alignment = {x = 1, y = 0}
		})
		self.hud.debug.parking_brake = driver:hud_add({
			hud_elem_type = "text",
			position = {x = 0.05, y = 0.72},
			name = "Clutch Pedal",
			scale = {x = 0.2,y = 1},
			text = "foo",
			number = 0xFFFFFF,
			alignment = {x = 1, y = 0}
		})
		self.hud.debug.gear = driver:hud_add({
			hud_elem_type = "text",
			position = {x = 0.05, y = 0.70},
			name = "Gear",
			scale = {x = 0.2,y = 1},
			text = "foo",
			number = 0xFFFFFF,
			alignment = {x = 1, y = 0}
		})
		self.hud.debug.rpm = driver:hud_add({
			hud_elem_type = "text",
			position = {x = 0.05, y = 0.68},
			name = "RPM",
			scale = {x = 0.2,y = 1},
			text = "foo",
			number = 0xFFFFFF,
			alignment = {x = 1, y = 0}
		})
	end
end

function vehicle:debug_refresh(id, prefix, value)
	self:get_driver():hud_change(id, "text", prefix .. ": " .. value)
end

function vehicle:debug_destroy(driver)
	if Vehicles.DEBUG then
		for _, v in pairs(self.hud.debug) do
			driver:hud_remove(v)
		end
	end
end

function vehicle:get_engine_torque()
	-- Nm
	return 143
end

function vehicle:get_thrust()
	return self.accelerator_pedal
end

function vehicle:get_brake()
	return self.brake_pedal
end

function vehicle:get_clutch()
	return self.clutch_pedal
end

function vehicle:get_active_gear()
	return self.gear
end

function vehicle:get_gearbox_efficiency()
	return 0.7
end

function vehicle:get_gearbox_translation(gear)
	local gears = {
		[-1] = -2.7,
		[0] = 0,
		[1] = 2.9,
		[2] = 1.9,
		[3] = 1.4,
		[4] = 1.1,
		[5] = 0.9,
		[6] = 0.7
	}
	return self:get_gearbox_efficiency() * gears[gear]
end

function vehicle:get_diffrential_translation()
	return 3.8
end

function vehicle:get_wheel_radius()
	return 0.3
end

function vehicle:get_projected_front_area()
	return 4.2
end

function vehicle:get_cw()
	return 0.78
end

function vehicle:get_speed()
	return vector.length(self.object:getvelocity())
end

function vehicle:handle_accelerator_pedal(ctrl, dtime)
	if ctrl.up and not ctrl.down then
		if self.accelerator_pedal < 1.0 then
			local leadfoot = ctrl.aux1 and 3 or 0.75
			self.accelerator_pedal = self.accelerator_pedal + leadfoot * dtime
		end
		if self.accelerator_pedal > 1.0 then
			self.accelerator_pedal = 1.0
		end
	else
		if self.accelerator_pedal > 0.0 then
			self.accelerator_pedal = self.accelerator_pedal - 2 * dtime
		end
		if self.accelerator_pedal < 0.0 then
			self.accelerator_pedal = 0.0
		end
	end
end

function vehicle:handle_brake_pedal(ctrl, dtime)
	if ctrl.down and not ctrl.up then
		if self.brake_pedal < 1.0 then
			self.brake_pedal = self.brake_pedal + 0.75 * dtime
		end
		if self.brake_pedal > 1.0 then
			self.brake_pedal = 1.0
		end
	else
		if self.brake_pedal > 0.0 then
			self.brake_pedal = self.brake_pedal - 2 * dtime
		end
		if self.brake_pedal < 0.0 then
			self.brake_pedal = 0.0
		end
	end
end

function vehicle:handle_clutch_pedal(ctrl, dtime)
	if ctrl.sneak then
		if self.clutch_pedal < 1.0 then
			self.clutch_pedal = self.clutch_pedal + 4 * dtime
		end
		if self.clutch_pedal > 1.0 then
			self.clutch_pedal = 1.0
		end
	else
		if self.clutch_pedal > 0.0 then
			self.clutch_pedal = self.clutch_pedal - 2 * dtime
		end
		if self.clutch_pedal < 0.0 then
			self.clutch_pedal = 0.0
		end
	end
end

function vehicle:handle_parking_brake(ctrl)
	if ctrl.jump then
		self.parking_brake = 1
	else
		self.parking_brake = 0
	end
end

function vehicle:on_step(dtime)
	self:add_gravity()

	if self:has_driver() then
		local ctrl = self:get_driver():get_player_control()

		-- self:handle_clutch_pedal(ctrl, dtime)
		self:handle_accelerator_pedal(ctrl, dtime)
		self:handle_brake_pedal(ctrl, dtime)
		self:handle_parking_brake(ctrl)
	end

	local wheel_force = self:get_engine_torque() * (1 - self:get_clutch()) *
			self:get_thrust() * self:get_gearbox_translation(self:get_active_gear()) *
			self:get_diffrential_translation() / self:get_wheel_radius()

	self:add_force(vector_from_length(wheel_force, self.object:getyaw()))

	-- AIR RESISTANCE
	--	= 0.5 Cw rho A v²
	--	Cw = 0.78 (Mercedes W 463)
	--	rho = 1.2 kg/m^3 (sea level)
	--	A = projected front area of the car
	--	v = speed
	self:add_force(vector.multiply(self.object:getvelocity(),	-0.5 * self:get_cw() * Density.AIR * self:get_projected_front_area() * vector.length(self.object:getvelocity())))

	if self:get_speed() > 0 then
		self:add_force(vector.multiply(self.object:getvelocity(), -100))
	end

	-- Stop when speed < 0.5
	if self:get_speed() < Vehicles.STOP_THRESHOLD then
		self.object:setvelocity(vector.new(0, 0, 0))
	end

	if Vehicles.DEBUG and self:has_driver() then
		self:debug_refresh(self.hud.debug.speed, "Speed", vector.length(self.object:getvelocity()))
		self:debug_refresh(self.hud.debug.accelerator_pedal, "Accelerator Pedal", self.accelerator_pedal)
		self:debug_refresh(self.hud.debug.brake_pedal, "Brake Pedal", self.brake_pedal)
		self:debug_refresh(self.hud.debug.parking_brake, "Parking Brake", self.parking_brake)
		self:debug_refresh(self.hud.debug.clutch_pedal, "Clutch Pedal", self.clutch_pedal)
		self:debug_refresh(self.hud.debug.gear, "Gear", self.gear)
		self:debug_refresh(self.hud.debug.rpm, "RPM", self.rpm)
	end

	self:apply_acceleration()
	self:clear_force()
end

function vehicle:on_rightclick(clicker)
	local name = clicker:get_player_name()

	if not self:has_driver() then
		self.driver = name
		clicker:set_attach(self.object, "", {x = 0, y = -5, z = 0}, {x = 0, y = 0, z = 0})
		clicker:hud_set_flags({
			hotbar = false,
			healthbar = false,
			crosshair = false,
			wielditem = false
		})
		vehicle:debug_init(clicker)
	else
		self.driver = nil
		clicker:set_detach()
		clicker:hud_set_flags({
			hotbar = true,
			healthbar = true,
			crosshair = true,
			wielditem = true
		})
		self.object:setvelocity(vector.new(0, 0, 0))
		vehicle:debug_destroy(clicker)
	end

end
