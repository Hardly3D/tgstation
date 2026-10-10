/// PISTOLS

/obj/item/gun/ballistic/automatic/pistol
	recoil = 0.2
	recoil_unwielded = 2
	spread = 0
	spread_unwielded = 7
	wield_delay = 0.2 SECONDS
	wield_slowdown = PISTOL_SLOWDOWN
	aimed_wield_slowdown = PISTOL_AIM_SLOWDOWN

/obj/item/gun/ballistic/automatic/pistol/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 0.2, scope_icon = FALSE)

/obj/item/gun/ballistic/automatic/pistol/deagle
	recoil = 0.5
	recoil_unwielded = 5
	spread = 0
	spread_unwielded = 10
	wield_delay = 0.55 SECONDS

/// REVOLVERS

/obj/item/gun/ballistic/revolver
	dry_fire_text = "snap"
	recoil = 0.3
	recoil_unwielded = 4
	spread = 0
	spread_unwielded = 7
	wield_delay = 0.2 SECONDS
	wield_slowdown = REVOLVER_SLOWDOWN
	aimed_wield_slowdown = PISTOL_AIM_SLOWDOWN

/obj/item/gun/ballistic/revolver/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 0.2, scope_icon = FALSE)
