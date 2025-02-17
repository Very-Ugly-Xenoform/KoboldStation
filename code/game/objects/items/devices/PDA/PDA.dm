
//The advanced pea-green monochrome lcd of tomorrow.

var/global/list/obj/item/device/pda/PDAs = list()

/obj/item/device/pda
	name = "\improper PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = 2.0
	slot_flags = SLOT_ID | SLOT_BELT
	uv_intensity = 15

	//Main variables
	var/owner = null
	var/default_cartridge = 0 // Access level defined by cartridge
	var/obj/item/weapon/cartridge/cartridge = null //current cartridge
	var/tmp/mode = 0 //Controls what menu the PDA will display. 0 is hub; the rest are either built in or based on cartridge.

	var/tmp/lastmode = 0
	var/tmp/ui_tick = 0
	var/tmp/nanoUI[0]

	//Secondary variables
	var/scanmode = 0 //1 is medical scanner, 2 is forensics, 3 is reagent scanner.
	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 2 //Luminosity for the flashlight function
	var/message_silent = 0 //To beep or not to beep, that is the question
	var/news_silent = 1 //To beep or not to beep, that is the question.  The answer is No.
	var/toff = 0 //If 1, messenger disabled
	var/tnote[0]  //Current Texts
	var/last_text //No text spamming
	var/last_honk //Also no honk spamming that's bad too
	var/ttone = "beep" //The PDA ringtone!
	var/newstone = "beep, beep" //The news ringtone!
	var/lock_code = "" // Lockcode to unlock uplink
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/note = "Congratulations, your station has chosen the Thinktronic 5230 Personal Data Assistant!" //Current note in the notepad function
	var/notehtml = ""
	var/cart = "" //A place to stick cartridge menu information
	var/detonate = 1 // Can the PDA be blown up?
	var/hidden = 0 // Is the PDA hidden from the PDA list?
	var/has_pen = 1 // Does the PDA have a pen + penslot?
	var/tmp/active_conversation = null // New variable that allows us to only view a single conversation.
	var/tmp/list/conversations = list()    // For keeping up with who we have PDA messsages from.
	var/new_message = 0			//To remove hackish overlay check
	var/new_news = 0
	var/pdafilter = 0			//0-all,1-synth,2-command,3-sec,4-eng,5-sci,6-cargo,7-service,8-med

	var/tmp/active_feed				// The selected feed
	var/tmp/list/warrant			// The warrant as we last knew it
	var/tmp/list/feeds = list()		// The list of feeds as we last knew them
	var/tmp/list/feed_info = list()	// The data and contents of each feed as we last knew them

	var/list/cartmodes = list(40, 42, 43, 433, 44, 441, 45, 451, 46, 48, 47, 49) // If you add more cartridge modes add them to this list as well.
	var/list/no_auto_update = list(1, 40, 43, 44, 441, 45, 451)		     // These modes we turn off autoupdate
	var/list/update_every_five = list(3, 41, 433, 46, 47, 48, 49)			     // These we update every 5 ticks

	var/obj/item/weapon/card/id/id = null //Making it possible to slot an ID card into the PDA so it can function as both.
	var/ownjob = null //related to above - this is assignment (potentially alt title)
	var/ownrank = null // this one is rank, never alt title

	var/obj/item/weapon/pen/pen
	var/tmp/list/obj/machinery/requests_console/linked_consoles

	var/flippable = 1
	var/flipped = 0
	var/wear_over_suit = 0

/obj/item/device/pda/examine(mob/user)
	if(..(user, 1))
		to_chat(user, "The time [worldtime2text()] is displayed in the corner of the screen.")
		if (pen)
			to_chat(user, "There is \a [pen] in the pen slot.")

/obj/item/device/pda/medical
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-m"

/obj/item/device/pda/viro
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-v"

/obj/item/device/pda/engineering
	default_cartridge = /obj/item/weapon/cartridge/engineering
	icon_state = "pda-e"

/obj/item/device/pda/security
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-s"

/obj/item/device/pda/detective
	default_cartridge = /obj/item/weapon/cartridge/detective
	icon_state = "pda-det"

/obj/item/device/pda/warden
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-warden"

/obj/item/device/pda/janitor
	default_cartridge = /obj/item/weapon/cartridge/janitor
	icon_state = "pda-j"
	ttone = "slip"

/obj/item/device/pda/science
	default_cartridge = /obj/item/weapon/cartridge/signal/science
	icon_state = "pda-tox"
	ttone = "boom"

/obj/item/device/pda/xenobio
	default_cartridge = /obj/item/weapon/cartridge/signal/science
	icon_state = "pda-xenobio"

/obj/item/device/pda/clown
	default_cartridge = /obj/item/weapon/cartridge/clown
	icon_state = "pda-clown"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	ttone = "honk"

/obj/item/device/pda/mime
	default_cartridge = /obj/item/weapon/cartridge/mime
	icon_state = "pda-mime"
	message_silent = 1
	news_silent = 1
	ttone = "silence"
	newstone = "silence"

/obj/item/device/pda/heads
	default_cartridge = /obj/item/weapon/cartridge/head
	icon_state = "pda-h"
	news_silent = 1

/obj/item/device/pda/heads/hop
	default_cartridge = /obj/item/weapon/cartridge/hop
	icon_state = "pda-hop"

/obj/item/device/pda/heads/hos
	default_cartridge = /obj/item/weapon/cartridge/hos
	icon_state = "pda-hos"

/obj/item/device/pda/heads/ce
	default_cartridge = /obj/item/weapon/cartridge/ce
	icon_state = "pda-ce"

/obj/item/device/pda/heads/cmo
	default_cartridge = /obj/item/weapon/cartridge/cmo
	icon_state = "pda-cmo"

/obj/item/device/pda/heads/rd
	default_cartridge = /obj/item/weapon/cartridge/rd
	icon_state = "pda-rd"

/obj/item/device/pda/captain
	default_cartridge = /obj/item/weapon/cartridge/captain
	icon_state = "pda-c"
	detonate = 0
	//toff = 1

/obj/item/device/pda/ert
	default_cartridge = /obj/item/weapon/cartridge/captain
	icon_state = "pda-h"
	detonate = 0
	hidden = 1

/obj/item/device/pda/cargo
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-cargo"

/obj/item/device/pda/quartermaster
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-q"

/obj/item/device/pda/shaftminer
	icon_state = "pda-miner"

/obj/item/device/pda/syndicate
	default_cartridge = /obj/item/weapon/cartridge/syndicate
	icon_state = "pda-syn"
	name = "Military PDA"
	owner = "John Doe"
	hidden = 1

/obj/item/device/pda/chaplain
	icon_state = "pda-holy"
	ttone = "holy"

/obj/item/device/pda/lawyer
	default_cartridge = /obj/item/weapon/cartridge/lawyer
	icon_state = "pda-lawyer"
	ttone = "..."

/obj/item/device/pda/botanist
	//default_cartridge = /obj/item/weapon/cartridge/botanist
	icon_state = "pda-hydro"

