return {
	run = function()
		fassert(rawget(_G, "new_mod"), "sneakrats must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("sneakrats", {
			mod_script       = "scripts/mods/sneakrats/sneakrats",
			mod_data         = "scripts/mods/sneakrats/sneakrats_data",
			mod_localization = "scripts/mods/sneakrats/sneakrats_localization"
		})
	end,
	packages = {
		"resource_packages/sneakrats/sneakrats"
	}
}
