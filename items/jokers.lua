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
    eternal_compat = true,
    perishable_compat = true, 
    blueprint_compat = true,
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
          'Deals {X:red,C:white}#4#{C:red} damage{} {C:attention}#5#{} times',
          'to cards {C:attention}in your hand{} randomly, and',
          'gains {X:mult,C:white}X#2#{} per card {C:red}damaged',
          '{C:mult,s:1.2,E:1}#3#{}',
          '{X:mult,C:white,s:2}X#1#{s:2,C:mult} Mult{}',
        },
    },
    atlas = 'crk', 
    rarity = "ninehund_icon",
    cost = 15,
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
          'gains {X:mult,C:white}X#2#{} per card deceived.',
          '{C:chips}[After playing, Concealed cards reveal themselves]{}',
          '{C:chips,s:1.2,E:1}#3#{}',
          '{X:mult,C:white,s:2}X#1#{s:2,C:mult} Mult{}',
        },
    },
    atlas = 'crk', 
    rarity = "ninehund_icon",
    cost = 25,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
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
          'Gains {X:chips,C:white}X#2#{} per card',
          'returned to their origin.',
          '{C:mult}Mult{C:attention} increases{} by current {C:chips}Chips{}',
          '{C:attention}after {C:chips}Chips{} have been multiplied.',
          '{C:inactive,s:1.2,E:1}#3#{}',
          '{X:chips,C:white,s:2}X#1#{s:2,C:chips} Chips{}',
        },
    },
    atlas = 'crk', 
    rarity = "ninehund_icon",
    cost = 20,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 2},
    soul_pos = {x = 1, y = 2, extra9 = {x = 2, y = 2}},
    config = { 
      extra = {
        xchip = 1,
        gain = 0.5
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
                mult_message = {message = "+"..to_number(hand_chips).." Mult", colour = G.C.MULT}
            }
        end
    end,
}

local eternalsugarYap = {
    "I can make your wishes come true!",
    "Oh, you wish to play~?",
    "Your passions will only lead to suffering...",
    "No need to try so hard!",
    "Embrace sweetness eternal~",
    "I can bring you to my Garden of Delights~",
    "Let us forget all pains and sorrow!",
    "Allow yourself a little moment of laziness~"
}