/obj/item/device/pda/roboticist
	icon_state = "pda-robot"

/obj/item/device/pda/librarian
	icon_state = "pda-libb"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a WGW-11 series e-reader."
	note = "Congratulations, your station has chosen the Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant!"
	message_silent = 1 //Quiet in the library!
	news_silent = 0		// Librarian is above the law!  (That and alt job title is reporter)

/obj/item/device/pda/clear
	icon_state = "pda-transp"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a special edition with a transparent case."
	note = "Congratulations, you have chosen the Thinktronic 5230 Personal Data Assistant Deluxe Special Max Turbo Limited Edition!"

/obj/item/device/pda/chef
	icon_state = "pda-chef"

/obj/item/device/pda/bar
	icon_state = "pda-bar"

/obj/item/device/pda/atmos
	default_cartridge = /obj/item/weapon/cartridge/atmos
	icon_state = "pda-atmo"

/obj/item/device/pda/chemist
	default_cartridge = /obj/item/weapon/cartridge/chemistry
	icon_state = "pda-chem"

/obj/item/device/pda/psych
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-psych"

/obj/item/device/pda/paramedic
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-paramedic"

/obj/item/device/pda/merchant
	icon_state = "pda-chef"
	hidden = 1

// Special AI/pAI PDAs that cannot explode.
/obj/item/device/pda/ai
	icon_state = "NONE"
	ttone = "data"
	newstone = "news"
	detonate = 0
	has_pen = 0


/obj/item/device/pda/ai/proc/set_name_and_job(newname as text, newjob as text, newrank as null|text)
	owner = newname
	ownjob = newjob
	if(newrank)
		ownrank = newrank
	else
		ownrank = ownjob
	name = newname + " (" + ownjob + ")"
	try_sort_pda_list()

//AI verb and proc for sending PDA messages.
/obj/item/device/pda/ai/verb/cmd_send_pdamesg()
	set category = "AI IM"
	set name = "Send Message"
	set src in usr
	if(usr.stat == 2)
		to_chat(usr, "You can't send PDA messages because you are dead!")
		return
	var/list/plist = available_pdas()
	if (plist)
		var/c = input(usr, "Please select a PDA") as null|anything in sortList(plist)
		if (!c) // if the user hasn't selected a PDA file we can't send a message
			return
		var/selected = plist[c]
		create_message(usr, selected, 0)


/obj/item/device/pda/ai/verb/cmd_toggle_pda_receiver()
	set category = "AI IM"
	set name = "Toggle Sender/Receiver"
	set src in usr
	if(usr.stat == 2)
		to_chat(usr, "You can't do that because you are dead!")
		return
	toff = !toff
	to_chat(usr, "<span class='notice'>PDA sender/receiver toggled [(toff ? "Off" : "On")]!</span>")


/obj/item/device/pda/ai/verb/cmd_toggle_pda_silent()
	set category = "AI IM"
	set name = "Toggle Ringer"
	set src in usr
	if(usr.stat == 2)
		to_chat(usr, "You can't do that because you are dead!")
		return
	message_silent=!message_silent
	to_chat(usr, "<span class='notice'>PDA ringer toggled [(message_silent ? "Off" : "On")]!</span>")


