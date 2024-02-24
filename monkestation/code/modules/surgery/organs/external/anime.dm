/obj/item/organ/external/anime_head
	name = "anime implants"
	desc = "An anime implant fitted for a persons head."
	icon_state = "antennae"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_ANIME_HEAD

	preference = "feature_anime_top"

	bodypart_overlay = /datum/bodypart_overlay/mutant/anime_head

/datum/bodypart_overlay/mutant/anime_head
	color_source = ORGAN_COLOR_ANIME
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = "anime_top"

/datum/bodypart_overlay/mutant/anime_head/get_global_feature_list()
	return GLOB.anime_top_list

/datum/bodypart_overlay/mutant/anime_head/get_base_icon_state()
	return sprite_datum.icon_state

/obj/item/organ/external/anime_middle
	name = "anime implants"
	desc = "An anime implant fitted for a persons chest."
	icon_state = "antennae"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_ANIME_CHEST

	preference = "feature_anime_middle"

	bodypart_overlay = /datum/bodypart_overlay/mutant/anime_middle

/datum/bodypart_overlay/mutant/anime_middle
	color_source = ORGAN_COLOR_ANIME
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = "anime_middle"

/datum/bodypart_overlay/mutant/anime_middle/get_global_feature_list()
	return GLOB.anime_middle_list

/datum/bodypart_overlay/mutant/anime_middle/get_base_icon_state()
	return sprite_datum.icon_state

/obj/item/organ/external/tail/anime_bottom
	name = "anime tail"
	desc = "A severed anime tail. What did you cut this off of?"
	preference = "feature_anime_bottom"

	wag_flags = WAG_ABLE

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/anime_bottom

/datum/bodypart_overlay/mutant/tail/anime_bottom
	color_source = ORGAN_COLOR_ANIME
	feature_key = "anime_bottom"

/datum/bodypart_overlay/mutant/tail/anime_bottom/get_global_feature_list()
	return GLOB.anime_bottom_list
