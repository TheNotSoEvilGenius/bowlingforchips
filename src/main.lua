
SMODS.Atlas{key = "spockholm", path = "JOKERS.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS"}

local old_ease_dollars = ease_dollars
function ease_dollars(mod,instant)
	local ret = old_ease_dollars(mod,instant)
	G.E_MANAGER:add_event(Event({
		trigger = 'immediate',
		func = function()
			SMODS.calculate_context({money_changed = true})
			return true
		end
	}))
	return ret
end

SMODS.Joker{ --OtterBox
    name = "Otter Box",
    key = "otterbox",
    config = {
        extra = {
			scored_chance = {
				[1] = 4,
				[2] = 4,
				[3] = 4,
				[4] = 4,
				[5] = 4
			}
		}
    },
    loc_txt = {
        ['name'] = 'Otter Box',
        ['text'] = {
            [1] = '{C:attention}Glass Cards{} won\'t Break'
        }
    },
    pos = {
        x = 4,
        y = 0
    },
	enhancement_gate = 'm_glass',
    cost = 4,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'spockholm',

    loc_vars = function(self, info_queue, card)
        return {}
    end,

    calculate = function(self, card, context)
		if context.before and not context.blueprint then
			-- sendDebugMessage("Otter Box Triggered", "TMLogger")
			for i=1, #context.scoring_hand do
				if context.scoring_hand[i].ability.name == 'Glass Card' and not context.scoring_hand[i].debuff then
					card.ability.extra.scored_chance[i] = context.scoring_hand[i].ability.extra
					context.scoring_hand[i].ability.extra = math.huge
				end
			end
        end
		if context.after and not context.blueprint then
			for i=1, #context.scoring_hand do
				if context.scoring_hand[i].ability.name == 'Glass Card' and not context.scoring_hand[i].debuff then
					context.scoring_hand[i].ability.extra = card.ability.extra.scored_chance[i]
				end
			end
        end
    end
}
SMODS.Joker{ --Insurance
    name = "Insurance",
    key = "insurance",
    config = {
        extra = {
			odds = 3,
			money = 5,
			max_money = 15
		}
    },
    loc_txt = {
        ['name'] = 'Insurance',
        ['text'] = {
            [1] = 'Scored {C:attention}Aces{} have a {C:green}#2# in #1#{}',
            [2] = 'chance to double money',
			[3] = 'Reduce money by {C:money}$#3#{} on failure',
			[4] = '{C:inactive}(Max Increase of{} {C:money}$#4#{}{C:inactive})'
        }
    }, 
    pos = {
        x = 3,
        y = 0
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'spockholm',

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.odds, G.GAME.probabilities.normal, card.ability.extra.money, card.ability.extra.max_money}}
    end,

    calculate = function(self, card, context)
		-- sendDebugMessage("Insurance Triggered", "TMLogger")
		-- SMODS.recalc_debuff(card) Incase I revsit previous idea to debuff instead
		if context.individual and context.cardarea == G.play and context.other_card:get_id() == 14 then
			if pseudorandom('insurance') < G.GAME.probabilities.normal / card.ability.extra.odds then
				ease_dollars(math.max(0,math.min(G.GAME.dollars, card.ability.extra.max_money)))
			else
				ease_dollars(-card.ability.extra.money)
			end
		end
    end
}
SMODS.Joker{ --Lucky Ladies
    name = "Lucky Ladies",
    key = "lladies",
    config = {
        extra = {
			odds = 2,
			Xmult = 2
		}
    },
    loc_txt = {
        ['name'] = 'Lucky Ladies',
        ['text'] = {
            [1] = '{C:green}#2# in #1#{} chance for played',
            [2] = '{C:attention}Queen of Hearts{} to',
			[3] = 'give {X:mult,C:white}X#3#{} when scored'
        }
    }, 
    pos = {
        x = 3,
        y = 1
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'spockholm',

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.odds, G.GAME.probabilities.normal, card.ability.extra.Xmult}}
    end,

    calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and context.other_card:get_id() == 12 and context.other_card:is_suit("Hearts") then
			if pseudorandom('lucky_lady') < G.GAME.probabilities.normal / card.ability.extra.odds then
				return{
					message = localize{type='variable',key='a_xmult',vars={card.ability.extra.Xmult}},
					Xmult_mod = card.ability.extra.Xmult
				}
			end
		end
    end
}
SMODS.Joker{ --Host
    name = "The Host",
    key = "host",
    config = {
        extra = {
			dollar_thres = 10,
			thres_increase = 2,
			last_dollars = 0,
			current_spending = 0,
			consumable_types = {
                [1] = 'Spectral',
                [2] = 'Planet',
				[3] = 'Planet',
                [4] = 'Tarot',
				[5] = 'Tarot'
            }
		}
    },
    loc_txt = {
        ['name'] = 'The Host',
        ['text'] = {
            [1] = 'Create a random {C:attention}consumable',
            [2] = 'after spending {C:money}$#1#{}',
			[3] = 'Increase by {C:money}$#2#{} on trigger',
			[4] = '{C:inactive}(Currently{} {C:money}$#3#{}{C:inactive} of{} {C:money}$#1#{}{C:inactive})'
        }
    }, 
    pos = {
        x = 1,
        y = 1
    },
    cost = 8,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'spockholm',

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.dollar_thres,card.ability.extra.thres_increase,card.ability.extra.current_spending}}
    end,
	
	add_to_deck = function(self, card, from_debuff)
		card.ability.extra.last_dollars = G.GAME.dollars
	end,
	
    calculate = function(self, card, context)
		if context.money_changed and not context.blueprint then
			if G.GAME.dollars < card.ability.extra.last_dollars then
				card.ability.extra.current_spending = card.ability.extra.current_spending + (card.ability.extra.last_dollars-G.GAME.dollars)
				if card.ability.extra.current_spending >= card.ability.extra.dollar_thres then
					card.ability.extra.current_spending = 0
					card.ability.extra.dollar_thres = card.ability.extra.dollar_thres + card.ability.extra.thres_increase
					--Hit spending limit, generate consumable
					if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
						G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
						G.E_MANAGER:add_event(Event({
							func = function() 
								local card = create_card(pseudorandom_element(card.ability.extra.consumable_types, pseudoseed('thehost')),G.consumeables, nil, nil, nil, nil, nil, 'host')
								card:add_to_deck()
								G.consumeables:emplace(card)
								G.GAME.consumeable_buffer = 0
								return true
							end
						}))
					end
				end
			end
			card.ability.extra.last_dollars = G.GAME.dollars
		end
    end
}
SMODS.Joker{ --The Count
    name = "The Count",
    key = "ccounter",
    config = {
        extra = {
			chips = 0,
			chip_gain = 1
		}
    },
    loc_txt = {
        ['name'] = 'The Count',
        ['text'] = {
			[1] = "This Joker adds {C:chips}chips{} equal to",
			[2] = "{C:green}Running Count{} x {C:attention}10{}",
            [3] = "{C:green}+#1#{} count for each played {C:attention}2-6",
            [4] = "{C:green}-#1#{} count for each played {C:attention}10-Ace",
            [5] = "{C:inactive}(Running Count: {C:green}#3##2#{C:inactive})",
			[6] = "{C:inactive}(Current Chips: {C:chips}#3##4#{C:inactive})"
        }
    }, 
    pos = {
        x = 4,
        y = 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'spockholm',

    loc_vars = function(self, info_queue, card)
		local modifier = "+"
		if card.ability.extra.chips < 0 then
			modifier = ""
		end
        return {vars = {card.ability.extra.chip_gain, card.ability.extra.chips,modifier,card.ability.extra.chips*10}}
    end,

    calculate = function(self, card, context)
		if context.before then
			-- sendDebugMessage("Counter Triggered", "TMLogger")
			-- sendDebugMessage("Played Cards: "..#G.play.cards, "TMLogger")
			local chips_gained = 0
			for i=1, #G.play.cards do
				--sendDebugMessage(G.play.cards[i].base.value, "TMLogger")
				if G.play.cards[i]:get_id() < 7 then
					card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
					chips_gained = chips_gained + card.ability.extra.chip_gain
					card_eval_status_text(card, 'jokers', nil, nil, nil, {message = G.play.cards[i].base.value.." -> +"..tostring(card.ability.extra.chip_gain), colour = G.C.FILTER})
				elseif 	G.play.cards[i]:get_id() >= 7 and G.play.cards[i]:get_id() < 10 then
					card_eval_status_text(card, 'jokers', nil, nil, nil, {message = G.play.cards[i].base.value.." -> No Change", colour = G.C.FILTER})
				elseif 	G.play.cards[i]:get_id() > 9 then
					card.ability.extra.chips = card.ability.extra.chips - card.ability.extra.chip_gain
					chips_gained = chips_gained - card.ability.extra.chip_gain
					card_eval_status_text(card, 'jokers', nil, nil, nil, {message = G.play.cards[i].base.value.." -> -"..tostring(card.ability.extra.chip_gain), colour = G.C.FILTER})
				end
			end
		end
		if context.cardarea == G.jokers and context.joker_main then
            return{
				message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
                chip_mod = card.ability.extra.chips*10, 
                colour = G.C.CHIPS
            }
		end
    end
}
SMODS.Joker{ --Advantage Play
    name = "Advantage Play",
    key = "AP",
    config = {
        extra = {
			cur_mult = 0,
			mult_gain = 0.1
		}
    },
    loc_txt = {
        ['name'] = 'Advantage Play',
        ['text'] = {
			[1] = "This Joker gains {X:mult,C:white}X#2#{}",
			[2] = "for each {C:attention}10-Ace{}",
			[3] = "remaining in the deck",
			[4] = "{C:inactive}(Current: {X:mult,C:white}X#1#{C:inactive})"
        }
    }, 
    pos = {
        x = 4,
        y = 2
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'spockholm',

    loc_vars = function(self, info_queue, card)
		local current_mult = 0
		local cards_in_deck = 0
		if G.deck ~= nil then
			for i=1, #G.deck.cards do
				if G.deck.cards[i]:get_id() >= 10 then
					cards_in_deck = cards_in_deck + 1
				end
			end
		end	
		current_mult = cards_in_deck*card.ability.extra.mult_gain
        return {vars = {current_mult, card.ability.extra.mult_gain}}
    end,

    calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.joker_main then
			local cards_in_deck = 0
			for i=1, #G.deck.cards do
				if G.deck.cards[i]:get_id() >= 10 then
					cards_in_deck = cards_in_deck + 1
				end
			end
			return{
				xmult = cards_in_deck*card.ability.extra.mult_gain
            }
		end
    end
}
SMODS.Joker{ --Strike
    name = "Strike",
    key = "strike",
    config = {
        extra = {
			Xmult = 4,
			cards_remaining = 10,
			active_hands = 2,
			hands_played = 0,
			cards_to_check = {
				[2] = true,
				[3] = true,
				[4] = true,
				[5] = true,
				[6] = true,
				[7] = true,
				[8] = true,
				[9] = true,
				[10] = true,
				[14] = true
			},
			cards_played = {
				[2] = false,
				[3] = false,
				[4] = false,
				[5] = false,
				[6] = false,
				[7] = false,
				[8] = false,
				[9] = false,
				[10] = false,
				[14] = false
			},
			rank_colours = {
				[1] = G.C.FILTER,
				[2] = G.C.FILTER,
				[3] = G.C.FILTER,
				[4] = G.C.FILTER,
				[5] = G.C.FILTER,
				[6] = G.C.FILTER,
				[7] = G.C.FILTER,
				[8] = G.C.FILTER,
				[9] = G.C.FILTER,
				[10] = G.C.FILTER
			}
		}
    },
    loc_txt = {
        ['name'] = 'Strike!',
        ['text'] = {
			[1] = "After one of each of the",
			[2] = "following cards are scored:",
			[3] = "{V:7}7{} {V:8}8{} {V:9}9{} {V:10}10{}",
			[4] = "{V:4}4{} {V:5}5{} {V:6}6{}",
			[5] = "{V:2}2{} {V:3}3{}",
			[6] = "{V:1}A{}",
			[7] = "{X:mult,C:white}X#1#{} for the next {C:blue}#3#{} hands",
			[8] = "{C:inactive}(#2#){}"
        }
    }, 
    pos = {
        x = 0,
        y = 1
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'spockholm',

    loc_vars = function(self, info_queue, card)
		local remaining_text = tostring(card.ability.extra.cards_remaining).." of 10 cards remaining"
		--sendDebugMessage(#card.ability.extra.cards_played, "TMLogger")
		
		if card.ability.extra.cards_remaining == 0 then
			remaining_text = "Active! "..tostring(card.ability.extra.active_hands-card.ability.extra.hands_played).." hand(s) remaining"
		end
		
        return {vars = {card.ability.extra.Xmult, remaining_text, card.ability.extra.active_hands, colours = card.ability.extra.rank_colours}}
    end,

    calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.joker_main then
			if card.ability.extra.cards_remaining == 0 then
				return{
					xmult = card.ability.extra.Xmult
				}
			else
				for i=1, #context.scoring_hand do
					--sendDebugMessage(context.scoring_hand[i]:get_id(), "TMLogger")
					if card.ability.extra.cards_to_check[context.scoring_hand[i]:get_id()] then
						card.ability.extra.cards_played[context.scoring_hand[i]:get_id()] = true
					end
				end
			end
		end
		if context.after then 
			if card.ability.extra.cards_remaining == 0 then
				--Card is active and was active this hand
				card.ability.extra.hands_played = card.ability.extra.hands_played + 1
				if card.ability.extra.hands_played >= card.ability.extra.active_hands then
					--Reset to "inactive"
					card.ability.extra.hands_played = 0
					card.ability.extra.cards_remaining = 10
					for k, v in pairs(card.ability.extra.cards_played) do
						card.ability.extra.cards_played[k] = false
						card.ability.extra.rank_colours[k] = G.C.FILTER
					end
					card.ability.extra.rank_colours[1] = G.C.FILTER
				end
			else
				card.ability.extra.cards_remaining = 10 
				for k, v in pairs(card.ability.extra.cards_played) do
					if card.ability.extra.cards_played[k]  then
						card.ability.extra.cards_remaining = card.ability.extra.cards_remaining - 1
						card.ability.extra.rank_colours[k] = G.C.GREEN
						if k == 14 then
							card.ability.extra.rank_colours[1] = G.C.GREEN
						end
					end
				end
				if card.ability.extra.cards_remaining == 0 then 
					local eval = function() return card.ability.extra.cards_remaining == 0 end
					juice_card_until(card, eval, true)
				end
			end
		end
    end
}
SMODS.Joker{ --Rerack
    name = "Rerack",
    key = "rerack",
    config = {
        extra = {
		}
    },
    loc_txt = {
        ['name'] = 'Re-Rack',
        ['text'] = {
			[1] = "Sell this card to",
			[2] = "reroll the current",
			[3] = "{C:attention}Boss Blind{}"
        }
    }, 
    pos = {
        x = 1,
        y = 3
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'spockholm',

    loc_vars = function(self, info_queue, card)
        return {}
    end,

    calculate = function(self, card, context)
		if context.selling_self then
			G.from_boss_tag = true --Think this is fine, makes it not cost money
			G.FUNCS.reroll_boss()
		end
    end
}
SMODS.Joker{ --Found a Line
    name = "Found a Line",
    key = "faline",
    config = {
        extra = {
			to_do_poker_hand = nil,
			multiplier = 5,
			hand_chips = 0,
			hand_mult = 0
		}
    },
    loc_txt = {
        ['name'] = 'Found a Line',
        ['text'] = {
			[1] = "{C:chips}+#1#{} Chips and {C:mult}+#3#{} Mult",
			[2] = "if played {C:attention}poker hand{}",
			[3] = "is a {C:attention}#2#{}",
			[4] = "{C:inactive}(Hand changes at end of round){}"
        }
    }, 
    pos = {
        x = 0,
        y = 3
    },
    cost = 7,
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'spockholm',

    loc_vars = function(self, info_queue, card)
		local _poker_hands = {}
		if card.ability.extra.to_do_poker_hand == nil then
			for k, v in pairs(G.GAME.hands) do
				if v.visible and k ~= card.ability.extra.to_do_poker_hand then _poker_hands[#_poker_hands+1] = k end
			end
			card.ability.extra.to_do_poker_hand = pseudorandom_element(_poker_hands, pseudoseed('faline'))
			card.ability.extra.hand_chips = G.GAME.hands[card.ability.extra.to_do_poker_hand].s_chips
			card.ability.extra.hand_mult = G.GAME.hands[card.ability.extra.to_do_poker_hand].s_mult
		end
		--sendDebugMessage(inspect(G.GAME.hands[card.ability.extra.to_do_poker_hand]), "TMLogger")
        return {vars = {card.ability.extra.hand_chips*card.ability.extra.multiplier,card.ability.extra.to_do_poker_hand,card.ability.extra.hand_mult*card.ability.extra.multiplier}}
    end,

    calculate = function(self, card, context)
		if context.before and card.ability.extra.to_do_poker_hand == nil and not context.blueprint then
			--I dont think this ever will happen, but just in case
			local _poker_hands = {}
			for k, v in pairs(G.GAME.hands) do
				if v.visible and k ~= card.ability.extra.to_do_poker_hand then _poker_hands[#_poker_hands+1] = k end
			end
			card.ability.extra.to_do_poker_hand = pseudorandom_element(_poker_hands, pseudoseed('faline'))
			card.ability.extra.hand_chips = G.GAME.hands[card.ability.extra.to_do_poker_hand].s_chips
			card.ability.extra.hand_mult = G.GAME.hands[card.ability.extra.to_do_poker_hand].s_mult
		end
		if context.cardarea == G.jokers and context.joker_main then
			if context.scoring_name  == card.ability.extra.to_do_poker_hand then
				return{
					mult = card.ability.extra.hand_mult*card.ability.extra.multiplier,
					chips = card.ability.extra.hand_chips*card.ability.extra.multiplier
				}
			end
		end
		if context.end_of_round and not context.blueprint then
			local _poker_hands = {}
			for k, v in pairs(G.GAME.hands) do
				if v.visible and k ~= card.ability.extra.to_do_poker_hand then _poker_hands[#_poker_hands+1] = k end
			end
			card.ability.extra.to_do_poker_hand = pseudorandom_element(_poker_hands, pseudoseed('faline'))
			card.ability.extra.hand_chips = G.GAME.hands[card.ability.extra.to_do_poker_hand].s_chips
			card.ability.extra.hand_mult = G.GAME.hands[card.ability.extra.to_do_poker_hand].s_mult
		end
    end
}
SMODS.Joker{ --Deadwood
    name = "Deadwood",
    key = "deadwood",
    config = {
        extra = {
		}
    },
    loc_txt = {
        ['name'] = 'Deadwood',
        ['text'] = {
			[1] = "If the played hand has {C:attention}5{} cards",
			[2] = "and contains {C:attention}1{} unscored card",
			[3] = "destroy the unscored card"
        }
    }, 
    pos = {
        x = 2,
        y = 1
    },
    cost = 8,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'spockholm',

    loc_vars = function(self, info_queue, card)
        return {}
    end,

    calculate = function(self, card, context)
		if context.destroy_card and context.cardarea == "unscored" then
			if #G.play.cards-#context.scoring_hand == 1 and #G.play.cards == 5 then
				SMODS.destroy_cards(context.destroy_card)
			end
		end
    end
}
SMODS.Joker{ --Turkey
    name = "Turkey",
    key = "turkey",
    config = {
        extra = {
			chips = 30,
			xmult = 3
		}
    },
    loc_txt = {
        ['name'] = 'Turkey',
        ['text'] = {
			[1] = "If the played hand is a",
			[2] = "{C:attention}Three of a Kind{} of {C:attention}10's{}",
			[3] = "each {C:attention}10{} adds {C:chips}+#1#{} and {X:mult,C:white}X#2#{}"
        }
    }, 
    pos = {
        x = 2,
        y = 2
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'spockholm',

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.chips,card.ability.extra.xmult}}
    end,

    calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and context.other_card:get_id() == 10 and context.scoring_name == "Three of a Kind" then
			return{
					x_mult = card.ability.extra.xmult,
					chips = card.ability.extra.chips
			}
		end
    end
}
SMODS.Joker{ --Spare Me
    name = "Spare Me",
    key = "spareme",
    config = {
        extra = {
			active = false,
			retrigger_val = nil,
			reps = 1,
			retrigged = false
		}
    },
    loc_txt = {
        ['name'] = 'Spare Me',
        ['text'] = {
			[1] = "If {C:attention}first hand{} of round",
			[2] = "has only {C:attention}1{} card,", 
			[3] = "retrigger cards of",
			[4] = "the same value in {C:attention}next hand{}.",
			[5] = "{C:inactive}(#1#){}"
        }
    }, 
    pos = {
        x = 1,
        y = 2
    },
    cost = 7,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'spockholm',

    loc_vars = function(self, info_queue, card)
		local active_text = "Inactive"
		
		if card.ability.extra.active then
			--borrowed from Sigil in base game
			local rank_suffix = card.ability.extra.retrigger_val < 10 and tostring(card.ability.extra.retrigger_val) or
                                        card.ability.extra.retrigger_val == 10 and 'T' or card.ability.extra.retrigger_val == 11 and 'J' or
                                        card.ability.extra.retrigger_val == 12 and 'Q' or card.ability.extra.retrigger_val == 13 and 'K' or
                                        card.ability.extra.retrigger_val == 14 and 'A'
			active_text = "Retriggering "..rank_suffix.."'s"
		end
        return {vars = {active_text}}
    end,

    calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.joker_main and G.GAME.current_round.hands_played == 0 and not card.ability.extra.active and #context.full_hand == 1 and not context.blueprint then
			--First hand and only 1 card and joker isn't currently active
			card.ability.extra.active = true
			card.ability.extra.retrigger_val = G.play.cards[1]:get_id()
			
			local eval = function() return card.ability.extra.active end
			juice_card_until(card, eval, true)
		end
		if context.repetition and context.cardarea == G.play and card.ability.extra.active then
            card.ability.extra.retrigged = true
			if context.other_card:get_id() == card.ability.extra.retrigger_val then
				return {
					message = localize('k_again_ex'),
					repetitions = card.ability.extra.reps,
					card = card
				}
			end
		end
		if context.after and not context.blueprint and card.ability.extra.active and card.ability.extra.retrigged then
			card.ability.extra.active = false
			card.ability.extra.retrigged = false
			card.ability.extra.retrigger_val = nil
		end
    end
}
SMODS.Joker{ --Brooklyn
    name = "Brooklyn",
    key = "brooklyn",
    config = {
        extra = {
			side = nil,
			side_options = {"leftmost","rightmost"},
			cards_ttrig = 2,
			reps = 1,
			cards_to_trigger = {}
		}
    },
    loc_txt = {
        ['name'] = 'Brooklyn',
        ['text'] = {
			[1] = "Retrigger the {C:green}#1#{} {C:attention}#2#{} cards",
			[2] = "in scoring hand {C:attention}#3#{} time", 
			[3] = "{C:inactive}(Side changes after each hand){}"
        }
    }, 
    pos = {
        x = 3,
        y = 2
    },
    cost = 8,
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'spockholm',

    loc_vars = function(self, info_queue, card)
		if card.ability.extra.side == nil then
			card.ability.extra.side = pseudorandom_element(card.ability.extra.side_options, pseudoseed('brooklyn'))
		end
        return {vars = {card.ability.extra.side,card.ability.extra.cards_ttrig,card.ability.extra.reps}}
    end,

    calculate = function(self, card, context)
		if context.before and not context.blueprint then
			if card.ability.extra.side == "leftmost" then
				card.ability.extra.cards_to_trigger[1] = context.scoring_hand[1]
				if #context.scoring_hand > 1 then
					card.ability.extra.cards_to_trigger[2] = context.scoring_hand[2]
				end
			else
				card.ability.extra.cards_to_trigger[1] = context.scoring_hand[#context.scoring_hand]
				if #context.scoring_hand > 1 then
					card.ability.extra.cards_to_trigger[2] = context.scoring_hand[#context.scoring_hand-1]
				end
			end
		end
		if context.repetition and context.cardarea == G.play then
			if context.other_card.ID == card.ability.extra.cards_to_trigger[1].ID or (card.ability.extra.cards_to_trigger[2] and context.other_card.ID == card.ability.extra.cards_to_trigger[2].ID) then
				return {
					message = localize('k_again_ex'),
					repetitions = card.ability.extra.reps,
					card = card
				}
			end
		end
		if context.after and not context.blueprint and card.ability.extra.active and card.ability.extra.retrigged then
			card.ability.extra.cards_to_trigger = {}
			card.ability.extra.side = pseudorandom_element(card.ability.extra.side_options, pseudoseed('brooklyn'))
		end
    end
}
SMODS.Joker{ --Hands up
    name = "Hands Up",
    key = "handsup",
    config = {
        extra = {
		}
    },
    loc_txt = {
        ['name'] = 'Hands Up',
        ['text'] = {
			[1] = "If {C:attention}first hand{} of round is",
			[2] = "is a single {C:attention}5{}, destroy it and",
			[3] = "create a {C:attention}Double Tag{}"
        }
    }, 
    pos = {
        x = 0,
        y = 2
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'spockholm',

    loc_vars = function(self, info_queue, card)
        return {}
    end,

    calculate = function(self, card, context)
		--#context.full_hand == 1 and context.full_hand[1]:get_id() == 6 and G.GAME.current_round.hands_played == 0 then
		if context.destroy_card and not context.blueprint and context.cardarea == G.play then
			if #context.scoring_hand == 1 and context.scoring_hand[1]:get_id() == 5 and G.GAME.current_round.hands_played == 0 then
				G.E_MANAGER:add_event(Event({
                    func = (function()
                        add_tag(Tag('tag_double'))
                        play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                        return true
                    end)
                }))
				SMODS.destroy_cards(context.destroy_card)
			end
		end
    end
}
