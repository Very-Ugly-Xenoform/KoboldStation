/* Food */
/datum/reagent/nutriment
	name = "Nutriment"
	id = "nutriment"
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	taste_mult = 4
	reagent_state = SOLID
	metabolism = REM * 2
	ingest_met = REM * 4
	var/nutriment_factor = 12 // Per removed in digest.
	var/hydration_factor = 0 // Per removed in digest.
	var/blood_factor = 2
	var/regen_factor = 0.8
	var/injectable = 0
	var/attrition_factor = -(REM * 4)/BASE_MAX_NUTRITION // Decreases attrition rate.
	color = "#664330"
	unaffected_species = IS_MACHINE
	taste_description = "food"
	fallback_specific_heat = 1.25

/datum/reagent/nutriment/synthetic
	name = "Synthetic Nutriment"
	id = "synnutriment"
	description = "A cheaper alternative to actual nutriment."
	taste_description = "cheap food"
	nutriment_factor = 10
	attrition_factor = (REM * 4)/BASE_MAX_NUTRITION // Increases attrition rate.

/datum/reagent/nutriment/mix_data(var/list/newdata, var/newamount)
	if(!islist(newdata) || !newdata.len)
		return
	for(var/i in 1 to newdata.len)
		LAZYSET(data, newdata[i], LAZYACCESS(data, newdata[i]) + newdata[newdata[i]])
	var/totalFlavor = 0
	for(var/i in 1 to data.len)
		totalFlavor += data[data[i]]

	if (!totalFlavor)
		return

	for(var/i in 1 to data.len) //cull the tasteless
		if(data[data[i]]/totalFlavor * 100 < 10)
			LAZYREMOVE(data, data[i])
			LAZYREMOVE(data, i)

/datum/reagent/nutriment/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(injectable)
		affect_ingest(M, alien, removed)

/datum/reagent/nutriment/affect_ingest(var/mob/living/carbon/human/M, var/alien, var/removed)
	if(!istype(M))
		return
	digest(M,removed)

/datum/reagent/nutriment/proc/digest(var/mob/living/carbon/M, var/removed)
	M.heal_organ_damage(regen_factor * removed, 0)
	M.adjustNutritionLoss(-nutriment_factor * removed)
	M.nutrition_attrition_rate = Clamp(M.nutrition_attrition_rate + attrition_factor, 1, 2)
	M.add_chemical_effect(CE_BLOODRESTORE, blood_factor * removed)
	M.intoxication -= min(M.intoxication,nutriment_factor*removed*0.05) //Nutrients can absorb alcohol.

/*
	Coatings are used in cooking. Dipping food items in a reagent container with a coating in it
	allows it to be covered in that, which will add a masked overlay to the sprite.

	Coatings have both a raw and a cooked image. Raw coating is generally unhealthy
	Generally coatings are intended for deep frying foods
*/
/datum/reagent/nutriment/coating
	nutriment_factor = 6 //Less dense than the food itself, but coatings still add extra calories
	var/messaged = 0
	var/icon_raw
	var/icon_cooked
	var/coated_adj = "coated"
	var/cooked_name = "coating"
	taste_description = "some sort of frying coating"

/datum/reagent/nutriment/coating/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)

	//We'll assume that the batter isnt going to be regurgitated and eaten by someone else. Only show this once
	if (data["cooked"] != 1)
		if (!messaged)
			to_chat(M, "Ugh, this raw [name] tastes disgusting.")
			nutriment_factor *= 0.5
			messaged = 1

		//Raw coatings will sometimes cause vomiting
		if (ishuman(M) && prob(1))
			var/mob/living/carbon/human/H = M
			H.delayed_vomit()
	..()

/datum/reagent/nutriment/coating/initialize_data(var/newdata) // Called when the reagent is created.
	..()
	if (!data)
		data = list()
	else
		if (isnull(data["cooked"]))
			data["cooked"] = 0
		return
	data["cooked"] = 0
	if (holder && holder.my_atom && istype(holder.my_atom,/obj/item/weapon/reagent_containers/food/snacks))
		data["cooked"] = 1
		name = cooked_name

		//Batter which is part of objects at compiletime spawns in a cooked state


//Handles setting the temperature when oils are mixed
/datum/reagent/nutriment/coating/mix_data(var/newdata, var/newamount)
	if (!data)
		data = list()

	data["cooked"] = newdata["cooked"]


/datum/reagent/nutriment/coating/batter
	name = "batter mix"
	cooked_name = "batter"
	id = "batter"
	color = "#f5f4e9"
	reagent_state = LIQUID
	icon_raw = "batter_raw"
	icon_cooked = "batter_cooked"
	coated_adj = "battered"
	taste_description = "batter"

/datum/reagent/nutriment/coating/beerbatter
	name = "beer batter mix"
	cooked_name = "beer batter"
	id = "beerbatter"
	color = "#f5f4e9"
	reagent_state = LIQUID
	icon_raw = "batter_raw"
	icon_cooked = "batter_cooked"
	coated_adj = "beer-battered"
	taste_description = "beer-batter"

/datum/reagent/nutriment/coating/beerbatter/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.intoxication += removed*0.02 //Very slightly alcoholic

//==============================
/datum/reagent/nutriment/protein // Bad for Skrell!
	name = "animal protein"
	id = "protein"
	color = "#440000"
	blood_factor = 3
	taste_description = "meat"

/datum/reagent/nutriment/protein/tofu //Good for Skrell!
	name = "tofu protein"
	id = "tofu"
	color = "#fdffa8"
	taste_description = "tofu"

/datum/reagent/nutriment/protein/seafood // Good for Skrell!
	name = "seafood protein"
	id = "seafood"
	color = "#f5f4e9"
	taste_description = "fish"

/datum/reagent/nutriment/protein/egg // Also bad for skrell.
	name = "egg yolk"
	id = "egg"
	color = "#FFFFAA"
	taste_description = "egg"

/datum/reagent/nutriment/protein/cheese // Also bad for skrell.
	name = "cheese"
	id = "cheese"
	color = "#EDB91F"
	taste_description = "cheese"

//Fats
//=========================
/datum/reagent/nutriment/triglyceride
	name = "triglyceride"
	id = "triglyceride"
	description = "More commonly known as fat, the third macronutrient, with over double the energy content of carbs and protein"

	reagent_state = SOLID
	nutriment_factor = 27//The caloric ratio of carb/protein/fat is 4:4:9
	color = "#CCCCCC"
	taste_description = "fat"

/datum/reagent/nutriment/triglyceride/oil
	//Having this base class incase we want to add more variants of oil
	name = "Oil"
	id = "oil"
	description = "Oils are liquid fats"
	reagent_state = LIQUID
	color = "#c79705"
	touch_met = 1.5
	var/lastburnmessage = 0
	taste_description = "some short of oil"
	taste_mult = 0.1

/datum/reagent/nutriment/triglyceride/oil/touch_turf(var/turf/simulated/T)
	if(!istype(T))
		return

	/*
	//Why should oil put out fires? Pondering removing this

	var/hotspot = (locate(/obj/fire) in T)
	if(hotspot && !istype(T, /turf/space))
		var/datum/gas_mixture/lowertemp = T.remove_air(T:air:total_moles)
		lowertemp.temperature = max(min(lowertemp.temperature-2000, lowertemp.temperature / 2), 0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)
	*/

	if(volume >= 3)
		T.wet_floor(WET_TYPE_LUBE,volume)

/datum/reagent/nutriment/triglyceride/oil/initialize_data(var/newdata) // Called when the reagent is created.
	..()
	if (!data)
		data = list("temperature" = T20C)

//Handles setting the temperature when oils are mixed
/datum/reagent/nutriment/triglyceride/oil/mix_data(var/newdata, var/newamount)

	if (!data)
		data = list()

	var/ouramount = volume - newamount
	if (ouramount <= 0 || !data["temperature"] || !volume)
		//If we get here, then this reagent has just been created, just copy the temperature exactly
		data["temperature"] = newdata["temperature"]

	else
		//Our temperature is set to the mean of the two mixtures, taking volume into account
		var/total = (data["temperature"] * ouramount) + (newdata["temperature"] * newamount)
		data["temperature"] = total / volume

	return ..()


//Calculates a scaling factor for scalding damage, based on the temperature of the oil and creature's heat resistance
/datum/reagent/nutriment/triglyceride/oil/proc/heatdamage(var/mob/living/carbon/M)
	var/threshold = 360//Human heatdamage threshold
	var/datum/species/S = M.get_species(1)
	if (S && istype(S))
		threshold = S.heat_level_1

	//If temperature is too low to burn, return a factor of 0. no damage
	if (data["temperature"] < threshold)
		return 0

	//Step = degrees above heat level 1 for 1.0 multiplier
	var/step = 60
	if (S && istype(S))
		step = (S.heat_level_2 - S.heat_level_1)*1.5

	. = data["temperature"] - threshold
	. /= step
	. = min(., 2.5)//Cap multiplier at 2.5

/datum/reagent/nutriment/triglyceride/oil/affect_touch(var/mob/living/carbon/M, var/alien, var/removed)
	var/dfactor = heatdamage(M)
	if (dfactor)
		M.take_organ_damage(0, removed * 1.5 * dfactor)
		data["temperature"] -= (6 * removed) / (1 + volume*0.1)//Cools off as it burns you
		if (lastburnmessage+100 < world.time	)
			to_chat(M, span("danger", "Searing hot oil burns you, wash it off quick!"))
			lastburnmessage = world.time


/datum/reagent/nutriment/triglyceride/oil/corn
	name = "Corn Oil"
	id = "cornoil"
	description = "An oil derived from various types of corn."
	taste_description = "corn oil"

/datum/reagent/nutriment/honey
	name = "Honey"
	id = "honey"
	description = "A golden yellow syrup, loaded with sugary sweetness."
	nutriment_factor = 10
	color = "#FFFF00"
	taste_description = "honey"
	germ_adjust = 5

/datum/reagent/nutriment/flour
	name = "flour"
	id = "flour"
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = SOLID
	nutriment_factor = 1
	color = "#FFFFFF"
	taste_description = "chalky wheat"

/datum/reagent/nutriment/flour/touch_turf(var/turf/simulated/T)
	if(!istype(T, /turf/space))
		if(locate(/obj/effect/decal/cleanable/flour) in T)
			return

		new /obj/effect/decal/cleanable/flour(T)

/datum/reagent/nutriment/coco
	name = "Coco Powder"
	id = "coco"
	description = "A fatty, bitter paste made from coco beans."
	reagent_state = SOLID
	nutriment_factor = 5
	color = "#302000"
	taste_description = "bitterness"
	taste_mult = 1.3

/datum/reagent/nutriment/soysauce
	name = "Soysauce"
	id = "soysauce"
	description = "A salty sauce made from the soy plant."
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#792300"
	taste_description = "umami"
	taste_mult = 1.1

/datum/reagent/nutriment/ketchup
	name = "Ketchup"
	id = "ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#731008"
	taste_description = "ketchup"

/datum/reagent/nutriment/rice
	name = "Rice"
	id = "rice"
	description = "Enjoy the great taste of nothing."
	reagent_state = SOLID
	nutriment_factor = 1
	color = "#FFFFFF"
	taste_description = "rice"
	taste_mult = 0.4

/datum/reagent/nutriment/cherryjelly
	name = "Cherry Jelly"
	id = "cherryjelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	reagent_state = LIQUID
	nutriment_factor = 1
	color = "#801E28"
	taste_description = "cherry"
	taste_mult = 1.3

/datum/reagent/nutriment/virus_food
	name = "Virus Food"
	id = "virusfood"
	description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#899613"
	taste_description = "vomit"
	taste_mult = 2

/datum/reagent/nutriment/sprinkles
	name = "Sprinkles"
	id = "sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	nutriment_factor = 1
	color = "#FF00FF"
	taste_description = "sweetness"

/datum/reagent/nutriment/mint
	name = "Mint"
	id = "mint"
	description = "Also known as Mentha."
	reagent_state = LIQUID
	color = "#CF3600"
	taste_description = "mint"

/datum/reagent/nutriment/glucose
	name = "Glucose"
	id = "glucose"
	color = "#FFFFFF"
	injectable = 1
	taste_description = "sweetness"

/datum/reagent/lipozine // The anti-nutriment.
	name = "Lipozine"
	id = "lipozine"
	description = "A chemical compound that causes a powerful fat-burning reaction."
	reagent_state = LIQUID
	color = "#BBEDA4"
	overdose = REAGENTS_OVERDOSE
	taste_description = "mothballs"

/datum/reagent/lipozine/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.adjustNutritionLoss(10*removed)
	M.overeatduration = 0

/datum/reagent/nutriment/barbecue
	name = "Barbecue Sauce"
	id = "barbecue"
	description = "Barbecue sauce for barbecues and long shifts."
	taste_description = "barbecue"
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#4F330F"

/datum/reagent/nutriment/garlicsauce
	name = "Garlic Sauce"
	id = "garlicsauce"
	description = "Garlic sauce, perfect for spicing up a plate of garlic."
	taste_description = "garlic"
	reagent_state = LIQUID
	nutriment_factor = 4
	color = "#d8c045"

/* Non-food stuff like condiments */

/datum/reagent/sodiumchloride
	name = "Salt"
	id = "sodiumchloride"
	description = "A salt made of sodium chloride. Commonly used to season food."
	reagent_state = SOLID
	color = "#FFFFFF"
	overdose = REAGENTS_OVERDOSE
	taste_description = "salt"

/datum/reagent/sodiumchloride/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	M.intoxication -= min(M.intoxication,removed*2) //Salt absorbs alcohol
	M.adjustHydrationLoss(2*removed)

/datum/reagent/sodiumchloride/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.intoxication -= min(M.intoxication,removed*20)
	M.adjustHydrationLoss(20*removed)
	M.adjustToxLoss(removed*2)

/datum/reagent/blackpepper
	name = "Black Pepper"
	id = "blackpepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	reagent_state = SOLID
	color = "#000000"
	taste_description = "pepper"
	fallback_specific_heat = 1.25

/datum/reagent/enzyme
	name = "Universal Enzyme"
	id = "enzyme"
	description = "A universal enzyme used in the preperation of certain chemicals and foods."
	reagent_state = LIQUID
	color = "#365E30"
	overdose = REAGENTS_OVERDOSE
	taste_description = "sweetness"
	taste_mult = 0.7
	fallback_specific_heat = 1

/datum/reagent/frostoil
	name = "Frost Oil"
	id = "frostoil"
	description = "A special oil that chemically chills the body. Extracted from Ice Peppers."
	reagent_state = LIQUID
	color = "#B31008"
	taste_description = "mint"
	taste_mult = 1.5

	fallback_specific_heat = 15
	default_temperature = T0C - 20

/datum/reagent/frostoil/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.bodytemperature = max(M.bodytemperature - 10 * TEMPERATURE_DAMAGE_COEFFICIENT, 0)
	if(prob(1))
		M.emote("shiver")
	if(istype(M, /mob/living/carbon/slime))
		M.bodytemperature = max(M.bodytemperature - rand(10,20), 0)
	holder.remove_reagent("capsaicin", 5)

/datum/reagent/capsaicin
	name = "Capsaicin Oil"
	id = "capsaicin"
	description = "This is what makes chilis hot."
	reagent_state = LIQUID
	color = "#B31008"
	taste_description = "hot peppers"
	taste_mult = 1.5
	fallback_specific_heat = 2

	var/agony_dose = 5
	var/agony_amount = 1
	var/discomfort_message = "<span class='danger'>Your insides feel uncomfortably hot!</span>"
	var/slime_temp_adj = 10


/datum/reagent/capsaicin/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.adjustToxLoss(0.5 * removed)

/datum/reagent/capsaicin/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.can_feel_pain())
			return
	if(dose < agony_dose)
		if(prob(5) || dose == metabolism) //dose == metabolism is a very hacky way of forcing the message the first time this procs
			to_chat(M, discomfort_message)
	else
		M.apply_effect(agony_amount, AGONY, 0)
		if(prob(5))
			M.custom_emote(2, "[pick("dry heaves!","coughs!","splutters!")]")
			to_chat(M, "<span class='danger'>You feel like your insides are burning!</span>")
	if(istype(M, /mob/living/carbon/slime))
		M.bodytemperature += rand(0, 15) + slime_temp_adj
	holder.remove_reagent("frostoil", 5)

#define EYES_PROTECTED 1
#define EYES_MECH 2

/datum/reagent/capsaicin/condensed
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	description = "A chemical agent used for self-defense and in police work."
	taste_mult = 10
	reagent_state = LIQUID
	touch_met = 50 // Get rid of it quickly
	color = "#B31008"
	agony_dose = 0.5
	agony_amount = 4
	discomfort_message = "<span class='danger'>You feel like your insides are burning!</span>"
	slime_temp_adj = 15
	fallback_specific_heat = 4

