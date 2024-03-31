local M = {}

function M.is_module_available(name)
	if package.loaded[name] then
		return true
	else
		for _, searcher in ipairs(package.searchers) do
			local loader = searcher(name)
			if type(loader) == "function" then
				package.preload[name] = loader
				return true
			end
		end
		return false
	end
end

function M.is_array(table)
	return #table == 0 or table[1] ~= nil
end

function M.get_table_keys(table)
	local r = {}
	for k, _ in pairs(table) do
		r[#r + 1] = k
	end
	return r
end

function M.get_table_values(table)
	local r = {}
	for _, v in pairs(table) do
		r[#r + 1] = v
	end
	return r
end

function M.flat_map(lists)
	local r = {}
	for _, list in pairs(lists) do
		if type(list) == "table" then
			for _, nv in pairs(list) do
				r[#r + 1] = nv
			end
		else
			r[#r + 1] = list
		end
	end
	return r
end

function M.concat_arrays(a1, a2)
	if not M.is_array(a1) then
		error("Argument 1 is not array")
	end
	if not M.is_array(a2) then
		error("Argument 2 is not array")
	end

	local r = {}
	for _, v in pairs(a1) do
		r[#r + 1] = v
	end
	for _, v in pairs(a2) do
		r[#r + 1] = v
	end

	return r
end

return M