/obj/item/device/pda/ai/verb/cmd_show_message_log()
	set category = "AI IM"
	set name = "Show Message Log"
	set src in usr
	if(usr.stat == 2)
		to_chat(usr, "You can't do that because you are dead!")
		return
	var/HTML = "<html><head><title>AI PDA Message Log</title></head><body>"
	for(var/index in tnote)
		if(index["sent"])
			HTML += addtext("<i><b>&rarr; To <a href='byond://?src=\ref[src];choice=Message;notap=1;target=",index["src"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")
		else
			HTML += addtext("<i><b>&larr; From <a href='byond://?src=\ref[src];choice=Message;notap=1;target=",index["target"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")
	HTML +="</body></html>"
	usr << browse(HTML, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")

/obj/item/device/pda/ai/attack_self(mob/user as mob)
	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)
	return


/obj/item/device/pda/ai/pai
	ttone = "assist"


/*
 *	The Actual PDA
 */

/obj/item/device/pda/Initialize(mapload)
	. = ..()
	if(!(src in PDAs))
		PDAs += src
	if (!mapload)
		try_sort_pda_list()
	if(default_cartridge)
		cartridge = new default_cartridge(src)

	if (has_pen)
		pen = new /obj/item/weapon/pen(src)

/obj/item/device/pda/proc/try_sort_pda_list()
	addtimer(CALLBACK(GLOBAL_PROC, /proc/sortTim, PDAs, /proc/cmp_pda), 1 SECOND, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)

/obj/item/device/pda/GetAccess()
	if(id)
		return id.GetAccess()
	else
		return ..()

/obj/item/device/pda/GetID()
	return id

/obj/item/device/pda/AltClick(var/mob/user)
	if(!user || user.stat || user.lying || user.restrained() || !Adjacent(user))	return
	if (ismob(src.loc))
		verb_remove_id()

/obj/item/device/pda/CtrlShiftClick(mob/user)
	remove_pen(user)

/obj/item/device/pda/MouseDrop(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /obj/screen)) && !use_check(M))
		return attack_self(M)

/obj/item/device/pda/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui_tick++
	var/datum/nanoui/old_ui = SSnanoui.get_open_ui(user, src, "main")
	var/auto_update = 1
	if(mode in no_auto_update)
		auto_update = 0
	if(old_ui && (mode == lastmode && ui_tick % 5 && mode in update_every_five))
		return

	lastmode = mode

	var/title = "Personal Data Assistant"

	var/data[0]  // This is the data that will be sent to the PDA

	data["owner"] = owner					// Who is your daddy...
	data["ownjob"] = ownjob					// ...and what does he do?

	data["mode"] = mode					// The current view
	data["scanmode"] = scanmode				// Scanners
	data["fon"] = fon					// Flashlight on?
	data["note"] = note					// current pda notes
	data["message_silent"] = message_silent					// does the pda make noise when it receives a message?
	data["news_silent"] = news_silent					// does the pda make noise when it receives news?
	data["toff"] = toff					// is the messenger function turned off?
	data["active_conversation"] = active_conversation	// Which conversation are we following right now?


	data["idInserted"] = (id ? 1 : 0)
	data["idLink"] = (id ? text("[id.registered_name], [id.assignment]") : "--------")

	data["cart_loaded"] = cartridge ? 1:0
	if(cartridge)
		var/cartdata[0]
		cartdata["access"] = list(\
					"access_security" = cartridge.access_security,\
					"access_engine" = cartridge.access_engine,\
					"access_atmos" = cartridge.access_atmos,\
					"access_medical" = cartridge.access_medical,\
					"access_clown" = cartridge.access_clown,\
					"access_mime" = cartridge.access_mime,\
					"access_janitor" = cartridge.access_janitor,\
					"access_quartermaster" = cartridge.access_quartermaster,\
					"access_hydroponics" = cartridge.access_hydroponics,\
					"access_reagent_scanner" = cartridge.access_reagent_scanner,\
					"access_remote_door" = cartridge.access_remote_door,\
					"access_status_display" = cartridge.access_status_display,\
					"access_detonate_pda" = cartridge.access_detonate_pda\
			)

		if(mode in cartmodes)
			data["records"] = cartridge.create_NanoUI_values()

		if(mode == 0)
			cartdata["name"] = cartridge.name
			if(isnull(cartridge.radio))
				cartdata["radio"] = 0
			else
				if(istype(cartridge.radio, /obj/item/radio/integrated/beepsky))
					cartdata["radio"] = 1
				if(istype(cartridge.radio, /obj/item/radio/integrated/signal))
					cartdata["radio"] = 2
				if(istype(cartridge.radio, /obj/item/radio/integrated/mule))
					cartdata["radio"] = 3

		if(mode == 2)
			cartdata["charges"] = cartridge.charges ? cartridge.charges : 0
		data["cartridge"] = cartdata

	data["stationTime"] = worldtime2text()
	data["new_Message"] = new_message
	data["new_News"] = new_news

	if(mode==2)
		var/convopdas[0]
		var/pdas[0]
		var/count = 0
		for (var/obj/item/device/pda/P in PDAs)
			if (!P.owner||P.toff||P == src||P.hidden)       continue
			if(conversations.Find("\ref[P]"))
				convopdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "1")))
			else
				switch(pdafilter)
					if(0)	//All
						pdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "0")))
					if(1)	//Synth -- Not working
						if(P == /obj/item/device/pda/ai)
							pdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "0")))
					if(2) //Command
						if(P.icon_state == "pda-hop"||P.icon_state == "pda-hos"||P.icon_state == "pda-ce"||P.icon_state == "pda-cmo"||P.icon_state == "pda-rd"||P.icon_state == "pda-c"||P.icon_state == "pda-h")
							pdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "0")))
					if(3)	//sec
						if(P.icon_state == "pda-hos"||P.icon_state == "pda-warden"||P.icon_state == "pda-det"||P.icon_state == "pda-sec"||P.icon_state == "pda-s")
							pdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "0")))
					if(4)	//eng
						if(P.icon_state == "pda-ce"||P.icon_state == "pda-e"||P.icon_state == "pda-atmo")
							pdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "0")))
					if(5)	//sci
						if(P.icon_state == "pda-rd"||P.icon_state == "pda-tox"||P.icon_state == "pda-v"||P.icon_state == "pda-robot")
							pdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "0")))
					if(6)	//cargo
						if(P.icon_state == "pda-hop"||P.icon_state == "pda-cargo"||P.icon_state == "pda-q"||P.icon_state == "pda-miner")
							pdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "0")))
					if(7)	//service
						if(P.icon_state == "pda-hop"||P.icon_state == "pda-bar"||P.icon_state == "pda-holy"||P.icon_state == "pda-lawyer"||P.icon_state == "pda-libb"||P.icon_state == "pda-hydro"||P.icon_state == "pda-chef"||P.icon_state == "pda-j")
							pdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "0")))
					if(8)	//medical
						if(P.icon_state == "pda-cmo"||P.icon_state == "pda-v"||P.icon_state == "pda-m"||P.icon_state == "pda-chem")
							pdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "0")))
			count++

		data["convopdas"] = convopdas
		data["pdas"] = pdas
		data["pda_count"] = count
		data["pdafilter"] = pdafilter

	if(mode==21)
		data["messagescount"] = tnote.len
		data["messages"] = tnote
	else
		data["messagescount"] = null
		data["messages"] = null

	if(active_conversation)
		for(var/c in tnote)
			if(c["target"] == active_conversation)
				data["convo_name"] = sanitize(c["owner"])
				data["convo_job"] = sanitize(c["job"])
				break
	if(mode==41)
		SSrecords.get_manifest_json()

	if(mode==3)
		var/turf/T = get_turf(user.loc)
		if(!isnull(T))
			var/datum/gas_mixture/environment = T.return_air()

			var/pressure = environment.return_pressure()
			var/total_moles = environment.total_moles

			if (total_moles)
				var/o2_level = environment.gas["oxygen"]/total_moles
				var/n2_level = environment.gas["nitrogen"]/total_moles
				var/co2_level = environment.gas["carbon_dioxide"]/total_moles
				var/phoron_level = environment.gas["phoron"]/total_moles
				var/unknown_level =  1-(o2_level+n2_level+co2_level+phoron_level)
				data["aircontents"] = list(\
					"pressure" = "[round(pressure,0.1)]",\
					"nitrogen" = "[round(n2_level*100,0.1)]",\
					"oxygen" = "[round(o2_level*100,0.1)]",\
					"carbon_dioxide" = "[round(co2_level*100,0.1)]",\
					"phoron" = "[round(phoron_level*100,0.01)]",\
					"other" = "[round(unknown_level, 0.01)]",\
					"temp" = "[round(environment.temperature-T0C,0.1)]",\
					"reading" = 1\
					)
		if(isnull(data["aircontents"]))
			data["aircontents"] = list("reading" = 0)
	if(mode==6)
		feeds.Cut()
		for(var/channel in SSnews.network_channels)
			var/datum/feed_channel/FC = SSnews.GetFeedChannel(channel)
			feeds[++feeds.len] = list("name" = FC.channel_name, "censored" = FC.censored)
		data["feedChannels"] = feeds
	if(mode==61)
		var/datum/feed_channel/FC = SSnews.GetFeedChannel(active_feed["name"])

		var/list/feed = feed_info[active_feed]
		if(!feed)
			feed = list()
			feed["channel"] = FC.channel_name
			feed["author"]	= "Unknown"
			feed["censored"]= 0
			feed["updated"] = -1
			feed_info[active_feed] = feed

		if(FC.updated > feed["updated"])
			feed["author"]	= FC.author
			feed["updated"]	= FC.updated
			feed["censored"] = FC.censored

			var/list/messages = list()
			if(!FC.censored)
				var/index = 0
				for(var/datum/feed_message/FM in FC.messages)
					index++
					if(FM.img)
						usr << browse_rsc(FM.img, "pda_news_tmp_photo_[feed["channel"]]_[index].png")
					// News stories are HTML-stripped but require newline replacement to be properly displayed in NanoUI
					var/body = replacetext(FM.body, "\n", "<br>")
					messages[++messages.len] = list("author" = FM.author, "body" = body, "message_type" = FM.message_type, "time_stamp" = FM.time_stamp, "has_image" = (FM.img != null), "caption" = FM.caption, "index" = index, "likes" = FM.likes, "dislikes" = FM.dislikes)
			feed["messages"] = messages

		data["feed"] = feed

	data["manifest"] = SSrecords.manifest

	nanoUI = data
	// update the ui if it exists, returns null if no ui is passed/found

	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		// the ui does not exist, so we'll create a new() one
	        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "pda.tmpl", title, 520, 400, state = inventory_state)
		// when the ui is first opened this is the data it will use

		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
	// auto update every Master Controller tick
	ui.set_auto_update(auto_update)