/datum/reagent/capsaicin/condensed/affect_touch(var/mob/living/carbon/M, var/alien, var/removed)
	var/eyes_covered = 0
	var/mouth_covered = 0
	var/no_pain = 0
	var/obj/item/eye_protection = null
	var/obj/item/face_protection = null

	var/list/protection
	if(istype(M, /mob/living/carbon/human))
		if(M.isSynthetic())
			return
		var/mob/living/carbon/human/H = M
		protection = list(H.head, H.glasses, H.wear_mask)
		if(!H.can_feel_pain())
			no_pain = 1

		// Robo-eyes are immune to pepperspray now. Wee.
		var/obj/item/organ/eyes/E = H.get_eyes()
		if (istype(E) && (E.status & (ORGAN_ROBOT|ORGAN_ADV_ROBOT)))
			eyes_covered |= EYES_MECH
	else
		protection = list(M.wear_mask)

	for(var/obj/item/I in protection)
		if(I)
			if(I.body_parts_covered & EYES)
				eyes_covered |= EYES_PROTECTED
				eye_protection = I.name
			if((I.body_parts_covered & FACE) && !(I.item_flags & FLEXIBLEMATERIAL))
				mouth_covered = 1
				face_protection = I.name

	var/message = null
	if(eyes_covered)
		if (!mouth_covered && (eyes_covered & EYES_PROTECTED))
			message = "<span class='warning'>Your [eye_protection] protects your eyes from the pepperspray!</span>"
		else if (eyes_covered & EYES_MECH)
			message = "<span class='warning'>Your mechanical eyes are invulnurable to pepperspray!</span>"
	else
		message = "<span class='warning'>The pepperspray gets in your eyes!</span>"
		if(mouth_covered)
			M.eye_blurry = max(M.eye_blurry, 15)
			M.eye_blind = max(M.eye_blind, 5)
		else
			M.eye_blurry = max(M.eye_blurry, 25)
			M.eye_blind = max(M.eye_blind, 10)

	if(mouth_covered)
		if(!message)
			message = "<span class='warning'>Your [face_protection] protects you from the pepperspray!</span>"
	else if(!no_pain)
		message = "<span class='danger'>Your face and throat burn!</span>"
		if(prob(25))
			M.custom_emote(2, "[pick("coughs!","coughs hysterically!","splutters!")]")
		M.apply_effect(40, AGONY, 0)

/datum/reagent/capsaicin/condensed/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.can_feel_pain())
			return
	if(dose == metabolism)
		to_chat(M, "<span class='danger'>You feel like your insides are burning!</span>")
	else
		M.apply_effect(4, AGONY, 0)
		if(prob(5))
			M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>", "<span class='danger'>You feel like your insides are burning!</span>")
	if(istype(M, /mob/living/carbon/slime))
		M.bodytemperature += rand(15, 30)
	holder.remove_reagent("frostoil", 5)

#undef EYES_PROTECTED
#undef EYES_MECH

/datum/reagent/spacespice
	name = "Space Spice"
	id = "spacespice"
	description = "An exotic blend of spices for cooking. It must flow."
	reagent_state = SOLID
	color = "#e08702"
	taste_description = "spices"
	taste_mult = 1.5
	fallback_specific_heat = 2

/datum/reagent/browniemix
	name = "Brownie Mix"
	id = "browniemix"
	description = "A dry mix for making delicious brownies."
	reagent_state = SOLID
	color = "#441a03"
	taste_description = "chocolate"

/* Drinks */

/datum/reagent/drink
	name = "Drink"
	id = "drink"
	description = "Uh, some kind of drink."
	reagent_state = LIQUID
	metabolism = REM * 10
	color = "#E78108"
	var/nutrition = 0 // Per unit
	var/hydration = 8 // Per unit
	var/adj_dizzy = 0 // Per tick
	var/adj_drowsy = 0
	var/adj_sleepy = 0
	var/adj_temp = 0 //do NOT use for temp changes based on the temperature of the drinks, only for things such as spices.
	var/caffeine = 0 // strength of stimulant effect, since so many drinks use it
	var/datum/modifier/modifier = null
	unaffected_species = IS_MACHINE
	var/blood_to_ingest_scale = 2
	fallback_specific_heat = 1.75

/datum/reagent/drink/Destroy()
	if (modifier)
		QDEL_NULL(modifier)
	return ..()

/datum/reagent/drink/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	digest(M,alien,removed * blood_to_ingest_scale, FALSE)

/datum/reagent/drink/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	digest(M,alien,removed)

/datum/reagent/drink/proc/digest(var/mob/living/carbon/M, var/alien, var/removed, var/add_nutrition = TRUE)
	if (caffeine && !modifier)
		modifier = M.add_modifier(/datum/modifier/stimulant, MODIFIER_REAGENT, src, _strength = caffeine, override = MODIFIER_OVERRIDE_STRENGTHEN)
	M.dizziness = max(0, M.dizziness + adj_dizzy)
	M.drowsyness = max(0, M.drowsyness + adj_drowsy)
	M.sleeping = max(0, M.sleeping + adj_sleepy)

	if(add_nutrition == TRUE)
		M.adjustHydrationLoss(-hydration * removed)
		M.adjustNutritionLoss(-nutrition * removed)

	if(adj_temp > 0 && M.bodytemperature < 310) // 310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))
	if(adj_temp < 0 && M.bodytemperature > 310)
		M.bodytemperature = min(310, M.bodytemperature - (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))

// Juices
/datum/reagent/drink/banana
	name = "Banana Juice"
	id = "banana"
	description = "The raw essence of a banana."
	color = "#C3AF00"
	taste_description = "banana"

	glass_icon_state = "banana"
	glass_name = "glass of banana juice"
	glass_desc = "The raw essence of a banana. HONK!"

/datum/reagent/drink/berryjuice
	name = "Berry Juice"
	id = "berryjuice"
	description = "A delicious blend of several different kinds of berries."
	color = "#990066"
	taste_description = "berries"

	glass_icon_state = "berryjuice"
	glass_name = "glass of berry juice"
	glass_desc = "Berry juice. Or maybe it's jam. Who cares?"

/datum/reagent/drink/carrotjuice
	name = "Carrot juice"
	id = "carrotjuice"
	description = "It is just like a carrot but without crunching."
	color = "#FF8C00" // rgb: 255, 140, 0
	taste_description = "carrots"

	glass_icon_state = "carrotjuice"
	glass_name = "glass of carrot juice"
	glass_desc = "It is just like a carrot but without crunching."

/datum/reagent/drink/carrotjuice/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.reagents.add_reagent("imidazoline", removed * 0.2)

/datum/reagent/drink/grapejuice
	name = "Grape Juice"
	id = "grapejuice"
	description = "It's grrrrrape!"
	color = "#863333"
	taste_description = "grapes"

	glass_icon_state = "grapejuice"
	glass_name = "glass of grape juice"
	glass_desc = "It's grrrrrape!"

/datum/reagent/drink/lemonjuice
	name = "Lemon Juice"
	id = "lemonjuice"
	description = "This juice is VERY sour."
	color = "#AFAF00"
	taste_description = "sourness"

	glass_icon_state = "lemonjuice"
	glass_name = "glass of lemon juice"
	glass_desc = "Sour..."

/datum/reagent/drink/limejuice
	name = "Lime Juice"
	id = "limejuice"
	description = "The sweet-sour juice of limes."
	color = "#365E30"
	taste_description = "tart citrus"
	taste_mult = 1.1

	glass_icon_state = "glass_green"
	glass_name = "glass of lime juice"
	glass_desc = "A glass of sweet-sour lime juice"

/datum/reagent/drink/limejuice/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.adjustToxLoss(-0.5 * removed)

/datum/reagent/drink/orangejuice
	name = "Orange juice"
	id = "orangejuice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"
	color = "#E78108"
	taste_description = "oranges"

	glass_icon_state = "glass_orange"
	glass_name = "glass of orange juice"
	glass_desc = "Vitamins! Yay!"

/datum/reagent/drink/orangejuice/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.adjustOxyLoss(-2 * removed)

/datum/reagent/toxin/poisonberryjuice // It has more in common with toxins than drinks... but it's a juice
	name = "Poison Berry Juice"
	id = "poisonberryjuice"
	description = "A tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#863353"
	strength = 5
	taste_description = "berries"

	glass_icon_state = "poisonberryjuice"
	glass_name = "glass of poison berry juice"
	glass_desc = "A glass of deadly juice."

/datum/reagent/drink/potato_juice
	name = "Potato Juice"
	id = "potato"
	description = "Juice of the potato. Bleh."
	nutrition = 2
	color = "#302000"
	taste_description = "potato"

	glass_icon_state = "glass_brown"
	glass_name = "glass of potato juice"
	glass_desc = "Juice from a potato. Bleh."

/datum/reagent/drink/tomatojuice
	name = "Tomato Juice"
	id = "tomatojuice"
	description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
	color = "#731008"
	taste_description = "tomatoes"

	glass_icon_state = "glass_red"
	glass_name = "glass of tomato juice"
	glass_desc = "Are you sure this is tomato juice?"

/datum/reagent/drink/tomatojuice/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.heal_organ_damage(0, 0.1 * removed)

/datum/reagent/drink/watermelonjuice
	name = "Watermelon Juice"
	id = "watermelonjuice"
	description = "Delicious juice made from watermelon."
	color = "#B83333"
	taste_description = "watermelon"

	glass_icon_state = "glass_red"
	glass_name = "glass of watermelon juice"
	glass_desc = "Delicious juice made from watermelon."

/datum/reagent/drink/pineapplejuice
	name = "Pineapple Juice"
	id = "pineapplejuice"
	description = "From freshly canned pineapples."
	color = "#FFFF00"
	taste_description = "pineapple"

	glass_icon_state = "lemonjuice"
	glass_name = "glass of pineapple juice"
	glass_desc = "What the hell is this?"

/datum/reagent/drink/earthenrootjuice
	name = "Earthen-Root Juice"
	id = "earthenrootjuice"
	description = "Juice extracted from earthen-root, a plant native to Adhomai."
	color = "#4D8F53"
	taste_description = "sweetness"

	glass_icon_state = "bluelagoon"
	glass_name = "glass of earthen-root juice"
	glass_desc = "Juice extracted from earthen-root, a plant native to Adhomai."

/datum/reagent/drink/juice/garlic
	name = "Garlic Juice"
	id = "garlicjuice"
	description = "Who would even drink this?"
	taste_description = "garlic"
	nutrition = 1
	color = "#eeddcc"

	glass_name = "glass of garlic juice"
	glass_desc = "Who would even drink juice from garlic?"

	germ_adjust = 7.5 // has allicin, an antibiotic

/datum/reagent/drink/juice/onion
	name = "Onion Juice"
	id = "onionjuice"
	description = "Juice from an onion, for when you need to cry."
	taste_description = "onion"
	nutrition = 1
	color = "#ffeedd"

	glass_name = "glass of onion juice"
	glass_desc = "Juice from an onion, for when you need to cry."

/datum/reagent/drink/applejuice
	name = "Apple Juice"
	id = "applejuice"
	description = "Juice from an apple. The most basic beverage you can imagine."
	taste_description = "apple juice"
	color = "#f2d779"

	glass_icon_state = "glass_apple"
	glass_name = "glass of apple juice"
	glass_desc = "Juice from an apple. The most basic beverage you can imagine."

/datum/reagent/drink/dynjuice
	name = "Dyn Juice"
	id = "dynjuice"
	description = "Juice from a dyn leaf. Good for you, but normally not consumed undiluted."
	taste_description = "astringent menthol"
	color = "#00e0e0"

	glass_icon_state = "dynjuice"
	glass_name = "glass of dyn juice"
	glass_desc = "Juice from a dyn leaf. Good for you, but normally not consumed undiluted."

/datum/reagent/drink/dynjuice/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.adjustToxLoss(-0.3 * removed)


/datum/reagent/drink/dynjuice/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.adjustToxLoss(-0.3 * removed)

/datum/reagent/drink/dynjuice/hot
	name = "Angel Grass Tea"
	id = "dynhot"
	taste_description = "peppermint water"
	description = "A tea made from a newly-discovered local shrub. Contains a chemical similar to dylovene."

	glass_icon_state = "dynhot"
	glass_name = "cup of angel grass tea"
	glass_desc = "A tea made from a newly-discovered local shrub. Contains a chemical similar to dylovene."

/datum/reagent/drink/dynjuice/cold
	name = "Iced Angel Grass Tea"
	id = "dyncold"
	taste_description = "fizzy mint tea"
	description = "Cold tea made from angel grass. Known to purge toxins from the body."

	glass_icon_state = "dyncold"
	glass_name = "glass of iced angel grass tea"
	glass_desc = "Cold tea made from angel grass. Known to purge toxins from the body."

// Everything else

/datum/reagent/drink/milk
	name = "Milk"
	id = "milk"
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#DFDFDF"
	taste_description = "milk"

	glass_icon_state = "glass_white"
	glass_name = "glass of milk"
	glass_desc = "White and nutritious goodness!"

	default_temperature = T0C + 5

/datum/reagent/drink/milk/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.heal_organ_damage(0.1 * removed, 0)
	holder.remove_reagent("capsaicin", 10 * removed)

/datum/reagent/drink/milk/cream
	name = "Cream"
	id = "cream"
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	color = "#DFD7AF"
	taste_description = "creamy milk"

	glass_icon_state = "glass_white"
	glass_name = "glass of cream"
	glass_desc = "Ewwww..."

/datum/reagent/drink/milk/soymilk
	name = "Soy Milk"
	id = "soymilk"
	description = "An opaque white liquid made from soybeans."
	color = "#DFDFC7"
	taste_description = "soy milk"

	glass_icon_state = "glass_white"
	glass_name = "glass of soy milk"
	glass_desc = "White and nutritious soy goodness!"

/datum/reagent/drink/milk/beetle
	name = "Purring Maggot Milk"
	id = "beetle_milk"
	description = "A milky substance secreted in bulk by the purring maggot, an annelid native to the kobold homeworld."
	nutrition = 4
	color = "#FFF8AD"
	taste_description = "alien milk"

	glass_name = "glass of purring maggot milk"
	glass_desc = "A milky substance secreted in bulk by the purring maggot, an annelid native to the kobold homeworld."

/datum/reagent/drink/tea
	name = "Tea"
	id = "tea"
	description = "Tasty black tea, it has antioxidants, it's good for you!"
	color = "#101000"
	adj_dizzy = -2
	adj_drowsy = -1
	adj_sleepy = -3
	taste_description = "tart black tea"

	glass_icon_state = "bigteacup"
	glass_name = "cup of tea"
	glass_desc = "Tasty black tea, it has antioxidants, it's good for you!"

	var/last_taste_time = -100

/datum/reagent/drink/tea/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.adjustToxLoss(-0.1 * removed)


/datum/reagent/drink/tea/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.adjustToxLoss(-0.1 * removed)

/datum/reagent/drink/tea/icetea
	name = "Iced Tea"
	id = "icetea"
	description = "Like tea, but with ice in it."
	color = "#984707"
	taste_description = "sweet tea"

	glass_icon_state = "icedteaglass"
	glass_name = "glass of iced tea"
	glass_desc = "Like tea, but with ice in it."
	glass_center_of_mass = list("x"=15, "y"=10)

//Hipster tea and cider drinks to go along with hipster coffee drinks

/datum/reagent/drink/tea/chaitea
	name = "Chai Tea"
	id = "chaitea"
	description = "A tea spiced with cinnamon and cloves."
	color = "#DBAD81"
	taste_description = "creamy cinnamon and spice"

	glass_icon_state = "chaitea"
	glass_name = "cup of chai tea"
	glass_desc = "A tea spiced with cinnamon and cloves."

/datum/reagent/drink/tea/coco_chaitea
	name = "Chocolate Chai"
	id = "coco_chaitea"
	description = "A surprisingly pleasant mix of chocolate and spice."
	color = "#664300"
	taste_description = "creamy spiced cocoa"

	glass_icon_state = "coco_chaitea"
	glass_name = "cup of chocolate chai tea"
	glass_desc = "A surprisingly pleasant mix of chocolate and spice."

/datum/reagent/drink/tea/chailatte
	name = "Chai Latte"
	id = "chailatte"
	description = "A frothy spiced tea."
	color = "#DBAD81"
	taste_description = "spiced milk foam"

	glass_icon_state = "chailatte"
	glass_name = "cup of chai latte"
	glass_desc = "For when you need the energy to yell at the barista for making your drink wrong."

/datum/reagent/drink/tea/chailatte/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed) //milk effects
	..()
	M.heal_organ_damage(0.1 * removed, 0)
	holder.remove_reagent("capsaicin", 10 * removed)


/datum/reagent/drink/tea/coco_chailatte
	name = "Chocolate Chai Latte"
	id = "coco_chailatte"
	description = "Sweet, liquid chocolate. Have a cup of this and maybe you'll calm down."
	color = "#664300"
	taste_description = "spiced milk chocolate"

	glass_icon_state = "coco_chailatte"
	glass_name = "cup of chocolate chai latte"
	glass_desc = "Sweet, liquid chocolate. Have a cup of this and maybe you'll calm down."

/datum/reagent/drink/tea/coco_chailatte/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed) //milk effects
	..()
	M.heal_organ_damage(0.1 * removed, 0)
	holder.remove_reagent("capsaicin", 10 * removed)

