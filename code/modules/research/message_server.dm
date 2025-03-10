/datum/data_pda_msg
	var/recipient = "Unspecified" //name of the person
	var/sender = "Unspecified" //name of the sender
	var/message = "Blank" //transferred message

/datum/data_pda_msg/New(param_rec = "",param_sender = "",param_message = "")

	if(param_rec)
		recipient = param_rec
	if(param_sender)
		sender = param_sender
	if(param_message)
		message = param_message

/datum/data_rc_msg
	var/rec_dpt = "Неопределенные" //name of the person
	var/send_dpt = "Неопределенные" //name of the sender
	var/message = "Пусто" //transferred message
	var/stamp = "Без штампа"
	var/id_auth = "Неаутентифицированный"
	var/priority = "Обычный"
	var/from = "Неопределенный"

/datum/data_rc_msg/New(param_rec = "",param_sender = "",param_message = "",param_stamp = "",param_id_auth = "", param_priority = 1, param_from="")
	if(param_rec)
		rec_dpt = param_rec
	if(param_sender)
		send_dpt = param_sender
	if(param_message)
		message = param_message
	if(param_stamp)
		stamp = param_stamp
	if(param_id_auth)
		id_auth = param_id_auth
	if(param_priority)
		switch(param_priority)
			if(1)
				priority = "Обычный"
			if(2)
				priority = "Высокий"
			if(3)
				priority = "Экстренный"
			else
				priority = "Неопределенный"
	if(param_from)
		from = param_from

/obj/machinery/message_server
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	name = "Messaging Server"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100

	resistance_flags = FULL_INDESTRUCTIBLE

	var/list/datum/data_pda_msg/pda_msgs = list()
	var/list/datum/data_rc_msg/rc_msgs = list()
	var/active = TRUE
	var/decryptkey = "password"

/obj/machinery/message_server/atom_init()
	message_servers += src
	decryptkey = GenerateKey()
	send_pda_message("System Administrator", "system", "This is an automated message. The messaging system is functioning correctly.")
	. = ..()

/obj/machinery/message_server/Destroy()
	message_servers -= src
	return ..()