SMODS.Joker{
    key = 'crk_eternalsugar',
    loc_txt = {
        name = 'Eternal Sugar Cookie',
        text = {
          'Cards played are {B:1,C:white}Demoted{}',
          'and {C:green}Healed{} for {C:white,X:green}#3#{}.',
          'Gains {X:chips,C:white}X#2#{} per card given rest.',
          '{C:chips}Chips{C:attention} increases{} by current {C:mult}Mult{}',
          '{C:attention}before {C:chips}Chips{} have been multiplied.',
          '{V:1}(Demoted cards decrease in rank by one)',
          '{V:1,s:1.2,E:1}#4#{}',
          '{X:chips,C:white,s:2}X#1#{s:2,C:chips} Chips{}',
        },
    },
    atlas = 'crk', 
    rarity = "ninehund_icon",
    cost = 20,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 3},
    soul_pos = {x = 1, y = 3, extra9 = {x = 2, y = 3}},
    config = { 
      extra = {
        xchip = 1,
        gain = 0.15,
        heal = 1
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.xchip,center.ability.extra.gain,center.ability.extra.heal,eternalsugarYap[math.random(#eternalsugarYap)], colours = {HEX("F9A6E2")}}}
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
                        SMODS.modify_rank(v,-1)
                        v:heal_card(1)
                        play_sound('generic1', math.random()*0.2 + 0.9,0.5)
                        SMODS.calculate_effect({ message = "+x"..card.ability.extra.gain.." Chips", colour = G.C.CHIPS, instant = true}, card)
                        return true
                    end
                })) 
            end
        end
        if context.joker_main then
            hand_chips = mod_chips((hand_chips+mult)*card.ability.extra.xchip)
            return {
                chips = 0,
                chip_message = {message = "(+"..to_number(mult)..")X"..card.ability.extra.xchip.." Chips", colour = G.C.CHIPS},
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
    pools = {["Fusions"] = true},
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
    pools = {["Fusions"] = true},
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
    key = 'whitediamond',
    loc_txt = {
        name = 'White Diamond',
        text = {
          'Scored cards with {C:attention}any of the four suits{} give:',
          '{C:money}$#1#{}',
          '{C:chips}+#3#{} Chips',
          '{C:mult}+#4#{} Mult',
          '{C:green}#6# in #2# chance{} for {X:mult,C:white}X#5#{} Mult',
          '{C:inactive}Perfection.',
        },
    },
    atlas = 'amalgam', 
    rarity = 'ninehund_fusion',
    pools = {["Fusions"] = true},
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
    pools = {["Fusions"] = true},
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
          'When a card is {C:red}damaged{}:',
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
        e_mult = 1.1,
        heal = 1,
        gain = 0.02
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
        local find = SMODS.find_card('j_ninehund_asrieljoker');
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

local hrt_horselist = {
    regular = {
        'bulletn',
        'comely',
        'cyan',
        'doorknob',
        'downtown',
        'jovial',
        'lightning',
        'resolute',
        'superstitional'
    },
    nightmare = {
        'cyan',
        'jovial',
        'superstitional',
        'garbage',
        'mysterious',
        'nighttime',
        'legacy'
    },
    nightmare_lookup = {
        ['cyan'] = true,
        ['jovial'] = true,
        ['superstitional'] = true,
        ['garbage'] = true,
        ['mysterious'] = true,
        ['nighttime'] = true,
        ['legacy'] = true
    }
}

local hrt_horses = {
    ["bulletn"] = {
        color = HEX("0000FF"),
        pos = {x = 0, y = 1},
        key = "bulletn",
        func = function(card,context)
            if context.joker_main then
                for k, v in pairs(context.full_hand) do
                    if pseudorandom(pseudoseed('hrt')) < G.GAME.probabilities.normal / 3 then
                        G.E_MANAGER:add_event(Event({
                            trigger = "before",
                            delay = 1,
                            func = function()
                                v:set_edition("e_foil",true)
                                v:juice_up()
                                card:juice_up()
                                play_sound("foil1",math.random()*0.2 + 0.9,0.5)
                                return true
                            end
                        })) 
                    end
                end
                for k, v in pairs(G.hand.cards) do
                    if v:is_suit('Spades') then
                        SMODS.calculate_effect({xchips = 1.5},v)
                    end
                end
            end
        end
    },
    ["comely"] = {
        color = HEX("FFA0FF"),
        pos = {x = 1, y = 1},
        key = "comely",
        func = function(card,context)
            if context.but_first then
                for k, v in pairs(context.full_hand) do
                    SMODS.change_base(v,"Hearts")
                end
            end
            if context.individual and context.cardarea == G.play then
                if context.other_card:getRank() == "Ace" then
                    return {
                            card = card,
                            x_mult = 2,
                        }
                end
            end
        end
    },
    ["cyan"] = {
        color = HEX("00CBCB"),
        pos = {x = 4, y = 0},
        key = "cyan",
        func = function(card,context)
            if context.discard and G.GAME.current_round.discards_used == 0 and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                local card = create_card(nil, G.consumeables, nil, nil, nil, nil, 'c_black_hole')
                card:add_to_deck()
                G.consumeables:emplace(card)
            end
        end
    },
    ["doorknob"] = {
        color = HEX("5F1F17"),
        pos = {x = 2, y = 1},
        key = "doorknob",
        func = function(card,context)
            if context.repetition and context.cardarea == G.play then
                if pseudorandom(pseudoseed('hrt')) < G.GAME.probabilities.normal / 2 then
                    return {
                        message = localize("k_again_ex"),
                        repetitions = 3,
                        card = card,
                    }
                end
            end
        end
    },
    ["downtown"] = {
        color = HEX("4B4B4B"),
        pos = {x = 3, y = 1},
        key = "downtown",
        func = function(card,context)
            if context.joker_main then
                for k, v in pairs(G.hand.cards) do
                    SMODS.calculate_effect({xchips = 1.25},v)
                end
            end
        end
    },
    ["jovial"] = {
        color = HEX("F37700"),
        pos = {x = 2, y = 0},
        key = "jovial",
        func = function(card,context)
            if context.joker_main then
                return {
                    xchips = 2,
                    x_mult = 5
                }
            end
        end
    },
    ["lightning"] = {
        color = HEX("FFFF43"),
        pos = {x = 3, y = 0},
        key = "lightning",
        func = function(card,context)
            if context.joker_main and context.scoring_name == G.GAME.current_round.most_played_poker_hand then
                return {
                    dollars = 10
                }
            end
        end
    },
    ["resolute"] = {
        color = HEX("C00000"),
        pos = {x = 1, y = 0},
        key = "resolute",
        func = function(card,context)
            if context.joker_main then
                for k, v in pairs(context.full_hand) do
                    if v:is_suit('Hearts') then
                        SMODS.calculate_effect({x_mult = 1.5},v)
                    end
                end
                for k, v in pairs(G.hand.cards) do
                    if pseudorandom(pseudoseed('hrt')) < G.GAME.probabilities.normal / 3 then
                        G.E_MANAGER:add_event(Event({
                            trigger = "before",
                            delay = 1,
                            func = function()
                                v:set_edition("e_holo",true)
                                v:juice_up()
                                card:juice_up()
                                play_sound("holo1",math.random()*0.2 + 0.9,0.5)
                                return true
                            end
                        })) 
                    end
                end
            end
        end
    },
    ["superstitional"] = {
        color = HEX("FFFFFF"),
        pos = {x = 4, y = 1},
        key = "superstitional",
        func = function(card,context)
            if context.individual and context.cardarea == G.play then
                if pseudorandom(pseudoseed('hrt')) < G.GAME.probabilities.normal / 6 then
                    context.other_card:set_edition("e_polychrome",true)
                    card:juice_up()
                end
            end
        end
    },
    ["mysterious"] = {
        color = HEX("CCCCCC"),
        pos = {x = 1, y = 2},
        key = "mysterious"
    },
    ["garbage"] = {
        color = HEX("006666"),
        pos = {x = 2, y = 2},
        key = "garbage"
    },
    ["nighttime"] = {
        color = HEX("003B3B"),
        pos = {x = 3, y = 2},
        key = "nighttime"
    },
    ["legacy"] = {
        color = HEX("00FF21"),
        pos = {x = 4, y = 2},
        key = "legacy"
    },
}

local hrt_nightmares = {
    ["jovial"] = {
        color = HEX("FF800B"),
        pos = {x = 0, y = 3},
        key = "jovial",
        func = function(card,context)
            if context.joker_main then
                return {
                    xchips = 10,
                    x_mult = 2
                }
            end
        end
    },
    ["cyan"] = {
        color = HEX("00BFF8"),
        pos = {x = 1, y = 3},
        key = "cyan",
        func = function(card,context)
            if context.discard then
                local card = create_card(nil, G.consumeables, nil, nil, nil, nil, 'c_black_hole')
                card:set_edition("e_negative",true)
                card:add_to_deck()
                G.consumeables:emplace(card)
            end
        end
    },
    ["superstitional"] = {
        color = HEX("FFFFFF"),
        pos = {x = 2, y = 3},
        key = "superstitional",
        func = function(card,context)
            if context.joker_main then
                for k, v in pairs(G.hand.cards) do
                    G.E_MANAGER:add_event(Event({
                        trigger = "before",
                        delay = 0.4,
                        func = function()
                            SMODS.change_base(v,nil,context.full_hand[1]:getRank())
                            play_sound('generic1', math.random()*0.2 + 0.9,0.5)
                            v:juice_up()
                            card:juice_up()
                            return true
                        end
                    })) 
                end
            end
        end
    },
    ["mysterious"] = {
        color = HEX("CCCCCC"),
        pos = {x = 1, y = 2},
        key = "mysterious",
        func = function(card,context)
            if context.joker_main then
                local card = create_card(nil, G.consumeables, nil, nil, nil, nil, 'c_hanged_man')
                card:add_to_deck()
                G.consumeables:emplace(card)
            end
        end
    },
    ["garbage"] = {
        color = HEX("006666"),
        pos = {x = 2, y = 2},
        key = "garbage",
        func = function(card,context)
            if context.repetition and context.cardarea == G.play then
                context.other_card:set_seal("Purple",true)
                return {
                    message = localize("k_again_ex"),
                    repetitions = 2,
                    card = card,
                }
            end
        end
    },
    ["nighttime"] = {
        color = HEX("003B3B"),
        pos = {x = 3, y = 2},
        key = "nighttime",
        func = function(card,context)
            if context.joker_main then
                for k, v in pairs(G.hand.cards) do
                    G.E_MANAGER:add_event(Event({
                        trigger = "before",
                        delay = 0.5,
                        func = function()
                            v:damage_card(1)
                            card:juice_up()
                            return true
                        end
                    })) 
                    if pseudorandom(pseudoseed('hrt')) < G.GAME.probabilities.normal / 2 then
                        v:set_edition("e_negative",true)
                    end
                end
            end
        end
    },
    ["legacy"] = {
        color = HEX("00FF21"),
        pos = {x = 4, y = 2},
        key = "legacy",
        func = function(card,context)
            local Hfunc = hrt_horses[pseudorandom_element(hrt_horselist.regular,pseudoseed('hrt'))].func(card,context)
            if Hfunc ~= nil then
                return Hfunc
            end
        end
    },
}

SMODS.Joker{
    key = 'hrtjoker',
    loc_txt = {
        name = 'Horse Race Test: High Rolling Tactics'
    },
    atlas = 'hrt', 
    rarity = 'ninehund_icon',
    cost = 16,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = false, 
    pos = {x = 0, y = 0},
    soul_pos = {x = 4, y = 3, extra9 = {x = 3, y = 3}},
    config = { 
        extra = {
        horse = "na",
        negative = false
      }
    },
    loc_vars = function(self,info_queue,center)
        if center.ability.extra.horse == "na" then
        return {
            vars = {G.GAME.probabilities.normal, colours = {G.C.RAINBOW}},
            key = self.key.."_na", set = "Jokers"
        }
        end
        if center.edition ~= nil then
            if center.edition.key == "e_negative" and hrt_horselist.nightmare_lookup[center.ability.extra.horse] then
                return {
                    vars = {G.GAME.probabilities.normal, colours = {hrt_nightmares[center.ability.extra.horse].color}},
                    key = self.key.."_"..center.ability.extra.horse.."_alt", set = "Jokers"
                }
            end
        end
        return {
            vars = {G.GAME.probabilities.normal, colours = {hrt_horses[center.ability.extra.horse].color}},
            key = self.key.."_"..center.ability.extra.horse, set = "Jokers"
        }
    end,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Horse Race Test', HEX('FF800B'), G.C.WHITE, 1)
        badges[#badges+1] = create_badge('By Blake Andrews', G.C.GREY, G.C.WHITE, 0.8)
    end,
    add_to_deck = function(self, card, from_debuff)
        G.nine_hrtmadness = 1
        card.ability.extra.negative = false
        if card.edition ~= nil then
            if card.edition.key == "e_negative" then
                card.ability.extra.negative = true
            end
        end
        if card.ability.extra.negative then
            card.ability.extra.horse = pseudorandom_element(hrt_horselist.nightmare,pseudoseed('hrt'))
            card.children.center:set_sprite_pos({x=0,y=2})
            card.children.float2:set_sprite_pos(hrt_nightmares[card.ability.extra.horse].pos)
        else
            card.ability.extra.horse = pseudorandom_element(hrt_horselist.regular,pseudoseed('hrt'))
            card.children.center:set_sprite_pos({x=0,y=0})
            card.children.float2:set_sprite_pos(hrt_horses[card.ability.extra.horse].pos)
        end
    end,
    calculate = function(self,card,context)
        if card.ability.extra.horse ~= "na" then
            if card.ability.extra.negative then
                if hrt_nightmares[card.ability.extra.horse]["func"] ~= nil then
                    local Hfunc = hrt_nightmares[card.ability.extra.horse].func(card,context)
                    if Hfunc ~= nil then
                        return Hfunc
                    end
                end
            else
                if hrt_horses[card.ability.extra.horse]["func"] ~= nil then
                    local Hfunc = hrt_horses[card.ability.extra.horse].func(card,context)
                    if Hfunc ~= nil then
                        return Hfunc
                    end
                end
            end
        end
        if context.end_of_round and not context.blueprint and context.cardarea == G.jokers then
            card.ability.extra.negative = false
            if card.edition ~= nil then
                if card.edition.key == "e_negative" then
                    card.ability.extra.negative = true
                end
            end
            if card.ability.extra.negative then
                card.ability.extra.horse = pseudorandom_element(hrt_horselist.nightmare,pseudoseed('hrt'))
                card.children.center:set_sprite_pos({x=0,y=2})
                card.children.float2:set_sprite_pos(hrt_nightmares[card.ability.extra.horse].pos)
            else
                card.ability.extra.horse = pseudorandom_element(hrt_horselist.regular,pseudoseed('hrt'))
                card.children.center:set_sprite_pos({x=0,y=0})
                card.children.float2:set_sprite_pos(hrt_horses[card.ability.extra.horse].pos)
            end
            card:juice_up()
            G.E_MANAGER:add_event(Event({
                trigger = "before",
                delay = 0.1,
                timer = "REAL",
                func = function()
                    play_sound("ninehund_horse", 1,1)
                    G.GAME.nine_musicspeed = 0.01
                    card:juice_up()
                    return true
                end
            })) 
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 1,
                timer = "REAL",
                func = function()
                    play_sound("ninehund_hrt_"..card.ability.extra.horse, 1,2)
                    return true
                end
            })) 
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 5 / G.nine_hrtmadness,
                timer = "REAL",
                func = function()
                    G.GAME.nine_musicspeed = 1
                    return true
                end
            })) 
            G.nine_hrtmadness = G.nine_hrtmadness + 1
        end
    end,
}