/datum/reagent/drink/tea/cofftea
	name = "Cofftea"
	id = "cofftea"
	description = "The only neutral ground in the tea versus coffee debate."
	color = "#292303"
	adj_dizzy = -3
	adj_drowsy = -3
	adj_sleepy = -2
	caffeine = 0.1
	taste_description = "lightly tart coffee"

	glass_icon_state = "cofftea"
	glass_name = "cup of cofftea"
	glass_desc = "The only neutral ground in the tea versus coffee debate."

/datum/reagent/drink/tea/bureacratea
	name = "Commi-tea"
	id = "bureacratea"
	description = "A favorite among the middle rungs of Loamer society. Great for attacking another twenty hour shift."
	color = "#2B1902"
	adj_dizzy = -2
	adj_drowsy = -3
	adj_sleepy = -3
	caffeine = 0.3
	taste_description = "properly completed paperwork, filed well before the deadline, with all the necessary signatures"

	glass_icon_state = "bureacratea"
	glass_name = "cup of bureacratea"
	glass_desc = "A favorite among the middle rungs of Loamer society. Great for attacking another twenty hour shift."

/datum/reagent/drink/tea/desert_tea //not in butanol path since xuizi is strength 5 by itself so the alcohol content is negligible when mixed
	name = "Desert Blossom Tea"
	id = "desert_tea"
	description = "A simple, semi-sweet tea from Moghes, that uses a little xuizi juice for flavor."
	color = "#A8F062"
	taste_description = "sweet cactus water"

	glass_icon_state = "deserttea"
	glass_name = "cup of desert blossom tea"
	glass_desc = "A simple, semi-sweet tea from Moghes, popular with guildsmen and peasants."

/datum/reagent/drink/tea/greentea
	name = "Green Tea"
	id = "greentea"
	description = "Tasty green tea. It's good for you!"
	color = "#B7C49D"
	taste_description = "light, refreshing tea"

	glass_icon_state = "bigteacup"
	glass_name = "cup of green tea"
	glass_desc = "Tasty green tea. It's good for you!"

/datum/reagent/drink/tea/halfandhalf
	name = "Half and Half"
	id = "halfandhalf"
	description = "Tea and lemonade; not to be confused with the dairy creamer."
	color = "#997207"
	taste_description = "refreshing tea mixed with crisp lemonade"

	glass_icon_state = "halfandhalf"
	glass_name = "glass of half and half"
	glass_desc = "Tea and lemonade; not to be confused with the dairy creamer."

/datum/reagent/drink/tea/heretic_tea
	name = "Heretics' Tea"
	id = "heretic_tea"
	description = "A non-alcoholic take on a bloody brew."
	color = "#820000"
	taste_description = "fizzy, heretically sweet iron"
	carbonated = TRUE

	glass_icon_state = "heretictea"
	glass_name = "glass of Heretics' Tea"
	glass_desc = "A non-alcoholic take on a bloody brew."

/datum/reagent/drink/tea/kira_tea
	name = "Kira Tea"
	id = "kira_tea"
	description = "A sweet take on a fizzy favorite."
	color = "#8A8A57"
	taste_description = "fizzy citrus tea"
	carbonated = TRUE

	glass_icon_state = "kiratea"
	glass_name = "glass of kira tea"
	glass_desc = "A sweet take on a fizzy favorite."

/datum/reagent/drink/tea/librarian_special
	name = "Librarian Special"
	id = "librarian_special"
	description = "Shhhhhh!"
	color = "#101000"
	taste_description = "peace and quiet"

	glass_icon_state = "bureacratea"
	glass_name = "cup of Librarian Special"
	glass_desc = "Shhhhhh!"

/datum/reagent/drink/tea/librarian_special/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.silent += 3

/datum/reagent/drink/tea/mars_tea
	name = "Bold Tea"
	id = "mars_tea"
	description = "A bold and robust-smelling tea. It's very liberating."
	color = "#101000"
	taste_description = "bitter tea, pungent black pepper and just a hint of broken chains"

	glass_icon_state = "bigteacup"
	glass_name = "cup of martian tea"
	glass_desc = "A bold and robust-smelling tea. It's very liberating."

/datum/reagent/drink/tea/mendell_tea
	name = "Civili-Tea"
	id = "mendell_tea"
	description = "Can't we all just get along? :)"
	color = "#859466"
	taste_description = "peppery contention with a smooth tv static finish"

	glass_icon_state = "mendelltea"
	glass_name = "Civili-Tea"
	glass_desc = "Can't we all just get along? :)"

/datum/reagent/drink/tea/berry_tea
	name = "Mixed Berry Tea"
	id = "berry_tea"
	description = "Hot tea with a sweet, fruity taste!"
	color = "#2E0206"
	taste_description = "tart, fruity tea"

	glass_icon_state = "berrytea"
	glass_name = "cup of mixed berry tea"
	glass_desc = "Hot tea with a sweet, fruity taste!"

/datum/reagent/drink/tea/pomegranate_icetea
	name = "Pomegranate Iced Tea"
	id = "pomegranate_icetea"
	description = "A refreshing, fruity tea. No fruit was harmed in the making of this drink."
	color = "#302109"
	taste_description = "sweet pomegranate"

	glass_icon_state = "pomegranatetea"
	glass_name = "glass of pomegranate iced tea"
	glass_desc = "A refreshing, fruity tea. No fruit was harmed in the making of this drink."

/datum/reagent/drink/tea/portsvilleminttea
	name = "Pa'an Mint Tea"
	id = "portsvilleminttea"
	description = "A popular iced pick-me-up originating from the warm, island world of Pa'an."
	color = "#b6f442"
	taste_description = "cool minty tea"

	glass_icon_state = "portsvilleminttea"
	glass_name = "glass of Pa'an Mint Tea"
	glass_desc = "A popular iced pick-me-up originating from the warm, island world of Pa'an."

/datum/reagent/drink/tea/potatea
	name = "Potatea"
	id = "potatea"
	description = "Why would you ever drink this?"
	color = "#2B2710"
	nutrition = 0.2
	taste_description = "starchy regret"

	glass_icon_state = "bigteacup"
	glass_name = "cup of potatea"
	glass_desc = "Why would you ever drink this?"

/datum/reagent/drink/tea/securitea
	name = "Securitea"
	id = "securitea"
	description = "Stop resisting!"
	color = "#030B36"
	taste_description = "freshly polished boots"

	glass_icon_state = "securitea"
	glass_name = "cup of securitea"
	glass_desc = "Stop resisting!"

/datum/reagent/drink/tea/sleepytime_tea
	name = "Sleepytime Tea"
	id = "sleepytime_tea"
	description = "The perfect drink to enjoy before falling asleep in your favorite chair."
	color = "#101000"
	adj_drowsy = 1
	adj_sleepy = 1
	taste_description = "liquid relaxation"

	glass_icon_state = "sleepytea"
	glass_name = "cup of sleepytime tea"
	glass_desc = "The perfect drink to enjoy before falling asleep in your favorite chair."

/datum/reagent/drink/tea/hakhma_tea
	name = "Purring Maggot Tea"
	id = "hakhma_tea"
	description = "A tea often brewed by Kobolds during major holidays or community functions."
	color = "#8F6742"
	nutrition = 1 //hakhma milk has nutrition 4
	taste_description = "creamy, cinnamon-spiced alien milk"

	glass_icon_state = "hakhmatea"
	glass_name = "cup of spiced hakhma tea"
	glass_desc = "A tea often brewed by Kobolds during major holidays or community functions."

/datum/reagent/drink/tea/hakhma_tea/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed) //milk effects
	..()
	M.heal_organ_damage(0.1 * removed, 0)
	holder.remove_reagent("capsaicin", 10 * removed)

/datum/reagent/drink/tea/sweet_tea
	name = "Sweet Tea"
	id = "sweet_tea"
	description = "Hope you have a good dentist!"
	color = "#984707"
	taste_description = "sweet sugary comfort"

	glass_icon_state = "icedteaglass"
	glass_name = "glass of sweet tea"
	glass_desc = "Hope you have a good dentist!"

/datum/reagent/drink/dynjuice/thewake //dyn properties
	name = "Spine Tingler"
	id = "thewake"
	description = "A mixture of local herbs. Highly caffienated, and with an interesting flavor. Humans don't seem to like it for some reason."
	color = "#00E0E0"
	adj_dizzy = -3
	adj_drowsy = -3
	adj_sleepy = -3
	taste_description = "Intensely bitter acid"

	glass_icon_state = "thewake"
	glass_name = "cup of Spine Tingler"
	glass_desc = "Smells like oranges and mint!"

/datum/reagent/drink/tea/tomatea
	name = "Tomatea"
	id = "tomatea"
	description = "Basically tomato soup in a mug."
	color = "#9F3400"
	taste_description = "sad tomato soup"

	glass_icon_state = "bigteacup"
	glass_name = "cup of tomatea"
	glass_desc = "Basically tomato soup in a mug."

/datum/reagent/drink/tea/tomatea/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.heal_organ_damage(0, 0.1 * removed) //has tomato juice

/datum/reagent/drink/tea/tropical_icetea
	name = "Tropical Iced Tea"
	id = "tropical_icetea"
	description = "For maximum enjoyment, drink while at the beach on a warm summer day."
	color = "#773404"
	taste_description = "sweet beachside fruit"

	glass_icon_state = "junglejuice"
	glass_name = "glass of tropical iced tea"
	glass_desc = "For maximum enjoyment, drink while at the beach on a warm summer day."


//Coffee
//==========

/datum/reagent/drink/coffee
	name = "Coffee"
	id = "coffee"
	description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
	color = "#482000"
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	overdose = 45
	caffeine = 0.3
	taste_description = "coffee"
	taste_mult = 1.3

	glass_icon_state = "hot_coffee"
	glass_name = "cup of coffee"
	glass_desc = "Don't drop it, or you'll send scalding liquid and glass shards everywhere."

/datum/reagent/drink/coffee/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	if(adj_temp > 0)
		holder.remove_reagent("frostoil", 10 * removed)

	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))


		M.dizziness = max(0, M.dizziness - 5)
		M.drowsyness = max(0, M.drowsyness - 3)
		M.sleeping = max(0, M.sleeping - 2)
		M.intoxication = max(0, (M.intoxication - (removed*0.25)))

/datum/reagent/drink/coffee/overdose(var/mob/living/carbon/M, var/alien)

		M.make_jittery(5)

/datum/reagent/drink/coffee/icecoffee
	name = "Frappe Coffee"
	id = "icecoffee"
	description = "Coffee and ice, refreshing and cool."
	color = "#102838"

	glass_icon_state = "frappe"
	glass_name = "glass of frappe coffee"
	glass_desc = "A drink to perk you up and refresh you!"

/datum/reagent/drink/coffee/soy_latte
	name = "Soy Latte"
	id = "soy_latte"
	description = "A nice and tasty beverage. Rumored to transform people into women."
	color = "#664300"
	taste_description = "creamy coffee"

	glass_icon_state = "soy_latte"
	glass_name = "glass of soy latte"
	glass_desc = "A nice and refreshing beverage to enjoy while reading."
	glass_center_of_mass = list("x"=15, "y"=9)

/datum/reagent/drink/coffee/soy_latte/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.heal_organ_damage(0.1 * removed, 0)

/datum/reagent/drink/coffee/cafe_latte
	name = "Cafe Latte"
	id = "cafe_latte"
	description = "A nice, strong and tasty beverage to enjoy while reading."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "bitter cream"

	glass_icon_state = "cafe_latte"
	glass_name = "glass of cafe latte"
	glass_desc = "A nice, strong and refreshing beverage to enjoy while reading."
	glass_center_of_mass = list("x"=15, "y"=9)

/datum/reagent/drink/coffee/cafe_latte/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.heal_organ_damage(0.1 * removed, 0)

/datum/reagent/drink/coffee/espresso
	name = "Espresso"
	id = "espresso"
	description = "A strong coffee made by passing nearly boiling water through coffee seeds at high pressure."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "bitter coffee"

	glass_icon_state = "hot_coffee"
	glass_name = "shot of espresso"
	glass_desc = "A strong coffee made by passing nearly boiling water through coffee seeds at high pressure."
	glass_center_of_mass = list("x"=15, "y"=9)

/datum/reagent/drink/coffee/freddo_espresso
	name = "Iced espresso"
	id = "freddo_espresso"
	description = "Espresso with ice cubes poured over ice."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "cold and bitter coffee"

	glass_icon_state = "hot_coffee"
	glass_name = "glass of freddo espresso"
	glass_desc = "Espresso with ice cubes poured over ice."
	glass_center_of_mass = list("x"=15, "y"=9)

/datum/reagent/drink/coffee/caffe_americano
	name = "Loamer special"
	id = "caffe_americano"
	description = "Watered down coffee."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "watery coffee"

	glass_icon_state = "hot_coffee"
	glass_name = "glass of Loamer special"
	glass_desc = "Watered down coffee."
	glass_center_of_mass = list("x"=15, "y"=9)

/datum/reagent/drink/coffee/flat_white
	name = "Flat White Espresso"
	id = "flat_white"
	description = "Espresso with a bit of steamy hot milk."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "bitter coffee and milk"

	glass_icon_state = "cafe_latte"
	glass_name = "glass of flat white"
	glass_desc = "Espresso with a bit of steamy hot milk."
	glass_center_of_mass = list("x"=15, "y"=9)

/datum/reagent/drink/coffee/latte
	name = "Latte"
	id = "latte"
	description = "A nice, strong, and refreshing beverage to enjoy while reading."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "bitter cream"

	glass_icon_state = "cafe_latte"
	glass_name = "glass of cafe latte"
	glass_desc = "A nice, strong, and refreshing beverage to enjoy while reading."
	glass_center_of_mass = list("x"=15, "y"=9)

/datum/reagent/drink/coffee/latte/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.heal_organ_damage(0.1 * removed, 0)

/datum/reagent/drink/coffee/cappuccino
	name = "Cappuccino"
	id = "cappuccino"
	description = "Espresso with steamed milk foam."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "bitter milk foam"

	glass_icon_state = "hot_coffee"
	glass_name = "glass of cappuccino"
	glass_desc = "Espresso with steamed milk foam."
	glass_center_of_mass = list("x"=15, "y"=9)

/datum/reagent/drink/coffee/freddo_cappuccino
	name = "Freddo Cappuccino"
	id = "freddo_cappuccino"
	description = "Espresso with steamed milk foam, on ice."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "cold and bitter milk foam"

	glass_icon_state = "hot_coffee"
	glass_name = "glass of freddo cappuccino"
	glass_desc = "Espresso with steamed milk foam, on ice."
	glass_center_of_mass = list("x"=15, "y"=9)

/datum/reagent/drink/coffee/macchiato
	name = "Macchiato"
	id = "macchiato"
	description = "Espresso with milk foam."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "bitter milk foam"

	glass_icon_state = "hot_coffee"
	glass_name = "glass of macchiato"
	glass_desc = "Espresso with milk foam."
	glass_center_of_mass = list("x"=15, "y"=9)

/datum/reagent/drink/coffee/mocacchino
	name = "Mocacchino"
	id = "mocacchino"
	description = "Espresso with hot milk and chocolate."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "sweet milk and bitter coffee"

	glass_icon_state = "cafe_latte"
	glass_name = "glass of mocacchino"
	glass_desc = "Espresso with hot milk and chocolate."
	glass_center_of_mass = list("x"=15, "y"=9)

/datum/reagent/drink/coffee/icecoffee/psfrappe
	name = "Pumpkin Spice Frappe"
	id = "psfrappe"
	description = "A seasonal treat popular around the autumn times."
	color = "#9C6B19"
	taste_description = "autumn bliss and coffee"

	glass_icon_state = "frappe_psl"
	glass_name = "glass of pumpkin spice frappe"
	glass_desc = "A seasonal treat popular around the autumn times."

/datum/reagent/drink/coffee/pslatte
	name = "Pumpkin Spice Latte"
	id = "pslatte"
	description = "A seasonal drink favored in autumn."
	color = "#9C6B19"
	taste_description = "hot creamy coffee and autumn bliss"

	glass_icon_state = "psl_cheap"
	glass_name = "cup of pumpkin spice latte"
	glass_desc = "A hot cup of pumpkin spiced coffee. Autumn really is the best season!"

/datum/reagent/drink/coffee/sadpslatte
	name = "Processed Pumpkin Latte"
	id = "sadpslatte"
	description = "A processed drink vaguely reminicent of autumn bliss."
	color = "#9C6B19"
	taste_description = "a disappointing approximation of autumn bliss"

	glass_icon_state = "psl_cheap"
	glass_name = "cup of cheap pumpkin latte"
	glass_desc = "Maybe you should just go ask the barista for something more authentic..."

/datum/reagent/drink/coffee/mars
	name = "Kob-ffee"
	id = "mars_coffee"
	description = "Bold and robust coffee, heavily peppered."
	taste_description = "bitter coffee, pungent black pepper and the strong flavor of broken chains"

	glass_icon_state = "hot_coffee"
	glass_name = "cup of Kob-ffee"
	glass_desc = "Kob-ffee: now in new extra bold."

