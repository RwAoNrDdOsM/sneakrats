local mod = get_mod("sneakrats")

mod:dofile("scripts/mods/sneakrats/patrols")
mod:dofile("scripts/mods/sneakrats/gutterrunners")

local CLASS_NAME = 1

local function create_btnode_from_lua_node(lua_node, parent_btnode)
	local class_name = lua_node[CLASS_NAME]
	local identifier = lua_node.name
	local condition_name = lua_node.condition or "always_true"
	local enter_hook_name = lua_node.enter_hook
	local leave_hook_name = lua_node.leave_hook
	local action_data = lua_node.action_data
	local class_type = rawget(_G, class_name)

	if not class_type then
		fassert(false, "BehaviorTree: no class registered named( %q )", tostring(class_name))
	else
		return class_type:new(identifier, parent_btnode, condition_name, enter_hook_name, leave_hook_name, lua_node), action_data
	end
end

mod:hook_origin(BehaviorTree, "parse_lua_node", function (self, lua_node, parent)
	local num_children = #lua_node

	for i = 2, num_children, 1 do
		local child = lua_node[i]
		local bt_node, action_data = create_btnode_from_lua_node(child, parent)

		if action_data then
			self._action_data[action_data.name] = action_data
		end

		fassert(bt_node.name, "Behaviour tree node with parent %q is missing name", lua_node.name)

		if parent then
			parent:add_child(bt_node)
		end

		self:parse_lua_node(child, bt_node)
	end

	if parent.ready then
		parent:ready(lua_node)
	end
end)