local tycoon_funcs = {
    add_to_deck = function(self, card, from_debuff)
        if (G.GAME.n_tycoon_space or 0) < ninehund.tycoon_limit then
            G.jokers.config.card_limit = G.jokers.config.card_limit + 1
            card.ability.extra.in_tycoon = true
        end
        G.GAME.n_tycoon_space = (G.GAME.n_tycoon_space or 0) + 1
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.n_tycoon_space = (G.GAME.n_tycoon_space or 0) - 1
        if card.ability.extra.in_tycoon == true then
		    G.jokers.config.card_limit = G.jokers.config.card_limit - 1
        end
	end,
}

SMODS.Joker{
    key = 'tycoondropper',
    loc_txt = {
        name = 'Basic Iron Dropper',
        text = {
          'Before play, adds a temporary',
          '{C:attention}Steel{} 2 of {C:void}Nothing{} with',
          '{C:money}$#1# sell value{} to your',
          'played hand',
          '{X:inactive,C:white,s:0.8}#2#'
        },
    },
    atlas = 'tycoon', 
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 0},
    soul_pos = {x = 1, y = 0},
    config = { 
      extra = {
        money = 2,
        in_tycoon = false
      }
    },
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Tycoon Machine', G.C.GREY, G.C.WHITE, 1)
    end,
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        return {vars = {center.ability.extra.money,
            center.ability.extra.in_tycoon and "In Tycoon" or "Outside"
        }}
    end,
    add_to_deck = tycoon_funcs.add_to_deck, remove_from_deck = tycoon_funcs.remove_from_deck,
    calculate = function(self,card,context)
        if context.but_first then
            local ore = make_card("ninehund_N_2",nil, G.play, nil, G.C.SECONDARY_SET.Spectral)
            ore:set_ability(G.P_CENTERS.m_steel)
            ore.ability["is_sandwiched"] = true;
            ore.sell_cost = card.ability.extra.money;
            if (G.GAME.n_tycoon_space or 0) < ninehund.tycoon_limit and not card.ability.extra.in_tycoon then --make droppers occupy vacant slots
                G.jokers.config.card_limit = G.jokers.config.card_limit + 1
                card.ability.extra.in_tycoon = true
            end
        end
        if context.destroy_card and context.cardarea == G.play then
            if context.destroying_card.ability["is_sandwiched"] then
                return { remove = true }
            end
        end
    end,
}