/datum/reagent/drink/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Made with love! And cocoa beans."
	reagent_state = LIQUID
	color = "#403010"
	nutrition = 2
	taste_description = "creamy chocolate"

	glass_icon_state = "chocolateglass"
	glass_name = "glass of hot chocolate"
	glass_desc = "Made with love! And cocoa beans."

/datum/reagent/drink/sodawater
	name = "Soda Water"
	id = "sodawater"
	description = "A can of club soda. Why not make a scotch and soda?"
	color = "#619494"
	adj_dizzy = -5
	adj_drowsy = -3
	taste_description = "carbonated water"
	carbonated = TRUE

	glass_icon_state = "glass_clear"
	glass_name = "glass of soda water"
	glass_desc = "Soda water. Why not make a scotch and soda?"

/datum/reagent/drink/grapesoda
	name = "Grape Soda"
	id = "grapesoda"
	description = "Grapes made into a fine drank."
	color = "#421C52"
	adj_drowsy = -3
	taste_description = "grape soda"
	carbonated = TRUE

	glass_icon_state = "gsodaglass"
	glass_name = "glass of grape soda"
	glass_desc = "Looks like a delicious drink!"

/datum/reagent/drink/tonic
	name = "Tonic Water"
	id = "tonic"
	description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
	color = "#664300"
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	taste_description = "tart and fresh"
	carbonated = TRUE

	glass_icon_state = "glass_clear"
	glass_name = "glass of tonic water"
	glass_desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."

/datum/reagent/drink/lemonade
	name = "Lemonade"
	description = "Oh the nostalgia..."
	id = "lemonade"
	color = "#FFFF00"
	taste_description = "tartness"

	glass_icon_state = "lemonadeglass"
	glass_name = "glass of lemonade"
	glass_desc = "Oh the nostalgia..."

/datum/reagent/drink/lemonade/pink
	name = "Pink Lemonade"
	description = "A fruity pink citrus drink."
	id = "pinklemonade"
	color = "#FFC0CB"
	taste_description = "girly tartness"

	glass_icon_state = "pinklemonade"
	glass_name = "glass of pink lemonade"
	glass_desc = "You feel girlier just looking at this."

/datum/reagent/drink/kiraspecial
	name = "Amateur Chemist"
	description = "Wh-what do you mean 'guwan'...?"
	id = "kiraspecial"
	color = "#CCCC99"
	taste_description = "sweet syrup and antidepressants"
	carbonated = TRUE

	glass_icon_state = "kiraspecial"
	glass_name = "glass of Amateur Chemist"
	glass_desc = "Wh-what do you mean 'guwan'...?"
	glass_center_of_mass = list("x"=16, "y"=12)

/datum/reagent/drink/brownstar
	name = "Brown Star"
	description = "It's not what it sounds like..."
	id = "brownstar"
	color = "#9F3400"
	taste_description = "orange and cola soda"
	carbonated = TRUE

	glass_icon_state = "brownstar"
	glass_name = "glass of Brown Star"
	glass_desc = "It's not what it sounds like..."

/datum/reagent/drink/mintsyrup
	name = "Mint Syrup"
	description = "A simple syrup that tastes strongly of mint."
	id = "mintsyrup"
	color = "#539830"
	taste_description = "mint"

	glass_icon_state = "mint_syrupglass"
	glass_name = "glass of mint syrup"
	glass_desc = "Pure mint syrup. Prepare your tastebuds."
	glass_center_of_mass = list("x"=17, "y"=6)

/datum/reagent/drink/milkshake
	name = "Milkshake"
	description = "Glorious brainfreezing mixture."
	id = "milkshake"
	color = "#AEE5E4"
	taste_description = "creamy vanilla"

	glass_icon_state = "milkshake"
	glass_name = "glass of milkshake"
	glass_desc = "Glorious brainfreezing mixture."
	glass_center_of_mass = list("x"=16, "y"=7)

/datum/reagent/drink/rewriter
	name = "Rewriter"
	description = "The secret of the sanctuary of the Libarian..."
	id = "rewriter"
	color = "#485000"
	caffeine = 0.4
	taste_description = "soda and coffee"
	carbonated = TRUE

	glass_icon_state = "rewriter"
	glass_name = "glass of Rewriter"
	glass_desc = "The secret of the sanctuary of the Libarian..."
	glass_center_of_mass = list("x"=16, "y"=9)

/datum/reagent/drink/rewriter/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.make_jittery(5)

/datum/reagent/drink/nuka_cola
	name = "Nuka Cola"
	id = "nuka_cola"
	description = "Cola, cola never changes."
	color = "#100800"
	adj_sleepy = -2
	caffeine = 1
	taste_description = "cola"
	carbonated = TRUE

	glass_icon_state = "nuka_colaglass"
	glass_name = "glass of Nuka-Cola"
	glass_desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland"
	glass_center_of_mass = list("x"=16, "y"=6)

/datum/reagent/drink/nuka_cola/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.add_chemical_effect(CE_SPEEDBOOST, 1)
	M.make_jittery(20)
	M.druggy = max(M.druggy, 30)
	M.dizziness += 5
	M.drowsyness = 0

/datum/reagent/drink/grenadine
	name = "Grenadine Syrup"
	id = "grenadine"
	description = "Made in the modern day with proper pomegranate substitute. Who uses real fruit, anyways?"
	color = "#FF004F"
	taste_description = "100% pure pomegranate"

	glass_icon_state = "grenadineglass"
	glass_name = "glass of grenadine syrup"
	glass_desc = "Sweet and tangy, a bar syrup used to add color or flavor to drinks."
	glass_center_of_mass = list("x"=17, "y"=6)

/datum/reagent/drink/space_cola
	name = "Space Cola"
	id = "cola"
	description = "A refreshing beverage."
	reagent_state = LIQUID
	color = "#100800"
	adj_drowsy = -3
	taste_description = "cola"
	carbonated = TRUE

	glass_icon_state  = "glass_brown"
	glass_name = "glass of Space Cola"
	glass_desc = "A glass of refreshing Space Cola"

/datum/reagent/drink/spacemountainwind
	name = "Mountain Wind"
	id = "spacemountainwind"
	description = "Blows right through you like a space wind."
	color = "#102000"
	adj_drowsy = -7
	adj_sleepy = -1
	taste_description = "sweet citrus soda"
	carbonated = TRUE

	glass_icon_state = "Space_mountain_wind_glass"
	glass_name = "glass of Space Mountain Wind"
	glass_desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."

/datum/reagent/drink/dr_gibb
	name = "Dr. Gibb"
	id = "dr_gibb"
	description = "A delicious blend of 42 different flavours"
	color = "#102000"
	adj_drowsy = -6
	taste_description = "cherry soda"
	carbonated = TRUE

	glass_icon_state = "dr_gibb_glass"
	glass_name = "glass of Dr. Gibb"
	glass_desc = "Dr. Gibb. Not as dangerous as the name might imply."

/datum/reagent/drink/root_beer
	name = "Root Beer"
	id = "root_beer"
	description = "A classic drink, older than civilization."
	color = "#211100"
	adj_drowsy = -6
	taste_description = "sassafras and anise soda"
	carbonated = TRUE

	glass_icon_state = "root_beer_glass"
	glass_name = "glass of Root Beer"
	glass_desc = "A glass of bubbly Root Beer."

/datum/reagent/drink/space_up
	name = "Space-Up"
	id = "space_up"
	description = "Tastes like a hull breach in your mouth."
	color = "#202800"
	taste_description = "a hull breach"
	carbonated = TRUE

	glass_icon_state = "space-up_glass"
	glass_name = "glass of Space-up"
	glass_desc = "Space-up. It helps keep your cool."

/datum/reagent/drink/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	id = "lemon_lime"
	color = "#878F00"
	taste_description = "tangy lime and lemon soda"

	glass_icon_state = "lemonlime"
	glass_name = "glass of lemon lime soda"
	glass_desc = "A tangy substance made of 0.5% natural citrus!"

/datum/reagent/drink/doctor_delight
	name = "The Doctor's Delight"
	id = "doctorsdelight"
	description = "A gulp a day keeps the cleric away. That's probably for the best."
	reagent_state = LIQUID
	color = "#FF8CFF"
	nutrition = 1
	taste_description = "homely fruit"

	glass_icon_state = "doctorsdelightglass"
	glass_name = "glass of The Doctor's Delight"
	glass_desc = "A healthy mixture of juices, guaranteed to keep you healthy until the next toolboxing takes place."
	glass_center_of_mass = list("x"=16, "y"=8)

	blood_to_ingest_scale = 1

/datum/reagent/drink/doctor_delight/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.adjustOxyLoss(-4 * removed)
	M.heal_organ_damage(2 * removed, 2 * removed)
	M.adjustToxLoss(-2 * removed)
	if(M.dizziness)
		M.dizziness = max(0, M.dizziness - 15)
	if(M.confused)
		M.confused = max(0, M.confused - 5)

/datum/reagent/drink/dry_ramen
	name = "Dry Ramen"
	id = "dry_ramen"
	description = "Space age food. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
	reagent_state = SOLID
	nutrition = 1
	hydration = 0
	color = "#302000"
	taste_description = "dry and cheap noodles"

/datum/reagent/drink/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	color = "#302000"
	nutrition = 5
	hydration = 5
	adj_temp = 5
	taste_description = "wet and cheap noodles"

/datum/reagent/drink/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	color = "#302000"
	nutrition = 5
	hydration = 5
	taste_description = "wet and cheap noodles on fire"
	adj_temp = 20

/datum/reagent/drink/ice
	name = "Ice"
	id = "ice"
	description = "Frozen water, your dentist wouldn't like you chewing this."
	reagent_state = SOLID
	color = "#619494"
	taste_description = "ice"
	taste_mult = 1.5
	hydration = 8

	glass_icon_state = "iceglass"
	glass_name = "glass of ice"
	glass_desc = "Generally, you're supposed to put something else in there too..."

	default_temperature = T0C - 10

/datum/reagent/drink/nothing
	name = "Nothing"
	id = "nothing"
	description = "Absolutely nothing."
	taste_description = "nothing"

	glass_icon_state = "nothing"
	glass_name = "glass of nothing"
	glass_desc = "Absolutely nothing."

/datum/reagent/drink/meatshake
	name = "Meatshake"
	id = "meatshake"
	color = "#874c20"
	description = "Blended meat and cream for those who want crippling heart failure down the road."
	taste_description = "liquified meat"

	glass_icon_state = "meatshake"
	glass_name = "Meatshake"
	glass_desc = "Blended meat and cream for those who want crippling health issues down the road. Has two straws for sharing! Perfect for dates!"

/datum/reagent/drink/ciderhot
	name = "Apple Cider"
	id = "ciderhot"
	description = "A great drink to warm up a crisp autumn afternoon!"
	color = "#664300"
	taste_description = "fresh apples mixed with cinnamon"

	glass_icon_state = "ciderhot"
	glass_name = "cup of apple cider"
	glass_desc = "A great drink to warm up a crisp autumn afternoon!"

/datum/reagent/drink/cidercold
	name = "Apple Cider"
	id = "cidercold"
	description = "A refreshing mug of fresh apples and cinnamon."
	color = "#664300"
	taste_description = "fresh apples mixed with cinnamon"

	glass_icon_state = "meadglass"
	glass_name = "mug of apple cider"
	glass_desc = "A refreshing mug of fresh apples and cinnamon."

/datum/reagent/drink/cidercheap
	name = "Apple Cider Juice"
	id = "cidercheap"
	description = "It's just spiced up apple juice. Ugh."
	color = "#664300"
	taste_description = "sad apple juice with cinnamon"

	glass_icon_state = "meadglass"
	glass_name = "mug of apple cider juice"
	glass_desc = "It's just spiced up apple juice. Sometimes the barista can't work miracles."
/* Alcohol */

// Basic

/datum/reagent/alcohol/ethanol/absinthe
	name = "Absinthe"
	id = "absinthe"
	description = "Watch out that the Green Fairy doesn't come for you!"
	color = "#33EE00"
	strength = 75
	taste_description = "licorice"

	glass_icon_state = "absintheglass"
	glass_name = "glass of absinthe"
	glass_desc = "Wormwood, anise, oh my."
	glass_center_of_mass = list("x"=16, "y"=5)

/datum/reagent/alcohol/ethanol/ale
	name = "Ale"
	id = "ale"
	description = "A dark alchoholic beverage made by malted barley and yeast."
	color = "#664300"
	strength = 6
	taste_description = "hearty barley ale"
	carbonated = TRUE

	glass_icon_state = "aleglass"
	glass_name = "glass of ale"
	glass_desc = "A freezing pint of delicious ale"
	glass_center_of_mass = list("x"=16, "y"=8)

/datum/reagent/alcohol/ethanol/beer
	name = "Beer"
	id = "beer"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	color = "#664300"
	strength = 5
	nutriment_factor = 1
	taste_description = "beer"
	carbonated = TRUE

	glass_icon_state = "beerglass"
	glass_name = "glass of beer"
	glass_desc = "A freezing pint of beer"
	glass_center_of_mass = list("x"=16, "y"=8)

/datum/reagent/alcohol/ethanol/beer/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.jitteriness = max(M.jitteriness - 3, 0)

/datum/reagent/alcohol/ethanol/bitters
	name = "Aromatic Bitters"
	id = "bitters"
	description = "A very, very concentrated and bitter herbal alcohol."
	color = "#223319"
	strength = 40
	taste_description = "bitter"

	glass_icon_state = "bittersglass"
	glass_name = "glass of bitters"
	glass_desc = "A pungent glass of bitters."
	glass_center_of_mass = list ("x"=17, "y"=8)

/datum/reagent/alcohol/ethanol/bluecuracao
	name = "Blue Curacao"
	id = "bluecuracao"
	description = "Exotically blue, fruity drink, distilled from oranges."
	color = "#0000CD"
	strength = 25
	taste_description = "oranges"

	glass_icon_state = "curacaoglass"
	glass_name = "glass of blue curacao"
	glass_desc = "Exotically blue, fruity drink, distilled from oranges."
	glass_center_of_mass = list("x"=16, "y"=5)

/datum/reagent/alcohol/ethanol/champagne
	name = "Champagne"
	id = "champagne"
	description = "A classy sparkling wine, usually found in meeting rooms and basements."
	color = "#EBECC0"
	strength = 15
	taste_description = "bubbly bitter-sweetness"
	carbonated = TRUE

	glass_icon_state = "champagneglass"
	glass_name = "glass of champagne"
	glass_desc = "Off-white and bubbly. So passe."
	glass_center_of_mass = list("x"=16, "y"=5)

/datum/reagent/alcohol/ethanol/cognac
	name = "Cognac"
	id = "cognac"
	description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
	color = "#AB3C05"
	strength = 40
	taste_description = "rich and smooth alcohol"

	glass_icon_state = "cognacglass"
	glass_name = "glass of cognac"
	glass_desc = "Damn, you feel like some kind of draconic aristocrat just by holding this."
	glass_center_of_mass = list("x"=16, "y"=6)

/datum/reagent/alcohol/ethanol/deadrum
	name = "Deadrum"
	id = "deadrum"
	description = "Popular with the sailors. Not very popular with everyone else."
	color = "#664300"
	strength = 40
	taste_description = "salty sea water"

	glass_icon_state = "rumglass"
	glass_name = "glass of rum"
	glass_desc = "Now you want to Pray for a pirate suit, don't you?"
	glass_center_of_mass = list("x"=16, "y"=12)

/datum/reagent/alcohol/ethanol/deadrum/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.dizziness +=5

/datum/reagent/alcohol/ethanol/gin
	name = "Gin"
	id = "gin"
	description = "A mixture of grain alcohol and bitter herbs. Only Loam could create such a substance."
	color = "#664300"
	strength = 30
	taste_description = "an alcoholic christmas tree"

	glass_icon_state = "ginvodkaglass"
	glass_name = "glass of gin"
	glass_desc = "A crystal clear glass of genuine Loamer gin."
	glass_center_of_mass = list("x"=16, "y"=12)

/datum/reagent/alcohol/ethanol/victorygin
	name = "Victory Gin"
	id = "victorygin"
	description = "An oily gin. Nobody seems to make it, but bottles keep appearing."
	color = "#664300"
	strength = 18
	taste_description = "oily gin"

	glass_icon_state = "ginvodkaglass"
	glass_name = "glass of gin"
	glass_desc = "It has an oily smell and doesn't taste like typical gin."
	glass_center_of_mass = list("x"=16, "y"=12)

//Base type for alchoholic drinks containing coffee
/datum/reagent/alcohol/ethanol/coffee
	overdose = 45

/datum/reagent/alcohol/ethanol/coffee/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.dizziness = max(0, M.dizziness - 5)
	M.drowsyness = max(0, M.drowsyness - 3)
	M.sleeping = max(0, M.sleeping - 2)
	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/alcohol/ethanol/coffee/overdose(var/mob/living/carbon/M, var/alien)
	M.make_jittery(5)

/datum/reagent/alcohol/ethanol/coffee/kahlua
	name = "Kahlua"
	id = "kahlua"
	description = "A widely known, coffee-flavoured liqueur. In production since before time itself."
	color = "#664300"
	strength = 20
	caffeine = 0.25
	taste_description = "spiked latte"

	glass_icon_state = "kahluaglass"
	glass_name = "glass of coffee liquor"
	glass_desc = "DAMN, THIS THING LOOKS ROBUST"
	glass_center_of_mass = list("x"=15, "y"=7)

