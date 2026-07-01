/obj/item/gun

	/*
	* Spread & Recoil
	*/
	///How much the bullet scatters when fired while unwielded.
	spread = 0
	var/spread_unwielded = 12
	///Screen shake when the weapon is fired while unwielded.
	recoil = 0
	var/recoil_unwielded = 0

	/*
	* Safety
	*/

	///Does this gun have a toggle for gun safety?
	var/has_safety = FALSE
	///Is safety on? If so, we can't fire the weapon
	var/safety = FALSE
	///The wording of safety. Useful for guns that have a non-standard safety system, like a revolver
	var/safety_wording = "safety"
	///multiplier for this gun's misfire chances. Closer to 0 is better.
	var/safety_multiplier = 1

	/*
	 *  Firing
	*/
	var/dry_fire_text = "click"

	/*
	 * Wielding
	*/

	///True if the gun is wielded via twohanded component, shouldnt affect anything else
	var/wielded = FALSE
	///True if the gun is wielded after delay, should affects accuracy
	var/wielded_fully = FALSE
	///Slowdown for wielding
	var/wield_slowdown = 0.1
	///Slowdown for aiming whilst wielding
	var/aimed_wield_slowdown = 0.1
	///How long between wielding and firing in tenths of seconds
	var/wield_delay	= 0.4 SECONDS
	///Storing value for above
	var/wield_time = 0

/obj/item/gun/examine(mob/user)
	. = ..()
	if(has_safety)
		. += "The safety is [safety ? span_green("ON") : span_red("OFF")]. Ctrl-Click or Right Click to toggle the safety."


/obj/item/gun/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, PROC_REF(on_wield))
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, PROC_REF(on_unwield))
	AddComponent(/datum/component/two_handed)

	// If the gun is from bitrunning/deathmatch, safety will be off by default if it isn't already
	if(safety && is_reserved_level(src.z) && !istype(get_area(src.loc), /area/shuttle))
		safety = FALSE

/// Triggered on wield of two handed item
/obj/item/gun/proc/on_wield(obj/item/source, mob/user, instant)
	wielded = TRUE
	INVOKE_ASYNC(src, PROC_REF(do_wield), user, instant)

/obj/item/gun/proc/do_wield(mob/user, instant)
	user.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/gun, multiplicative_slowdown = wield_slowdown)
	wield_time = world.time + wield_delay
	if(wield_time > 0 && !instant)
		if(do_after(
			user,
			wield_delay,
			user,
			IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE,
			TRUE,
			CALLBACK(src, PROC_REF(is_wielded)))
			)
			wielded_fully = TRUE
			return TRUE
	else
		wielded_fully = TRUE
		return TRUE

/// triggered on unwield of two handed item
/obj/item/gun/proc/on_unwield(obj/item/source, mob/user)
	wielded = FALSE
	wielded_fully = FALSE
	user.remove_movespeed_modifier(/datum/movespeed_modifier/gun)

/obj/item/gun/proc/is_wielded()
	return wielded

/obj/item/gun/proc/toggle_safety(mob/user, silent=FALSE, override_check = FALSE)
	if(!has_safety)
		return FALSE

	// only checks for first level storage e.g pockets, hands, suit storage, belts, nothing in containers
	if(!in_contents_of(user) && !override_check)
		return FALSE

	safety = !safety

	if(!silent)
		playsound(user, 'modular_doppler/gunplay_changes/sound/selector.ogg', 100, TRUE)
		user.visible_message(
			span_notice("[user] turns the [safety_wording] on [src] [safety ? span_green("ON") : span_red("OFF")]."),
			span_notice("You turn the [safety_wording] on [src] [safety ? span_green("ON") : span_red("OFF")]."),
		)
	SEND_SIGNAL(src, COMSIG_GUN_TOGGLE_SAFETY, user)
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/item/gun/item_ctrl_click(mob/user)
	toggle_safety(user)
	return CLICK_ACTION_SUCCESS

