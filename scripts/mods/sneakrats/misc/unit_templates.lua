local mod = get_mod("sneakrats")

unit_templates.ai_unit_gutter_runner = {
	base_template = "ai_unit_base",
	go_type = "ai_unit_gutter_runner",
	self_owned_extensions = {
		"AiHeroicEnemyExtension",
		"AIInventoryExtension",
		"PingTargetExtension",
		"EnemyOutlineExtension"
	},
	husk_extensions = {
		"AiHeroicEnemyExtension",
		"AIInventoryExtension",
		"PingTargetExtension",
		"EnemyOutlineExtension"
	}
}

local extension_table_names = {
	"self_owned_extensions",
	"self_owned_extensions_server",
	"husk_extensions",
	"husk_extensions_server"
}
local extension_table_names_n = #extension_table_names

for unit_template_name, template_data in pairs(unit_templates) do
	template_data.NAME = unit_template_name

	for i = 1, extension_table_names_n, 1 do
		local extension_table_name = extension_table_names[i]
		local extension_list = template_data[extension_table_name] or {}
		local extension_list_n = #extension_list

		if template_data.base_template ~= nil then
			local inherited_template_name = template_data.base_template
			local inherited_template_data = unit_templates[inherited_template_name]

			assert(inherited_template_data.base_template == nil, "%s tried to inherit from template that had a base_template", unit_template_name)

			local inherited_extension_list = inherited_template_data[extension_table_name]

			if inherited_extension_list then
				inherited_extension_list_n = #inherited_extension_list

				for j = 1, inherited_extension_list_n, 1 do
					extension_list_n = extension_list_n + 1
					extension_list[extension_list_n] = inherited_extension_list[j]
				end
			end

			local inherited_remove_when_killed = inherited_template_data.remove_when_killed and inherited_template_data.remove_when_killed[extension_table_name]

			if inherited_remove_when_killed then
				if template_data.remove_when_killed == nil then
					template_data.remove_when_killed = {}
				end

				if template_data.remove_when_killed[extension_table_name] == nil then
					template_data.remove_when_killed[extension_table_name] = {}
				end

				for j = 1, #inherited_remove_when_killed, 1 do
					local remove_when_killed = template_data.remove_when_killed[extension_table_name]
					remove_when_killed[#remove_when_killed + 1] = inherited_remove_when_killed[j]
				end
			end
		end

		template_data["num_" .. extension_table_name] = extension_list_n
		local remove_when_killed = template_data.remove_when_killed

		if remove_when_killed then
			for i = 1, extension_table_names_n, 1 do
				local extension_table_name = extension_table_names[i]
				local extension_list = remove_when_killed[extension_table_name]

				if extension_list then
					remove_when_killed["num_" .. extension_table_name] = #extension_list
				end
			end
		end
	end
end