/datum/reagent/alcohol/ethanol/melonliquor
	name = "Melon Liquor"
	id = "melonliquor"
	description = "A relatively sweet and fruity 46 proof liquor."
	color = "#138808" // rgb: 19, 136, 8
	strength = 23
	taste_description = "fruity alcohol"

	glass_icon_state = "emeraldglass"
	glass_name = "glass of melon liquor"
	glass_desc = "A relatively sweet and fruity 46 proof liquor."
	glass_center_of_mass = list("x"=16, "y"=5)

/datum/reagent/alcohol/ethanol/rum
	name = "Rum"
	id = "rum"
	description = "Yohoho and all that."
	color = "#664300"
	strength = 40
	taste_description = "spiked butterscotch"

	glass_icon_state = "rumglass"
	glass_name = "glass of rum"
	glass_desc = "Now you want to Pray for a pirate suit, don't you?"
	glass_center_of_mass = list("x"=16, "y"=12)

/datum/reagent/alcohol/ethanol/sake
	name = "Sake"
	id = "sake"
	description = "Rice wine."
	color = "#664300"
	strength = 20
	taste_description = "old alcoholic socks"

	glass_icon_state = "ginvodkaglass"
	glass_name = "glass of sake"
	glass_desc = "A glass of sake."
	glass_center_of_mass = list("x"=16, "y"=12)

/datum/reagent/alcohol/ethanol/tequilla
	name = "Tequila"
	id = "tequilla"
	description = "A strong and mildly flavoured spirit produced from a desert succulent."
	color = "#FFFF91"
	strength = 40
	taste_description = "paint stripper"

	glass_icon_state = "tequillaglass"
	glass_name = "glass of Tequilla"
	glass_desc = "Now all that's missing is the weird colored shades!"
	glass_center_of_mass = list("x"=16, "y"=12)

/datum/reagent/alcohol/ethanol/thirteenloko
	name = "Thirteen Loko"
	id = "thirteenloko"
	description = "A potent mixture of caffeine and alcohol."
	color = "#102000"
	strength = 10
	nutriment_factor = 1
	caffeine = 0.5
	taste_description = "jitters and death"
	carbonated = TRUE

	glass_icon_state = "thirteen_loko_glass"
	glass_name = "glass of Thirteen Loko"
	glass_desc = "This is a glass of Thirteen Loko, it appears to be of the highest quality. The drink, not the glass."

/datum/reagent/alcohol/ethanol/thirteenloko/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.drowsyness = max(0, M.drowsyness - 7)
	M.make_jittery(5)
	if (M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))


/datum/reagent/alcohol/ethanol/vermouth
	name = "Vermouth"
	id = "vermouth"
	description = "You suddenly feel a craving for a martini..."
	color = "#91FF91" // rgb: 145, 255, 145
	strength = 17
	taste_description = "dry alcohol"
	taste_mult = 1.3

	glass_icon_state = "vermouthglass"
	glass_name = "glass of vermouth"
	glass_desc = "You wonder why you're even drinking this straight."
	glass_center_of_mass = list("x"=16, "y"=12)

/datum/reagent/alcohol/ethanol/vodka
	name = "Vodka"
	id = "vodka"
	description = "Watered-down fermented potato stored adjacent to flavoring. Popular amongst kobolds from the colder regions."
	color = "#0064C8" // rgb: 0, 100, 200
	strength = 50
	taste_description = "grain alcohol"

	glass_icon_state = "ginvodkaglass"
	glass_name = "glass of vodka"
	glass_desc = "The glass contain wodka."
	glass_center_of_mass = list("x"=16, "y"=12)

/datum/reagent/alcohol/ethanol/vodka/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.apply_effect(max(M.total_radiation - 1 * removed, 0), IRRADIATE, blocked = 0)

/datum/reagent/alcohol/ethanol/whiskey
	name = "Whiskey"
	id = "whiskey"
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#664300"
	strength = 40
	taste_description = "molasses"

	glass_icon_state = "whiskeyglass"
	glass_name = "glass of whiskey"
	glass_desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."
	glass_center_of_mass = list("x"=16, "y"=12)

/datum/reagent/alcohol/ethanol/wine
	name = "Wine"
	id = "wine"
	description = "A premium alchoholic beverage made from distilled grape juice."
	color = "#7E4043" // rgb: 126, 64, 67
	strength = 15
	taste_description = "bitter sweetness"

	glass_icon_state = "wineglass"
	glass_name = "glass of wine"
	glass_desc = "A very classy looking drink."
	glass_center_of_mass = list("x"=15, "y"=7)

// Cocktails

/datum/reagent/alcohol/ethanol/acid_spit
	name = "Acid Spit"
	id = "acidspit"
	description = "A drink for the daring, can be deadly if incorrectly prepared!"
	reagent_state = LIQUID
	color = "#365000"
	strength = 25
	taste_description = "stomach acid"

	glass_icon_state = "acidspitglass"
	glass_name = "glass of Acid Spit"
	glass_desc = "A drink from the guild archives. Made from live aliens."
	glass_center_of_mass = list("x"=16, "y"=7)

/datum/reagent/alcohol/ethanol/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	description = "A drink made from your allies, not as sweet as when made from your enemies."
	color = "#664300"
	strength = 25
	taste_description = "bitter yet free"

	glass_icon_state = "alliescocktail"
	glass_name = "glass of Allies cocktail"
	glass_desc = "A drink made from your allies."
	glass_center_of_mass = list("x"=17, "y"=8)

/datum/reagent/alcohol/ethanol/aloe
	name = "Aloe"
	id = "aloe"
	description = "So very, very, very good."
	color = "#664300"
	strength = 15
	taste_description = "sweet 'n creamy"

	glass_icon_state = "aloe"
	glass_name = "glass of Aloe"
	glass_desc = "Very, very, very good."
	glass_center_of_mass = list("x"=17, "y"=8)

/datum/reagent/alcohol/ethanol/amasec
	name = "Amasec"
	id = "amasec"
	description = "A fine year..."
	reagent_state = LIQUID
	color = "#664300"
	strength = 25
	taste_description = "dark and metallic"

	glass_icon_state = "amasecglass"
	glass_name = "glass of Amasec"
	glass_desc = "Best enjoyed in an armchair."
	glass_center_of_mass = list("x"=16, "y"=9)

/datum/reagent/alcohol/ethanol/andalusia
	name = "Andalusia"
	id = "andalusia"
	description = "A nice, strangely named drink."
	color = "#664300"
	strength = 35
	taste_description = "lemons"

	glass_icon_state = "andalusia"
	glass_name = "glass of Andalusia"
	glass_desc = "A nice, strange named drink."
	glass_center_of_mass = list("x"=16, "y"=9)

/datum/reagent/alcohol/ethanol/antifreeze
	name = "Anti-freeze"
	id = "antifreeze"
	description = "Ultimate refreshment."
	color = "#664300"
	strength = 20
	adj_temp = 20
	targ_temp = 330
	taste_description = "cold cream"

	glass_icon_state = "antifreeze"
	glass_name = "glass of Anti-freeze"
	glass_desc = "The ultimate refreshment."
	glass_center_of_mass = list("x"=16, "y"=8)

/datum/reagent/alcohol/ethanol/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	description = "Nuclear proliferation never tasted so good."
	reagent_state = LIQUID
	color = "#666300"
	strength = 50
	druggy = 50
	taste_description = "da bomb"

	glass_icon_state = "atomicbombglass"
	glass_name = "glass of Atomic Bomb"
	glass_desc = "We cannot take legal responsibility for your actions after imbibing."
	glass_center_of_mass = list("x"=15, "y"=7)

/datum/reagent/alcohol/ethanol/coffee/b52
	name = "Bomber"
	id = "b52"
	description = "No night fighter gonna stop us getting through"
	color = "#664300"
	strength = 35
	taste_description = "explosive anger"

	glass_icon_state = "b52glass"
	glass_name = "glass of B-52"
	glass_desc = "No night fighter gonna stop us getting through"

/datum/reagent/alcohol/ethanol/bahama_mama
	name = "Bahama mama"
	id = "bahama_mama"
	description = "Tropical cocktail."
	color = "#FF7F3B"
	strength = 15
	taste_description = "lime and orange"

	glass_icon_state = "bahama_mama"
	glass_name = "glass of Bahama Mama"
	glass_desc = "Tropical cocktail"
	glass_center_of_mass = list("x"=16, "y"=5)

/datum/reagent/alcohol/ethanol/bananahonk
	name = "Banana Mama"
	id = "bananahonk"
	description = "A drink from a terrifying alternate universe."
	nutriment_factor = 1
	color = "#FFFF91"
	strength = 15
	taste_description = "a bad joke"

	glass_icon_state = "bananahonkglass"
	glass_name = "glass of Banana Honk"
	glass_desc = "A drink from Banana Heaven."
	glass_center_of_mass = list("x"=16, "y"=8)

/datum/reagent/alcohol/ethanol/barefoot
	name = "Barefoot"
	id = "barefoot"
	description = "Barefoot and pregnant"
	color = "#664300"
	strength = 15
	taste_description = "creamy berries"

	glass_icon_state = "b&p"
	glass_name = "glass of Barefoot"
	glass_desc = "Barefoot and pregnant"
	glass_center_of_mass = list("x"=17, "y"=8)

/datum/reagent/alcohol/ethanol/beepsky_smash
	name = "Helmet Brew"
	id = "beepskysmash"
	description = "It doesn't look very plump..."
	reagent_state = LIQUID
	color = "#664300"
	strength = 35
	taste_description = "avarice and tenacity"

	glass_icon_state = "beepskysmashglass"
	glass_name = "Beepsky Smash"
	glass_desc = "Served in a glass made of goblinite."
	glass_center_of_mass = list("x"=18, "y"=10)

/datum/reagent/alcohol/ethanol/beepsky_smash/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.Stun(2)

/datum/reagent/alcohol/ethanol/bilk
	name = "Bilk"
	id = "bilk"
	description = "This appears to be beer mixed with milk. Disgusting."
	color = "#895C4C"
	strength = 4
	nutriment_factor = 2
	taste_description = "desperation and lactate"

	glass_icon_state = "glass_brown"
	glass_name = "glass of bilk"
	glass_desc = "A brew of milk and beer. For those alcoholics who fear osteoporosis."

/datum/reagent/alcohol/ethanol/black_russian
	name = "Black Baron"
	id = "blackrussian"
	description = "Preparing the throne for us again. Still as classy as a White Army."
	color = "#360000"
	strength = 20
	taste_description = "bitterness"

	glass_icon_state = "blackrussianglass"
	glass_name = "glass of Black Baron"
	glass_desc = "Preparing the throne for us again. Still as classy as a White Army."
	glass_center_of_mass = list("x"=16, "y"=9)

/datum/reagent/alcohol/ethanol/bloody_mary
	name = "Bloody Mary"
	id = "bloodymary"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	color = "#664300"
	strength = 20
	taste_description = "tomatoes with a hint of lime"

	glass_icon_state = "bloodymaryglass"
	glass_name = "glass of Bloody Mary"
	glass_desc = "Tomato juice, mixed with Vodka and a lil' bit of lime. Tastes like liquid murder."

/datum/reagent/alcohol/ethanol/booger
	name = "Booger"
	id = "booger"
	description = "Ewww..."
	color = "#8CFF8C"
	strength = 20
	taste_description = "sweet 'n creamy"

	glass_icon_state = "booger"
	glass_name = "glass of Booger"
	glass_desc = "Ewww..."

/datum/reagent/alcohol/ethanol/coffee/brave_bull
	name = "Brave Bull"
	id = "bravebull"
	description = "It's just as effective as Dutch-Courage!"
	color = "#664300"
	strength = 30
	caffeine = 0.2
	taste_description = "alcoholic bravery"

	glass_icon_state = "bravebullglass"
	glass_name = "glass of Brave Bull"
	glass_desc = "Tequilla and coffee liquor, brought together in a mouthwatering mixture. Drink up."
	glass_center_of_mass = list("x"=15, "y"=8)

/datum/reagent/alcohol/ethanol/cmojito
	name = "Champagne Mojito"
	id = "cmojito"
	description = "A fizzy, minty and sweet drink."
	color = "#5DBA40"
	strength = 15
	taste_description = "sweet mint alcohol"

	glass_icon_state = "cmojito"
	glass_name = "glass of champagne mojito"
	glass_desc = "Looks fun!"

/datum/reagent/alcohol/ethanol/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	description = "You take a tiny sip and feel a burning sensation..."
	color = "#2E6671"
	strength = 40
	taste_description = "your brain coming out your nose"

	glass_icon_state = "changelingsting"
	glass_name = "glass of Changeling Sting"
	glass_desc = "A stingy drink."

/datum/reagent/alcohol/ethanol/classic
	name = "The Classic"
	id = "classic"
	description = "The classic bitter lemon cocktail."
	color = "#9a8922"
	strength = 20
	taste_description = "sour and bitter"
	carbonated = TRUE

	glass_icon_state = "classic"
	glass_name = "glass of the classic"
	glass_desc = "Just classic. Wow."
	glass_center_of_mass = list("x"=17, "y"=8)

/datum/reagent/alcohol/ethanol/martini
	name = "Classic Martini"
	id = "martini"
	description = "Vermouth with Gin. Painfully dry."
	color = "#664300"
	strength = 25
	taste_description = "dry class"

	glass_icon_state = "martiniglass"
	glass_name = "glass of classic martini"
	glass_desc = "Damn, the bartender even stirred it, not shook it."
	glass_center_of_mass = list("x"=17, "y"=8)

/datum/reagent/alcohol/ethanol/corkpopper
	name = "Cork Popper"
	id = "corkpopper"
	description = "A fancy cocktail with a hint of lemon."
	color = "#766818"
	strength = "30"
	taste_description = "sour and smokey"

	glass_icon_state = "corkpopper"
	glass_name = "glass of cork popper"
	glass_desc = "The confusing scent only proves all the more alluring."
	glass_center_of_mass = list("x"=16, "y"=9)

/datum/reagent/alcohol/ethanol/cuba_libre
	name = "Naarvat Libre"
	id = "cubalibre"
	description = "Rum, mixed with cola. Viva la revolucion."
	color = "#3E1B00"
	strength = 10
	taste_description = "cola"
	carbonated = TRUE

	glass_icon_state = "cubalibreglass"
	glass_name = "glass of Naarvat Libre"
	glass_desc = "A classic mix of rum and cola."
	glass_center_of_mass = list("x"=16, "y"=8)

/datum/reagent/alcohol/ethanol/demonsblood
	name = "Demons Blood"
	id = "demonsblood"
	description = "AHHHH!!!!"
	color = "#820000"
	strength = 15
	taste_description = "sweet tasting iron"
	carbonated = TRUE

	glass_icon_state = "demonsblood"
	glass_name = "glass of Demons' Blood"
	glass_desc = "Just looking at this thing makes the scales at the back of your neck stand up."
	glass_center_of_mass = list("x"=16, "y"=2)

/datum/reagent/alcohol/ethanol/devilskiss
	name = "Devils Kiss"
	id = "devilskiss"
	description = "Creepy time!"
	color = "#A68310"
	strength = 15
	taste_description = "bitter iron"

	glass_icon_state = "devilskiss"
	glass_name = "glass of Devil's Kiss"
	glass_desc = "Creepy time!"
	glass_center_of_mass = list("x"=16, "y"=8)

/datum/reagent/alcohol/ethanol/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = 1
	color = "#2E6671"
	strength = 20
	taste_description = "a beach"

	glass_icon_state = "driestmartiniglass"
	glass_name = "glass of Driest Martini"
	glass_desc = "Only for the experienced. You think you see sand floating in the glass."
	glass_center_of_mass = list("x"=17, "y"=8)

/datum/reagent/alcohol/ethanol/french75
	name = "Franka 75"
	id = "french75"
	description = "A sharp and classy cocktail."
	color = "#F4E68D"
	strength = 25
	taste_description = "sour and classy"
	carbonated = TRUE

	glass_icon_state = "french75"
	glass_name = "glass of franka 75"
	glass_desc = "It looks like a lemon shaved into your cocktail."
	glass_center_of_mass = list("x"=16, "y"=5)

/datum/reagent/alcohol/ethanol/ginfizz
	name = "Gin Fizz"
	id = "ginfizz"
	description = "Refreshingly lemony, deliciously dry."
	color = "#664300"
	strength = 20
	taste_description = "dry, tart lemons"
	carbonated = TRUE

	glass_icon_state = "ginfizzglass"
	glass_name = "glass of gin fizz"
	glass_desc = "Refreshingly lemony, deliciously dry."
	glass_center_of_mass = list("x"=16, "y"=7)

/datum/reagent/alcohol/ethanol/grog
	name = "Grog"
	id = "grog"
	description = "Watered-down rum, pirate approved!"
	reagent_state = LIQUID
	color = "#664300"
	strength = 10
	taste_description = "a poor excuse for alcohol"

	glass_icon_state = "grogglass"
	glass_name = "glass of grog"
	glass_desc = "A fine and cepa drink for Space."