/obj/item/gun/attack_self_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(toggle_safety(user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/gun/update_overlays()
	. = ..()
	if(ismob(loc) && has_safety)
		var/mutable_appearance/safety_overlay
		safety_overlay = mutable_appearance('modular_doppler/gunplay_changes/icon/safety.dmi')
		if(safety)
			safety_overlay.icon_state = "[safety_wording]-on"
		else
			safety_overlay.icon_state = "[safety_wording]-off"
		. += safety_overlay

// for guns firing on their own without a user
/obj/item/gun/proc/discharge(cause, seek_chance = 10)
	var/target
	if(!safety && has_safety)
		// someone is very unlucky and about to be shot
		if(prob(seek_chance))
			for(var/mob/living/target_mob in range(6, get_turf(src)))
				if(!is_in_sight(src, target_mob))
					continue
				target = target_mob
				break
		if(!target)
			var/fire_dir = pick(GLOB.alldirs)
			target = get_ranged_target_turf(get_turf(src),fire_dir,6)
		if(!chambered || !chambered.loaded_projectile)
			visible_message(span_danger("\The [src] [cause ? "[cause], suddenly going off" : "suddenly goes off"] without its safteies on! Luckily it wasn't live."))
			playsound(src, dry_fire_sound, 30, TRUE)
		else
			visible_message(span_danger("\The [src] [cause ? "[cause], suddenly going off" : "suddenly goes off"] without its safeties on!"))
			unsafe_shot(target)

/obj/item/gun/proc/unsafe_shot(target)
	if(chambered)
		chambered.fire_casing(target, null, null, null, suppressed, ran_zone(BODY_ZONE_CHEST, 50), 0, src)
		playsound(src, fire_sound, 100, TRUE)

/mob/living/proc/trip_with_gun(cause)
	var/mob/living/carbon/human/human_holder
	if(ishuman(src))
		human_holder = src
	for(var/obj/item/gun/at_risk in get_all_contents())
		var/chance_to_fire = round(GUN_NO_SAFETY_MALFUNCTION_CHANCE_MEDIUM * at_risk.safety_multiplier)
		var/bodyzone = pick_weight(list(BODY_ZONE_HEAD = 1, BODY_ZONE_CHEST = 9, BODY_ZONE_L_ARM = 4, BODY_ZONE_R_ARM = 4, BODY_ZONE_L_LEG = 41, BODY_ZONE_R_LEG = 41))
		if(human_holder)
			// gun is less likely to go off in a holster
			if(at_risk == human_holder.s_store)
				chance_to_fire = round(GUN_NO_SAFETY_MALFUNCTION_CHANCE_LOW * at_risk.safety_multiplier)
				bodyzone = pick_weight(list(BODY_ZONE_CHEST = 10, BODY_ZONE_L_LEG = 45, BODY_ZONE_R_LEG = 45))
		if(at_risk.safety == FALSE && prob(chance_to_fire))
			if(at_risk.process_fire(src,src,FALSE, null, bodyzone) == TRUE)
				log_combat(src,src,"misfired",at_risk,"caused by [cause]")
				visible_message(span_danger("\The [at_risk.name]'s trigger gets caught as [src] falls, suddenly going off into [src]'s [get_bodypart(bodyzone)]!"), span_danger("\The [at_risk.name]'s trigger gets caught on something as you fall, suddenly going off into your [get_bodypart(bodyzone)]!"))
				INVOKE_ASYNC(human_holder, TYPE_PROC_REF(/mob, emote), "scream")

/obj/item/gun/equipped(mob/user, slot, initial)
	. = ..()
	update_appearance()

/obj/item/gun/dropped(mob/user)
	. = ..()
	update_appearance()

/datum/movespeed_modifier/gun
	multiplicative_slowdown = 1
	variable = TRUE

/obj/item/gun/ballistic
	has_safety = TRUE
	safety = TRUE

/obj/item/gun/ballistic/bow
	has_safety = FALSE
	safety = FALSE

/obj/item/gun/energy/wiremod_gun
	has_safety = FALSE
	safety = FALSE

/obj/item/gun/energy
	has_safety = TRUE
	safety = TRUE

/obj/item/gun/syringe/blowgun
	dry_fire_text = "pshoo" //heehee pshoo

/obj/item/gun/ballistic/automatic
	spread = 0
	spread_unwielded = 13
	recoil = 0
	recoil_unwielded = 0.2
	wield_delay	= 1 SECONDS

	wield_slowdown = PDW_SLOWDOWN
	aimed_wield_slowdown = SMG_AIM_SLOWDOWN

/// PISTOLS

/obj/item/gun/ballistic/automatic/pistol
	wield_delay = 0.2 SECONDS
	recoil = 0.2
	recoil_unwielded = 3
	spread = 0
	spread_unwielded = 7
	wield_slowdown = PISTOL_SLOWDOWN
	aimed_wield_slowdown = PISTOL_AIM_SLOWDOWN

/obj/item/gun/ballistic/automatic/pistol/deagle
	wield_delay = 0.55 SECONDS
	recoil = 0.5
	recoil_unwielded = 2
	spread = 0
	spread_unwielded = 10

/// SMGS

/obj/item/gun/ballistic/automatic/c20r
	recoil = 0.2
	recoil_unwielded = 1.5

/// REVOLVERS

/obj/item/gun/ballistic/revolver
	dry_fire_text = "snap"
	recoil_unwielded = 2

	wield_slowdown = REVOLVER_SLOWDOWN
	aimed_wield_slowdown = PISTOL_AIM_SLOWDOWN

/obj/item/gun/ballistic/shotgun
	recoil = 0.5
	recoil_unwielded = 6 // Should only happen with sawoff or unique shotguns (Warden, Bulldog, etc)

	wield_slowdown = SHOTGUN_SLOWDOWN
	aimed_wield_slowdown = SHOTGUN_AIM_SLOWDOWN
	wield_delay = 0.8 SECONDS

/obj/item/gun/ballistic/shotgun/bulldog
	recoil = 0.2

	wield_slowdown = HEAVY_SHOTGUN_SLOWDOWN
	wield_delay = 0.65 SECONDS // More compact or something

/obj/item/gun/ballistic/shotgun/automatic
	recoil = 0.3

/obj/item/gun/ballistic/shotgun/musket // What the fuck do you mean this is a shotgun
	wield_slowdown = RIFLE_SLOWDOWN
	aimed_wield_slowdown = RIFLE_AIM_SLOWDOWN

/obj/item/proc/unique_action(mob/living/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_UNIQUE_ACTION, user))
		return TRUE

/obj/item/gun/ballistic/revolver/unique_action(mob/living/user)
	rack(user)
	return

/// ENERGY

/obj/item/gun/energy
	spread = 0
	spread_unwielded = 10
	wield_slowdown = LASER_PISTOL_SLOWDOWN

/obj/item/gun/energy/e_gun
	wield_slowdown = LASER_RIFLE_SLOWDOWN

/// No recoil for toys, they still get safeties because I think it's funny.

/obj/item/gun/ballistic/automatic/toy
	recoil = 0
	recoil_unwielded = 0

/obj/item/gun/ballistic/shotgun/toy
	recoil = 0
	recoil_unwielded = 0

/obj/item/gun/ballistic/automatic/l6_saw/toy
	recoil = 0
	recoil_unwielded = 0

/obj/item/gun/ballistic/automatic/c20r/toy
	recoil = 0
	recoil_unwielded = 0

/obj/item/gun/ballistic/automatic/pistol/toy
	recoil = 0
	recoil_unwielded = 0
