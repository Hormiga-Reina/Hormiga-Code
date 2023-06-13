/mob/living/carbon/ant/queen
	name = "ant queen"
	caste = "q"
	maxHealth = 250
	health = 250
	icon_state = "antq_s"
	status_flags = CANPARALYSE
	loudspeaker = TRUE
	heal_rate = 5
	large = 1
	ventcrawler = 0
	pressure_resistance = 200 //Because big, stompy xenos should not be blown around like paper.
	move_resist = MOVE_FORCE_STRONG //Yes, queenos is huge and heavy
	alien_disarm_damage = 60 //Queens do higher disarm stamina damage than normal aliens
	alien_slash_damage = 30 //Queens do higher slashing damage to people
	alien_movement_delay = 1 //This represents a movement delay of 1, or roughly 80% the movement speed of a normal carbon mob

/mob/living/carbon/ant/queen/Initialize(mapload)
	. = ..()
	//there should only be one queen
	for(var/mob/living/carbon/ant/queen/Q in GLOB.alive_mob_list)
		if(Q == src)
			ADD_TRAIT(Q, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
			continue
		if(Q.stat == DEAD)
			ADD_TRAIT(Q, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
			continue
		if(Q.client)
			name = "ant princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name

/*CREAR ORGANOS PROPIOS LUEGO*/
/mob/living/carbon/ant/queen/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/alien/plasmavessel/queen,
		/obj/item/organ/internal/alien/acidgland,
		/obj/item/organ/internal/alien/eggsac,
		/obj/item/organ/internal/alien/resinspinner,
		/obj/item/organ/internal/alien/neurotoxin,
	)


/mob/living/carbon/ant/queen/can_inject(mob/user, error_msg, target_zone, penetrate_thick)
	return FALSE

