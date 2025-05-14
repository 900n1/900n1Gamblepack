SMODS.Joker{
    key = 'eye_rah',
    loc_txt = {
        name = 'Joker of Rah',
        text = {
          'When only one card is played,',
          'if that card is not {C:attention}Stone{},',
          'turn that card into {C:attention}Stone{}',
          'and create {C:attention}#1# Tarot{} cards',
          '{C:inactive}(Must have room)',
        },
    },
    atlas = 'Jokers', 
    rarity = 2,
    cost = 4,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 0},
    config = { 
      extra = {
        tarotCount = 2
      }
    },
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return {vars = {center.ability.extra.tarotCount}}
    end,
    calculate = function(self,card,context)
        if context.joker_main and #G.play.cards == 1 then
            if  G.play.cards[1].config.center_key ~= 'm_stone'  then
                local amoun = card.ability.extra.tarotCount
                if #G.consumeables.cards + amoun > G.consumeables.config.card_limit then
                    amoun = G.consumeables.config.card_limit - #G.consumeables.cards
                end
                G.play.cards[1]:flip()
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 1,
                    func = function()
                        G.play.cards[1]:flip()
                        card:juice_up(1, 1)
                        G.play.cards[1]:set_ability(G.P_CENTERS.m_stone)
                        SMODS.calculate_effect({ message = "chill the fuck up yo", colour = G.C.MULT, instant = true}, card)
                        play_sound('ninehund_rah')
                        if amoun > 0 then
                            for i=1, amoun do
                                local _card = create_card('Tarot', G.consumeables)
                                _card:add_to_deck()
                                G.consumeables:emplace(_card)
                            end
                        end
                        return true
                    end
                }))
            else
                SMODS.calculate_effect({ message = "yall trippin", colour = G.C.PURPLE, instant = true}, card)
            end
        end
    end,
}

local burnspiceYap =  {
    "I'm bored, BORED!",
    "Witness DESTRUCTION!!",
    "This will be entertaining!",
    "In the end, everything becomes dust.",
    "Oh please, this is child's play! I want MORE!",
    "What am I even doing here in the first place?!"
}

local burnspiceDissapoint = {
    "Seriously?!",
    "BOOORING!",
    "WHAT?! NO MORE??",
    "*sigh*",
    "Give me more!"
}

