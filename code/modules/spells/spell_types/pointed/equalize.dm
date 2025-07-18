#define EQUALIZED_GLOW "equalizer glow"

/datum/action/cooldown/spell/equalize
	name = "Equalize"
	desc = "Weaken someone to the difference between me and them."
	button_icon_state = "equalize"
	sound = 'sound/magic/churn.ogg'

	spell_type = SPELL_MIRACLE
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	associated_skill = /datum/skill/magic/holy
	invocation_type = INVOCATION_NONE

	cast_range = 4
	charge_required = TRUE
	charge_time = 4 SECONDS
	charge_slowdown = 1.3
	cooldown_time = 2 MINUTES
	spell_cost = 20
	attunements = list(
		/datum/attunement/electric = 0.3,
		/datum/attunement/life = 0.3,
	)
	var/totalstatshift = 0
	var/totalstatchange = 0
	var/outline_colour = "#FFD700"

/datum/action/cooldown/spell/equalize/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return ishuman(cast_on)

/datum/action/cooldown/spell/equalize/cast(mob/living/carbon/human/cast_on)
	. = ..()
	var/mob/living/carbon/C = owner
	totalstatchange += (cast_on.STASPD - C.STASPD)
	totalstatchange += ((cast_on.STASTR - C.STASTR)*2) // We're gonna weigh strength as double, being the strongest stat.
	totalstatchange += (cast_on.STAEND - C.STAEND)
	totalstatchange += (cast_on.STALUC - C.STALUC)
	totalstatchange += (cast_on.STAINT - C.STAINT)
	totalstatchange += (cast_on.STACON - C.STACON)
	totalstatchange += (cast_on.STAPER - C.STAPER)
	totalstatchange -=3 // We need Atleast a 4 point disadvantage before we start siphoning
	totalstatshift = CLAMP((totalstatchange), 0, 2) // We DO NOT WANT Matthian Clerics stealing 30 stats from Ascendants, Cap the statshift by 2
	if(totalstatshift <1)
		to_chat(owner, "<font color='yellow'>[cast_on] fire burns dimly, there is nothing worth equalizing.</font>")
		return
	else
		// there is SURELY a better way to do this
		playsound(owner, 'sound/magic/swap.ogg', 100, TRUE)
		owner.add_filter(EQUALIZED_GLOW, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 200, "size" = 1))
		cast_on.add_filter(EQUALIZED_GLOW, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 200, "size" = 1))
		to_chat(cast_on, span_danger("I feel my flame being siphoned!"))
		to_chat(owner, "<font color='yellow'>The Equalizing link is made, I am siphoning flame!</font>")
		cast_on.STASPD -= totalstatshift // LALA LA NOTHING TO SEE DOWN HERE OFFICER
		C.STASPD += totalstatshift
		cast_on.STASTR -= totalstatshift
		C.STASTR += totalstatshift
		cast_on.STAEND -=totalstatshift
		C.STAEND += totalstatshift
		cast_on.STALUC -= totalstatshift
		C.STALUC += totalstatshift
		cast_on.STAINT -= totalstatshift
		C.STAINT += totalstatshift
		cast_on.STACON -= totalstatshift
		C.STACON += totalstatshift
		cast_on.STAPER -= totalstatshift
		C.STAPER += totalstatshift
		addtimer(CALLBACK(src, PROC_REF(returnstatstarget), cast_on), 1 MINUTES) // 2 timers incase only one guy gets deleted or smthing
		addtimer(CALLBACK(src, PROC_REF(returnstatsuser), owner), 1 MINUTES)
		return

/datum/action/cooldown/spell/equalize/proc/returnstatstarget(mob/living/target)
	target.remove_filter(EQUALIZED_GLOW)
	target.STASPD += totalstatshift
	target.STASTR += totalstatshift
	target.STAEND += totalstatshift
	target.STALUC += totalstatshift
	target.STAINT += totalstatshift
	target.STACON += totalstatshift
	target.STAPER += totalstatshift
	to_chat(target, span_danger("I feel my strength returned to me!"))

/datum/action/cooldown/spell/equalize/proc/returnstatsuser(mob/living/user)
	user.remove_filter(EQUALIZED_GLOW)
	user.STASTR -= totalstatshift
	user.STASPD -= totalstatshift
	user.STAEND -= totalstatshift
	user.STALUC -= totalstatshift
	user.STAINT -= totalstatshift
	user.STACON -= totalstatshift
	user.STAPER -= totalstatshift
	to_chat(user, "<font color='yellow'>My link wears off, their stolen fire returns to them</font>")

#undef EQUALIZED_GLOW
