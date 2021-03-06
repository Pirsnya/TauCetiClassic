#define CHANGELING_STATPANEL_STATS(BYOND) \
	if(mind && mind.changeling) \
	{ \
		stat("Chemical Storage", "[mind.changeling.chem_charges]/[mind.changeling.chem_storage]"); \
		stat("Genetic Damage Time", mind.changeling.geneticdamage); \
		stat("Absorbed DNA", mind.changeling.absorbedcount); \
	}


#define CHANGELING_STATPANEL_POWERS(BYOND) \
	if(mind && mind.changeling && mind.changeling.purchasedpowers.len) \
	{ \
		for(var/P in mind.changeling.purchasedpowers) \
		{ \
			var/obj/effect/proc_holder/changeling/S = P; \
			if(S.chemical_cost >=0 && S.can_be_used_by(src)) \
			{ \
				statpanel("[S.panel]", ((S.chemical_cost > 0) ? "[S.chemical_cost]" : ""), S); \
			} \
		} \
	}

// see _DEFINES/is_helpers.dm for mob type checks
#define SAFE_PERP -50

/mob/living/proc/isSynthetic()
	return FALSE

/mob/living/carbon/human/isSynthetic(target_zone)
	if(isnull(full_prosthetic))
		robolimb_count = 0
		for(var/obj/item/organ/external/BP in bodyparts)
			if(BP.status & ORGAN_ROBOT)
				robolimb_count++
		full_prosthetic = (robolimb_count == bodyparts.len)

	if(!full_prosthetic && target_zone)
		var/obj/item/organ/external/BP = get_bodypart(target_zone)
		if(BP)
			return BP.status & ORGAN_ROBOT

	return full_prosthetic

/mob/living/silicon/isSynthetic()
	return TRUE

/proc/hsl2rgb(h, s, l)
	return

/proc/ismindshielded(A, only_mindshield = FALSE) //Checks to see if the person contains a mindshield implant, then checks that the implant is actually inside of them

	for(var/obj/item/weapon/implant/mindshield/L in A)
		if(only_mindshield && L.type != /obj/item/weapon/implant/mindshield)
			continue
		if(L.implanted)
			return TRUE
	return FALSE

/proc/isloyal(A)
	for(var/obj/item/weapon/implant/mindshield/loyalty/L in A)
		if(L.implanted)
			return TRUE
	return FALSE

/proc/check_zone(zone)
	if(!zone)
		return BP_CHEST

	switch(zone)
		if(O_EYES)
			zone = BP_HEAD
		if(O_MOUTH)
			zone = BP_HEAD

	return zone

// Returns zone with a certain probability.
// If the probability misses, returns "chest" instead.
// If "chest" was passed in as zone, then on a "miss" will return "head", "l_arm", or "r_arm"
// Do not use this if someone is intentionally trying to hit a specific body part.
// Use get_zone_with_miss_chance() for that.
/proc/ran_zone(zone, probability = 90)
	zone = check_zone(zone)
	if(probability == 100)
		return zone

	if(zone == BP_CHEST)
		if(prob(probability))
			return BP_CHEST

		var/t = rand(1, 9)
		switch(t)
			if(1 to 3) return BP_HEAD
			if(4 to 6) return BP_L_ARM
			if(7 to 9) return BP_R_ARM

	if(prob(probability * 0.75))
		return zone

	return BP_CHEST

// Emulates targetting a specific body part, and miss chances
// May return null if missed
// miss_chance_mod may be negative.
/proc/get_zone_with_miss_chance(zone, mob/target, miss_chance_mod = 0)
	zone = check_zone(zone)

	// you can only miss if your target is standing and not restrained
	if(!target.buckled && !target.lying)
		var/miss_chance = 10
		switch(zone)
			if(BP_HEAD)
				miss_chance = 50
			if(BP_GROIN)
				miss_chance = 50
			if(BP_L_ARM)
				miss_chance = 60
			if(BP_R_ARM)
				miss_chance = 60
			if(BP_L_LEG)
				miss_chance = 60
			if(BP_R_LEG)
				miss_chance = 60
		if(prob(max(miss_chance + miss_chance_mod, 0)))
			if(prob(max(20, (miss_chance/2))))
				return null
			else
				var/t = rand(1, 100)
				switch(t)
					if(1 to 65)
						return BP_CHEST
					if(66 to 75)
						return BP_HEAD
					if(76 to 80)
						return BP_L_ARM
					if(81 to 85)
						return BP_R_ARM
					if(86 to 90)
						return BP_R_LEG
					if(91 to 95)
						return BP_L_LEG
					if(96 to 100)
						return BP_GROIN

	return zone

