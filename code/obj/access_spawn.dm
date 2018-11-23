/obj/access_spawn
	name = "access spawn"
	desc = "Sets access of machines on the same turf as it to its access, then destroys itself."

	New()
		..()
		spawn(1)
			src.setup()
			spawn(10)
				qdel(src)

	/*
	 * loop through valid objects in the same location and, if they have no access set, set it to this one
	 */

	proc/setup()
		for (var/obj/machinery/M in src.loc)
			if (!M.req_access)
				M.req_access = src.req_access
			else
				M.req_access += src.req_access
			//todo : autoname doors	here too. var editing is illegal!


/obj/access_spawn/security
	name = "security access spawn"
	req_access = list(access_security)

/obj/access_spawn/brig
	name = "brig access spawn"
	req_access = list(access_brig)

/obj/access_spawn/medical
	name = "medical access spawn"
	req_access = list(access_medical)

/obj/access_spawn/morgue
	name = "morgue access spawn"
	req_access = list(access_morgue)

/obj/access_spawn/tox
	name = "tox access spawn"
	req_access = list(access_tox)

/obj/access_spawn/tox_storage
	name = "tox access spawn"
	req_access = list(access_tox_storage)

/obj/access_spawn/medlab
	name = "medlab access spawn"
	req_access = list(access_medlab)

/obj/access_spawn/research_director
	name = "RD access spawn"
	req_access = list(access_research_director)

/obj/access_spawn/maint
	name = "maint access spawn"
	req_access = list(access_maint_tunnels)

/obj/access_spawn/emergency_storage
	name = "emergency storage access spawn"
	req_access = list(access_emergency_storage)

/obj/access_spawn/emergency_storage
	name = "emergency storage access spawn"
	req_access = list(access_emergency_storage)

/obj/access_spawn/ai_upload
	name = "ai upload access spawn"
	req_access = list(access_ai_upload)

/obj/access_spawn/teleporter
	name = "teleporter access spawn"
	req_access = list(access_teleporter)

/obj/access_spawn/eva
	name = "eva access spawn"
	req_access = list(access_eva)

/obj/access_spawn/heads
	name = "heads access spawn"
	req_access = list(access_heads)

/obj/access_spawn/captain
	name = "captain access spawn"
	req_access = list(access_captain)

/obj/access_spawn/medical_director
	name = "MD access spawn"
	req_access = list(access_medical_director)

/obj/access_spawn/head_of_personnel
	name = "HOP access spawn"
	req_access = list(access_head_of_personnel)

/obj/access_spawn/chapel_office
	name = "chapel office access spawn"
	req_access = list(access_chapel_office)

/obj/access_spawn/tech_storage
	name = "tech storage access spawn"
	req_access = list(access_tech_storage)

/obj/access_spawn/research
	name = "research access spawn"
	req_access = list(access_research)

/obj/access_spawn/bar
	name = "bar access spawn"
	req_access = list(access_bar)

/obj/access_spawn/janitor
	name = "janitor access spawn"
	req_access = list(access_janitor)

/obj/access_spawn/crematorium
	name = "crematorium access spawn"
	req_access = list(access_crematorium)

/obj/access_spawn/kitchen
	name = "kitchen access spawn"
	req_access = list(access_kitchen)

/obj/access_spawn/robotics
	name = "robotics access spawn"
	req_access = list(access_robotics)

/obj/access_spawn/hangar
	name = "hangar access spawn"
	req_access = list(access_hangar)

/obj/access_spawn/cargo
	name = "cargo access spawn"
	req_access = list(access_cargo)

/obj/access_spawn/chemistry
	name = "chem access spawn"
	req_access = list(access_chemistry)

/obj/access_spawn/hydro
	name = "hydro access spawn"
	req_access = list(access_hydro)

/obj/access_spawn/hos
	name = "HOS access spawn"
	req_access = list(access_maxsec)

/obj/access_spawn/sec_lockers
	name = "security weapons access spawn"
	req_access = list(access_securitylockers)

/obj/access_spawn/carry_permit
	name = "carry permit access spawn"
	req_access = list(access_carrypermit)

/obj/access_spawn/engineering
	name = "engineering access spawn"
	req_access = list(access_engineering)

/obj/access_spawn/engineering_storage
	name = "engineering storage access spawn"
	req_access = list(access_engineering_storage)

/obj/access_spawn/engineering_eva
	name = "engineering EVA access spawn"
	req_access = list(access_engineering_eva)

/obj/access_spawn/engineering_power
	name = "engineering power access spawn"
	req_access = list(access_engineering_power)

/obj/access_spawn/engineering_engine
	name = "engineering engine access spawn"
	req_access = list(access_engineering_engine)

/obj/access_spawn/engineering_power
	name = "engineering power access spawn"
	req_access = list(access_engineering_power)

/obj/access_spawn/engineering_mechanic
	name = "engineering mechanics access spawn"
	req_access = list(access_engineering_mechanic)

/obj/access_spawn/engineering_atmos
	name = "engineering atmos access spawn"
	req_access = list(access_engineering_atmos)

/obj/access_spawn/engineering_control
	name = "engineering control access spawn"
	req_access = list(access_engineering_control)

/obj/access_spawn/engineering_chief
	name = "CE access spawn"
	req_access = list(access_engineering_chief)

/obj/access_spawn/mining_shuttle
	name = "mining_shuttle access spawn"
	req_access = list(access_mining_shuttle)

/obj/access_spawn/mining
	name = "mining EVA access spawn"
	req_access = list(access_mining)

/obj/access_spawn/mining_outpost
	name = "mining_outpost access spawn"
	req_access = list(access_mining_outpost)

/obj/access_spawn/syndie_shuttle
	name = "syndie_shuttle access spawn"
	req_access = list(access_syndicate_shuttle)