SMODS.Joker{
    key = 'tycoonfurnace',
    loc_txt = {
        name = 'Basic Furnace',
        text = {
          '{C:money}Sells{} the {C:attention}right-most{}',
          'played card that has',
          'not been {C:money}sold{} yet',
          '{X:inactive,C:white,s:0.8}#1#'
        },
    },
    atlas = 'tycoon', 
    rarity = 2,
    cost = 10,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 0},
    soul_pos = {x = 2, y = 0},
    config = { 
      extra = {
        in_tycoon = false
      }
    },
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Tycoon Machine', G.C.GREY, G.C.WHITE, 1)
    end,
    loc_vars = function(self,info_queue,center)
        return {vars = {
            center.ability.extra.in_tycoon and "In Tycoon" or "Outside"
        }}
    end,
    add_to_deck = tycoon_funcs.add_to_deck, remove_from_deck = tycoon_funcs.remove_from_deck,
    calculate = function(self,card,context)
        if context.joker_main then
            for i=#G.play.cards,1,-1 do
                if G.play.cards[i].ability["sold"] == nil then
                    G.play.cards[i].ability.sold = true
                    ease_dollars(G.play.cards[i].sell_cost)
                    G.E_MANAGER:add_event(Event({
                        trigger = "before",
                        delay = 1,
                        func = function()
                            G.play.cards[i]:start_dissolve()
                            card:juice_up()
                            return true
                        end
                    }))
                    break
                end
            end
        end
        if context.but_first then
            if (G.GAME.n_tycoon_space or 0) < ninehund.tycoon_limit and not card.ability.extra.in_tycoon then --make droppers occupy vacant slots
                G.jokers.config.card_limit = G.jokers.config.card_limit + 1
                card.ability.extra.in_tycoon = true
            end
        end
        if context.destroy_card and context.cardarea == G.play then
            if context.destroying_card.ability["sold"] then
                return { remove = true }
            end
        end
    end,
}

SMODS.Joker{
    key = 'tycoonupgrader_basic',
    loc_txt = {
        name = 'Ore Purifier',
        text = {
          'Increases the {C:money}sell value{} and {C:mult}bonus mult',
          'of the cards in {C:attention}played hand{}',
          'by {C:money}$#1#{} and {C:mult}+#1#{} if the card has',
          'less than {C:money}$#3# sell value{}',
          '{X:inactive,C:white,s:0.8}#2#'
        },
    },
    atlas = 'tycoon', 
    rarity = 2,
    cost = 15,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 0},
    soul_pos = {x = 3, y = 0},
    config = { 
      extra = {
        upgrade = 1,
        in_tycoon = false,
        limit = 5
      }
    },
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Tycoon Machine', G.C.GREY, G.C.WHITE, 1)
    end,
    loc_vars = function(self,info_queue,center)
        return {vars = { center.ability.extra.upgrade,
            center.ability.extra.in_tycoon and "In Tycoon" or "Outside",
            center.ability.extra.limit
        }}
    end,
    add_to_deck = tycoon_funcs.add_to_deck, remove_from_deck = tycoon_funcs.remove_from_deck,
    calculate = function(self,card,context)
        if context.pre_joker then
            for i=#G.play.cards,1,-1 do
                if G.play.cards[i].sell_cost < card.ability.extra.limit then
                    G.play.cards[i].sell_cost = G.play.cards[i].sell_cost + card.ability.extra.upgrade
                    G.play.cards[i].ability.perma_mult = G.play.cards[i].ability.perma_mult + card.ability.extra.upgrade
                    G.E_MANAGER:add_event(Event({
                        trigger = "before",
                        delay = 1,
                        func = function()
                            card:juice_up()
                            G.play.cards[i]:juice_up()
                            SMODS.calculate_effect({ message = "Upgrade!", colour = G.C.PURPLE, instant = true}, G.play.cards[i])
                            return true
                        end
                    }))
                end
            end
        end
        if context.but_first then
            if (G.GAME.n_tycoon_space or 0) < ninehund.tycoon_limit and not card.ability.extra.in_tycoon then --make droppers occupy vacant slots
                G.jokers.config.card_limit = G.jokers.config.card_limit + 1
                card.ability.extra.in_tycoon = true
            end
        end
    end,
}