/datum/reagent/alcohol/ethanol/erikasurprise
	name = "Vynys Surprise"
	id = "erikasurprise"
	description = "Surprisingly agreeable!"
	color = "#2E6671"
	strength = 15
	taste_description = "tartness and bananas"

	glass_icon_state = "erikasurprise"
	glass_name = "glass of Vynys Surprise"
	glass_desc = "Surprisingly agreeable!"
	glass_center_of_mass = list("x"=16, "y"=9)

/datum/reagent/alcohol/ethanol/gargle_blaster
	name = "Unstable Hydrocarbon"
	id = "gargleblaster"
	description = "Yikes, is that a drink or rocket fuel?"
	reagent_state = LIQUID
	color = "#664300"
	strength = 50
	taste_description = "alcoholism and glitter"

	glass_icon_state = "gargleblasterglass"
	glass_name = "glass of Pan-Galactic Gargle Blaster"
	glass_desc = "Yikes, is that a drink or rocket fuel?"
	glass_center_of_mass = list("x"=17, "y"=6)

/datum/reagent/alcohol/ethanol/gintonic
	name = "Gin and Tonic"
	id = "gintonic"
	description = "An all time classic, mild cocktail."
	color = "#664300"
	strength = 12
	taste_description = "mild and tart"
	carbonated = TRUE

	glass_icon_state = "gintonicglass"
	glass_name = "glass of gin and tonic"
	glass_desc = "A mild but still great cocktail. Drink up, like a true Loamer."
	glass_center_of_mass = list("x"=16, "y"=7)

/datum/reagent/alcohol/ethanol/goldschlager
	name = "Goldschlager"
	id = "goldschlager"
	description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
	color = "#664300"
	strength = 50
	taste_description = "burning cinnamon"

	glass_icon_state = "ginvodkaglass"
	glass_name = "glass of Goldschlager"
	glass_desc = "100 proof that teen girls will drink anything with gold in it."
	glass_center_of_mass = list("x"=16, "y"=12)

/datum/reagent/alcohol/ethanol/hippies_delight
	name = "Hippies' Delight"
	id = "hippiesdelight"
	description = "You just don't get it maaaan."
	reagent_state = LIQUID
	color = "#664300"
	strength = 15
	druggy = 50
	taste_description = "giving peace a chance"

	glass_icon_state = "hippiesdelightglass"
	glass_name = "glass of Hippie's Delight"
	glass_desc = "A drink enjoyed by people of an earlier era."
	glass_center_of_mass = list("x"=16, "y"=8)

/datum/reagent/alcohol/ethanol/hooch
	name = "Hooch"
	id = "hooch"
	description = "Either someone's failure at cocktail making or attempt in alchohol production. In any case, do you really want to drink that?"
	color = "#664300"
	strength = 65
	taste_description = "pure resignation"

	glass_icon_state = "glass_brown2"
	glass_name = "glass of Hooch"
	glass_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."

/datum/reagent/alcohol/ethanol/iced_beer
	name = "Iced Beer"
	id = "iced_beer"
	description = "A beer which is so cold the air around it freezes."
	color = "#664300"
	strength = 5
	targ_temp = 270
	taste_description = "refreshingly cold"
	carbonated = TRUE

	glass_icon_state = "iced_beerglass"
	glass_name = "glass of iced beer"
	glass_desc = "A beer so frosty, the air around it freezes."
	glass_center_of_mass = list("x"=16, "y"=7)

/datum/reagent/alcohol/ethanol/irishcarbomb
	name = "Irish Car Bomb"
	id = "irishcarbomb"
	description = "What's Irish mean, anyway?"
	color = "#2E6671"
	strength = 50
	taste_description = "delicious anger"
	carbonated = TRUE

	glass_icon_state = "irishcarbomb"
	glass_name = "glass of Irish Car Bomb"
	glass_desc = "What does Irish mean, anyway?"
	glass_center_of_mass = list("x"=16, "y"=8)

/datum/reagent/alcohol/ethanol/coffee/irishcoffee
	name = "Irish Coffee"
	id = "irishcoffee"
	description = "Coffee, and alcohol.What does 'Irish' mean? It is a mystery."
	color = "#664300"
	strength = 50
	caffeine = 0.3
	taste_description = "giving up on the day"

	glass_icon_state = "irishcoffeeglass"
	glass_name = "glass of Irish coffee"
	glass_desc = "Coffee and alcohol. What does 'Irish' mean? It is a mystery."
	glass_center_of_mass = list("x"=15, "y"=10)

/datum/reagent/alcohol/ethanol/irish_cream
	name = "Irish Cream"
	id = "irishcream"
	description = "Whiskey-imbued cream. The debate rages on over why it is called 'Irish'."
	color = "#664300"
	strength = 25
	taste_description = "creamy alcohol"

	glass_icon_state = "irishcreamglass"
	glass_name = "glass of Irish cream"
	glass_desc = "It's cream, mixed with whiskey. The debate rages on over why it is called 'Irish'."
	glass_center_of_mass = list("x"=16, "y"=9)

/datum/reagent/alcohol/ethanol/longislandicedtea
	name = "Long Eared Iced Tea"
	id = "longislandicedtea"
	description = "The liquor cabinet, brought together in a delicious mix. Believed by some younger elves to amplify their magic."
	color = "#664300"
	strength = 40
	taste_description = "a mixture of cola and alcohol"
	carbonated = TRUE

	glass_icon_state = "longislandicedteaglass"
	glass_name = "glass of Long Eared iced tea"
	glass_desc = "The liquor cabinet, brought together in a delicious mix. Believed by some younger elves to amplify their magic."
	glass_center_of_mass = list("x"=16, "y"=8)

/datum/reagent/alcohol/ethanol/manhattan
	name = "Manhackan"
	id = "manhattan"
	description = "The hacks can't kill you if alcohol gets you first."
	color = "#664300"
	strength = 30
	taste_description = "mild dryness"

	glass_icon_state = "manhattanglass"
	glass_name = "glass of Manhackan"
	glass_desc = "The hacks can't kill you if alcohol gets you first."
	glass_center_of_mass = list("x"=17, "y"=8)

/datum/reagent/alcohol/ethanol/manhattan_proj
	name = "Uranium Fever"
	id = "manhattan_proj"
	description = "A scientist's drink of choice, for pondering ways to blow up the station."
	color = "#664300"
	strength = 30
	druggy = 30
	taste_description = "death, the destroyer of worlds"

	glass_icon_state = "proj_manhattanglass"
	glass_name = "glass of Manhattan Project"
	glass_desc = "A scientist's drink of choice, for thinking how to blow up the station."
	glass_center_of_mass = list("x"=17, "y"=8)

/datum/reagent/alcohol/ethanol/manly_dorf
	name = "The Manly Dorf"
	id = "manlydorf"
	description = "Beer and Ale, brought together in a delicious mix. Radiates an air of mudanity."
	color = "#664300"
	strength = 45
	taste_description = "hidden fun stuff"
	carbonated = TRUE

	glass_icon_state = "manlydorfglass"
	glass_name = "glass of The Manly Dorf"
	glass_desc = "A manly concotion made from Ale and Beer. Radiates an air of mudanity."

/datum/reagent/alcohol/ethanol/margarita
	name = "Margarita"
	id = "margarita"
	description = "On the rocks with salt on the rim. Arriba~!"
	color = "#8CFF8C"
	strength = 30
	taste_description = "dry and salty"

	glass_icon_state = "margaritaglass"
	glass_name = "glass of margarita"
	glass_desc = "On the rocks with salt on the rim. Arriba~!"
	glass_center_of_mass = list("x"=16, "y"=8)

/datum/reagent/alcohol/ethanol/mead
	name = "Mead"
	id = "mead"
	description = "A raider's drink, though a cheap one."
	reagent_state = LIQUID
	color = "#664300"
	strength = 25
	nutriment_factor = 1
	taste_description = "sweet yet alcoholic"

	glass_icon_state = "meadglass"
	glass_name = "glass of mead"
	glass_desc = "A raider's beverage, though a cheap one."
	glass_center_of_mass = list("x"=17, "y"=10)

/datum/reagent/alcohol/ethanol/moonshine
	name = "Moonshine"
	id = "moonshine"
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	color = "#664300"
	strength = 65
	taste_description = "bitterness"

	glass_icon_state = "glass_clear"
	glass_name = "glass of moonshine"
	glass_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."

/datum/reagent/alcohol/ethanol/muscmule
	name = "Marduk Mule"
	id = "muscmule"
	description = "Surprisingly mellow, until it hits the back of your throat."
	color = "#8EEC5F"
	strength = 40
	taste_description = "mint and a mule's kick"

	glass_icon_state = "muscmule"
	glass_name = "glass of marduk mule"
	glass_desc = "Such a pretty green, this couldn't possible go wrong!"
	glass_center_of_mass = list("x"=17, "y"=10)

/datum/reagent/alcohol/ethanol/neurotoxin
	name = "Neurotoxin"
	id = "neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = LIQUID
	color = "#2E2E61"
	strength = 50
	taste_description = "a numbing sensation"

	glass_icon_state = "neurotoxinglass"
	glass_name = "glass of Neurotoxin"
	glass_desc = "A drink that is guaranteed to knock you silly."
	glass_center_of_mass = list("x"=16, "y"=8)

	blood_to_ingest_scale = 1
	metabolism = REM * 5

/datum/reagent/alcohol/ethanol/neurotoxin/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.Weaken(3)

/datum/reagent/alcohol/ethanol/omimosa
	name = "Orange Mimosa"
	id = "omimosa"
	description = "Wonderful start to any day."
	color = "#F4A121"
	strength = 15
	taste_description = "fizzy orange"
	carbonated = TRUE

	glass_icon_state = "omimosa"
	glass_name = "glass of orange mimosa"
	glass_desc = "Smells like a fresh start."

/datum/reagent/alcohol/ethanol/patron
	name = "Patron"
	id = "patron"
	description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
	color = "#585840"
	strength = 20
	taste_description = "metallic and expensive"

	glass_icon_state = "patronglass"
	glass_name = "glass of Patron"
	glass_desc = "Drinking patron in the bar, with all the subpar ladies."
	glass_center_of_mass = list("x"=7, "y"=8)

/datum/reagent/alcohol/ethanol/pinkgin
	name = "Pink Gin"
	id = "pinkgin"
	description = "Bitters and Gin."
	color = "#DB80B2"
	strength = 25
	taste_description = "bitter christmas tree"

	glass_icon_state = "pinkgin"
	glass_name = "glass of pink gin"
	glass_desc = "What an eccentric cocktail."
	glass_center_of_mass = list("x"=16, "y"=9)

/datum/reagent/alcohol/ethanol/pinkgintonic
	name = "Pink Gin and Tonic."
	id = "pinkgintonic"
	description = "Bitterer gin and tonic."
	color = "#F4BDDB"
	strength = 25
	taste_description = "very bitter christmas tree"
	carbonated = TRUE

	glass_icon_state = "pinkgintonic"
	glass_name = "glass of pink gin and tonic"
	glass_desc = "You made gin and tonic more bitter... you madman!"

/datum/reagent/alcohol/ethanol/piratepunch
	name = "Pirate's Punch"
	id = "piratepunch"
	description = "Nautical punch!"
	color = "#ECE1A0"
	strength = 25
	taste_description = "spiced fruit cocktail"

	glass_icon_state = "piratepunch"
	glass_name = "glass of pirate's punch"
	glass_desc = "Yarr harr fiddly dee, drink whatcha want 'cause a pirate is ye!"
	glass_center_of_mass = list("x"=17, "y"=10)

/datum/reagent/alcohol/ethanol/planterpunch
	name = "Planter's Punch"
	id = "planterpunch"
	description = "A popular beach cocktail."
	color = "#FFA700"
	strength = 25
	taste_description = "jamaica"

	glass_icon_state = "planterpunch"
	glass_name = "glass of planter's punch"
	glass_desc = "This takes you back, back to those endless white beaches of yore."
	glass_center_of_mass = list("x"=16, "y"=8)

/datum/reagent/alcohol/ethanol/pwine
	name = "Poison Wine"
	id = "pwine"
	description = "Is this even wine? Toxic! Hallucinogenic! Probably consumed in boatloads by your superiors!"
	color = "#000000"
	strength = 15
	druggy = 50
	halluci = 10
	taste_description = "purified alcoholic death"

	glass_icon_state = "pwineglass"
	glass_name = "glass of ???"
	glass_desc = "A black ichor with an oily purple sheer on top. Are you sure you should drink this?"
	glass_center_of_mass = list("x"=16, "y"=5)

/datum/reagent/alcohol/ethanol/pwine/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	if(dose > 30)
		M.adjustToxLoss(2 * removed)

	if(dose > 60 && prob(5))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/heart/L = H.internal_organs_by_name["heart"]
		if (L && istype(L))
			if(dose < 120)
				L.take_damage(10 * removed, 0)
			else
				L.take_damage(100, 0)

/datum/reagent/alcohol/ethanol/red_mead
	name = "Red Mead"
	id = "red_mead"
	description = "The true raider's drink! Even though it has a strange red color."
	color = "#C73C00"
	strength = 21
	taste_description = "sweet and salty alcohol"

	glass_icon_state = "red_meadglass"
	glass_name = "glass of red mead"
	glass_desc = "A true raider's beverage, though its color is strange."
	glass_center_of_mass = list("x"=17, "y"=10)

/datum/reagent/alcohol/ethanol/sbiten
	name = "Sbiten"
	id = "sbiten"
	description = "A spicy mix of mead and spices! Might be a little hot for the little guys!"
	color = "#664300"
	strength = 40
	adj_temp = 50
	targ_temp = 360
	taste_description = "hot and spice"

	glass_icon_state = "sbitenglass"
	glass_name = "glass of Sbiten"
	glass_desc = "A spicy mix of Mead and Spices. Very hot."
	glass_center_of_mass = list("x"=17, "y"=8)

/datum/reagent/alcohol/ethanol/screwdrivercocktail
	name = "Screwdriver"
	id = "screwdrivercocktail"
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	color = "#A68310"
	strength = 15
	taste_description = "oranges"

	glass_icon_state = "screwdriverglass"
	glass_name = "glass of Screwdriver"
	glass_desc = "A simple, yet superb mixture of Vodka and orange juice. Just the thing for the tired engineer."
	glass_center_of_mass = list("x"=15, "y"=10)

/datum/reagent/alcohol/ethanol/silencer
	name = "Suppressor"
	id = "silencer"
	description = "It can't actually totally silence you..."
	nutriment_factor = 1
	color = "#664300"
	strength = 50
	taste_description = "a misnomer"

	glass_icon_state = "silencerglass"
	glass_name = "glass of Suppressor"
	glass_desc = "It can't actually totally silence you..."
	glass_center_of_mass = list("x"=16, "y"=9)

/datum/reagent/alcohol/ethanol/singulo
	name = "Free Spirit"
	id = "singulo"
	description = "A magical beverage!"
	color = "#2E6671"
	strength = 50
	taste_description = "airy spirits"

	glass_icon_state = "singulo"
	glass_name = "glass of Singulo"
	glass_desc = "A magical beverage!"
	glass_center_of_mass = list("x"=17, "y"=4)

/datum/reagent/alcohol/ethanol/snowwhite
	name = "Snow White"
	id = "snowwhite"
	description = "A cold refreshment"
	color = "#FFFFFF"
	strength = 7
	taste_description = "refreshing cold"
	carbonated = TRUE

	glass_icon_state = "snowwhite"
	glass_name = "glass of Snow White"
	glass_desc = "A cold refreshment."
	glass_center_of_mass = list("x"=16, "y"=8)

/datum/reagent/alcohol/ethanol/ssroyale
	name = "Southside Royale"
	id = "ssroyale"
	description = "Classy cocktail containing citrus."
	color = "#66F446"
	strength = 20
	taste_description = "lime christmas tree"

	glass_icon_state = "ssroyale"
	glass_name = "glass of southside royale"
	glass_desc = "This cocktail is better than you. Maybe it's the crossed arms that give it away. Or the rich parents."
	glass_center_of_mass = list("x"=17, "y"=8)

/datum/reagent/alcohol/ethanol/suidream
	name = "Laah Special"
	id = "suidream"
	description = "Pale, blue, beautiful. Very scholarly!"
	color = "#00A86B"
	strength = 5
	taste_description = "skittles and anxiety"
	carbonated = TRUE

	glass_icon_state = "sdreamglass"
	glass_name = "glass of Laah Special"
	glass_desc = "Pale, blue, beautiful. Very scholarly!"
	glass_center_of_mass = list("x"=16, "y"=5)

/datum/reagent/alcohol/ethanol/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	description = "Tastes like freedom!"
	color = "#2E6671"
	strength = 65
	taste_description = "truth to power"
	carbonated = TRUE

	glass_icon_state = "syndicatebomb"
	glass_name = "glass of Syndicate Bomb"
	glass_desc = "Tastes like freedom!"
	glass_center_of_mass = list("x"=16, "y"=4)

