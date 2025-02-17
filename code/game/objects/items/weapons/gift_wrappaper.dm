/* Gifts and wrapping paper
 * Contains:
 *		Gifts
 *		X-mas Gifts
 */

/*
 * Gifts
 */
/obj/item/weapon/a_gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/items.dmi'
	icon_state = "gift1"
	item_state = "gift1"
	drop_sound = 'sound/items/drop/box.ogg'

/obj/item/weapon/a_gift/New()
	..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	if(w_class > 0 && w_class < 4)
		icon_state = "gift[w_class]"
	else
		icon_state = "gift[pick(1, 2, 3)]"
	return

/obj/item/weapon/gift/attack_self(mob/user as mob)
	user.drop_item()
	playsound(src.loc, 'sound/items/package_unwrap.ogg', 50,1)
	if(src.gift)
		user.put_in_active_hand(gift)
		src.gift.add_fingerprint(user)
	else
		to_chat(user, "<span class='warning'>The gift was empty!</span>")
	qdel(src)
	return

/obj/item/weapon/a_gift/ex_act(var/severity = 2.0)
	qdel(src)
	return

/obj/effect/spresent/relaymove(mob/user as mob)
	if (user.stat)
		return
	to_chat(user, "<span class='warning'>You can't move.</span>")

/obj/effect/spresent/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if (!W.iswirecutter())
		to_chat(user, "<span class='warning'>I need wirecutters for that.</span>")
		return

	to_chat(user, "<span class='notice'>You cut open the present.</span>")

	for(var/mob/M in src) //Should only be one but whatever.
		M.forceMove(src.loc)
		if (M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

	qdel(src)

/obj/item/weapon/a_gift/attack_self(mob/M as mob)
	var/gift_type = pick(
		/obj/item/weapon/storage/wallet,
		/obj/item/weapon/storage/photo_album,
		/obj/item/weapon/storage/box/snappops,
		/obj/item/weapon/storage/fancy/crayons,
		/obj/item/weapon/storage/backpack/holding,
		/obj/item/weapon/storage/belt/champion,
		/obj/item/weapon/soap/deluxe,
		/obj/item/weapon/pickaxe/silver,
		/obj/item/weapon/pen/invisible,
		/obj/item/weapon/lipstick/random,
		/obj/item/weapon/grenade/smokebomb,
		/obj/item/weapon/corncob,
		/obj/item/weapon/contraband/poster,
		/obj/item/weapon/book/manual/barman_recipes,
		/obj/item/weapon/book/manual/chef_recipes,
		/obj/item/weapon/bikehorn,
		/obj/item/weapon/beach_ball,
		/obj/item/weapon/beach_ball/holoball,
		/obj/item/toy/balloon,
		/obj/item/toy/blink,
		/obj/item/toy/crossbow,
		/obj/item/weapon/gun/projectile/revolver/capgun,
		/obj/item/toy/katana,
		/obj/item/toy/prize/deathripley,
		/obj/item/toy/prize/durand,
		/obj/item/toy/prize/fireripley,
		/obj/item/toy/prize/gygax,
		/obj/item/toy/prize/honk,
		/obj/item/toy/prize/marauder,
		/obj/item/toy/prize/mauler,
		/obj/item/toy/prize/odysseus,
		/obj/item/toy/prize/phazon,
		/obj/item/toy/prize/ripley,
		/obj/item/toy/prize/seraph,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/device/violin,
		/obj/item/weapon/storage/belt/utility/full,
		/obj/item/clothing/accessory/horrible)

	if(!ispath(gift_type,/obj/item))	return

	var/obj/item/I = new gift_type(M)
	M.remove_from_mob(src)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	qdel(src)
	return

/*
 * Wrapping Paper
 */

/*
 * Xmas Gifts
 */
/obj/item/weapon/xmasgift
	name = "christmas gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/items.dmi'
	icon_state = "gift1"
	item_state = "gift1"
	w_class = 1

/obj/item/weapon/xmasgift/New()
	..()
	var/gift_benefactor = pick("the NanoTrasen Department of Christmas Affairs", "Miranda Trasen", "Joseph Dorne", "Isaac Asimov", "Baal D. Griffon", "the Sol Alliance (Sorry about the blockade!)",
		"Hephaestus Industries", "Idris Incorporated", "Glorsh Omega II", "the Jargon Federation", "the People's Republic of Adhomai", "the Adhomai Liberation Army", "the Izweski Hegemony",
		"the Zo'ra Hive","the Frontier Alliance", "Digital Dingo", "Optimum Jeffrey", "Lemmy and the Clockworks", "President Hadii", "King Azunja","Supreme Commander Nated'Hakhan",
		"Lord-Regent Not'zar","Jesus Christ","Santa Claus","Mrs. Claus","Sandy Claws","Buddha","Gary","Jesus Christ!","the True Queen of Biesel, God-Lady Seon-rin von Illdenberg, First of Her Name",
		"Admiral Frost","Pirate King Frost", "The Secret NanoTrasen Cabal of Duty Officers", "The Society for the Preservation of Rats", "Officer Beepsky","Lieutenant Columbo","B.O.B","Runtime",
		"Bones","Chauncey","Ian","Pun Pun","Nup Nup","Waldo","Odlaw","Crew of the NSS Exodus", "Custodial Staff of the NTCC Odin","ERT Phoenix","grey slime (357)","Bob the Blob","People for the Ethical Treatment of Bluespace Bears",
		"Mr. Clown and Mrs. Mime from New Puerto Rico","the Grinch","the Krampus","Satan","Mega-Satan","<span class='danger'>\[BENEFACTOR REDACTED]\</span>","Bluespace Cat","Union of Bluespace Technicians Tau Ceti","Robo Mickey Mouse")
	var/pick_emotion = pick("love","platonic admiration","approval","love (not in a sexual way or anything, though)","apathy", "schadenfreude","love","God's blessing","Santa's blessing","Non-demoninational deity's blessing","love","compassion","appreciation",
		"respect","begrudging respect","love")
	desc = "To: <i>The [station_name()]</i><BR>From: <i>[gift_benefactor], with [pick_emotion]</i>"

	return

/obj/item/weapon/xmasgift/ex_act(var/severity = 2.0)
	qdel(src)
	return

/obj/item/weapon/xmasgift/small/attack_self(mob/M as mob)
	var/gift_type = pick(
		/obj/random/action_figure,
		/obj/random/coin,
		/obj/random/spacecash,
		/obj/random/glowstick,
		/obj/item/weapon/storage/wallet,
		/obj/item/weapon/storage/photo_album,
		/obj/item/weapon/storage/box/snappops,
		/obj/item/weapon/storage/fancy/crayons,
		/obj/item/weapon/soap/deluxe,
		/obj/item/weapon/pen/invisible,
		/obj/item/clothing/gloves/watch,
		/obj/item/weapon/lipstick/random,
		/obj/item/weapon/corncob,
		/obj/item/weapon/bikehorn,
		/obj/item/toy/balloon,
		/obj/item/toy/blink,
		/obj/item/weapon/gun/projectile/revolver/capgun,
		/obj/item/toy/prize/deathripley,
		/obj/item/toy/prize/durand,
		/obj/item/toy/prize/fireripley,
		/obj/item/toy/prize/gygax,
		/obj/item/toy/prize/honk,
		/obj/item/toy/prize/marauder,
		/obj/item/toy/prize/mauler,
		/obj/item/toy/prize/odysseus,
		/obj/item/toy/prize/phazon,
		/obj/item/toy/prize/ripley,
		/obj/item/toy/prize/seraph,
		/obj/item/clothing/accessory/horrible,
		/obj/item/device/camera,
		/obj/item/bluespace_crystal,
		/obj/item/weapon/flame/lighter/zippo,
		/obj/item/device/taperecorder,
		/obj/item/weapon/storage/fancy/cigarettes/dromedaryco,
		/obj/item/toy/bosunwhistle,
		/obj/item/clothing/mask/fakemoustache,
		/obj/item/clothing/mask/gas/clown_hat,
		/obj/item/clothing/mask/gas/mime,
		/obj/item/clothing/head/festive/santa,
		/obj/item/stack/material/animalhide/lizard,
		/obj/item/stack/material/animalhide/cat,
		/obj/item/stack/material/animalhide/corgi,
		/obj/item/stack/material/animalhide/human,
		/obj/item/stack/material/animalhide/monkey,
		/obj/item/stack/material/animalhide/xeno,
		/obj/item/trash/cheesie,
		/obj/item/trash/raisins,
		/obj/item/trash/koisbar,
		/obj/item/weapon/xmasgift/medium,
		/obj/item/toy/syndicateballoon,
		/obj/item/toy/xmastree,
		/obj/item/clothing/accessory/medal/gold/heroism,
		/obj/item/clothing/accessory/medal/nobel_science,
		/obj/item/clothing/accessory/medal/bronze_heart,
		/obj/item/clothing/accessory/medal/silver/valor,
		/obj/item/bluespace_crystal,
		/obj/random/junk,
		/obj/item/weapon/gun/energy/mousegun,
		/obj/item/weapon/gun/energy/wand/toy,
		/obj/item/weapon/mirror,
		/obj/item/weapon/ore/coal,
		/obj/item/weapon/ore/coal,
		/obj/item/weapon/ore/coal,
		/obj/item/weapon/stamp/clown,
		/obj/item/latexballon)

	var/atom/movable/I = new gift_type(get_turf(M))
	M.remove_from_mob(src)
	M.put_in_hands(I)
	to_chat(M, "<span class='notice'>You open the gift, revealing your new [I.name]! Just what you always wanted!</span>")
	qdel(src)
	return

/obj/item/weapon/xmasgift/medium
	icon_state = "gift2"
	item_state = "gift2"
	w_class = 2

/obj/item/weapon/xmasgift/medium/attack_self(mob/M as mob)
	var/gift_type = pick(
		/obj/item/weapon/sord,
		/obj/random/booze,
		/obj/item/weapon/storage/belt/champion,
		/obj/item/weapon/pickaxe/silver,
		/obj/item/weapon/grenade/smokebomb,
		/obj/item/weapon/contraband/poster,
		/obj/item/weapon/book/manual/barman_recipes,
		/obj/item/weapon/book/manual/chef_recipes,
		/obj/item/weapon/banhammer,
		/obj/item/toy/crossbow,
		/obj/item/toy/katana,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/clothing/accessory/horrible,
		/obj/item/weapon/storage/box/donkpockets,
		/obj/item/weapon/reagent_containers/food/drinks/teapot,
		/obj/item/device/flashlight/lantern,
		/obj/item/clothing/mask/balaclava,
		/obj/item/clothing/accessory/badge/old,
		/obj/item/clothing/mask/gas/clown_hat,
		/obj/item/clothing/mask/gas/mime,
		/obj/item/clothing/shoes/galoshes,
		/mob/living/simple_animal/lizard,
		/mob/living/simple_animal/rat/brown,
		/mob/living/simple_animal/rat/gray,
		/mob/living/simple_animal/rat/white,
		/obj/item/weapon/xmasgift/small,
		/obj/item/weapon/tank/jetpack/void,
		/obj/item/weapon/xmasgift/large,
		/obj/item/weapon/reagent_containers/food/snacks/pudding,
		/obj/item/weapon/contraband/poster,
		/obj/item/clothing/head/hardhat/red/atmos,
		/mob/living/bot/cleanbot,
		/obj/item/device/binoculars,
		/obj/item/device/camera,
		/obj/item/device/gps,
		/obj/item/device/uv_light,
		/obj/random/loot,
		/obj/random/contraband,
		/obj/item/weapon/autochisel,
		/obj/item/weapon/ore/coal,
		/obj/item/weapon/ore/coal,
		/obj/item/weapon/ore/coal,
		/obj/item/weapon/phone,
		/obj/item/device/dociler,
		/obj/item/device/flashlight/maglight,
		/obj/item/device/megaphone,
		/obj/item/device/violin)

	var/atom/movable/I = new gift_type(get_turf(M))
	M.remove_from_mob(src)
	if (!M.put_in_hands(I))
		M.forceMove(get_turf(src))
	to_chat(M, "<span class='notice'>You open the gift, revealing your new [I.name]! Just what you always wanted!</span>")
	qdel(src)
	return

/obj/item/weapon/xmasgift/large
	icon_state = "gift3"
	item_state = "gift3"
	w_class = 3

/obj/item/weapon/xmasgift/large/attack_self(mob/M as mob)
	var/gift_type = pick(
		/obj/item/weapon/inflatable_duck,
		/obj/item/weapon/beach_ball,
		/obj/item/clothing/under/redcoat,
		/obj/item/clothing/under/syndicate/tracksuit,
		/obj/item/clothing/under/rank/clown,
		/obj/item/clothing/under/mime,
		/obj/item/clothing/under/rank/fatigues/marine,
		/obj/item/clothing/under/rank/dress/marine,
		/mob/living/simple_animal/cat/kitten,
		/mob/living/simple_animal/chick,
		/mob/living/simple_animal/corgi/puppy,
		/mob/living/simple_animal/mushroom,
		/obj/item/weapon/xmasgift/medium,
		/obj/item/weapon/tank/jetpack,
		/obj/item/toy/plushie/drone,
		/obj/item/toy/plushie/ivancarp,
		/obj/item/weapon/ore/coal,
		/obj/item/weapon/ore/coal,
		/obj/item/weapon/ore/coal,
		/obj/item/weapon/mass_driver_diy,
		/mob/living/simple_animal/crab,
		/mob/living/simple_animal/parrot,
		/mob/living/simple_animal/hostile/commanded/dog/pug,
		/obj/item/target/alien)

	var/atom/movable/I = new gift_type(get_turf(M))
	M.remove_from_mob(src)
	M.put_in_hands(I)
	to_chat(M, "<span class='notice'>You open the gift, revealing your new [I.name]! Just what you always wanted!</span>")
	qdel(src)
	return