/proc/get_zone_with_probabilty(zone, probability = 80)

	zone = check_zone(zone)

	if(prob(probability))
		return zone

	var/t = rand(1, 18) // randomly pick a different zone, or maybe the same one
	switch(t)
		if(1)        return BP_HEAD
		if(2)        return BP_CHEST
		if(3 to 6)   return BP_L_ARM
		if(7 to 10)  return BP_R_ARM
		if(11 to 14) return BP_L_LEG
		if(15 to 18) return BP_R_LEG

	return zone

/proc/stars(n, pr)
	if (pr == null)
		pr = 25
	if (pr <= 0)
		return null
	else
		if (pr >= 100)
			return n
	var/te = n
	var/t = ""
	n = length(n)
	var/p = null
	p = 1
	while(p <= n)
		if ((copytext(te, p, p + 1) == " " || prob(pr)))
			t = text("[][]", t, copytext(te, p, p + 1))
		else
			t = text("[]*", t)
		p++
	return t

proc/slur(phrase)
	phrase = html_decode(phrase)
	var/leng=lentext(phrase)
	var/counter=lentext(phrase)
	var/newphrase=""
	var/newletter=""
	var/lletter=""
	while(counter>=1)
		newletter=copytext(phrase,(leng-counter)+1,(leng-counter)+2)
		if(rand(1,3)==3)
			if(lletter=="o")	newletter="u"
			if(lletter=="s")	newletter="ch"
			if(lletter=="a")	newletter="ah"
			if(lletter=="c")	newletter="k"
			if(lletter=="�")	newletter="�" //246->249
			if(lletter=="�")	newletter="�" //229->232
		switch(rand(1,15))
			if(1 to 4)
				newletter = "[lowertext_plus(newletter)]"
			if(5 to 8)
				newletter = "[uppertext_plus(newletter)]"
			if(9)	newletter+="'"
		newphrase+="[newletter]";counter-=1
	return newphrase

// TODO:CYRILLIC ������������ lowertext_plus
/proc/stutter(text)
	text = html_decode(text)
	var/t = ""
	var/lenght = length(text)//length of the entire word
	var/alphabet[0]
	//alphabet.Add("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z")
	//alphabet.Add("á","â","ã","ä","æ","ç","é","ê","ë","ì","í","ï","ð","ñ","ò","ô","õ","ö","÷","ø","ù")
	alphabet.Add(98,99,100,102,103,104,105,106,107,108,109,110,112,113,114,115,116,118,119,120,121,122)
	alphabet.Add(225,226,227,228,230,231,233,234,235,236,237,239,240,241,242,244,245,246,247,248,249)
	var/letter
	var/lcase_letter
	var/tletter
	var/p = 1
	while(p <= lenght)//while P, which starts at 1 is less or equal to N which is the length.
		letter = copytext(text, p, p + 1)//copies text from a certain distance. In this case, only one letter at a time.
		tletter = letter
		lcase_letter = text2ascii(letter)
		if((lcase_letter >= 65 && lcase_letter <=90) || (lcase_letter >= 192 && lcase_letter <=223))
			tletter = ascii2text(lcase_letter + 32)
		if (prob(80) && (text2ascii(tletter) in alphabet))
			if (prob(10))
				letter = text("[letter]-[letter]-[letter]-[letter]")//replaces the current letter with this instead.
			else
				if (prob(20))
					letter = text("[letter]-[letter]-[letter]")
				else
					if (prob(5))
						letter = null
					else
						letter = text("[letter]-[letter]")
		t = text("[t][letter]")//since the above is ran through for each letter, the text just adds up back to the original word.
		p++//for each letter p is increased to find where the next letter will be.
	//return sanitize(copytext(t,1,MAX_MESSAGE_LEN))
	return copytext(t,1,MAX_MESSAGE_LEN)