/datum/reagent/alcohol/ethanol/tequilla_sunrise
	name = "Tequila Sunrise"
	id = "tequillasunrise"
	description = "Tequila and orange juice. Much like a Screwdriver."
	color = "#FFE48C"
	strength = 15
	taste_description = "oranges"

	glass_icon_state = "tequillasunriseglass"
	glass_name = "glass of Tequilla Sunrise"
	glass_desc = "Oh great, now you feel nostalgic about sunrises back on Loam..."

/datum/reagent/alcohol/ethanol/threemileisland
	name = "Atomic Iced Tea"
	id = "threemileisland"
	description = "Made for a woman, strong enough for a man."
	color = "#666340"
	strength = 60
	druggy = 50
	taste_description = "dry"
	carbonated = TRUE

	glass_icon_state = "threemileislandglass"
	glass_name = "glass of Three Mile Island iced tea"
	glass_desc = "A glass of this is sure to prevent a meltdown."
	glass_center_of_mass = list("x"=16, "y"=2)

/datum/reagent/alcohol/ethanol/toxins_special
	name = "Toxins Special"
	id = "phoronspecial"
	description = "This thing is ON FIRE! CALL THE DAMN SHUTTLE!"
	reagent_state = LIQUID
	color = "#664300"
	strength = 40
	adj_temp = 15
	targ_temp = 330
	taste_description = "spicy toxins"

	glass_icon_state = "toxinsspecialglass"
	glass_name = "glass of Toxins Special"
	glass_desc = "Whoah, this thing is on FIRE"

/datum/reagent/alcohol/ethanol/vodkamartini
	name = "Vodka Martini"
	id = "vodkamartini"
	description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#664300"
	strength = 32
	taste_description = "shaken, not stirred"

	glass_icon_state = "martiniglass"
	glass_name = "glass of vodka martini"
	glass_desc ="A bastardisation of the classic martini. Still great."
	glass_center_of_mass = list("x"=17, "y"=8)

/datum/reagent/alcohol/ethanol/vodkatonic
	name = "Vodka and Tonic"
	id = "vodkatonic"
	description = "For when a gin and tonic isn't painful enough."
	color = "#0064C8" // rgb: 0, 100, 200
	strength = 35
	taste_description = "tart bitterness"

	glass_icon_state = "vodkatonicglass"
	glass_name = "glass of vodka and tonic"
	glass_desc = "For when a gin and tonic isn't painful enough."
	glass_center_of_mass = list("x"=16, "y"=7)

/datum/reagent/alcohol/ethanol/white_russian
	name = "White Army"
	id = "whiterussian"
	description = "Preparing the throne for us again. At least it's creamy..."
	color = "#A68340"
	strength = 30
	taste_description = "bitter cream"

	glass_icon_state = "whiterussianglass"
	glass_name = "glass of White Army"
	glass_desc = "Preparing the throne for us again. At least it's creamy..."
	glass_center_of_mass = list("x"=16, "y"=9)

/datum/reagent/alcohol/ethanol/whiskey_cola
	name = "Whiskey Cola"
	id = "whiskeycola"
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	color = "#3E1B00"
	strength = 15
	taste_description = "cola"
	carbonated = TRUE

	glass_icon_state = "whiskeycolaglass"
	glass_name = "glass of whiskey cola"
	glass_desc = "An innocent-looking mixture of cola and Whiskey. Delicious."
	glass_center_of_mass = list("x"=16, "y"=9)

/datum/reagent/alcohol/ethanol/whiskeysoda
	name = "Whiskey Soda"
	id = "whiskeysoda"
	description = "For the more refined griffon."
	color = "#664300"
	strength = 15
	taste_description = "cola"
	carbonated = TRUE

	glass_icon_state = "whiskeysodaglass2"
	glass_name = "glass of whiskey soda"
	glass_desc = "Ultimate refreshment."
	glass_center_of_mass = list("x"=16, "y"=9)

/datum/reagent/alcohol/ethanol/specialwhiskey // I have no idea what this is and where it comes from
	name = "Special Blend Whiskey"
	id = "specialwhiskey"
	description = "Just when you thought regular whiskey was good... This silky, amber goodness has to come along and ruin everything."
	color = "#664300"
	strength = 45
	taste_description = "silky, amber goodness"

	glass_icon_state = "whiskeyglass"
	glass_name = "glass of special blend whiskey"
	glass_desc = "Just when you thought regular whiskey was good... This silky, amber goodness has to come along and ruin everything."
	glass_center_of_mass = list("x"=16, "y"=12)

// Snowflake drinks
/datum/reagent/drink/dr_gibb_diet
	name = "Diet Dr. Gibb"
	id = "dr_gibb_diet"
	description = "A delicious blend of 42 different flavours, one of which is water."
	color = "#102000"
	taste_description = "watered down liquid sunshine"
	carbonated = TRUE

	glass_icon_state = "dr_gibb_glass"
	glass_name = "glass of Diet Dr. Gibb"
	glass_desc = "Regular Dr.Gibb is probably healthier than this cocktail of artificial flavors."

/datum/reagent/alcohol/ethanol/drdaniels
	name = "Dr. Daniels"
	id = "dr_daniels"
	description = "A limited edition tallboy of Dr. Gibb's Infusions."
	color = "#8e6227"
	caffeine = 0.2
	overdose = 80
	strength = 20
	nutriment_factor = 2
	taste_description = "smooth, honeyed carbonation"
	carbonated = TRUE

	glass_icon_state = "drdaniels"
	glass_name = "glass of Dr. Daniels"
	glass_desc = "A tall glass of honey, whiskey, and diet Dr. Gibb. The perfect blend of throat-soothing liquid."

//aurora unique drinks

/datum/reagent/alcohol/ethanol/daiquiri
	name = "Daiquiri"
	id = "daiquiri"
	description = "Exotically blue, fruity drink, distilled from oranges."
	color = "#664300"
	strength = 15
	taste_description = "oranges"

	glass_icon_state = "daiquiri"
	glass_name = "glass of Daiquiri"
	glass_desc = "A splendid looking cocktail."

/datum/reagent/alcohol/ethanol/icepick
	name = "Ice Pick"
	id = "icepick"
	description = "Big. And red. Hmm...."
	color = "#664300"
	strength = 10
	taste_description = "vodka and lemon"

	glass_icon_state = "icepick"
	glass_name = "glass of Ice Pick"
	glass_desc = "Big. And red. Hmm..."

/datum/reagent/alcohol/ethanol/poussecafe
	name = "Pousse-Cafe"
	id = "poussecafe"
	description = "Smells of Franka and liquore."
	color = "#664300"
	strength = 15
	taste_description = "layers of liquors"

	glass_icon_state = "pousseecafe"
	glass_name = "glass of Pousse-Cafe"
	glass_desc = "Smells of French and liquore."

/datum/reagent/alcohol/ethanol/mintjulep
	name = "Mint Julep"
	id = "mintjulep"
	description = "As old as time itself, but how does it taste?"
	color = "#664300"
	strength = 25
	taste_description = "old as time"

	glass_icon_state = "mintjulep"
	glass_name = "glass of Mint Julep"
	glass_desc = "As old as time itself, but how does it taste?"

/datum/reagent/alcohol/ethanol/johncollins
	name = "John Collins"
	id = "johncollins"
	description = "Crystal clear, yellow, and smells of whiskey. How could this go wrong?"
	color = "#664300"
	strength = 25
	taste_description = "whiskey"
	carbonated = TRUE

	glass_icon_state = "johnscollins"
	glass_name = "glass of John Collins"
	glass_desc = "Named after a man, perhaps?"

/datum/reagent/alcohol/ethanol/gimlet
	name = "Gimlet"
	id = "gimlet"
	description = "Small, elegant, and kicks."
	color = "#664300"
	strength = 20
	taste_description = "gin and class"
	carbonated = TRUE

	glass_icon_state = "gimlet"
	glass_name = "glass of Gimlet"
	glass_desc = "Small, elegant, and packs a punch."

/datum/reagent/alcohol/ethanol/starsandstripes
	name = "Stars and Stripes"
	id = "starsandstripes"
	description = "Someone, somewhere, is saluting."
	color = "#664300"
	strength = 10
	taste_description = "freedom"

	glass_icon_state = "starsandstripes"
	glass_name = "glass of Stars and Stripes"
	glass_desc = "Someone, somewhere, is saluting."

/datum/reagent/alcohol/ethanol/metropolitan
	name = "Metropolitan"
	id = "metropolitan"
	description = "What more could you ask for?"
	color = "#664300"
	strength = 27
	taste_description = "fruity sweetness"

	glass_icon_state = "metropolitan"
	glass_name = "glass of Metropolitan"
	glass_desc = "What more could you ask for?"

/datum/reagent/alcohol/ethanol/caruso
	name = "Caruso"
	id = "caruso"
	description = "Green, almost alien."
	color = "#664300"
	strength = 25
	taste_description = "dryness"

	glass_icon_state = "caruso"
	glass_name = "glass of Caruso"
	glass_desc = "Green, almost alien."

/datum/reagent/alcohol/ethanol/aprilshower
	name = "April Shower"
	id = "aprilshower"
	description = "Smells of brandy."
	color = "#664300"
	strength = 25
	taste_description = "brandy and oranges"

	glass_icon_state = "aprilshower"
	glass_name = "glass of April Shower"
	glass_desc = "Smells of brandy."

/datum/reagent/alcohol/ethanol/carthusiansazerac
	name = "Carthusian Sazerac"
	id = "carthusiansazerac"
	description = "Whiskey and... Syrup?"
	color = "#664300"
	strength = 15
	taste_description = "sweetness"

	glass_icon_state = "carthusiansazerac"
	glass_name = "glass of Carthusian Sazerac"
	glass_desc = "Whiskey and... Syrup?"

/datum/reagent/alcohol/ethanol/deweycocktail
	name = "Dewey Cocktail"
	id = "deweycocktail"
	description = "Colours, look at all the colours!"
	color = "#664300"
	strength = 25
	taste_description = "dry gin"

	glass_icon_state = "deweycocktail"
	glass_name = "glass of Dewey Cocktail"
	glass_desc = "Colours, look at all the colours!"

/datum/reagent/alcohol/ethanol/chartreusegreen
	name = "Green Chartreuse"
	id = "chartreusegreen"
	description = "A green, strong liqueur."
	color = "#664300"
	strength = 40
	taste_description = "a mixture of herbs"

	glass_icon_state = "greenchartreuseglass"
	glass_name = "glass of Green Chartreuse"
	glass_desc = "A green, strong liqueur."

/datum/reagent/alcohol/ethanol/chartreuseyellow
	name = "Yellow Chartreuse"
	id = "chartreuseyellow"
	description = "A yellow, strong liqueur."
	color = "#664300"
	strength = 40
	taste_description = "a sweet mixture of herbs"

	glass_icon_state = "chartreuseyellowglass"
	glass_name = "glass of Yellow Chartreuse"
	glass_desc = "A yellow, strong liqueur."

/datum/reagent/alcohol/ethanol/cremewhite
	name = "White Creme de Menthe"
	id = "cremewhite"
	description = "Mint-flavoured alcohol, in a bottle."
	color = "#664300"
	strength = 20
	taste_description = "mint"

	glass_icon_state = "whitecremeglass"
	glass_name = "glass of White Creme de Menthe"
	glass_desc = "Mint-flavoured alcohol."

/datum/reagent/alcohol/ethanol/cremeyvette
	name = "Creme de Yvette"
	id = "cremeyvette"
	description = "Berry-flavoured alcohol, in a bottle."
	color = "#664300"
	strength = 20
	taste_description = "berries"

	glass_icon_state = "cremedeyvetteglass"
	glass_name = "glass of Creme de Yvette"
	glass_desc = "Berry-flavoured alcohol."

/datum/reagent/alcohol/ethanol/brandy
	name = "Brandy"
	id = "brandy"
	description = "Cheap knock off for cognac."
	color = "#664300"
	strength = 40
	taste_description = "cheap cognac"

	glass_icon_state = "brandyglass"
	glass_name = "glass of Brandy"
	glass_desc = "Cheap knock off for cognac."

/datum/reagent/alcohol/ethanol/guinnes
	name = "Guinness"
	id = "guinnes"
	description = "Special Guinnes drink."
	color = "#2E6671"
	strength = 8
	taste_description = "dryness"
	carbonated = TRUE

	glass_icon_state = "guinnes_glass"
	glass_name = "glass of Guinness"
	glass_desc = "A glass of Guinness."

/datum/reagent/alcohol/ethanol/drambuie
	name = "Drambuie"
	id = "drambuie"
	description = "A drink that smells like whiskey but tastes different."
	color = "#2E6671"
	strength = 40
	taste_description = "sweet whisky"

	glass_icon_state = "drambuieglass"
	glass_name = "glass of Drambuie"
	glass_desc = "A drink that smells like whiskey but tastes different."

/datum/reagent/alcohol/ethanol/oldfashioned
	name = "Old Fashioned"
	id = "oldfashioned"
	description = "That looks pretty old."
	color = "#2E6671"
	strength = 30
	taste_description = "bitterness"

	glass_icon_state = "oldfashioned"
	glass_name = "glass of Old Fashioned"
	glass_desc = "That looks pretty old."

/datum/reagent/alcohol/ethanol/blindrussian
	name = "Bolt of Blindness"
	id = "blindrussian"
	description = "You can't see?"
	color = "#2E6671"
	strength = 40
	taste_description = "bitter blindness"

	glass_icon_state = "blindrussian"
	glass_name = "glass of Bolt of Blindness"
	glass_desc = "You can't see?"

/datum/reagent/alcohol/ethanol/rustynail
	name = "Rusty Nail"
	id = "rustynail"
	description = "Smells like lemon."
	color = "#2E6671"
	strength = 25
	taste_description = "lemons"

	glass_icon_state = "rustynail"
	glass_name = "glass of Rusty Nail"
	glass_desc = "Smells like lemon."

/datum/reagent/alcohol/ethanol/tallrussian
	name = "Tall Black Army"
	id = "tallrussian"
	description = "Just like black Army but taller."
	color = "#2E6671"
	strength = 25
	taste_description = "tall bitterness"
	carbonated = TRUE

	glass_icon_state = "tallblackrussian"
	glass_name = "glass of Tall Black Army"
	glass_desc = "Just like black army but taller."

//Synnono Meme Drinks
//=====================================
// Organized here because why not.

/datum/reagent/alcohol/ethanol/badtouch
	name = "Bad Touch"
	id = "badtouch"
	description = "We're nothing but reptiles, after all."
	color = "#42f456"
	strength = 50
	taste_description = "naughtiness"

	glass_icon_state = "badtouch"
	glass_name = "glass of Bad Touch"
	glass_desc = "We're nothing but reptiles, after all."

/datum/reagent/alcohol/ethanol/bluelagoon
	name = "Blue Lagoon"
	id = "bluelagoon"
	description = "Because lagoons shouldn't come in other colors."
	color = "#51b8ef"
	strength = 25
	taste_description = "electric lemonade"

	glass_icon_state = "bluelagoon"
	glass_name = "glass of Blue Lagoon"
	glass_desc = "Because lagoons shouldn't come in other colors."

/datum/reagent/alcohol/ethanol/boukha
	name = "Boukha"
	id = "boukha"
	description = "A distillation of figs, popular in the Serene Republic of Loam."
	color = "#efd0d0"
	strength = 40
	taste_description = "spiced figs"

	glass_icon_state = "boukhaglass"
	glass_name = "glass of boukha"
	glass_desc = "A distillation of figs, popular in the Serene Republic of Loam."

/datum/reagent/alcohol/ethanol/fireball
	name = "Fireball"
	id = "fireball"
	description = "Whiskey that's been infused with cinnamon and hot pepper. Meant for mixing."
	color = "#773404"
	strength = 35
	taste_description = "cinnamon whiskey"

	glass_icon_state = "fireballglass"
	glass_name = "glass of fireball"
	glass_desc = "Whiskey that's been infused with cinnamon and hot pepper. Is this safe to drink?"
	taste_mult = 1.2
	var/agony_dose = 5
	var/agony_amount = 1
	var/discomfort_message = "<span class='danger'>Your insides feel uncomfortably hot!</span>"
	var/slime_temp_adj = 3

/datum/reagent/alcohol/ethanol/fireball/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.adjustToxLoss(0.1 * removed)

/datum/reagent/alcohol/ethanol/fireball/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.can_feel_pain())
			return
	if(dose < agony_dose)
		if(prob(5) || dose == metabolism)
			to_chat(M, discomfort_message)
	else
		M.apply_effect(agony_amount, AGONY, 0)
		if(prob(5))
			M.custom_emote(2, "[pick("dry heaves!","coughs!","splutters!")]")
			to_chat(M, "<span class='danger'>You feel like your insides are burning!</span>")
	holder.remove_reagent("frostoil", 2)

/datum/reagent/alcohol/ethanol/cherrytreefireball
	name = "Cherry Tree Fireball"
	id = "cherrytreefireball"
	description = "An iced fruit cocktail shaken with cinnamon whiskey. Hot, cold and sweet all at once."
	color = "#e87727"
	strength = 15
	taste_description = "sweet spiced cherries"

	glass_icon_state = "cherrytreefireball"
	glass_name = "glass of Cherry Tree Fireball"
	glass_desc = "An iced fruit cocktail shaken with cinnamon whiskey. Hot, cold and sweet all at once."

