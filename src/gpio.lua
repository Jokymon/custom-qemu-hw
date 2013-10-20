
-- very basic (without any useful function) demonstration of a script
-- to be used by the special GPIO device 'pl061bbv'.

function gpio_set(id, val)
	print("Inside LUA: gpio " .. id .. " set to " .. val)
end

function gpio_get(id)
	print("Inside LUA: gpio " .. id .. " get")
	return 0
end

print("gpio init")