/proc/Gibberish(t, p)//t is the inputted message, and any value higher than 70 for p will cause letters to be replaced instead of added
	/* Turn text into complete gibberish! */
	var/returntext = ""
	for(var/i = 1, i <= length(t), i++)

		var/letter = copytext(t, i, i+1)
		if(prob(50))
			if(p >= 70)
				letter = ""

			for(var/j = 1, j <= rand(0, 2), j++)
				letter += pick("#","@","*","&","%","$","/", "<", ">", ";","*","*","*","*","*","*","*")

		returntext += letter

	return returntext

/proc/GibberishAll(t) // Same as above, except there is no probability and chance always 100.
	/* Turn text into complete gibberish! */
	var/returntext = ""
	for(var/i = 1 to length(t))

		var/letter = ""

		for(var/j = rand(0, 2) to 0 step -1)
			letter += pick("#","@","*","&","%","$","/", "<", ">", ";","*","*","*","*","*","*","*")

		returntext += letter

	return returntext


/proc/ninjaspeak(n)
/*
The difference with stutter is that this proc can stutter more than 1 letter
The issue here is that anything that does not have a space is treated as one word (in many instances). For instance, "LOOKING," is a word, including the comma.
It's fairly easy to fix if dealing with single letters but not so much with compounds of letters./N
*/
	var/te = html_decode(n)
	var/t = ""
	n = length(n)
	var/p = 1
	while(p <= n)
		var/n_letter
		var/n_mod = rand(1,4)
		if(p+n_mod>n+1)
			n_letter = copytext(te, p, n+1)
		else
			n_letter = copytext(te, p, p+n_mod)
		if (prob(50))
			if (prob(30))
				n_letter = text("[n_letter]-[n_letter]-[n_letter]")
			else
				n_letter = text("[n_letter]-[n_letter]")
		else
			n_letter = text("[n_letter]")
		t = text("[t][n_letter]")
		p=p+n_mod
	return copytext(t,1,MAX_MESSAGE_LEN)


/proc/shake_camera(mob/M, duration, strength=1)
	if(!M || !M.client || !strength) return
	spawn()
		strength *= 32
		for(var/i=0; i<duration, i++)
			animate(M.client, pixel_x = rand(-strength,strength), pixel_y = rand(-strength,strength), time = 2)
			sleep(2)
		animate(M.client, pixel_x = 0, pixel_y = 0, time = 0)


/proc/findname(msg)
	for(var/mob/M in mob_list)
		if (M.real_name == text("[msg]"))
			return 1
	return 0


/mob/proc/abiotic(var/full_body = 0)
	if(full_body && ((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )) || (src.back || src.wear_mask)))
		return 1

	if((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )))
		return 1

	if(l_hand && !l_hand.flags&ABSTRACT || r_hand && !r_hand.flags&ABSTRACT)
		return 1

	return 0

//converts intent-strings into numbers and back
var/list/intents = list("help","disarm","grab","hurt")
/proc/intent_numeric(argument)
	if(istext(argument))
		switch(argument)
			if("help")		return 0
			if("disarm")	return 1
			if("grab")		return 2
			else			return 3
	else
		switch(argument)
			if(0)			return "help"
			if(1)			return "disarm"
			if(2)			return "grab"
			else			return "hurt"

//change a mob's act-intent. Input the intent as a string such as "help" or use "right"/"left
/mob/verb/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = 1

	if(ishuman(src) || isalienadult(src) || isbrain(src))
		switch(input)
			if("help","disarm","grab","hurt")
				a_intent = input
			if("right")
				a_intent = intent_numeric((intent_numeric(a_intent)+1) % 4)
			if("left")
				a_intent = intent_numeric((intent_numeric(a_intent)+3) % 4)
		if(hud_used && hud_used.action_intent)
			hud_used.action_intent.icon_state = "intent_[a_intent]"

	else if(isrobot(src) || ismonkey(src) || islarva(src)|| isfacehugger(src) || isIAN(src))
		switch(input)
			if("help")
				a_intent = "help"
			if("hurt")
				a_intent = "hurt"
			if("right","left")
				a_intent = intent_numeric(intent_numeric(a_intent) - 3)
		if(hud_used && hud_used.action_intent)
			if(a_intent == "hurt")
				hud_used.action_intent.icon_state = "harm"
			else
				hud_used.action_intent.icon_state = "help"

