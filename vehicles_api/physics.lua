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

function vector_from_length(force, angle)
	local v = vector.new(0, 0, 0)
	v.x = force * math.sin(angle)
	v.z = force * math.sin(90 - angle)
	return v
end