//NOTE: graphic resources are loaded on client login
/obj/item/device/pda/attack_self(mob/user as mob)

	user.set_machine(src)

	if(active_uplink_check(user))
		return

	ui_interact(user) //NanoUI requires this proc
	return

/obj/item/device/pda/Topic(href, href_list)
	if(href_list["cartmenu"] && !isnull(cartridge))
		cartridge.Topic(href, href_list)
		return 1
	if(href_list["radiomenu"] && !isnull(cartridge) && !isnull(cartridge.radio))
		cartridge.radio.Topic(href, href_list)
		return 1


	..()
	var/mob/user = usr
	var/datum/nanoui/ui = SSnanoui.get_open_ui(user, src, "main")
	var/mob/living/U = usr
	//Looking for master was kind of pointless since PDAs don't appear to have one.)
	if(use_check_and_message(usr)) // Need to allow silicons here.
		U.unset_machine()
		if(ui)
			ui.close()
		return 0

	add_fingerprint(U)
	U.set_machine(src)

	switch(href_list["choice"])

//BASIC FUNCTIONS===================================

		if("Close")//Self explanatory
			U.unset_machine()
			ui.close()
			return 0
		if("Refresh")//Refresh, goes to the end of the proc.
		if("Return")//Return
			if(mode<=9)
				mode = 0
			else
				mode = round(mode/10)
				if(mode==2)
					active_conversation = null
				if(mode==4)//Fix for cartridges. Redirects to hub.
					mode = 0
				else if(mode >= 40 && mode <= 49)//Fix for cartridges. Redirects to refresh the menu.
					cartridge.mode = mode
		if ("Authenticate")//Checks for ID
			id_check(U, 1)
		if("UpdateInfo")
			ownjob = id.assignment
			ownrank = id.rank
			name = "PDA-[owner] ([ownjob])"
		if("Eject")//Ejects the cart, only done from hub.
			verb_remove_cartridge()

//MENU FUNCTIONS===================================

		if("0")//Hub
			mode = 0
		if("1")//Notes
			mode = 1
		if("2")//Messenger
			mode = 2
		if("21")//Read messages
			mode = 21
		if("3")//Atmos scan
			mode = 3
		if("4")//Redirects to hub
			mode = 0
		if("chatroom") // chatroom hub
			mode = 5
		if("41") //Manifest
			mode = 41


//MAIN FUNCTIONS===================================

		if("Light")
			if(fon)
				fon = 0
				set_light(0)
			else
				fon = 1
				set_light(f_lum)
		if("Medical Scan")
			if(scanmode == 1)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_medical))
				scanmode = 1
		if("Reagent Scan")
			if(scanmode == 3)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_reagent_scanner))
				scanmode = 3
		if("Halogen Counter")
			if(scanmode == 4)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_engine))
				scanmode = 4
		if("Honk")
			if ( !(last_honk && world.time < last_honk + 20) )
				playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
				last_honk = world.time
		if("Gas Scan")
			if(scanmode == 5)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_atmos))
				scanmode = 5

//MESSENGER/NOTE FUNCTIONS===================================

		if ("Edit")
			var/n = input(U, "Please enter message", name, notehtml) as message
			if (in_range(src, U) && loc == U)
				n = sanitizeSafe(n, extra = 0)
				if (mode == 1)
					note = html_decode(n)
					notehtml = note
					note = replacetext(note, "\n", "<br>")
			else
				ui.close()
		if("Toggle Messenger")
			toff = !toff
		if("Toggle Ringer")//If viewing texts then erase them, if not then toggle silent status
			message_silent = !message_silent
		if("Toggle News")
			news_silent = !news_silent
		if("Clear")//Clears messages
			if(href_list["option"] == "All")
				tnote.Cut()
				conversations.Cut()
			if(href_list["option"] == "Convo")
				var/new_tnote[0]
				for(var/i in tnote)
					if(i["target"] != active_conversation)
						new_tnote[++new_tnote.len] = i
				tnote = new_tnote
				conversations.Remove(active_conversation)

			active_conversation = null
			if(mode==21)
				mode=2


		if("Filter") // Filters through available pdas
			if (href_list["option"])
				pdafilter = sanitize_integer(text2num(href_list["option"]), 0, 8, pdafilter)

		if("Ringtone")
			var/t = input(U, "Please enter new ringtone", name, ttone) as text|null
			if (in_range(src, U) && loc == U)
				if (t)
					if(src.hidden_uplink && hidden_uplink.check_trigger(U, lowertext(t), lowertext(lock_code)))
						to_chat(U, "The PDA softly beeps.")
						ui.close()
					else
						t = sanitize(t, 20)
						ttone = t
			else
				ui.close()
				return 0
		if("Newstone")
			var/t = input(U, "Please enter new news tone", name, newstone) as text|null
			if (in_range(src, U) && loc == U)
				if (t)
					t = sanitize(t, 20)
					newstone = t
			else
				ui.close()
				return 0
		if("Message")

			var/obj/item/device/pda/P = locate(href_list["target"])
			var/tap = istype(U, /mob/living/carbon)
			src.create_message(U, P, tap)
			if(mode == 2)
				if(href_list["target"] in conversations)            // Need to make sure the message went through, if not welp.
					active_conversation = href_list["target"]
					mode = 21

		if("Select Conversation")
			var/P = href_list["convo"]
			for(var/n in conversations)
				if(P == n)
					active_conversation=P
					mode=21
		if("Select Feed")
			var/n = href_list["name"]
			for(var/f in feeds)
				if(f["name"] == n)
					active_feed = f
					mode=61
		if("Send Honk")//Honk virus
			if(cartridge && cartridge.access_clown)//Cartridge checks are kind of unnecessary since everything is done through switch.
				var/obj/item/device/pda/P = locate(href_list["target"])//Leaving it alone in case it may do something useful, I guess.
				if(!isnull(P))
					if (!P.toff && cartridge.charges > 0)
						cartridge.charges--
						U.show_message("<span class='notice'>Virus sent!</span>", 1)
						P.honkamt = (rand(15,20))
				else
					to_chat(U, "PDA not found.")
			else
				ui.close()
				return 0
		if("Send Silence")//Silent virus
			if(cartridge && cartridge.access_mime)
				var/obj/item/device/pda/P = locate(href_list["target"])
				if(!isnull(P))
					if (!P.toff && cartridge.charges > 0)
						cartridge.charges--
						U.show_message("<span class='notice'>Virus sent!</span>", 1)
						P.message_silent = 1
						P.news_silent = 1
						P.ttone = "silence"
						P.newstone = "silence"
				else
					to_chat(U, "PDA not found.")
			else
				ui.close()
				return 0