/proc/broadcast_security_hud_message(message, broadcast_source)
	broadcast_hud_message(message, broadcast_source, sec_hud_users)

/proc/broadcast_medical_hud_message(message, broadcast_source)
	broadcast_hud_message(message, broadcast_source, med_hud_users)

/proc/broadcast_hud_message(message, broadcast_source, list/targets)
	var/turf/sourceturf = get_turf(broadcast_source)
	for(var/mob/M in targets)
		var/turf/targetturf = get_turf(M)
		if((targetturf.z == sourceturf.z))
			M.show_message("<span class='info'>[bicon(broadcast_source)] [message]</span>", 1)
	for(var/mob/dead/observer/G in player_list) //Ghosts? Why not.
		G.show_message("<span class='info'>[bicon(broadcast_source)] [message]</span>", 1)

/mob/living/proc/assess_perp(obj/access_obj, check_access, auth_weapons, check_records, check_arrest)
	if(stat == DEAD)
		return SAFE_PERP
	return 0

/mob/living/carbon/assess_perp(obj/access_obj, check_access, auth_weapons, check_records, check_arrest)
	if(handcuffed)
		return SAFE_PERP
	return ..()

/mob/living/carbon/human/assess_perp(obj/access_obj, check_access, auth_weapons, check_records, check_arrest)
	var/threatcount = ..()
	if(threatcount == SAFE_PERP)
		return SAFE_PERP

	//Agent cards lower threatlevel.
	var/obj/item/weapon/card/id/id = null
	if(wear_id)
		id = wear_id.GetID()
	else if(l_hand)
		id = l_hand.GetID()
	else if(r_hand)
		id = r_hand.GetID()

	if(id && istype(id, /obj/item/weapon/card/id/syndicate))
		threatcount -= 2
	// A proper CentCom id is hard currency.
	else if(id && is_type_in_list(id, list(/obj/item/weapon/card/id/centcom, /obj/item/weapon/card/id/ert)))
		return SAFE_PERP

	if(check_access && !access_obj.allowed(src))
		threatcount += 4

	if(auth_weapons && !access_obj.allowed(src))
		var/list/weapon_list = list(/obj/item/weapon/gun, /obj/item/weapon/melee)
		if(l_hand && is_type_in_list(l_hand, weapon_list))
			threatcount += 4

		if(r_hand && is_type_in_list(r_hand, weapon_list))
			threatcount += 4

		if(belt && is_type_in_list(belt, weapon_list))
			threatcount += 2

		if(species.name != HUMAN)
			threatcount += 2

	if(check_records || check_arrest)
		var/perpname = name
		if(id)
			perpname = id.registered_name

		var/datum/data/record/R = find_security_record("name", perpname)
		if(check_records && !R)
			threatcount += 4

		if(check_arrest && R && (R.fields["criminal"] == "*Arrest*"))
			threatcount += 4

	return threatcount

/mob/living/simple_animal/hostile/assess_perp(obj/access_obj, check_access, auth_weapons, check_records, check_arrest)
	var/threatcount = ..()
	if(threatcount == SAFE_PERP)
		return SAFE_PERP

	if(!istype(src, /mob/living/simple_animal/hostile/retaliate/goat))
		threatcount += 4
	return threatcount

#undef SAFE_PERP

/proc/IsAdminGhost(mob/user)
	if(!user) // Are they a mob? Auto interface updates call this with a null src
		return
	if(!user.client) // Do they have a client?
		return
	if(!isobserver(user)) // Are they a ghost?
		return
	if(!check_rights_for(user.client, R_ADMIN)) // Are they allowed?
		return
	if(!user.client.AI_Interact) // Do they have it enabled?
		return
	return TRUE

/mob/proc/is_busy(atom/target, show_warning = TRUE)
	if(busy_with_action)
		if(show_warning)
			to_chat(src, "<span class='warning'>You are busy. Please finish or cancel your current action.</span>")
		return TRUE
	if(target && target.in_use_action)
		if(show_warning)
			to_chat(src, "<span class='warning'>Please wait while someone else will finish interacting with [target].</span>")
		return TRUE
	return FALSE
