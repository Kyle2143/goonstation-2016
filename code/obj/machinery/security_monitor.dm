//This is the base stuff. the actual interaction with the attached computer, and the physical monitor
/obj/machinery/security_monitor
	name = "Security Monitor"
	icon = 'icons/obj/sec_TV.dmi'
	icon_state = "monitor"
	anchored = 1.0
	var/obj/item/clothing/glasses/sunglasses/camera/pair = null

	var/datum/monitor_screen/screen = null

	New()
		..()
		screen = new(src)


	attack_hand(mob/user as mob)
		if (screen)
			pair()

	proc/pair()
		for (var/obj/item/clothing/glasses/sunglasses/camera/g in orange(5, src))
			// pair = g
			pair = g
			g.connected_screen = src.screen
			// g.connected_screen = full_image
			// pair.pair = src

			g.visible_message("<span style=\"color:blue\"><b>PAIREDDDD!</b></span>")

			continue



//The image displayed on the "screen". Takes input from the "camera"
/datum/monitor_screen
	var/obj/machinery/security_monitor/holder

	var/image/full_image/* = new*/
	// var/obj/item/clothing/glasses/sunglasses/camera/pair = null
	var/count = 1

	New(var/obj/machinery/security_monitor/TV)
		src.holder = TV
		// src.full_image = image(null, holder.loc)
		// src.full_image = new(holder.icon, holder.icon_state )
		src.full_image = image('icons/obj/sec_TV.dmi', "monitor")

		src.holder.UpdateOverlays(src.full_image, "screen")

		src.full_image.transform = matrix(src.full_image.transform, 0.4, 0.4, MATRIX_SCALE)

		full_image.pixel_x = 20
		full_image.pixel_y = 20

		//// src.full_image = image('icons/obj/security_monitor.dmi', loc=holder.loc, "monitor-sw", layer=EFFECTS_LAYER_BASE)
		src.full_image.appearance_flags = KEEP_TOGETHER 
		// src.full_image = matrix(src.full_image, 0.4, 0.4, MATRIX_SCALE)



	// proc/thing()
	// 	// var/obj/item/photo/P = new/obj/item/photo( get_turf(src) )
	// 	// src.full_image.scale(0.5, 0.5)

	// 	// src.full_image = photo//image(photo, "")
	// 	// src.fullIcon = photo_icon

	// 	var/oldtransform = src.full_image.transform
	// 	src.full_image.transform = matrix(0.6875, 0.625, MATRIX_SCALE)
	// 	src.full_image.pixel_y = 1
	// 	src.overlays += src.full_image
	// 	src.full_image.transform = oldtransform
	// 	src.full_image.pixel_y = 0

	// 	src.overlays += src.full_image
	// 	//boutput(world, "[bicon(P.full_image)]")
			

			

	// process()