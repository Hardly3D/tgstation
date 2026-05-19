/obj/item/gun
	/*
	* Safety
	*/

	/// Does this gun have a toggle for gun safety?
	var/has_safety = FALSE
	/// Is safety on? If so, we can't fire the weapon
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

	//true if the gun is wielded via twohanded component, shouldnt affect anything else
	var/wielded = FALSE
	//true if the gun is wielded after delay, should affects accuracy
	var/wielded_fully = FALSE
	///Slowdown for wielding
	var/wield_slowdown = 0.1
	///slowdown for aiming whilst wielding
	var/aimed_wield_slowdown = 0.1
	///How long between wielding and firing in tenths of seconds
	var/wield_delay	= 0.4 SECONDS
	///Storing value for above
	var/wield_time = 0

/obj/item/gun/examine(mob/user)
	. = ..()
	if(has_safety)
		. += "The safety is [safety ? "<span class='green'>ON</span>" : "<span class='red'>OFF</span>"]. Ctrl-Click to toggle the safety."

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
	//SEND_SIGNAL(src, COMSIG_GUN_TOGGLE_SAFETY, user)
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/item/gun/item_ctrl_click(mob/user)
	toggle_safety(user)
	return CLICK_ACTION_SUCCESS

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
		chambered.fire_casing(target, null, null, null, suppressed, ran_zone(BODY_ZONE_CHEST, 50), 0, src, TRUE)
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

/obj/item/gun/ballistic
	has_safety = TRUE
	safety = TRUE

/obj/item/gun/energy
	has_safety = TRUE
	safety = TRUE

/obj/item/gun/syringe/blowgun
	dry_fire_text = "pshoo" //heehee pshoo

/obj/item/gun/ballistic/revolver
	dry_fire_text = "snap"