//SYNDICATE FUNCTIONS===================================

		if("Toggle Door")
			if(cartridge && cartridge.access_remote_door)
				for(var/obj/machinery/door/blast/M in SSmachinery.all_machines)
					if(M.id == cartridge.remote_door_id)
						if(M.density)
							M.open()
						else
							M.close()

		if("Detonate")//Detonate PDA... maybe
			if(cartridge && cartridge.access_detonate_pda)
				var/obj/item/device/pda/P = locate(href_list["target"])
				var/datum/reception/reception = get_reception(src, P, "", do_sleep = 0)
				if(!(reception.message_server && reception.telecomms_reception & TELECOMMS_RECEPTION_SENDER))
					U.show_message("<span class='warning'>An error flashes on your [src]: Connection unavailable</span>", 1)
					return
				if(reception.telecomms_reception & TELECOMMS_RECEPTION_RECEIVER == 0) // Does our recepient have a broadcaster on their level?
					U.show_message("<span class='warning'>An error flashes on your [src]: Recipient unavailable</span>", 1)
					return
				if(!isnull(P))
					if (!P.toff && cartridge.charges > 0)
						cartridge.charges--

						var/difficulty = 2

						if(P.cartridge)
							difficulty += P.cartridge.access_medical
							difficulty += P.cartridge.access_security
							difficulty += P.cartridge.access_engine
							difficulty += P.cartridge.access_clown
							difficulty += P.cartridge.access_janitor
							if(P.hidden_uplink)
								difficulty += 3

						if(prob(difficulty))
							U.show_message("<span class='warning'>An error flashes on your [src].</span>", 1)
						else if (prob(difficulty * 7))
							U.show_message("<span class='warning'>Energy feeds back into your [src]!</span>", 1)
							ui.close()
							detonate_act(src)
							log_admin("[key_name(U)] just attempted to blow up [P] with the Detomatix cartridge but failed, blowing themselves up",ckey=key_name(U),ckey_target=key_name(P))
							message_admins("[key_name_admin(U)] just attempted to blow up [P] with the Detomatix cartridge but failed.", 1)
						else
							U.show_message("<span class='notice'>Success!</span>", 1)
							log_admin("[key_name(U)] just attempted to blow up [P] with the Detomatix cartridge and succeeded",ckey=key_name(U),ckey_target=key_name(P))
							message_admins("[key_name_admin(U)] just attempted to blow up [P] with the Detomatix cartridge and succeeded.", 1)
							detonate_act(P)
					else
						to_chat(U, "No charges left.")
				else
					to_chat(U, "PDA not found.")
			else
				U.unset_machine()
				ui.close()
				return 0
		else
			mode = text2num(href_list["choice"])
			if(cartridge)
				cartridge.mode = mode

//EXTRA FUNCTIONS===================================

	if (mode == 2||mode == 21)//To clear message overlays.
		new_message = 0
		update_icon()

	if (mode == 6||mode == 61)//To clear news overlays.
		new_news = 0
		update_icon()

	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)

	return 1 // return 1 tells it to refresh the UI in NanoUI

/obj/item/device/pda/update_icon()
	..()

	cut_overlays()
	if(new_message || new_news)
		add_overlay("pda-r")

/obj/item/device/pda/proc/detonate_act(var/obj/item/device/pda/P)
	//TODO: sometimes these attacks show up on the message server
	var/effect = pick("explosion", "burn", "emp", "smoke", "stun", "spark")
	var/message = ""
	var/mob/living/M = null
	if(ismob(P.loc))
		M = P.loc

	switch(effect)

		if("explosion")
			P.explode()
			message += "Your [P] suddenly explodes!"

		if("burn")
			if(M && isliving(M))
				M.apply_damage( rand(30,60) , BURN)
			message += "You feel a searing heat! Your [P] is burning!"

		if("emp")
			empulse(P.loc, 3, 6, 1)

		if("smoke")
			var/datum/effect/effect/system/smoke_spread/bad/S = new /datum/effect/effect/system/smoke_spread/bad
			S.set_up(P, 10, 0, P.loc, 60)
			S.attach(P.loc)
			S.start()
			playsound(P.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
			message += "Large clouds of smoke billow forth from your [P]!"

		if("stun")
			if(M && isliving(M))
				M.apply_effect(5, WEAKEN)
				flick("flash", M.flash)
			message += "Your [P] flashes with a blinding white light!"

		if("spark")
			spark(P.loc, 2)
			message += "Your [P] begins to spark violently!"

	if(message)
		message += " "

	if(effect == "explosion")
		message += "Your [P] shatters in a thousand pieces!"
	else
		message += "\The [P] melts in a puddle of plastic."

	if(M && isliving(M))
		to_chat(M, "<span class='warning'>[message]</span>")

	qdel(P)

/obj/item/device/pda/proc/remove_id()
	if (id)
		if (ismob(loc))
			var/mob/M = loc
			M.put_in_hands(id)
			to_chat(usr, "<span class='notice'>You remove the ID from the [name].</span>")
			playsound(loc, 'sound/machines/id_swipe.ogg', 100, 1)
		else
			id.forceMove(get_turf(src))
		id = null

/obj/item/device/pda/proc/remove_pen(mob/user)
	if (!istype(user))
		PROCLOG_WEIRD("user variable was insane, aborting!")
		return
	if (!has_pen)
		to_chat(user, "<span class='notice'>[src] does not have a pen slot.</span>")
		return

	switch (use_check(user, USE_DISALLOW_SILICONS, show_messages = FALSE))
		if (USE_FAIL_NON_ADJACENT)
			to_chat(user, "<span class='notice'>You are too far away from [src].</span>")

		if (USE_FAIL_NON_ADV_TOOL_USR)
			if (!pen)
				to_chat(user, "<span class='notice'>[src] does not have a pen in it.</span>")
			else
				to_chat(user, "<span class='notice'>You are unable to figure out the mechanism holding [pen] in-place.</span>")

		if (USE_FAIL_IS_SILICON)
			if (pen)
				to_chat(user, "<span class='notice'>You do not have hands, how do you propose to remove [pen]?</span>")
			else
				to_chat(user, "<span class='notice'>You do not have hands.</span>")

		if (USE_FAIL_DEAD,USE_FAIL_INCAPACITATED)
			to_chat(user, "<span class='notice'>You cannot do this in your current state.</span>")

		if (USE_SUCCESS)
			if (!pen)
				to_chat(user, "<span class='notice'>[src] does not have a pen in it.</span>")
				return

			if (loc == user && !user.get_active_hand())
				to_chat(user, "<span class='notice'>You remove [pen] from [src].</span>")
				user.put_in_hands(pen)
				pen = null
			else
				to_chat(user, "<span class='notice'>You remove [pen] from [src], dropping it on the ground. Whoops.</span>")
				pen.forceMove(get_turf(src))
				pen = null

/obj/item/device/pda/proc/create_message(var/mob/living/U = usr, var/obj/item/device/pda/P, var/tap = 1)
	if(tap)
		U.visible_message("<span class='notice'>\The [U] taps on \his PDA's screen.</span>")
	var/t = input(U, "Please enter message", P.name, null) as text|null
	t = sanitize(t)
	//t = readd_quotes(t)
	t = replace_characters(t, list("&#34;" = "\""))
	if (!t || !istype(P))
		return
	if (!in_range(src, U) && loc != U)
		return

	if (isnull(P)||P.toff || toff)
		return

	if (last_text && world.time < last_text + 5)
		return

	if(use_check_and_message(U))
		return

	last_text = world.time
	var/datum/reception/reception = get_reception(src, P, t)
	t = reception.message

	if(reception.message_server && (reception.telecomms_reception & TELECOMMS_RECEPTION_SENDER)) // only send the message if it's stable
		if(!(reception.telecomms_reception & TELECOMMS_RECEPTION_RECEIVER)) // Does our recipient have a broadcaster on their level?
			to_chat(U, "ERROR: Cannot reach recipient.")
			return
		var/send_result = reception.message_server.send_pda_message("[P.owner]","[owner]","[t]")
		if (send_result)
			to_chat(U, "ERROR: Messaging server rejected your message. Reason: contains '[send_result]'.")
			return

		tnote.Add(list(list("sent" = 1, "owner" = "[P.owner]", "job" = "[P.ownjob]", "message" = "[t]", "target" = "\ref[P]")))
		P.tnote.Add(list(list("sent" = 0, "owner" = "[owner]", "job" = "[ownjob]", "message" = "[t]", "target" = "\ref[src]")))
		for(var/mob/M in player_list)
			if(M.stat == DEAD && M.client && (M.client.prefs.toggles & CHAT_GHOSTEARS)) // src.client is so that ghosts don't have to listen to rats
				if(istype(M, /mob/abstract/new_player))
					continue
				M.show_message("<span class='game say'>PDA Message - <span class='name'>[owner]</span> -> <span class='name'>[P.owner]</span>: <span class='message'>[t]</span></span>")

		if(!conversations.Find("\ref[P]"))
			conversations.Add("\ref[P]")
		if(!P.conversations.Find("\ref[src]"))
			P.conversations.Add("\ref[src]")


		if (prob(15)) //Give the AI a chance of intercepting the message
			var/who = src.owner // revealing sender
			if(prob(50))
				who = P.owner // revealing recipient

			for(var/mob/living/silicon/ai/ai in mob_list)
				if(ai.aiPDA != P && ai.aiPDA != src)
					if(who != P.owner) // if not revealing the recipient
						ai.show_message("<i>Intercepted message from <b>[who]</b>: [t]</i>")
					else // if not revealing the sender
						ai.show_message("<i>Intercepted message to <b>[who]</b>: [t]</i>")

		P.new_message_from_pda(src, t)
		SSnanoui.update_user_uis(U, src) // Update the sending user's PDA UI so that they can see the new message
	else
		to_chat(U, "<span class='notice'>ERROR: Messaging server is not responding.</span>")

/obj/item/device/pda/proc/new_info(var/beep_silent, var/message_tone, var/reception_message)
	if (!beep_silent)
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)
		for (var/mob/O in hearers(2, loc))
			O.show_message(text("\icon[src] *[message_tone]*"))
	//Search for holder of the PDA.
	var/mob/living/L = null
	if(loc && isliving(loc))
		L = loc
	//Maybe they are a pAI!
	else
		L = get(src, /mob/living/silicon)

	if(L)
		if(reception_message)
			to_chat(L, reception_message)
		SSnanoui.update_user_uis(L, src) // Update the receiving user's PDA UI so that they can see the new message