local blocktalesbossrush = {
    "bl_ninehund_greed",
    "bl_ninehund_solitude",
    "bl_ninehund_fear",
    "bl_ninehund_hatred",
}
SMODS.Joker{
    key = 'necklace',
    loc_txt = {
        name = 'The Pendant',
    },
    atlas = 'necklace', 
    rarity = 3,
    cost = 99,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = false, 
    pos = {x = 0, y = 0},
    soul_pos = {x = 1, y = 0},
    config = { 
        extra = {
        FUNNY = 2,
        pure = false,
      }
    },
    loc_vars = function(self,info_queue,center)
        if center.ability.extra.pure then
            return {
                vars = {center.ability.extra.FUNNY},
                key = self.key.."_purified", set = "Jokers"
            }
        end
        return {
            vars = {center.ability.extra.FUNNY},
            key = self.key.."_unpure", set = "Jokers"
        }
    end,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Singular', HEX('525A65'), G.C.WHITE, 1)
        badges[#badges+1] = create_badge('Antimatter', G.C.VOID, G.C.WHITE, 1)
    end,
    add_to_deck = function(self, card, from_debuff)
        card:set_eternal(true);
        G.jokers.config.card_limit = G.jokers.config.card_limit + 1
        local find = SMODS.find_card('j_ninehund_necklace');
        if #find > 0 then
            SMODS.calculate_effect({ message = "There can only be one.", colour = G.C.PURPLE, instant = false}, find[1])
            card:start_dissolve(nil, true);
            return
        end
        if not G.GAME.n_bossrush then
            G.GAME.n_bossrush = true
            G.GAME.n_bossPending = {
                bosses = blocktalesbossrush,
                win = "pendant",
                current = 0
            }
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
	end,
    calculate = function(self,card,context)
        if context.joker_main and card.ability.extra.pure  then
            return {
                card = card,
                echips = card.ability.extra.FUNNY,
            }
        end
    end
}

SMODS.Joker{
    key = 'titanspawn',
    loc_txt = {
        name = 'Titan Spawn',
        text = {
          '{C:mult}-#1# Mult',
        },
    },
    atlas = 'titanspawn', 
    rarity = 'ninehund_burden',
    cost = 0,
    unlocked = true,
    discovered = false, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 0},
    soul_pos = {x = 1, y = 0},
    config = { 
      extra = {
        mult = 999999,
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.mult}}
    end,
    add_to_deck = function(self, card, from_debuff)
        card:set_eternal(true);
    end,
    calculate = function(self,card,context)
        if context.joker_main then
            return {
                card = card,
                mult = -card.ability.extra.mult,
                colour = G.C.MULT
            }
        end
    end,
}

SMODS.Joker{
    key = 'starwalker',
    loc_txt = {
        name = 'The Original',
        text = {},
    },
    atlas = 'starwalker', 
    rarity = 'ninehund_starwalker',
    cost = 0,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 0},
    soul_pos = {x = 1, y = 0},
    config = { 
      extra = {
        mult = 7,
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.mult}}
    end,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Singular', HEX('525A65'), G.C.WHITE, 1)
    end,
    add_to_deck = function(self, card, from_debuff)
        local find = SMODS.find_card('j_ninehund_starwalker');
        if #find > 0 then
            SMODS.calculate_effect({ message = "i am the original       starwalker", colour = G.C.MONEY, instant = false}, find[1])
            find[1].ability.extra.mult = find[1].ability.extra.mult * 10;
            card:start_dissolve(nil, true);
            return
        end
    end,
    calculate = function(self,card,context)
        if context.joker_main then
            return {
                card = card,
                mult = card.ability.extra.mult,
            }
        end
    end,
}

SMODS.Joker{
    key = 'radiomistake',
    loc_txt = {
        name = 'the best song to spend a night with',
        text = {
          'replaces the song with',
          '{C:void,s:1.2}Cbat by Hudson Mohawke',
          'multiplies own mult by {X:mult,C:white}#1#{}',
          'after every round',
          '{C:inactive}(currently {C:mult}+#2# mult{C:inactive})'
        },
    },
    atlas = 'Jokers', 
    rarity = 1,
    cost = 2,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 1},
    config = { 
      extra = {
        selfmult = 1.5,
        mult = 1,
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.selfmult,center.ability.extra.mult}}
    end,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Menance', HEX('ED96A6'), G.C.WHITE, 1)
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.n_ithoughtitwasfunny = true
    end,
    remove_from_deck = function(self, card, from_debuff)
		G.GAME.n_ithoughtitwasfunny = nil
	end,
    calculate = function(self,card,context)
        if context.joker_main then
            return {
                card = card,
                mult = card.ability.extra.mult,
            }
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition and not context.retrigger_joker then
            card.ability.extra.mult = card.ability.extra.mult * card.ability.extra.selfmult
        end
    end,
}

