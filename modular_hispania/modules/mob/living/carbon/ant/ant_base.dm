/mob/living/carbon/ant
	name = "Ant"
	voice_name = "ant"
	speak_emote = list("clicks")
	bubble_icon = "ant"
	icon = 'modular_hispania/icons/mob/ant.dmi'
	gender = NEUTER
	dna = null
	icon_state = "alien_s"

	var/nightvision = TRUE
	see_in_dark = 4

	var/obj/item/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/has_fine_manipulation = FALSE
	var/move_delay_add = FALSE // movement delay to add

	status_flags = CANPARALYSE|CANPUSH
	var/heal_rate = 5
	var/large = FALSE
	var/loudspeaker = FALSE
	var/heat_protection = 0.5
	var/leaping = FALSE
	ventcrawler = 2
	var/death_message = "lets out a waning guttural screech, green blood bubbling from its maw..."
	var/death_sound = 'sound/voice/hiss6.ogg'

	/*MOVIDAS DE HUMANOID.DM QUITAR LAS QUE NO SE NECESITAN*/
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/caste = ""
	var/alt_icon = 'icons/mob/alienleap.dmi' //used to switch between the two alien icon files.
	var/next_attack = 0
	var/pounce_cooldown = 0
	var/pounce_cooldown_time = 30
	var/leap_on_click = 0
	var/custom_pixel_x_offset = 0 //for admin fuckery.
	var/custom_pixel_y_offset = 0
	var/alien_disarm_damage = 5 //Aliens deal a good amount of stamina damage on disarm intent
	var/alien_slash_damage = 5 //Aliens deal a good amount of damage on harm intent
	var/alien_movement_delay = 0 //This can be + or -, how fast an alien moves

/mob/living/carbon/ant/Initialize(mapload)
	. = ..()
	create_reagents(1000)
	verbs += /mob/living/verb/mob_sleep
	verbs += /mob/living/verb/rest

	for(var/organ_path in get_caste_organs())
		var/obj/item/organ/internal/organ = new organ_path()
		organ.insert(src)

/// returns the list of type paths of the organs that we need to insert into
/// this particular xeno upon its creation
/mob/living/carbon/ant/proc/get_caste_organs()
	RETURN_TYPE(/list/obj/item/organ/internal)
	return list(
		/obj/item/organ/internal/brain/xeno,
		/obj/item/organ/internal/alien/hivenode,
		/obj/item/organ/internal/ears
	)

/mob/living/carbon/ant/get_default_language()
	if(default_language)
		return default_language
	return GLOB.all_languages["Xenomorph"]

/*ESTO SEGURO NO ES NECESARIO*/
/mob/living/carbon/ant/say_quote(message, datum/language/speaking = null)
	var/verb = "clicks"
	var/ending = copytext(message, length(message))

	if(speaking && (speaking.name != "Galactic Common")) //this is so adminbooze xenos speaking common have their custom verbs,
		verb = speaking.get_spoken_verb(ending)          //and use normal verbs for their own languages and non-common languages
	else
		if(ending=="!")
			verb = "roars"
		else if(ending=="?")
			verb = "hisses curiously"
	return verb

/*DE MOMENTO NDEJO LAS DEBILIDADES DE LOS XENOS*/
/mob/living/carbon/ant/adjustToxLoss(amount)
	return STATUS_UPDATE_NONE

/mob/living/carbon/ant/adjustFireLoss(amount) // Weak to Fire
	if(amount > 0)
		return ..(amount * 2)
	else
		return ..(amount)


/mob/living/carbon/ant/check_eye_prot()
	return 2

/mob/living/carbon/ant/handle_environment(datum/gas_mixture/environment)

	if(!environment)
		return

	var/loc_temp = get_temperature(environment)

//	to_chat(world, "Loc temp: [loc_temp] - Body temp: [bodytemperature] - Fireloss: [getFireLoss()] - Fire protection: [heat_protection] - Location: [loc] - src: [src]")

	// Aliens are now weak to fire.

	//After then, it reacts to the surrounding atmosphere based on your thermal protection
	if(!on_fire) // If you're on fire, ignore local air temperature
		if(loc_temp > bodytemperature)
			//Place is hotter than we are
			var/thermal_protection = heat_protection //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				bodytemperature += (1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)
		else
			bodytemperature += 1 * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)
		//	bodytemperature -= max((loc_temp - bodytemperature / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)

	// +/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(bodytemperature > 360.15)
		//Body temperature is too hot.
		throw_alert("alien_fire", /obj/screen/alert/alien_fire)
		switch(bodytemperature)
			if(360 to 400)
				apply_damage(HEAT_DAMAGE_LEVEL_1, BURN)
			if(400 to 460)
				apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
			if(460 to INFINITY)
				if(on_fire)
					apply_damage(HEAT_DAMAGE_LEVEL_3, BURN)
				else
					apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
	else
		clear_alert("alien_fire")

/*EN EL FUTURO PROBABLEMENTE NECESITEN ESTO PARA USAR HERRAMIENTANTS*/
/mob/living/carbon/ant/IsAdvancedToolUser()
	return has_fine_manipulation

/mob/living/carbon/ant/Stat()
	..()
	statpanel("Status")
	stat(null, "Intent: [a_intent]")
	stat(null, "Move Mode: [m_intent]")
	show_stat_emergency_shuttle_eta()