/obj/item/device/pda/proc/new_news(var/message)
	new_info(news_silent, newstone, news_silent ? "" : "\icon[src] <b>[message]</b>")

	if(!news_silent)
		new_news = 1
		update_icon()

/obj/item/device/pda/ai/new_news(var/message)
	// Do nothing

/obj/item/device/pda/proc/new_message_from_pda(var/obj/item/device/pda/sending_device, var/message)
	new_message(sending_device, sending_device.owner, sending_device.ownjob, message)

/obj/item/device/pda/proc/new_message(var/sending_unit, var/sender, var/sender_job, var/message)
	var/reception_message = "\icon[src] <b>Message from [sender] ([sender_job]), </b>\"[message]\" (<a href='byond://?src=\ref[src];choice=Message;skiprefresh=1;target=\ref[sending_unit]'>Reply</a>)"
	new_info(message_silent, ttone, reception_message)

	log_pda("[usr] (PDA: [sending_unit]) sent \"[message]\" to [name]",ckey=key_name(usr),ckey_target=key_name(name))
	new_message = 1
	update_icon()

/obj/item/device/pda/ai/new_message(var/atom/movable/sending_unit, var/sender, var/sender_job, var/message)
	var/track = ""
	if(ismob(sending_unit.loc) && isAI(loc))
		track = "(<a href='byond://?src=\ref[loc];track=\ref[sending_unit.loc];trackname=[html_encode(sender)]'>Follow</a>)"

	var/reception_message = "\icon[src] <b>Message from [sender] ([sender_job]), </b>\"[message]\" (<a href='byond://?src=\ref[src];choice=Message;skiprefresh=1;target=\ref[sending_unit]'>Reply</a>) [track]"
	new_info(message_silent, newstone, reception_message)

	log_pda("[usr] (PDA: [sending_unit]) sent \"[message]\" to [name]",ckey=key_name(usr),ckey_target=key_name(name))
	new_message = 1

/obj/item/device/pda/proc/mob_icon_update()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_wear_id()

/obj/item/device/pda/verb/verb_flip_id_icon()
	set category = "Object"
	set name = "Flip PDA side"
	set src in usr

	if(use_check_and_message(usr, use_flags = USE_DISALLOW_SILICONS))
		return
	if (!flippable)
		to_chat(usr, "You cannot flip \the [src] as it is not a flippable item.")
		return

	src.flipped = !src.flipped
	if(src.flipped)
		src.overlay_state = "[overlay_state]_flip"
	else
		src.overlay_state = initial(overlay_state)
	to_chat(usr, "You change \the [src] to be on your [src.flipped ? "left" : "right"] side.")
	mob_icon_update()

/obj/item/device/pda/verb/toggle_icon_layer()
	set name = "Switch PDA Layer"
	set category = "Object"
	set src in usr

	if(use_check_and_message(usr, use_flags = USE_DISALLOW_SILICONS))
		return
	if(wear_over_suit == -1)
		to_chat(usr, "<span class='notice'>\The [src] cannot be worn above your suit!</span>")
		return
	wear_over_suit = !wear_over_suit
	mob_icon_update()

/obj/item/device/pda/verb/verb_reset_pda()
	set category = "Object"
	set name = "Reset PDA"
	set src in usr

	if(issilicon(usr))
		return

	switch (use_check(usr, USE_FORCE_SRC_IN_USER))
		if (USE_ALLOW_DEAD,USE_ALLOW_INCAPACITATED)
			to_chat(usr, "<span class='notice'>You cannot do this in your current state.</span>")
		if (USE_SUCCESS)
			mode = 0
			SSnanoui.update_uis(src)
			to_chat(usr, "<span class='notice'>You press the reset button on \the [src].</span>")