SMODS.Joker{
    key = 'crk_burnspice',
    loc_txt = {
        name = 'Burning Spice Cookie',
        text = {
          'Deals {C:mult}#4# damage{} {C:attention}#5#{} times',
          'to cards in your hand randomly, and',
          'gains {X:mult,C:white}x#2#{} per card {C:mult}damaged',
          '{C:mult,s:1.2,E:1}#3#{}',
          '{X:mult,C:white,s:2}x#1#{s:2,C:mult} Mult{}',
        },
    },
    atlas = 'crk', 
    rarity = "ninehund_icon",
    cost = 4,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 0},
    soul_pos = {x = 1, y = 0, extra9 = {x = 2, y = 0}},
    config = { 
      extra = {
        xmult = 1,
        gain = 0.35,
        dmg = 5,
        amount = 3
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.xmult,center.ability.extra.gain, burnspiceYap[math.random(#burnspiceYap)],center.ability.extra.dmg,center.ability.extra.amount}}
    end,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Beast', HEX('66041E'), G.C.WHITE, 1)
        badges[#badges+1] = create_badge('Cookie Run: Kingdom', G.C.GREY, G.C.WHITE, 0.8)
    end,
    calculate = function(self,card,context)
        if context.pre_joker then
            local didathing = false
            for i=1,card.ability.extra.amount do
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 1,
                    func = function()
                        if #G.hand.cards >= 1 then
                            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.gain;
                            local _chosen = pseudorandom_element(G.hand.cards,pseudoseed('crk'))
                            _chosen:damage_card(card.ability.extra.dmg);
                            didathing = true
                            SMODS.calculate_effect({ message = "+x" ..card.ability.extra.gain.." Mult", colour = G.C.MULT, instant = true}, card)
                        end
                        return true
                    end
                }))
            end
            G.E_MANAGER:add_event(Event({
                trigger = "before",
                delay = 1,
                func = function()
                    if not didathing then
                        SMODS.calculate_effect({ message = burnspiceDissapoint[math.random(#burnspiceDissapoint)], colour = G.C.MULT, instant = true}, card)
                    end
                    return true
                end
            }))
        end
        if context.joker_main then
            return {
                card = card,
                Xmult_mod = card.ability.extra.xmult,
                message = 'X' .. card.ability.extra.xmult,
                colour = G.C.MULT
            }
        end
    end,
}

local shadowmilkYap = {
    'Oh, this is going to be FUN!',
    "Ever told a lie? Then we're pals!",
    'The game is just beginning!',
    'Let the show BEGIN!',
    "Even I can't tell where I am right now!",
    'Oh no, you got tricked? Well, TOO BAD!',
    "Aw, don't be a drag! C'mon, have some fun!"
}

SMODS.Joker{
    key = 'crk_shadowmilk',
    loc_txt = {
        name = 'Shadow Milk Cookie',
        text = {
          'Playing cards are {C:white,X:chips}Concealed{}',
          'gains {X:mult,C:white}x#2#{} per card deceived.',
          '{C:chips}[After playing, Concealed cards reveal themselves]{}',
          '{C:chips,s:1.2,E:1}#3#{}',
          '{X:mult,C:white,s:2}x#1#{s:2,C:mult} Mult{}',
        },
    },
    atlas = 'crk', 
    rarity = "ninehund_icon",
    cost = 4,
    unlocked = true,
    discovered = true, 
    blueprint_compat = false, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 1},
    soul_pos = {x = 1, y = 1, extra9 = {x = 2, y = 1}},
    config = { 
      extra = {
        xmult = 1,
        gain = 0.1
      }
    },
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_SEALS.ninehund_truth
        return {vars = {center.ability.extra.xmult,center.ability.extra.gain, shadowmilkYap[math.random(#shadowmilkYap)]}}
    end,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Beast', HEX('66041E'), G.C.WHITE, 1)
        badges[#badges+1] = create_badge('Cookie Run: Kingdom', G.C.GREY, G.C.WHITE, 0.8)
    end,
    add_to_deck = function(self, card, from_debuff)
		if not from_debuff then
            local prevXMult = card.ability.extra.xmult
            card.ability.extra.xmult = card.ability.extra.xmult + (card.ability.extra.gain*#G.playing_cards)
            card:juice_up(1, 1)
            card:speak("+x"..(card.ability.extra.xmult-prevXMult).." Mult",G.C.MULT)
            for k, v in pairs(G.playing_cards) do
                v.ability["truth1"] = v:getSuit()
                v.ability["truth2"] = v:getRank()
                SMODS.change_base(v,pseudorandom_element({'Hearts','Diamonds','Clubs','Spades'}, pseudoseed('lies')),pseudorandom_element({'2','3','4','5','6','7','8','9','10','Jack','Queen','King','Ace'}, pseudoseed('lies')))
                v:set_seal("ninehund_truth",true)
            end
        end
	end,
    calculate = function(self,card,context)
        if context.post_joker then
            card.ability.extra.xmult = card.ability.extra.xmult + (card.ability.extra.gain*#context.full_hand)
            for k, v in pairs(context.full_hand) do
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 1,
                    func = function()
                        v.ability["truth1"] = v:getSuit()
                        v.ability["truth2"] = v:getRank()
                        SMODS.change_base(v,pseudorandom_element({'Hearts','Diamonds','Clubs','Spades'}, pseudoseed('lies')),pseudorandom_element({'2','3','4','5','6','7','8','9','10','Jack','Queen','King','Ace'}, pseudoseed('lies')))
                        v:set_seal("ninehund_truth",true)
                        v:juice_up()
                        play_sound('generic1', math.random()*0.2 + 0.9,0.5)
                        SMODS.calculate_effect({ message = "+x"..card.ability.extra.gain.." Mult", colour = G.C.MULT, instant = true}, card)
                        return true
                    end
                })) 
            end
        end
        if context.joker_main then
            return {
                card = card,
                Xmult_mod = card.ability.extra.xmult,
                message = 'X' .. card.ability.extra.xmult,
                colour = G.C.MULT
            }
        end
    end,
}

local mysticflourYap = {
    "Nothing shall last.",
    "Win or lose, it matters not.",
    "Is this truly what you want?",
    "It is all meaningless.",
    "...",
    "I await your moment of awakening.",
    "Empty your heart.",
    "For even greed shall pass...",
    "Wake up, and you shall see the truth.",
    "This place, will eventually decay as well."
}

SMODS.Joker{
    key = 'crk_mysticflour',
    loc_txt = {
        name = 'Mystic Flour Cookie',
        text = {
          'Cards played are {C:white,X:inactive}Wiped.{}',
          'Gains {X:chips,C:white}x#2#{} per card',
          'returned to their origin.',
          '{C:mult}Mult{C:attention} increases{} by current{C:chips}Chips{}',
          'after {C:chips}Chips{} have been multiplied.',
          '{C:inactive,s:1.2,E:1}#3#{}',
          '{X:chips,C:white,s:2}x#1#{s:2,C:chips} Chips{}',
        },
    },
    atlas = 'crk', 
    rarity = "ninehund_icon",
    cost = 4,
    unlocked = true,
    discovered = true, 
    blueprint_compat = false, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 2},
    soul_pos = {x = 1, y = 2, extra9 = {x = 2, y = 2}},
    config = { 
      extra = {
        xchip = 1,
        gain = 0.1
      }
    },
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.m_ninehund_blankcard
        return {vars = {center.ability.extra.xchip,center.ability.extra.gain, mysticflourYap[math.random(#mysticflourYap)]}}
    end,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Beast', HEX('66041E'), G.C.WHITE, 1)
        badges[#badges+1] = create_badge('Cookie Run: Kingdom', G.C.GREY, G.C.WHITE, 0.8)
    end,
    calculate = function(self,card,context)
        if context.pre_joker then
            local prevXchip = card.ability.extra.xchip
            card.ability.extra.xchip = card.ability.extra.xchip + (card.ability.extra.gain*#context.full_hand)
            for k, v in pairs(context.full_hand) do
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.6,
                    func = function()
                        v:juice_up()
                        if v.config.center_key ~= "m_ninehund_blankcard" then
                            v:set_ability(G.P_CENTERS.m_ninehund_blankcard)
                            v:set_edition(nil)
                            v:set_seal(nil)
                            play_sound('generic1', math.random()*0.2 + 0.9,0.5)
                            SMODS.calculate_effect({ message = "+x"..card.ability.extra.gain.." Chips", colour = G.C.CHIPS, instant = true}, card)
                        end
                        return true
                    end
                })) 
            end
        end
        if context.joker_main then
            hand_chips = mod_chips(hand_chips*card.ability.extra.xchip)
            return {
                chips = 0,
                mult = hand_chips,
                chip_message = {message = "X"..card.ability.extra.xchip.." Chips", colour = G.C.CHIPS},
                mult_message = {message = "+Chips Mult", colour = G.C.MULT}
            }
        end
    end,
}

SMODS.Joker{
    key = 'rockbanana',
    loc_txt = {
        name = 'Rocher Michel',
        text = {
          '{C:mult}+#2#{} Mult per {C:attention}Stone Card{}',
          'in your {C:attention}full deck{}.',
          '{C:green}#3# in #1#{} chance this is',
          'destroyed at the end of the round',
          '{C:inactive}Heh, you know what else is rock hard?',
        },
    },
    atlas = 'amalgam', 
    rarity = 'ninehund_fusion',
    cost = 7,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 0},
    config = { 
      extra = {
        mult = 0,
        chance = 6,
        percard = 50
      }
    },
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return {vars = {center.ability.extra.chance,center.ability.extra.percard,"" .. (G.GAME and G.GAME.probabilities.normal or 1)}}
    end,
    calculate = function(self,card,context)
        if context.joker_main then
            card.ability.extra.mult = 0
            for k, v in pairs(G.playing_cards) do
                if v.config.center == G.P_CENTERS.m_stone then card.ability.extra.mult = card.ability.extra.mult+card.ability.extra.percard end
            end
            return {
                card = card,
                mult_mod = card.ability.extra.mult,
                message = '+' .. card.ability.extra.mult,
                colour = G.C.MULT
            }
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition and not context.retrigger_joker then
            if pseudorandom(pseudoseed('banana')) < G.GAME.probabilities.normal / card.ability.extra.chance then
                card:speak("Extinct!")
                G.E_MANAGER:add_event(Event({
					func = function()
                        card:start_dissolve()
                	    return true
					end
				}))
            else
                card:speak("Safe!",G.C.CHANCE)
            end
        end
    end,
}

SMODS.Joker{
    key = 'pridejoker',
    loc_txt = {
        name = 'Prideful Joker',
        text = {
          'Played cards with',
          '{C:attention}any of the four suits{}',
          'give {C:mult}+#1#{} Mult when scored',
          '{C:inactive}Really now?',
        },
    },
    atlas = 'amalgam', 
    rarity = 'ninehund_fusion',
    cost = 10,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 2, y = 0},
    config = { 
      extra = {
        mult = 12,
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.mult}}
    end,
    calculate = function(self,card,context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Hearts') or context.other_card:is_suit('Diamonds') or context.other_card:is_suit('Clubs') or context.other_card:is_suit('Spades') then
                return {
                    card = card,
                    mult = card.ability.extra.mult,
                }
            end
        end
    end,
}

SMODS.Joker{
    key = 'whitediamondjoker',
    loc_txt = {
        name = 'White Diamond Joker',
        text = {
          'Scored cards with {C:attention}any of the four suits{} give:',
          '{C:money}$#1#{}',
          '{C:chips}+#3#{} Chips',
          '{C:mult}+#4#{} Mult',
          '{C:green}#6# in #2# chance{} for {X:mult,C:white}x#5#{} Mult',
          '{C:inactive}Perfection.',
        },
    },
    atlas = 'amalgam', 
    rarity = 'ninehund_fusion',
    cost = 21,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 3, y = 0},
    config = { 
      extra = {
        money = 1,
        chance = 2,
        chips = 50,
        mult = 7,
        Xmult = 1.5,
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.money,center.ability.extra.chance,center.ability.extra.chips,center.ability.extra.mult,center.ability.extra.Xmult,G.GAME.probabilities.normal}}
    end,
    calculate = function(self,card,context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Hearts') or context.other_card:is_suit('Diamonds') or context.other_card:is_suit('Clubs') or context.other_card:is_suit('Spades') then
                if pseudorandom(pseudoseed('wild')) < G.GAME.probabilities.normal / card.ability.extra.chance then
                    return {
                        card = card,
                        dollars = card.ability.extra.money,
                        chips = card.ability.extra.chips,
                        mult = card.ability.extra.mult,
                        x_mult = card.ability.extra.Xmult,
                    }
                else
                    return {
                        card = card,
                        dollars = card.ability.extra.money,
                        chips = card.ability.extra.chips,
                        mult = card.ability.extra.mult,
                    }
                end
            end
        end
    end,
}

SMODS.Joker{
    key = 'hitlistjoker',
    loc_txt = {
        name = 'Hitlist Joker',
        text = {
          'Reduce the {C:attention}blind requirement{} by {C:attention}#2#%{}',
          'if {C:attention}poker hand{} is a {C:attention}#1#{}',
          "{C:inactive}(Hand changes after use",
          "{C:inactive}and start of a Blind)",
          "{C:inactive,s:0.8}Hating on Boss Blinds became",
          "{C:inactive,s:0.8}a part of my lifestyle.",
        },
    },
    atlas = 'amalgam', 
    rarity = 'ninehund_fusion',
    cost = 7,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 4, y = 0},
    config = { 
      extra = {
        type = "High Card",
        percent = 10,
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.type,center.ability.extra.percent}}
    end,
    set_ability = function(self, card, initial, delay_sprites)
		local _poker_hands = {}
        	for k, v in pairs(G.GAME.hands) do
            		if v.visible then _poker_hands[#_poker_hands+1] = k end
	        end
		card.ability.extra.type = pseudorandom_element(_poker_hands, pseudoseed('pokerhand'))
	end,
    calculate = function(self,card,context)
        if (context.cardarea == G.jokers and context.before) or context.setting_blind  then
			if context.scoring_name == card.ability.extra.type then
                card:speak('-'..card.ability.extra.percent..'% Blind Size',G.C.FILTER)
				change_blind_size(to_big(G.GAME.blind.chips) - (to_big(G.GAME.blind.chips)*to_big(card.ability.extra.percent*0.01)))
                local _poker_hands = {}
                for k, v in pairs(G.GAME.hands) do
                        if v.visible then _poker_hands[#_poker_hands+1] = k end
                end
                card.ability.extra.type = pseudorandom_element(_poker_hands, pseudoseed('pokerhand'))
            end
        end
    end,
}

SMODS.Joker{
    key = 'bible',
    loc_txt = {
        name = 'The Holy Bible',
        text = {
          '{C:attention}Cleanses and enlightens you.{}'
        },
    },
    atlas = 'Jokers', 
    rarity = 2,
    cost = 0,
    unlocked = true,
    discovered = true, 
    blueprint_compat = false, 
    eternal_compat = true,
    perishable_compat = false, 
    pos = {x = 4, y = 0},
    add_to_deck = function(self, card, from_debuff)
        display_image({x=0,y=0}, "ninehund_whitescreen", {x = 0, y = 0, sx = 32, sy = 18}, 0)
        play_sound('ninehund_und_flash', 1,0.5);
        for _, j in pairs(G.jokers.cards) do
            j:start_dissolve(nil,true);
        end
        for _, c in pairs(G.consumeables.cards) do
            c:start_dissolve(nil,true);
        end
        ease_hands_played(2- G.GAME.current_round.hands_left,true);
        ease_discard(0 - G.GAME.current_round.discards_left,true);
        ease_dollars(-G.GAME.dollars-77, true)
        G.GAME.round_resets.hands = 2
        G.GAME.round_resets.discards = 0
        card:set_eternal(true);
        G.GAME.nine_biblekillcount = 1;
    end,
    calculate = function(self,card,context)
        if context.questionably_drew and not context.blueprint then
            G.GAME.nine_disableplay = true;
            for i, k in ipairs(G.hand.cards) do
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 2/(G.GAME.nine_biblekillcount+(i*0.3)),
                    timer = "REAL",
                    blocking = true,
                    func = function()
                        G.GAME.nine_biblekillcount = G.GAME.nine_biblekillcount + 0.3;
                        card:juice_up(G.GAME.nine_biblekillcount-1, G.GAME.nine_biblekillcount-1);
                        G.GAME.nine_musicspeed = 1+((G.GAME.nine_biblekillcount+(i*0.3))*0.2);
                        display_image({x=math.random(0,6),y=0}, "ninehund_jesus", {x = 0, y = 0, sx = 23.2, sy = 13.05}, 0)
                        play_sound('ninehund_bell',1,0.5);
                        k:start_dissolve(nil, true);
                        return true
                    end
                })) 
            end
        end
    end,
}

SMODS.Joker{
    key = 'asrieljoker',
    loc_txt = {
        name = 'Core of Desire',
        text = {
          'When a card is {C:mult}damaged{}:',
          'Increase the {X:mult,C:white}Health{} and {X:mult,C:white}MaxHealth{}',
          'of the card by {X:green,C:white}#1#{}.',
          'Gain {X:purple,C:white}^#3#{}.',
          '{X:purple,C:white,s:2}^#2#{C:purple,s:2} Mult',
          "{C:rainbow,s:0.8,E:1}Half of the world's prayers.",
        },
    },
    atlas = 'supernatural', 
    rarity = 'ninehund_super',
    cost = 99,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = false, 
    pos = {x = 0, y = 0},
    soul_pos = {x = 1, y = 0, extra9 = {x = 2, y = 0}},
    config = { 
        extra = {
        e_mult = 1.01,
        heal = 1,
        gain = 0.01
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.heal,center.ability.extra.e_mult,center.ability.extra.gain}}
    end,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Singular', HEX('525A65'), G.C.WHITE, 1)
        badges[#badges+1] = create_badge('Antimatter', G.C.VOID, G.C.WHITE, 1)
    end,
    add_to_deck = function(self, card, from_debuff)
        card:set_eternal(true);
        G.jokers.config.card_limit = G.jokers.config.card_limit + 1
        local find = find_joker('j_ninehund_asrieljoker');
        if #find > 0 then
            find[1].ability.extra.heal = find[1].ability.extra.heal + 1;
            find[1].ability.extra.gain = find[1].ability.extra.gain + 0.01;
            SMODS.calculate_effect({ message = "Upgrade!", colour = G.C.PURPLE, instant = false}, find[1])
            card:start_dissolve(nil, true);
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
	end,
    calculate = function(self,card,context)
        if context.joker_main then
            return {
                card = card,
                emult = card.ability.extra.e_mult,
            }
        end
        if context.card_damaged then
            context.card_damaged.ability.health = context.card_damaged.ability.health + card.ability.extra.heal;
            context.card_damaged.ability.max_health = context.card_damaged.ability.max_health + card.ability.extra.heal;
            card.ability.extra.e_mult = card.ability.extra.e_mult + card.ability.extra.gain;
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    SMODS.calculate_effect({ message = "+" ..card.ability.extra.heal, colour = G.C.GREEN, instant = true}, context.card_damaged)
                    SMODS.calculate_effect({ message = "+^" ..card.ability.extra.gain, colour = G.C.PURPLE, instant = true}, card)
                    return true
                end
            }))
        end
    end,
}