/mob/living/carbon/ant/SetStunned(amount, updating = TRUE, force = 0)
	..()
	if(!(status_flags & CANSTUN) && amount)
		// add some movement delay
		move_delay_add = min(move_delay_add + round(amount / 2), 10) // a maximum delay of 10

/mob/living/carbon/alien/movement_delay()
	. = ..()
	. += move_delay_add + GLOB.configuration.movement.alien_delay //move_delay_add is used to slow aliens with stuns

/mob/living/carbon/ant/getDNA()
	return null

/mob/living/carbon/ant/setDNA()
	return

/*EN EL FUTURO NO TENDRÁN VISION NOCTURNA SINO QUE SEGUIRÁN RASTROS DE FEROMONAS CUANDO NO PUEDAN VER, DE MOMENTO LO PODEMOS DEJAR*/
/mob/living/carbon/ant/verb/nightvisiontoggle()
	set name = "Toggle Night Vision"
	set category = "Alien"

	if(!nightvision)
		see_in_dark = 8
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		nightvision = TRUE
		usr.hud_used.nightvisionicon.icon_state = "nightvision1"
	else if(nightvision)
		see_in_dark = initial(see_in_dark)
		lighting_alpha = initial(lighting_alpha)
		nightvision = FALSE
		usr.hud_used.nightvisionicon.icon_state = "nightvision0"

	update_sight()

/*ESTO SE PODRÁ ELIMINAR YA QUE NO HABRÁ NADA DE ESTO*/
/mob/living/carbon/ant/assess_threat(mob/living/simple_animal/bot/secbot/judgebot, lasercolor)
	if(judgebot.emagged == 2)
		return 10 //Everyone is a criminal!
	var/threatcount = 0

	//Securitrons can't identify aliens
	if(!lasercolor && judgebot.idcheck)
		threatcount += 4

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if((istype(r_hand,/obj/item/gun/energy/laser/tag/red)) || (istype(l_hand,/obj/item/gun/energy/laser/tag/red)))
				threatcount += 4

		if(lasercolor == "r")
			if((istype(r_hand,/obj/item/gun/energy/laser/tag/blue)) || (istype(l_hand,/obj/item/gun/energy/laser/tag/blue)))
				threatcount += 4

		return threatcount

	//Check for weapons
	if(judgebot.weaponscheck)
		if(judgebot.check_for_weapons(l_hand))
			threatcount += 4
		if(judgebot.check_for_weapons(r_hand))
			threatcount += 4

	//Mindshield implants imply trustworthyness
	if(ismindshielded(src))
		threatcount -= 1

	return threatcount

/*----------------------------------------
Proc: AddInfectionImages()
Des: Gives the client of the alien an image on each infected mob.
----------------------------------------*/
/mob/living/carbon/ant/proc/AddInfectionImages()
	if(client)
		for(var/mob/living/C in GLOB.mob_list)
			if(HAS_TRAIT(C, TRAIT_XENO_HOST))
				var/obj/item/organ/internal/body_egg/alien_embryo/A = C.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo)
				if(A)
					var/I = image('icons/mob/alien.dmi', loc = C, icon_state = "infected[A.stage]")
					client.images += I
	return


/*----------------------------------------
Proc: RemoveInfectionImages()
Des: Removes all infected images from the alien.
----------------------------------------*/
/mob/living/carbon/ant/proc/RemoveInfectionImages()
	if(client)
		for(var/image/I in client.images)
			if(dd_hasprefix_case(I.icon_state, "infected"))
				qdel(I)
	return

/mob/living/carbon/ant/canBeHandcuffed()
	return TRUE

/* Although this is on the carbon level, we only want this proc'ing for aliens that do have this hud. Only humanoid aliens do at the moment, so we have a check
and carry the owner just to make sure*/
/* COMENTADO PAR EVITAR CONFLICTO CON ALIEN_BASE.DM, LA IDEA ES EVENTUALMENTE QUITAR ALIEN.DM Y DEJARLO SOLO AQUI
/mob/living/carbon/proc/update_plasma_display(mob/owner)
	for(var/datum/action/spell_action/action in actions)
		action.UpdateButtonIcon()
	if(!hud_used || !isalien(owner)) //clientless aliens or non aliens
		return
	hud_used.alien_plasma_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font face='Small Fonts' color='magenta'>[get_plasma()]</font></div>"
	hud_used.alien_plasma_display.maptext_x = -3
*/
/mob/living/carbon/ant/larva/update_plasma_display()
	return

/mob/living/carbon/ant/can_use_vents()
	return

/mob/living/carbon/ant/getTrail()
	if(getBruteLoss() < 200)
		return pick("xltrails_1", "xltrails_2")
	else
		return pick("xttrails_1", "xttrails_2")

/mob/living/carbon/ant/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		grant_death_vision()
		return

	see_invisible = initial(see_invisible)
	sight = SEE_MOBS
	if(nightvision)
		see_in_dark = 8
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	else
		see_in_dark = initial(see_in_dark)
		lighting_alpha = initial(lighting_alpha)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

/mob/living/carbon/ant/on_lying_down(new_lying_angle)
	. = ..()
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, LYING_DOWN_TRAIT) //Xenos can't crawl