SMODS.Joker{
    key = 'onepiece',
    loc_txt = {
        name = 'The One Card',
        text = {
          'When only {C:attention,s:1.2}One{} card is played,',
          'level up {C:attention}High Card {}with a',
          '{C:green}#2# in #1#{} chance and {C:rainbow,E:1}repeats until failure',
          'while multipling the {C:green}required odds{} per repeat by {X:green,C:white}#3#',
          '{C:inactive,s:0.8}(Has a cap of 100 retries)',
          '{C:inactive,s:0.8}(Cannot be retriggered)'
        },
    },
    atlas = 'Jokers', 
    rarity = 3,
    cost = 11.34,
    unlocked = true,
    discovered = true, 
    blueprint_compat = false, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 3, y = 0},
    config = { 
      extra = {
        chance = 1.5,
        gain = 2
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.chance,G.GAME and G.GAME.probabilities.normal or 1,center.ability.extra.gain}}
    end,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Singular', HEX('525A65'), G.C.WHITE, 1)
    end,
    add_to_deck = function(self, card, from_debuff)
        local find = SMODS.find_card('j_ninehund_onepiece');
        if #find > 0 then
            SMODS.calculate_effect({ message = "There can only be ONE piece.", colour = G.C.MULT, instant = false}, find[1])
            find[1].ability.extra.gain = 1 + ((find[1].ability.extra.gain-1) * 0.5);
            card:start_dissolve(nil, true);
            return
        end
    end,
    calculate = function(self,card,context)
        if context.joker_main and #G.play.cards == 1 and not context.blueprint and not context.repetition then
            local epicfail = false
            local repeats = 0
            repeat
                if pseudorandom(pseudoseed('canwegetmuchhigher')) < G.GAME.probabilities.normal / (card.ability.extra.chance*(card.ability.extra.gain^repeats)) then
                    card:speak(G.GAME.probabilities.normal.." in "..(card.ability.extra.chance*(card.ability.extra.gain^repeats)),G.C.GREEN)
                    G.E_MANAGER:add_event(Event({
                        trigger = "before",
                        delay = 1,
                        func = function()
                            if math.random(1,20) == 1 then
                                play_sound('ninehund_scream', math.random(9,11)*0.1,0.5);
                                n_makeImage(
                                    "OPjumpscare","luffy",
                                    ninehund.constants.CS.x*(math.random(20,180)*0.01), ninehund.constants.CS.y*(math.random(20,180)*0.01), 0,
                                    1, 1,
                                    function(self)
                                        self.timer = self.timer + ninehund.dt
                                        if self.timer >= 0.2 then
                                           n_removeImage("OPjumpscare")
                                        end
                                    end,
                                    nil, nil, nil,
                                    {
                                        timer = 0,
                                    }
                                )
                            else
                                play_sound('ninehund_canweget', math.random(9,11)*0.1,0.5);
                            end
                            card:juice_up()
                            level_up_hand(card, 'High Card', true, 1)
                            return true
                        end
                    }))
                    repeats = repeats + 1
                else
                    epicfail = true
                end
            until epicfail or repeats >= 100
        end
    end,
}