/obj/item/device/pda/verb/verb_remove_id()
	set category = "Object"
	set name = "Remove id"
	set src in usr

	if(issilicon(usr))
		return

	switch (use_check(usr, USE_DISALLOW_SILICONS))
		if (USE_FAIL_DEAD,USE_FAIL_INCAPACITATED)
			to_chat(usr, "<span class='notice'>You cannot do this in your current state.</span>")

		if (USE_SUCCESS)
			if(id)
				remove_id()
			else
				to_chat(usr, "<span class='notice'>This PDA does not have an ID in it.</span>")

/obj/item/device/pda/verb/verb_remove_pen()
	set category = "Object"
	set name = "Remove pen"
	set src in usr

	remove_pen(usr)

/obj/item/device/pda/verb/verb_remove_cartridge()
	set category = "Object"
	set name = "Remove cartridge"
	set src in usr

	if(issilicon(usr))
		return

	switch (use_check(usr, USE_DISALLOW_SILICONS))
		if (USE_FAIL_DEAD,USE_FAIL_INCAPACITATED)
			to_chat(usr, "<span class='notice'>You cannot do this in your current state.</span>")
		if (USE_SUCCESS)
			if (!cartridge)
				to_chat(usr, "<span class='notice'>There is no cartridge in the [name].</span>")
			else
				var/turf/T = get_turf(src)
				cartridge.forceMove(T)
				if (ismob(loc))
					var/mob/M = loc
					M.put_in_hands(cartridge)

				mode = 0
				scanmode = 0
				if (cartridge.radio)
					cartridge.radio.hostpda = null
				to_chat(usr, "<span class='notice'>You remove \the [cartridge] from the [name].</span>")
				playsound(loc, 'sound/machines/click.ogg', 100, 1)
				cartridge = null

/obj/item/device/pda/proc/id_check(mob/user as mob, choice as num)//To check for IDs; 1 for in-pda use, 2 for out of pda use.
	if(choice == 1)
		if (id)
			remove_id()
			return 1
		else
			var/obj/item/I = user.get_active_hand()
			if (istype(I, /obj/item/weapon/card/id) && user.unEquip(I))
				I.forceMove(src)
				id = I
			return 1
	else
		var/obj/item/weapon/card/I = user.get_active_hand()
		if (istype(I, /obj/item/weapon/card/id) && I:registered_name && user.unEquip(I))
			var/obj/old_id = id
			I.forceMove(src)
			id = I
			user.put_in_hands(old_id)
			return 1
	return 0

