Gravity = {
	EARTH = -9.81
}

Density = {
	AIR = 1.2
}

function F_g(m)
	return Gravity.EARTH * m
end

function F_n(angle, F_g)
	return math.cos(angle) * F_g
end

function F_rr(u_rr, F_n, r)
	return u_rr * F_n / r
end

function vector_from_length(length, angle)
	local v = vector.new(0, 0, 0)
	v.x = length * math.sin(angle)
	v.z = length * math.sin(90 - angle)
	return v
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end