SMODS.Joker{
    key = 'algebrajoker',
    loc_txt = {
        name = 'The Quadratic Equation',
        text = {
          'At the end of the round:',
          'Increase {C:attention}all numbered stats{} of the {C:attention}Joker to the left',
          'by using the {C:attention}stats{} from the {C:attention}Joker to the right{}.',
          'The {C:rainbow,E:1}quadratic equation{} will be used, with the',
          'variables {C:chips,s:1.2}a{} and {C:mult,s:1.2}b{} substituted by {C:attention}2 stat values{}',
          'along with {C:money,s:1.2}c{} substituted with the',
          '{C:money}sell cost{} of the selected Joker.',
          'The two results from the equation will be {C:attention}absolute',
          'and either one will randomly be chosen.',
          '{C:inactive}(b^2-4ac will be absolute to prevent imaginary numbers)',
          '{B:1,C:white,s:0.8}#1#{} {B:2,C:white,s:0.8}#2#{}',
          '{C:chips,s:1.5,E:1}a = #4# {C:mult,s:1.5,E:1}b = #5# {C:money,s:1.5,E:1}c = #6#',
          '{C:void,s:1.5,E:1}x = #3#'
        },
    },
    atlas = 'supernatural', 
    rarity = 'ninehund_super',
    cost = 99,
    unlocked = true,
    discovered = true, 
    blueprint_compat = false, 
    eternal_compat = true,
    perishable_compat = false, 
    pos = {x = 0, y = 1},
    soul_pos = {x = 1, y = 1, extra9 = {x = 2, y = 1}},
    config = { 
        extra = {
            leftJoker = {"??",G.C.VOID},
            rightJoker = {"??",G.C.VOID},
            calculation = nil,
      }
    },
    loc_vars = function(self,info_queue,center)
        if G.STAGE == G.STAGES.RUN then
            local left_joker, right_joker
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == center then
                    left_joker = G.jokers.cards[i - 1]
                    right_joker = G.jokers.cards[i + 1]
                end
            end

            if left_joker and left_joker ~= center then
                local compat = false
                if left_joker.ability.extra ~= nil and type(left_joker.ability.extra) ~= "nil" then
                    if type(left_joker.ability.extra) == "number" then
                        compat = true
                    elseif type(left_joker.ability.extra) == "table" then
                        for _, m in pairs(left_joker.ability.extra) do
                            if type(m) == "number" then
                                compat = true
                                break
                            end
                        end
                    end
                end
                if compat then 
                    center.ability.extra.leftJoker = {"compatible",G.C.GREEN}
                else
                    center.ability.extra.leftJoker = {"incompatible",G.C.RED}
                end
            else
                center.ability.extra.leftJoker = {"missing",G.C.GREY}
            end
            if right_joker and right_joker ~= center then
                local compat = 0
                if right_joker.ability.extra ~= nil and type(right_joker.ability.extra) ~= "nil" then
                    if type(right_joker.ability.extra) == "table" then
                        for _, m in pairs(right_joker.ability.extra) do
                            if type(m) == "number" then
                                compat = compat + 1
                            end
                        end
                    end
                end
                if compat > 1 then 
                    center.ability.extra.rightJoker = {"compatible",G.C.GREEN}
                else
                    center.ability.extra.rightJoker = {"incompatible",G.C.RED}
                end
            else
                center.ability.extra.rightJoker = {"missing",G.C.GREY}
            end

            if center.ability.extra.rightJoker[1] == "compatible" then
                local _a,_b
                local _c = right_joker.sell_cost
                local _lecount = 0
                for _, m in pairs(right_joker.ability.extra) do
                    if type(m) == "number" then
                        if _lecount == 0 then
                            _lecount = 1
                            _a = m
                        else
                            _b = m
                            break
                        end
                    end
                end
                center.ability.extra.calculation = {
                    math.abs((-_b + math.sqrt(math.abs((_b^2)-(4*_a*_c))))/(2*_a)),
                    math.abs((-_b - math.sqrt(math.abs((_b^2)-(4*_a*_c))))/(2*_a)),
                    _a,_b,_c
                }
            else
                center.ability.extra.calculation = nil
            end
        end
        return {vars = {
            center.ability.extra.leftJoker[1], center.ability.extra.rightJoker[1], 
            center.ability.extra.calculation and (center.ability.extra.calculation[1].." or "..center.ability.extra.calculation[2]) or "??",
            center.ability.extra.calculation and center.ability.extra.calculation[3] or "?",
            center.ability.extra.calculation and center.ability.extra.calculation[4] or "?",
            center.ability.extra.calculation and center.ability.extra.calculation[5] or "?",
            colours = {
                center.ability.extra.leftJoker[2],
                center.ability.extra.rightJoker[2]
            }
        }}
    end,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Singular', HEX('525A65'), G.C.WHITE, 1)
        badges[#badges+1] = create_badge('Antimatter', G.C.VOID, G.C.WHITE, 1)
    end,
    add_to_deck = function(self, card, from_debuff)
        card:set_eternal(true);
        G.jokers.config.card_limit = G.jokers.config.card_limit + 1
        local find = SMODS.find_card('j_ninehund_algebrajoker');
        if #find > 0 then
            SMODS.calculate_effect({ message = "Not Allowed Nincompoop!", colour = G.C.RED, instant = false}, find[1])
            local _card = create_card('Joker',G.jokers,nil,nil,nil,nil,'j_ninehund_eulerjoker');
            _card:add_to_deck()
            _card:start_materialize()
            G.jokers:emplace(_card)
            card:start_dissolve(nil, true);
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
	end,
    calculate = function(self,card,context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition and not context.retrigger_joker then
            local left_joker, right_joker
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    left_joker = G.jokers.cards[i - 1]
                    right_joker = G.jokers.cards[i + 1]
                end
            end

            if left_joker and left_joker ~= card then
                local compat = false
                if left_joker.ability.extra ~= nil and type(left_joker.ability.extra) ~= "nil" then
                    if type(left_joker.ability.extra) == "number" then
                        compat = true
                    elseif type(left_joker.ability.extra) == "table" then
                        for k, m in pairs(left_joker.ability.extra) do
                            if type(m) == "number" then
                                compat = true
                                break
                            end
                        end
                    end
                end
                if compat then 
                    card.ability.extra.leftJoker = {"compatible",G.C.GREEN}
                else
                    card.ability.extra.leftJoker = {"incompatible",G.C.RED}
                end
            else
                card.ability.extra.leftJoker = {"missing",G.C.GREY}
            end
            if right_joker and right_joker ~= card then
                local compat = 0
                if right_joker.ability.extra ~= nil and type(right_joker.ability.extra) ~= "nil" then
                    if type(right_joker.ability.extra) == "table" then
                        for _, m in pairs(right_joker.ability.extra) do
                            if type(m) == "number" then
                                compat = compat + 1
                            end
                        end
                    end
                end
                if compat > 1 then 
                    card.ability.extra.rightJoker = {"compatible",G.C.GREEN}
                else
                    card.ability.extra.rightJoker = {"incompatible",G.C.RED}
                end
            else
                card.ability.extra.rightJoker = {"missing",G.C.GREY}
            end

            if card.ability.extra.leftJoker[1] == "compatible" and card.ability.extra.rightJoker[1] == "compatible" then
                local _a,_b
                local _c = right_joker.sell_cost
                local _lecount = 0
                for _, m in pairs(right_joker.ability.extra) do
                    if type(m) == "number" then
                        if _lecount == 0 then
                            _lecount = 1
                            _a = m
                        else
                            _b = m
                            break
                        end
                    end
                end
                card.ability.extra.calculation = {
                    math.abs((-_b + math.sqrt(math.abs((_b^2)-(4*_a*_c))))/(2*_a)),
                    math.abs((-_b - math.sqrt(math.abs((_b^2)-(4*_a*_c))))/(2*_a)),
                    _a,_b,_c
                }

                local itisdecided = math.random(1,2)==1 and card.ability.extra.calculation[1] or card.ability.extra.calculation[2]
                if type(left_joker.ability.extra) == "number" then
                    left_joker.ability.extra = left_joker.ability.extra + itisdecided
                else
                    for k, m in pairs(left_joker.ability.extra) do
                        if type(m) == "number" then
                            compat = true
                            left_joker.ability.extra[k] = m + itisdecided
                        end
                    end
                end

                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 1,
                    func = function()
                        card:juice_up(4,4)
                        left_joker:juice_up()
                        right_joker:juice_up()
                        SMODS.calculate_effect({ message = "+"..itisdecided, colour = G.C.VOID, instant = true}, card)
                        play_sound('ninehund_algebra_intro', 1,0.75)
                        return true
                    end
                }))
            else
                card.ability.extra.calculation = nil
            end
        end
    end,
}