// access to status display signals
/obj/item/device/pda/attackby(obj/item/C as obj, mob/user as mob)
	..()
	if(istype(C, /obj/item/weapon/cartridge) && !cartridge)
		cartridge = C
		user.drop_from_inventory(cartridge,src)
		to_chat(user, "<span class='notice'>You insert [cartridge] into [src].</span>")
		playsound(loc, 'sound/machines/click.ogg', 100, 1)
		SSnanoui.update_uis(src) // update all UIs attached to src
		if(cartridge.radio)
			cartridge.radio.hostpda = src

	else if(istype(C, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/idcard = C
		if(!idcard.registered_name)
			to_chat(user, "<span class='notice'>\The [src] rejects the ID.</span>")
			return
		if(!owner)
			update_userinfo(idcard, user)
		else
			//Basic safety check. If either both objects are held by user or PDA is on ground and card is in hand.
			if(((src in user.contents) && (C in user.contents)) || (istype(loc, /turf) && in_range(src, user) && (C in user.contents)) )
				if(id_check(user, 2))
					to_chat(user, "<span class='notice'>You put the ID into \the [src]'s slot.</span>")
					playsound(loc, 'sound/machines/id_swipe.ogg', 100, 1)
					updateSelfDialog()//Update self dialog on success.
			return	//Return in case of failed check or when successful.
		updateSelfDialog()//For the non-input related code.
	else if(C.ispen())
		if(pen)
			to_chat(user, "<span class='notice'>There is already a pen in \the [src].</span>")
		else
			user.drop_from_inventory(C,src)
			pen = C
			to_chat(user, "<span class='notice'>You slide \the [C] into \the [src].</span>")
	return

/obj/item/device/pda/proc/update_userinfo(var/obj/item/weapon/card/id/idcard, var/mob/living/user)
	owner = idcard.registered_name
	ownjob = idcard.assignment
	ownrank = idcard.rank
	name = "PDA-[owner] ([ownjob])"
	if(user)
		to_chat(user, "<span class='notice'>Card scanned.</span>")
	try_sort_pda_list()

/obj/item/device/pda/attack(mob/living/C as mob, mob/living/user as mob)
	if (istype(C, /mob/living/carbon))
		switch(scanmode)
			if(1)

				for (var/mob/O in viewers(C, null))
					O.show_message("<span class='warning'>\The [user] has analyzed [C]'s vitals!</span>", 1)

				user.show_message("<span class='notice'>Analyzing Results for [C]:</span>")
				user.show_message("<span class='notice'>    Overall Status: [C.stat > 1 ? "dead" : "[C.health - C.halloss]% healthy"]</span>", 1)
				user.show_message(text("<span class='notice'>    Damage Specifics:</span> <span class='[]'>[]</span>-<span class='[]'>[]</span>-<span class='[]'>[]</span>-<span class='[]'>[]</span>",
						(C.getOxyLoss() > 50) ? "warning" : "", calcDamage(C.getOxyLoss()),
						(C.getToxLoss() > 50) ? "warning" : "", calcDamage(C.getToxLoss()),
						(C.getFireLoss() > 50) ? "warning" : "", calcDamage(C.getFireLoss()),
						(C.getBruteLoss() > 50) ? "warning" : "", calcDamage(C.getBruteLoss())
						), 1)
				user.show_message("<span class='notice'>    Key: Suffocation/Toxin/Burns/Brute</span>", 1)
				user.show_message("<span class='notice'>    Body Temperature: [C.bodytemperature-T0C]&deg;C ([C.bodytemperature*1.8-459.67]&deg;F)</span>", 1)
				if(C.tod && (C.stat == DEAD || (C.status_flags & FAKEDEATH)))
					user.show_message("<span class='notice'>    Time of Death: [C.tod]</span>")
				if(istype(C, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = C
					var/list/damaged = H.get_damaged_organs(1,1)
					user.show_message("<span class='notice'>Localized Damage, Brute/Burn:</span>",1)
					if(length(damaged)>0)
						for(var/obj/item/organ/external/org in damaged)
							user.show_message(text("<span class='notice'>     []: <span class='[]'>[]</span>-<span class='[]'>[]</span></span>",
									capitalize(org.name), (org.brute_dam > 0) ? "warning" : "notice", calcDamage(org.brute_dam), (org.burn_dam > 0) ? "warning" : "notice", calcDamage(org.burn_dam)),1)
					else
						user.show_message("<span class='notice'>    Limbs are OK.</span>",1)

				for(var/datum/disease/D in C.viruses)
					if(!D.hidden[SCANNER])
						user.show_message("<span class='warning'><b>Warning: [D.form] Detected</b>\nName: [D.name].\nType: [D.spread].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure]</span>")

			if(2)
				if (!istype(C:dna, /datum/dna))
					to_chat(user, "<span class='notice'>No fingerprints found on [C]</span>")
				else
					to_chat(user, text("<span class='notice'>\The [C]'s Fingerprints: [md5(C:dna.uni_identity)]</span>"))
				if ( !(C:blood_DNA) )
					to_chat(user, "<span class='notice'>No blood found on [C]</span>")
					if(C:blood_DNA)
						qdel(C:blood_DNA)
				else
					to_chat(user, "<span class='notice'>Blood found on [C]. Analysing...</span>")
					spawn(15)
						for(var/blood in C:blood_DNA)
							to_chat(user, "<span class='notice'>Blood type: [C:blood_DNA[blood]]\nDNA: [blood]</span>")

			if(4)
				for (var/mob/O in viewers(C, null))
					O.show_message("<span class='warning'>\The [user] has analyzed [C]'s radiation levels!</span>", 1)

				user.show_message("<span class='notice'>Analyzing Results for [C]:</span>")
				if(C.total_radiation)
					user.show_message("<span class='notice'>Radiation Level: [C.total_radiation]</span>")
				else
					user.show_message("<span class='notice'>No radiation detected.</span>")

/obj/item/device/pda/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	switch(scanmode)

		if(3)
			if(!isobj(A))
				return
			if(!isnull(A.reagents))
				if(A.reagents.reagent_list.len > 0)
					var/reagents_length = A.reagents.reagent_list.len
					to_chat(user, "<span class='notice'>[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found.</span>")
					for (var/re in A.reagents.reagent_list)
						to_chat(user, "<span class='notice'>    [re]</span>")
				else
					to_chat(user, "<span class='notice'>No active chemical agents found in [A].</span>")
			else
				to_chat(user, "<span class='notice'>No significant chemical agents found in [A].</span>")

		if(5)
			analyze_gases(A, user)

	if (!scanmode && istype(A, /obj/item/weapon/paper) && owner)
		// JMO 20140705: Makes scanned document show up properly in the notes. Not pretty for formatted documents,
		// as this will clobber the HTML, but at least it lets you scan a document. You can restore the original
		// notes by editing the note again. (Was going to allow you to edit, but scanned documents are too long.)
		var/raw_scan = (A:info)
		var/formatted_scan = ""
		// Scrub out the tags (replacing a few formatting ones along the way)

		// Find the beginning and end of the first tag.
		var/tag_start = findtext(raw_scan,"<")
		var/tag_stop = findtext(raw_scan,">")

		// Until we run out of complete tags...
		while(tag_start&&tag_stop)
			var/pre = copytext(raw_scan,1,tag_start) // Get the stuff that comes before the tag
			var/tag = lowertext(copytext(raw_scan,tag_start+1,tag_stop)) // Get the tag so we can do intellegent replacement
			var/tagend = findtext(tag," ") // Find the first space in the tag if there is one.

			// Anything that's before the tag can just be added as is.
			formatted_scan = formatted_scan+pre

			// If we have a space after the tag (and presumably attributes) just crop that off.
			if (tagend)
				tag=copytext(tag,1,tagend)

			if (tag=="p"||tag=="/p"||tag=="br") // Check if it's I vertical space tag.
				formatted_scan=formatted_scan+"<br>" // If so, add some padding in.

			raw_scan = copytext(raw_scan,tag_stop+1) // continue on with the stuff after the tag

			// Look for the next tag in what's left
			tag_start = findtext(raw_scan,"<")
			tag_stop = findtext(raw_scan,">")

		// Anything that is left in the page. just tack it on to the end as is
		formatted_scan=formatted_scan+raw_scan

    	// If there is something in there already, pad it out.
		if (length(note)>0)
			note = note + "<br><br>"

    	// Store the scanned document to the notes
		note = "Scanned Document. Edit to restore previous notes/delete scan.<br>----------<br>" + formatted_scan + "<br>"
		// notehtml ISN'T set to allow user to get their old notes back. A better implementation would add a "scanned documents"
		// feature to the PDA, which would better convey the availability of the feature, but this will work for now.

		// Inform the user
		to_chat(user, "<span class='notice'>Paper scanned and OCRed to notekeeper.</span>") //concept of scanning paper copyright brainoblivion 2009



/obj/item/device/pda/proc/explode() //This needs tuning. //Sure did.
	if(!src.detonate) return
	var/turf/T = get_turf(src.loc)
	if(T)
		T.hotspot_expose(700,125)
		explosion(T, 0, 0, 1, rand(1,2))
	return

/obj/item/device/pda/Destroy()
	PDAs -= src
	QDEL_NULL(id)
	QDEL_NULL(pen)
	if (LAZYLEN(linked_consoles))
		for(var/A in linked_consoles)
			var/obj/machinery/requests_console/B = A
			B.alert_pdas -= src
			linked_consoles -= B
	return ..()

/obj/item/device/pda/clown/Crossed(AM as mob|obj) //Clown PDA is slippery.
	if (istype(AM, /mob/living))
		var/mob/living/M = AM

		if(M.slip("the PDA",8) && M.real_name != src.owner && istype(src.cartridge, /obj/item/weapon/cartridge/clown))
			if(src.cartridge.charges < 5)
				src.cartridge.charges++

/obj/item/device/pda/proc/available_pdas()
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if (toff)
		to_chat(usr, "Turn on your receiver in order to send messages.")
		return

	for (var/obj/item/device/pda/P in PDAs)
		if (!P.owner)
			continue
		else if(P.hidden)
			continue
		else if (P == src)
			continue
		else if (P.toff)
			continue

		var/name = P.owner
		if (name in names)
			namecounts[name]++
			name = text("[name] ([namecounts[name]])")
		else
			names.Add(name)
			namecounts[name] = 1

		plist[text("[name]")] = P
	return plist


//Some spare PDAs in a box
/obj/item/weapon/storage/box/PDAs
	name = "box of spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon_state = "pdabox"

/obj/item/weapon/storage/box/PDAs/fill()
	..()
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/weapon/cartridge/head(src)

	var/newcart = pick(	/obj/item/weapon/cartridge/engineering,
						/obj/item/weapon/cartridge/security,
						/obj/item/weapon/cartridge/medical,
						/obj/item/weapon/cartridge/signal/science,
						/obj/item/weapon/cartridge/quartermaster)
	new newcart(src)

// Pass along the pulse to atoms in contents, largely added so pAIs are vulnerable to EMP
/obj/item/device/pda/emp_act(severity)
	for(var/atom/A in src)
		A.emp_act(severity)
