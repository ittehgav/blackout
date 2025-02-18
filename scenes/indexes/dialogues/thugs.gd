extends Dialogue

func _ready()->void:
	lines = [
		["S", "Party of Thugs"],
		["T", "Hey you, give me everything you have!"],
		["P",
			[
				"From my cold, dead hands! " + engage_outcome_text,
				"Of course, just don't hurt me! " + yield_outcome_text,
				"Maybe we can talk this out?"
			],
			[
				#CHANGE THIS SO ALL PROMPTS LEAD TO INDIVIDUAL DIALOGUE 
				#INSTANCES UNLESS THERE'S NO MORE DIALOGUE AFTER THE CHOIECS 
				
				
				MapEvents.battle_speaking_party,
				MapEvents.yield_resources,
				Entities.dialogue_player.fork.bind(talk_out)
			]
		]
		
	]

var talk_out = [
	["T", "Oh yea? And what do you have to say?"],
	["P",
	[
		"Never mind, i'll just kill you. [color=]",
		"Look, what if you just take "
	]]
]
