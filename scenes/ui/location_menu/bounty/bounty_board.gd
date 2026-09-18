@icon("res://assets/visual/editor_ui/IconGodotNode/white/icon_area_damage.png")
class_name BountyBoard
extends Node
## cleaner than just slapping 3 bountines on the location node i guess

@export var bounties:Array[Bounty]

func refresh_bounties(location:Location)->void:
	var refreshed_bounties:Array[Bounty] = []
	for b:Bounty in bounties:
		b.location = location ## ugly do better please
		b.concurrent_bounties = refreshed_bounties;
		b.refresh()
		refreshed_bounties.append(b)
