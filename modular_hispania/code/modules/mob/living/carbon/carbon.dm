/*/mob/living/carbon/Stat()
	..()
	if(statpanel("Status"))
		var/obj/item/organ/internal/ant/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/ant/plasmavessel)
		if(vessel)
			stat(null, "Plasma Stored: [vessel.stored_plasma]/[vessel.max_plasma]")
*/