SMODS.Joker{
    key = 'eulerjoker',
    loc_txt = {
        name = "Euler's Identity",
        text = {
          'At the end of the round:',
          'Adds {C:void,s:1.2}#3#{} to {C:attention}all numbered',
          '{C:attention}stats{} to the {C:attention}Joker on the left',
          'by deducting {C:void,s:1.2}#3#{} from {C:attention}all numbered{}',
          '{C:attention}stats{} to the {C:attention}Joker on the right.',
          '{B:1,C:white,s:0.8}#1#{} {B:2,C:white,s:0.8}#2#{}',
        },
    },
    atlas = 'supernatural', 
    rarity = 'ninehund_super',
    cost = 99,
    unlocked = true,
    discovered = true, 
    blueprint_compat = false, 
    eternal_compat = true,
    perishable_compat = false, 
    pos = {x = 0, y = 2},
    soul_pos = {x = 1, y = 2, extra9 = {x = 2, y = 2}},
    config = { 
        extra = {
            leftJoker = {"??",G.C.VOID},
            rightJoker = {"??",G.C.VOID},
            calculation = 1,
      }
    },
    loc_vars = function(self,info_queue,center)
        if G.STAGE == G.STAGES.RUN then
            local left_joker, right_joker
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == center then
                    left_joker = G.jokers.cards[i - 1]
                    right_joker = G.jokers.cards[i + 1]
                end
            end

            if left_joker and left_joker ~= center then
                local compat = false
                if left_joker.ability.extra ~= nil and type(left_joker.ability.extra) ~= "nil" then
                    if type(left_joker.ability.extra) == "number" then
                        compat = true
                    elseif type(left_joker.ability.extra) == "table" then
                        for _, m in pairs(left_joker.ability.extra) do
                            if type(m) == "number" then
                                compat = true
                                break
                            end
                        end
                    end
                end
                if compat then 
                    center.ability.extra.leftJoker = {"compatible",G.C.GREEN}
                else
                    center.ability.extra.leftJoker = {"incompatible",G.C.RED}
                end
            else
                center.ability.extra.leftJoker = {"missing",G.C.GREY}
            end
            if right_joker and right_joker ~= center then
                local compat = 0
                if right_joker.ability.extra ~= nil and type(right_joker.ability.extra) ~= "nil" then
                    if type(right_joker.ability.extra) == "number" then
                        compat = true
                    elseif type(right_joker.ability.extra) == "table" then
                        for _, m in pairs(right_joker.ability.extra) do
                            if type(m) == "number" then
                                compat = true
                                break
                            end
                        end
                    end
                end
                if compat then 
                    center.ability.extra.rightJoker = {"compatible",G.C.GREEN}
                else
                    center.ability.extra.rightJoker = {"incompatible",G.C.RED}
                end
            else
                center.ability.extra.rightJoker = {"missing",G.C.GREY}
            end
        end
        return {vars = {
            center.ability.extra.leftJoker[1], center.ability.extra.rightJoker[1], 
            center.ability.extra.calculation,
            colours = {
                center.ability.extra.leftJoker[2],
                center.ability.extra.rightJoker[2]
            }
        }}
    end,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Singular', HEX('525A65'), G.C.WHITE, 1)
        badges[#badges+1] = create_badge('Antimatter', G.C.VOID, G.C.WHITE, 1)
    end,
    add_to_deck = function(self, card, from_debuff)
        card:set_eternal(true);
        G.jokers.config.card_limit = G.jokers.config.card_limit + 1
        local find = SMODS.find_card('j_ninehund_eulerjoker');
        if #find > 0 then
            SMODS.calculate_effect({ message = "Upgrade!", colour = G.C.PURPLE, instant = false}, find[1])
            find[1].ability.extra.calculation = find[1].ability.extra.calculation + 1
            card:start_dissolve(nil, true);
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
	end,
    calculate = function(self,card,context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition and not context.retrigger_joker then
            local left_joker, right_joker
            local toChange_left = {}
            local toChange_right = {}
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    left_joker = G.jokers.cards[i - 1]
                    right_joker = G.jokers.cards[i + 1]
                end
            end

            if left_joker and left_joker ~= card then
                local compat = false
                if left_joker.ability.extra ~= nil and type(left_joker.ability.extra) ~= "nil" then
                    if type(left_joker.ability.extra) == "number" then
                        compat = true
                    elseif type(left_joker.ability.extra) == "table" then
                        for k, m in pairs(left_joker.ability.extra) do
                            if type(m) == "number" then
                                compat = true
                                table.insert(toChange_left,k)
                            end
                        end
                    end
                end
                if compat then 
                    card.ability.extra.leftJoker = {"compatible",G.C.GREEN}
                else
                    card.ability.extra.leftJoker = {"incompatible",G.C.RED}
                end
            else
                card.ability.extra.leftJoker = {"missing",G.C.GREY}
            end
            if right_joker and right_joker ~= card then
                local compat = false
                if right_joker.ability.extra ~= nil and type(right_joker.ability.extra) ~= "nil" then
                    if type(right_joker.ability.extra) == "number" then
                        compat = true
                    elseif type(right_joker.ability.extra) == "table" then
                        for k, m in pairs(right_joker.ability.extra) do
                            if type(m) == "number" then
                                compat = true
                                table.insert(toChange_right,k)
                            end
                        end
                    end
                end
                if compat then 
                    card.ability.extra.rightJoker = {"compatible",G.C.GREEN}
                else
                    card.ability.extra.rightJoker = {"incompatible",G.C.RED}
                end
            else
                card.ability.extra.rightJoker = {"missing",G.C.GREY}
            end

            if card.ability.extra.leftJoker[1] == "compatible" and card.ability.extra.rightJoker[1] == "compatible" then
                if type(left_joker.ability.extra) == "number" then
                    left_joker.ability.extra = left_joker.ability.extra + card.ability.extra.calculation
                else
                    for k, m in pairs(left_joker.ability.extra) do
                        if type(m) == "number" then
                            compat = true
                            left_joker.ability.extra[k] = m + card.ability.extra.calculation
                        end
                    end
                end
                if type(right_joker.ability.extra) == "number" then
                    right_joker.ability.extra = right_joker.ability.extra - card.ability.extra.calculation
                else
                    for k, m in pairs(right_joker.ability.extra) do
                        if type(m) == "number" then
                            compat = true
                            right_joker.ability.extra[k] = m - card.ability.extra.calculation
                        end
                    end
                end

                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 1,
                    func = function()
                        card:juice_up(4,4)
                        left_joker:juice_up()
                        right_joker:juice_up()
                        SMODS.calculate_effect({ message = "+"..card.ability.extra.calculation, colour = G.C.GREEN, instant = true}, left_joker)
                        SMODS.calculate_effect({ message = "-"..card.ability.extra.calculation, colour = G.C.RED, instant = true}, right_joker)
                        play_sound('ninehund_algebra_intro', 1,0.75)
                        return true
                    end
                }))
            end
        end
    end,
}