/obj/machinery/message_server/proc/GenerateKey()
	//Feel free to move to Helpers.
	var/newKey
	newKey += pick("the", "if", "of", "as", "in", "a", "you", "from", "to", "an", "too", "little", "snow", "dead", "drunk", "rosebud", "duck", "al", "le")
	newKey += pick("diamond", "beer", "mushroom", "assistant", "clown", "captain", "twinkie", "security", "nuke", "small", "big", "escape", "yellow", "gloves", "monkey", "engine", "nuclear", "ai")
	newKey += pick("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	return newKey

/obj/machinery/message_server/process()
	//if(decryptkey == "password")
	//	decryptkey = generateKey()
	if(active && (stat & (BROKEN|NOPOWER)))
		active = 0
		return
	update_icon()
	return

/obj/machinery/message_server/proc/send_pda_message(recipient = "",sender = "",message = "")
	pda_msgs += new/datum/data_pda_msg(recipient,sender,message)

/obj/machinery/message_server/proc/send_rc_message(recipient = "", sender = "", message = "", stamp = "", id_auth = "", priority = 1, from="")
	rc_msgs += new/datum/data_rc_msg(recipient,sender,message,stamp,id_auth,priority,from)
	var/list/auth_data = list()
	if(id_auth)
		auth_data.Add(id_auth)
	if(stamp)
		auth_data.Add(stamp)
	var/auth = jointext(auth_data, "<BR>")
	for(var/obj/machinery/requests_console/Console in requests_console_list)
		if(Console.department == recipient)
			var/from_desc = sender
			if(length(from))
				from_desc = from
			var/content = "<A href='byond://?src=\ref[Console];write=[url_encode(sender)]'><B>[from_desc]</B></A>:<BR><DIV class='Section'>[message]</DIV>[auth]"
			switch(priority)
				if(2)		//High priority
					if(Console.newmessagepriority < 2)
						Console.newmessagepriority = 2
						Console.icon_state = "req_comp2"
					if(!Console.silent)
						playsound(Console, 'sound/machines/req_alarm.ogg', VOL_EFFECTS_MASTER)
						Console.audible_message("[bicon(Console)] **Консоль Запроса пищит: 'ПРИОРИТЕТНОЕ сообщение от [from_desc]'")
					Console.messages += "[worldtime2text()] <B><FONT color='red'>Приоритетное сообщение от </FONT></B>[content]"
				else		// Normal priority
					if(Console.newmessagepriority < 1)
						Console.newmessagepriority = 1
						Console.icon_state = "req_comp1"
					if(!Console.silent)
						playsound(Console, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
						Console.audible_message("[bicon(Console)] **Консоль Запроса пищит: 'Сообщение от [from_desc]'")
					Console.messages += "[worldtime2text()] <B>Получено от </B>[content]"
			Console.set_light(2)

/obj/machinery/message_server/attack_hand(user)
	. = ..()
	if(.)
		return

//	user << "<span class='notice'>There seem to be some parts missing from this server. They should arrive on the station in a few days, give or take a few CentCom delays.</span>"
	to_chat(user, "You toggle PDA message passing from [active ? "On" : "Off"] to [active ? "Off" : "On"]")
	active = !active
	update_icon()

/obj/machinery/message_server/update_icon()
	if((stat & (BROKEN|NOPOWER)))
		icon_state = "server-nopower"
	else if (!active)
		icon_state = "server-off"
	else
		icon_state = "server-on"

	return


/datum/feedback_variable
	var/variable
	var/value
	var/details

/datum/feedback_variable/New(param_variable,param_value = 0)
	variable = param_variable
	value = param_value

/datum/feedback_variable/proc/inc(num = 1)
	if(isnum(value))
		value += num
	else
		value = text2num(value)
		if(isnum(value))
			value += num
		else
			value = num

/datum/feedback_variable/proc/dec(num = 1)
	if(isnum(value))
		value -= num
	else
		value = text2num(value)
		if(isnum(value))
			value -= num
		else
			value = -num

/datum/feedback_variable/proc/set_value(num)
	if(isnum(num))
		value = num

/datum/feedback_variable/proc/get_value()
	return value

/datum/feedback_variable/proc/get_variable()
	return variable

/datum/feedback_variable/proc/set_details(text)
	if(istext(text))
		details = text

/datum/feedback_variable/proc/add_details(text)
	if(istext(text))
		if(!details)
			details = text
		else
			details += " [text]"

/datum/feedback_variable/proc/get_details()
	return details

/datum/feedback_variable/proc/get_parsed()
	return list(variable,value,details)

var/global/obj/machinery/blackbox_recorder/blackbox

/obj/machinery/blackbox_recorder
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox"
	name = "Blackbox Recorder"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100

	resistance_flags = FULL_INDESTRUCTIBLE

	var/list/messages = list()		//Stores messages of non-standard frequencies
	var/list/messages_admin = list()

	var/list/msg_common = list()
	var/list/msg_science = list()
	var/list/msg_command = list()
	var/list/msg_medical = list()
	var/list/msg_engineering = list()
	var/list/msg_security = list()
	var/list/msg_deathsquad = list()
	var/list/msg_syndicate = list()
	var/list/msg_heist = list()
	var/list/msg_mining = list()
	var/list/msg_cargo = list()

	var/list/datum/feedback_variable/feedback = new()

	//Only one can exsist in the world!
/obj/machinery/blackbox_recorder/atom_init()
	. = ..()
	if(blackbox)
		return INITIALIZE_HINT_QDEL
	blackbox = src

/obj/machinery/blackbox_recorder/Destroy()
	if(blackbox != src)
		return ..()
	var/centcom_z = SSmapping.level_by_trait(ZTRAIT_CENTCOM)
	var/turf/T = locate(1,1, centcom_z)
	if(T)
		blackbox = null
		var/obj/machinery/blackbox_recorder/BR = new/obj/machinery/blackbox_recorder(T)
		BR.msg_common = msg_common
		BR.msg_science = msg_science
		BR.msg_command = msg_command
		BR.msg_medical = msg_medical
		BR.msg_engineering = msg_engineering
		BR.msg_security = msg_security
		BR.msg_deathsquad = msg_deathsquad
		BR.msg_syndicate = msg_syndicate
		BR.msg_heist = msg_heist
		BR.msg_mining = msg_mining
		BR.msg_cargo = msg_cargo
		BR.feedback = feedback
		BR.messages = messages
		BR.messages_admin = messages_admin
		if(blackbox != BR)
			blackbox = BR
	return ..()

/obj/machinery/blackbox_recorder/proc/find_feedback_datum(variable)
	for(var/datum/feedback_variable/FV in feedback)
		if(FV.get_variable() == variable)
			return FV
	var/datum/feedback_variable/FV = new(variable)
	feedback += FV
	return FV

/obj/machinery/blackbox_recorder/proc/get_round_feedback()
	return feedback

/obj/machinery/blackbox_recorder/proc/round_end_data_gathering()

	var/pda_msg_amt = 0
	var/rc_msg_amt = 0

	for(var/obj/machinery/message_server/MS in message_servers)
		if(MS.pda_msgs.len > pda_msg_amt)
			pda_msg_amt = MS.pda_msgs.len
		if(MS.rc_msgs.len > rc_msg_amt)
			rc_msg_amt = MS.rc_msgs.len

	feedback_set_details("radio_usage","")

	feedback_add_details("radio_usage","COM-[msg_common.len]")
	feedback_add_details("radio_usage","SCI-[msg_science.len]")
	feedback_add_details("radio_usage","HEA-[msg_command.len]")
	feedback_add_details("radio_usage","MED-[msg_medical.len]")
	feedback_add_details("radio_usage","ENG-[msg_engineering.len]")
	feedback_add_details("radio_usage","SEC-[msg_security.len]")
	feedback_add_details("radio_usage","DTH-[msg_deathsquad.len]")
	feedback_add_details("radio_usage","SYN-[msg_syndicate.len]")
	feedback_add_details("radio_usage","VOX-[msg_heist.len]")
	feedback_add_details("radio_usage","MIN-[msg_mining.len]")
	feedback_add_details("radio_usage","CAR-[msg_cargo.len]")
	feedback_add_details("radio_usage","OTH-[messages.len]")
	feedback_add_details("radio_usage","PDA-[pda_msg_amt]")
	feedback_add_details("radio_usage","RC-[rc_msg_amt]")


	feedback_set_details("round_end","[time2text(world.realtime)]") //This one MUST be the last one that gets set.


//This proc is only to be called at round end.
/obj/machinery/blackbox_recorder/proc/save_all_data_to_sql()
	if(!feedback) return

	round_end_data_gathering() //round_end time logging and some other data processing

	if(!establish_db_connection("erro_feedback"))
		return

	for(var/datum/feedback_variable/FV in feedback)
		var/sql = "INSERT INTO erro_feedback VALUES (null, Now(), [global.round_id], \"[sanitize_sql(FV.get_variable())]\", [sanitize_sql(FV.get_value())], \"[sanitize_sql(FV.get_details())]\")"
		var/DBQuery/query_insert = dbcon.NewQuery(sql)
		query_insert.Execute()

/proc/feedback_set(variable,value)
	if(!blackbox) return

	variable = sanitize_sql(variable)

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV) return

	FV.set_value(value)

/proc/feedback_inc(variable,value)
	if(!blackbox) return

	variable = sanitize_sql(variable)

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV) return

	FV.inc(value)

/proc/feedback_dec(variable,value)
	if(!blackbox) return

	variable = sanitize_sql(variable)

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV) return

	FV.dec(value)

/proc/feedback_set_details(variable,details)
	if(!blackbox) return

	variable = sanitize_sql(variable)
	details = sanitize_sql(details)

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV) return

	FV.set_details(details)

/proc/feedback_add_details(variable,details)
	if(!blackbox) return

	variable = sanitize_sql(variable)
	details = sanitize_sql(details)

	var/datum/feedback_variable/FV = blackbox.find_feedback_datum(variable)

	if(!FV) return

	FV.add_details(details)
