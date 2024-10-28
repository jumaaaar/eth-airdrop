Config = {}
Config.AirdropTimer = 120 -- 2 hours

Config.DropPositions = {
	[1] = {
		plane_position = {
			model = 'ex_prop_exec_crashedp', 
			coords = vector3(1450.33, 2594.52, 48.4),
			rotation = vector3(11.75, -2.07, -82.78),
		},
		crate_position = {
			model = 'ex_prop_crate_closed_bc',		
			coords = vector3(1452.19, 2597.31, 47.60),
			rotation = vector3(-7.45, 8.96, 141.58),
		}
	},
	[2] = {
		plane_position = {
			model = 'ex_prop_exec_crashedp', 	
			coords = vector3(3177.99, 3991.84, 110.92),
			rotation = vector3(34.93, 9.63, 49.96),
		},
		crate_position = {
			model = 'ex_prop_crate_closed_bc',		
			coords = vector3(3175.35, 3990.69, 111.09),
			rotation = vector3(12.47, 34.13, -5.84),
		}
	},
	[3] = {
		plane_position = {
			model = 'ex_prop_exec_crashedp', 
			coords = vector3(657.62, 4359.89, 89.04),
			rotation = vector3(15.26, -16.49, 79.23),
		},
		crate_position = {
			model = 'ex_prop_crate_closed_bc',		
			coords = vector3(654.82, 4357.43, 87.29),
			rotation = vector3(-9.07, -21.38, 128.28),
		}
	},
	[4] = {
		plane_position = {
			model = 'ex_prop_exec_crashedp', 	
			coords = vector3(777.24, 2996.43, 47.37),
			rotation = vector3(-6.45, 1.34, -91.92),
		},
		crate_position = {
			model = 'ex_prop_crate_closed_bc',		
			coords = vector3(778.49, 2999.11, 46.08),
			rotation = vector3(-2.19, 4.72, -41.91),
		}
	},
}


Config.rewards = {
    {item = "weapon_minismg", percentage = 20, min_qty = 2, max_qty = 2},
    {item = "weapon_machinepistol", percentage = 20, min_qty = 2, max_qty = 2},
    {item = "weapon_assaultrifle", percentage = 100, min_qty = 1, max_qty = 1},
    {item = "ammo-box4", percentage = 100, min_qty = 1, max_qty = 2},
    {item = "WEAPON_GLOCK22", percentage = 100, min_qty = 2, max_qty = 2}
}