/datum/reagent/alcohol/ethanol/cobaltvelvet
	name = "Cobalt Velvet"
	id = "cobaltvelvet"
	description = "An electric blue champagne cocktail that's popular on the club scene."
	color = "#a3ecf7"
	strength = 25
	taste_description = "neon champagne"
	carbonated = TRUE

	glass_icon_state = "cobaltvelvet"
	glass_name = "glass of Cobalt Velvet"
	glass_desc = "An electric blue champagne cocktail that's popular on the club scene."

/datum/reagent/alcohol/ethanol/fringeweaver
	name = "Fringe Weaver"
	id = "fringeweaver"
	description = "Effectively pure alcohol with a dose of sugar. It's as simple as it is strong."
	color = "#f78888"
	strength = 65
	taste_description = "liquid regret"

	glass_icon_state = "fringeweaver"
	glass_name = "glass of Fringe Weaver"
	glass_desc = "Effectively pure alcohol with a dose of sugar. It's as simple as it is strong."

/datum/reagent/alcohol/ethanol/junglejuice
	name = "Jungle Juice"
	id = "junglejuice"
	description = "You're in the jungle now, baby."
	color = "#773404"
	strength = 35
	taste_description = "a fraternity house party"

	glass_icon_state = "junglejuice"
	glass_name = "glass of Jungle Juice"
	glass_desc = "You're in the jungle now, baby."

/datum/reagent/alcohol/ethanol/marsarita
	name = "Kobsarita"
	id = "marsarita"
	description = "The margarita with a kobold twist. They call it something less embarrassing."
	color = "#3eb7c9"
	strength = 30
	taste_description = "spicy, salty lime"

	glass_icon_state = "marsarita"
	glass_name = "glass of Marsarita"
	glass_desc = "The margarita with a kobold twist. They call it something less embarrassing."

/datum/reagent/drink/meloncooler
	name = "Melon Cooler"
	id = "meloncooler"
	description = "Summertime on the beach, in liquid form."
	color = "#d8457b"
	taste_description = "minty melon"

	glass_icon_state = "meloncooler"
	glass_name = "glass of Melon Cooler"
	glass_desc = "Summertime on the beach, in liquid form."

/datum/reagent/alcohol/ethanol/midnightkiss
	name = "Midnight Kiss"
	id = "midnightkiss"
	description = "A champagne cocktail, quietly bubbling in a slender glass."
	color = "#13144c"
	strength = 25
	taste_description = "a late-night promise"
	carbonated = TRUE

	glass_icon_state = "midnightkiss"
	glass_name = "glass of Midnight Kiss"
	glass_desc = "A champagne cocktail, quietly bubbling in a slender glass."

/datum/reagent/drink/millionairesour
	name = "Millionaire Sour"
	id = "millionairesour"
	description = "It's a good mix, a great mix. The best mix in known space. It's terrific, you're gonna love it."
	color = "#13144c"
	taste_description = "tart fruit"

	glass_icon_state = "millionairesour"
	glass_name = "glass of Millionaire Sour"
	glass_desc = "It's a good mix, a great mix. Best mix in the galaxy. It's terrific, you're gonna love it."

/datum/reagent/alcohol/ethanol/olympusmons
	name = "High Command"
	id = "olympusmons"
	description = "Another, stronger version of the Black Army. It's popular in some deep tunnel communities."
	color = "#020407"
	strength = 30
	taste_description = "bittersweet independence"

	glass_icon_state = "olympusmons"
	glass_name = "glass of High Command"
	glass_desc = "Another, stronger version of the Black Russian. It's popular in some deep tunnel communities."

/datum/reagent/alcohol/ethanol/europanail
	name = "Merope Nail"
	id = "europanail"
	description = "Named for one of Loam's devastated continents. It looks about as crusty."
	color = "#785327"
	strength = 30
	taste_description = "coffee-flavored earth"

	glass_icon_state = "europanail"
	glass_name = "glass of Merope Nail"
	glass_desc = "Named for one of Loam's devastated continents. It looks about as crusty."

/datum/reagent/drink/shirleytemple
	name = "Shirley Temple"
	id = "shirleytemple"
	description = "Named for a famous temple that was recently destroyed by a meteor impact. Pour one out."
	color = "#ce2727"
	taste_description = "innocence"

	glass_icon_state = "shirleytemple"
	glass_name = "glass of Shirley Temple"
	glass_desc = "Pour one out."

/datum/reagent/alcohol/ethanol/sugarrush
	name = "Sugar Rush"
	id = "sugarrush"
	description = "Sweet, light and fruity. As girly as it gets."
	color = "#d51d5d"
	strength = 15
	taste_description = "sweet soda"
	carbonated = TRUE

	glass_icon_state = "sugarrush"
	glass_name = "glass of Sugar Rush"
	glass_desc = "Sweet, light and fruity. As girly as it gets."

/datum/reagent/alcohol/ethanol/sangria
	name = "Sangria"
	id = "sangria"
	description = "Red wine, splashed with brandy and infused with fruit."
	color = "#960707"
	strength = 30
	taste_description = "sweet wine"

	glass_icon_state = "sangria"
	glass_name = "glass of Sangria"
	glass_desc = "Red wine, splashed with brandy and infused with fruit."

/datum/reagent/alcohol/ethanol/bassline
	name = "Bassline"
	id = "bassline"
	description = "A vodka cocktail from Starnival, a loamer party-yacht on an endless cruise through the cosmos. Purple and deep."
	color = "#6807b2"
	strength = 25
	taste_description = "the groove"

	glass_icon_state = "bassline"
	glass_name = "glass of Bassline"
	glass_desc = "A vodka cocktail from Starnival, a loamer party-yacht on an endless cruise through the cosmos. Purple and deep."

/datum/reagent/alcohol/ethanol/bluebird
	name = "Bluebird"
	id = "bluebird"
	description = "A gin drink popularized by a spy thriller."
	color = "#4286f4"
	strength = 30
	taste_description = "a blue christmas tree"

	glass_icon_state = "bluebird"
	glass_name = "glass of Bluebird"
	glass_desc = "A gin drink popularized by a spy thriller."

/datum/reagent/alcohol/ethanol/whitewine
	name = "White Wine"
	id = "whitewine"
	description = "A premium alchoholic beverage made from distilled grape juice. Balance with shrimp."
	color = "#e5d272"
	strength = 15
	taste_description = "dry sweetness"

	glass_icon_state = "whitewineglass"
	glass_name = "glass of white wine"
	glass_desc = "A very classy looking drink. Ensure your shrimp intake keeps pace with your white wine."
	glass_center_of_mass = list("x"=15, "y"=7)

/datum/reagent/alcohol/ethanol/cinnamonapplewhiskey
	name = "Cinnamon Apple Whiskey"
	id = "cinnamonapplewhiskey"
	description = "Cider with cinnamon whiskey. It's like drinking a hot apple pie!"
	color = "#664300"
	strength = 20
	taste_description = "sweet spiced apples"

	glass_icon_state = "manlydorfglass"
	glass_name = "mug of cinnamon apple whiskey"
	glass_desc = "Cider with cinnamon whiskey. It's like drinking a hot apple pie!"

/datum/reagent/drink/smokinglizard
	name = "Cigarette Lizard"
	id = "cigarettelizard"
	color = "#80C274"
	description = "The amusement of Cigarette Lizard, now in a cup!"
	taste_description = "minty sass"

	glass_icon_state = "cigarettelizard"
	glass_name = "glass of Cigarette Lizard"
	glass_desc = "The amusement of Cigarette Lizard, now in a cup!"

// Butanol-based alcoholic drinks
//=====================================
//These are mainly for unathi, and have very little (but still some) effect on other species

/datum/reagent/alcohol/ethanol/xuizijuice
	name = "Xuizi Juice"
	id = "xuizijuice"
	description = "Blended flower buds from a Moghean Xuizi cactus. Has a mild butanol content and is a staple recreational beverage in Unathi culture."
	color = "#91de47"
	strength = 5
	taste_description = "water"

	glass_icon_state = "xuiziglass"
	glass_name = "glass of Xuizi Juice"
	glass_desc = "The clear green liquid smells like vanilla, tastes like water. Unathi swear it has a rich taste and texture."

/datum/reagent/alcohol/ethanol/sarezhiwine
	name = "Sarezhi Wine"
	id = "sarezhiwine"
	description = "An alcoholic beverage made from lightly fermented Sareszhi berries, considered an upper class delicacy on Moghes. Significant butanol content indicates intoxicating effects on Unathi."
	color = "#bf8fbc"
	strength = 20
	taste_description = "berry juice"

	glass_icon_state = "sarezhiglass"
	glass_name = "glass of Sarezhi Wine"
	glass_desc = "It tastes like plain berry juice. Is this supposed to be alcoholic?"

//Kaed's Unathi Cocktails
//=======
//What an exciting time we live in, that lizards may drink fruity girl drinks.
/datum/reagent/alcohol/ethanol/moghesmargarita
	name = "Moghes Margarita"
	id = "moghesmargarita"
	description = "A classic human cocktail, now ruined with cactus juice instead of tequila."
	color = "#8CFF8C"
	strength = 30
	taste_description = "lime juice"

	glass_icon_state = "cactusmargarita"
	glass_name = "glass of Moghes Margarita"
	glass_desc = "A classic human cocktail, now ruined with cactus juice instead of tequila."
	glass_center_of_mass = list("x"=16, "y"=8)

/datum/reagent/alcohol/ethanol/cactuscreme
	name = "Cactus Creme"
	id = "cactuscreme"
	description = "A tasty mix of berries and cream with xuizi juice, for the discerning unathi."
	color = "#664300"
	strength = 15
	taste_description = "creamy berries"

	glass_icon_state = "cactuscreme"
	glass_name = "glass of Cactus Creme"
	glass_desc = "A tasty mix of berries and cream with xuizi juice, for the discerning unathi."
	glass_center_of_mass = list("x"=17, "y"=8)

/datum/reagent/alcohol/ethanol/bahamalizard
	name = "Bahama Lizard"
	id = "bahamalizard"
	description = "A tropical cocktail containing cactus juice from Moghes, but no actual alcohol."
	color = "#FF7F3B"
	strength = 15
	taste_description = "sweet lemons"

	glass_icon_state = "bahamalizard"
	glass_name = "glass of Bahama Lizard"
	glass_desc = "A tropical cocktail containing cactus juice from Moghes, but no actual alcohol."
	glass_center_of_mass = list("x"=16, "y"=5)

/datum/reagent/alcohol/ethanol/lizardphlegm
	name = "Lizard Phlegm"
	id = "lizardphlegm"
	description = "Looks gross, but smells fruity."
	color = "#8CFF8C"
	strength = 20
	taste_description = "creamy fruit"

	glass_icon_state = "lizardphlegm"
	glass_name = "glass of Lizard Phlegm"
	glass_desc = "Looks gross, but smells fruity."

/datum/reagent/alcohol/ethanol/cactustea
	name = "Cactus Tea"
	id = "cactustea"
	description = "Tea flavored with xuizi juice."
	color = "#664300"
	strength = 10
	taste_description = "tea"

	glass_icon_state = "icepick"
	glass_name = "glass of Cactus Tea"
	glass_desc = "Tea flavored with xuizi juice."

/datum/reagent/alcohol/ethanol/moghespolitan
	name = "Moghespolitan"
	id = "moghespolitan"
	description = "Pomegranate syrup and cactus juice, with a splash of Sarezhi Wine. Delicious!"
	color = "#664300"
	strength = 27
	taste_description = "fruity sweetness"

	glass_icon_state = "moghespolitan"
	glass_name = "glass of Moghespolitan"
	glass_desc = "Pomegranate syrup and cactus juice, with a splash of Sarezhi Wine. Delicious!"

/datum/reagent/alcohol/ethanol/wastelandheat
	name = "Wasteland Heat"
	id = "wastelandheat"
	description = "A mix of spicy cactus juice to warm you up."
	color = "#664300"
	strength = 40
	adj_temp = 60
	targ_temp = 390
	taste_description = "burning heat"

	glass_icon_state = "moghesheat"
	glass_name = "glass of Wasteland Heat"
	glass_desc = "A mix of spicy cactus juice to warm you up. Maybe a little too warm for non-unathi, though."
	glass_center_of_mass = list("x"=17, "y"=8)

/datum/reagent/alcohol/ethanol/Sandgria
	name = "Sandgria"
	id = "sandgria"
	description = "Sarezhi wine, blended with citrus and a splash of cactus juice."
	color = "#960707"
	strength = 30
	taste_description = "tart berries"

	glass_icon_state = "sangria"
	glass_name = "glass of Sandgria"
	glass_desc = "Sarezhi wine, blended with citrus and a splash of cactus juice."

/datum/reagent/alcohol/ethanol/contactwine
	name = "Contact Wine"
	id = "contactwine"
	description = "A perfectly good glass of Sarezhi wine, ruined by adding radioactive material. It reminds you of something..."
	color = "#2E6671"
	strength = 50
	taste_description = "berries and regret"

	glass_icon_state = "contactwine"
	glass_name = "glass of Contact Wine"
	glass_desc = "A perfectly good glass of Sarezhi wine, ruined by adding radioactive material. It reminds you of something..."
	glass_center_of_mass = list("x"=17, "y"=4)

/datum/reagent/alcohol/ethanol/hereticblood
	name = "Heretics Blood"
	id = "hereticblood"
	description = "A fizzy cocktail made with cactus juice and heresy."
	color = "#820000"
	strength = 15
	taste_description = "heretically sweet iron"

	glass_icon_state = "demonsblood"
	glass_name = "glass of Heretics' Blood"
	glass_desc = "A fizzy cocktail made with cactus juice and heresy."
	glass_center_of_mass = list("x"=16, "y"=2)

/datum/reagent/alcohol/ethanol/sandpit
	name = "Sandpit"
	id = "sandpit"
	description = "An unusual mix of cactus and orange juice, mostly favored by unathi."
	color = "#A68310"
	strength = 15
	taste_description = "oranges"

	glass_icon_state = "screwdriverglass"
	glass_name = "glass of Sandpit"
	glass_desc = "An unusual mix of cactus and orange juice, mostly favored by unathi."
	glass_center_of_mass = list("x"=15, "y"=10)

/datum/reagent/alcohol/ethanol/cactuscola
	name = "Cactus Cola"
	id = "cactuscola"
	description = "Cactus juice splashed with cola, on ice. Simple and delicious."
	color = "#3E1B00"
	strength = 15
	taste_description = "cola"
	carbonated = TRUE

	glass_icon_state = "whiskeycolaglass"
	glass_name = "glass of Cactus Cola"
	glass_desc = "Cactus juice splashed with cola, on ice. Simple and delicious."
	glass_center_of_mass = list("x"=16, "y"=9)

/datum/reagent/alcohol/ethanol/bloodwine
	name = "Bloodwine"
	id = "bloodwine"
	description = "A traditional unathi drink said to strengthen one before a battle."
	color = "#C73C00"
	strength = 21
	taste_description = "strong berries"

	glass_icon_state = "bloodwine"
	glass_name = "glass of Bloodwine"
	glass_desc = "A traditional unathi drink said to strengthen one before a battle."
	glass_center_of_mass = list("x"=15, "y"=7)

/datum/reagent/alcohol/ethanol/crocodile_booze
	name = "Crocodile Guwan"
	id = "crocodile_booze"
	description = "A highly alcoholic butanol based beverage typically fermented using the venom of a zerl'ock and cheaply made Sarezhi Wine. A popular drink among Unathi troublemakers, conviently housed in a 2L plastic bottle."
	color = "#b0f442"
	strength = 50
	taste_description = "sour body sweat"

	glass_icon_state = "crocodile_glass"
	glass_name = "glass of Crocodile Guwan"
	glass_desc = "The smell says no, but the pretty colors say yes."

/datum/reagent/alcohol/ethanol/trizkizki_tea
	name = "Trizkizki Tea"
	id = "trizkizki_tea"
	description = "A popular drink from Ouerea that smells of crisp sea air."
	color = "#876185"
	strength = 5
	taste_description = "light, sweet wine, with a hint of sea breeze"

	glass_icon_state = "trizkizkitea"
	glass_name = "cup of Trizkizki tea"
	glass_desc = "A popular drink from Ouerea that smells of crisp sea air."


	var/last_taste_time = -100

/datum/reagent/alcohol/ethanol/trizkizki_tea/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed) //contains tea. Gotta get those tea effects.
	..()
	M.adjustToxLoss(-0.1 * removed)


/datum/reagent/alcohol/ethanol/trizkizki_tea/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.adjustToxLoss(-0.1 * removed)

/datum/reagent/nutriment/pumpkinpulp
	name = "Pumpkin Pulp"
	id = "pumpkinpulp"
	description = "The gooey insides of a slain pumpkin"
	color = "#f9ab28"
	taste_description = "gooey pumpkin"

/datum/reagent/spacespice/pumpkinspice
	name = "Pumpkin Spice"
	id = "pumpkinspice"
	description = "A delicious seasonal flavoring."
	color = "#AE771C"
	taste_description = "autumn bliss"
