SMODS.Back({
    key = "emptydeck",
    loc_txt = {
        name = "Raw Deck",
        text = {
            "{C:inactive}Playing cards have",
            "{C:inactive}not been printed yet...",
            "{C:inactive}Creates {C:dark_edition}Negative",
            "{C:attention}#1# Emprehant{C:inactive} cards",
            "{C:inactive}and {C:attention}#2# Loss{C:inactive} cards",
        },
    },
	config = {
        hands = 0, discards = 0, n_count = 2, n_nuke = 3
    },
	pos = { x = 0, y = 0 },
	atlas = "decks",
    unlocked = true,
    loc_vars = function (self, info_queue, card)
        return {vars = {
            self.config.n_count,
            self.config.n_nuke
        }}
    end,
	apply = function(self)
        local cards = {"A","K","Q","J","T","9","8","7","6","5","4","3","2"}
        local THEcard_protos = {}
        for _, c in pairs(cards) do
            for i=1,4 do
                table.insert(THEcard_protos,{
                    s = "ninehund_N",
                    r = c,
                    e = "m_ninehund_blankcard"
                })
            end
        end
        G.GAME.starting_params.n_deck = THEcard_protos
        G.E_MANAGER:add_event(Event({
			func = function()
				if G.consumeables then
                    for i=1,self.config.n_count do
                        local card = create_card(nil, G.consumeables, nil, nil, nil, nil, 'c_ninehund_emprehant')
                        card:set_edition("e_negative",true)
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                    end
                    for i=1,self.config.n_nuke do
                        local card = create_card(nil, G.consumeables, nil, nil, nil, nil, 'c_ninehund_fuckingnuke')
                        card:set_edition("e_negative",true)
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                    end
                    return true
                  end
			end,
		}))
	end,

	check_for_unlock = function(self, args)
        unlock_card(self)
	end,
})

SMODS.Back({
    key = "tycoondeck",
    loc_txt = {
        name = "Tycoon Deck",
        text = {
            "Start with {C:attention}Basic Iron Dropper{},",
            "{C:attention}Ore Purifier{}, and {C:attention}Basic Furnace{}",
            "{C:red}No discards"
        },
    },
	config = {
        hands = 0, discards = -100
    },
	pos = { x = 1, y = 0 },
	atlas = "decks",
    unlocked = true,
	apply = function(self)
        G.E_MANAGER:add_event(Event({
			func = function()
                local lejokers = {
                    "j_ninehund_tycoondropper",
                    "j_ninehund_tycoonupgrader_basic",
                    "j_ninehund_tycoonfurnace",
                }
				if G.jokers then
                    for i=1, #lejokers do
                        local card = create_card(nil, G.jokers, nil, nil, nil, nil, lejokers[i])
                        card:add_to_deck()
                        G.jokers:emplace(card)
                    end
                    return true
                  end
			end,
		}))
	end,

	check_for_unlock = function(self, args)
        unlock_card(self)
	end,
})

SMODS.Back({
    key = "blanddeck",
    loc_txt = {
        name = "Bland Deck",
        text = {
            "Deck only contains one",
            "set of cards of {C:void}Nothing"
        },
    },
	config = {
        hands = 0, discards = 0
    },
	pos = { x = 2, y = 0 },
	atlas = "decks",
    unlocked = true,
    apply = function(self)
        local cards = {"A","K","Q","J","T","9","8","7","6","5","4","3","2"}
        local THEcard_protos = {}
        for _, c in pairs(cards) do
            table.insert(THEcard_protos,{
                s = "ninehund_N",
                r = c
            })
        end
        G.GAME.starting_params.n_deck = THEcard_protos
    end,
	check_for_unlock = function(self, args)
        unlock_card(self)
	end,
})

SMODS.Back({
    key = "deltarunedeck",
    loc_txt = {
        name = "Sanctuary Deck",
        text = {
            "Start with a",
            "{C:void,E:1}Dark Fountain",
            "Playing cards have",
            "a {C:void,E:1}random edition"
        },
    },
	config = {
        hands = 0, discards = 0
    },
	pos = { x = 3, y = 0 },
	atlas = "decks",
    unlocked = true,
    apply = function(self)
        local randEditions = {}
        for e, t in pairs(G.P_CENTERS) do
            if t.set == "Edition" and t.name ~= "Base" then
                table.insert(randEditions,e)
            end
        end
        G.GAME.n_darkworld = true
        G.E_MANAGER:add_event(Event({
			func = function()
				if G.playing_cards then
                    for k, v in pairs(G.playing_cards) do
                        v:set_edition(pseudorandom_element(randEditions,pseudoseed('i_love_fucking_coding_balatro')),true,true)
                    end
                    return true
                  end
			end,
		}))
    end,
	check_for_unlock = function(self, args)
        unlock_card(self)
	end,
})

SMODS.Back({
    key = "onecarddeck",
    loc_txt = {
        name = "The One Card Deck",
        text = {
            "Deck only contains {C:blue,s:1.2}One Card",
            "{C:inactive,s:0.8}(Red Seal Polychrome ",
            "{C:inactive,s:0.8}Extra Bonus Ace of Hearts)",
            "Start with the {C:attention,s:1.2}The One Card{},",
            "{C:attention}Oops! All 6's{}, and {C:money}+$#1#",
        },
    },
	config = {
        hands = 0, discards = 0, dollars = 10
    },
	pos = { x = 4, y = 0 },
	atlas = "decks",
    unlocked = true,
    loc_vars = function (self, info_queue, card)
        return {vars = {
            self.config.dollars
        }}
    end,
    apply = function(self)
        G.GAME.starting_params.n_deck = {
            {
                s = "H",
                r = "A",
                e = "m_ninehund_multchip",
                d = "polychrome",
                g = "Red"
            }
        }
         G.E_MANAGER:add_event(Event({
			func = function()
				local lejokers = {
                    "j_ninehund_onepiece",
                    "j_oops"
                }
				if G.jokers then
                    for i=1, #lejokers do
                        local card = create_card(nil, G.jokers, nil, nil, nil, nil, lejokers[i])
                        card:add_to_deck()
                        G.jokers:emplace(card)
                    end
                    return true
                  end
			end,
		}))
    end,
	check_for_unlock = function(self, args)
        unlock_card(self)
	end,
})

SMODS.Back({
    key = "microdeck",
    loc_txt = {
        name = "Micromanagement Deck",
        text = {
            "Start with {C:attention}Euler's Identity",
            "{C:blue}#1# hands{} per round",
            "{C:red}#2# discards{} per round"
    }},
	config = {
        hands = -3, discards = 5,
    },
	pos = { x = 5, y = 0 },
	atlas = "decks",
    unlocked = true,
    loc_vars = function (self, info_queue, card)
        return {vars = {
            self.config.hands < 0 and self.config.hands or "+"..self.config.hands,
            self.config.discards < 0 and self.config.discards or "+"..self.config.discards,
        }}
    end,
    apply = function(self)
         G.E_MANAGER:add_event(Event({
			func = function()
				if G.jokers then
                    local card = create_card(nil, G.jokers, nil, nil, nil, nil, "j_ninehund_eulerjoker")
                    card:add_to_deck()
                    G.jokers:emplace(card)
                    return true
                end
			end,
		}))
    end,
	check_for_unlock = function(self, args)
        unlock_card(self)
	end,
})

if CardSleeves then
    CardSleeves.Sleeve {
        key = "emptysleeve",
        atlas = "sleeves",
        pos = { x = 0, y = 0 },
        config = { alt = false },
        loc_vars = function(self)
            local key
            if self.get_current_deck_key() == "b_ninehund_emptydeck" then
                key = self.key .. "_alt"
                self.config = { alt = true }
            else
                key = self.key
                self.config = { alt = false }
            end
            return {key = key}
        end,
        apply = function(self)
            if self.config.alt then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        if G.jokers then
                            local card = create_card(nil, G.jokers, nil, nil, nil, nil, "j_ninehund_crk_mysticflour")
                            card:add_to_deck()
                            G.jokers:emplace(card)
                            return true
                        end
                    end,
                }))
            else
                G.E_MANAGER:add_event(Event({
                    func = function()
                        if G.playing_cards then
                            for k, v in pairs(G.playing_cards) do
                                v:set_ability(G.P_CENTERS.m_ninehund_blankcard)
                            end
                            return true
                        end
                    end
                }))
            end
        end
    }

    CardSleeves.Sleeve {
        key = "tycoonsleeve",
        atlas = "sleeves",
        pos = { x = 1, y = 0 },
        config = { discards = -100, alt = false },
        loc_vars = function(self)
            local key
            if self.get_current_deck_key() == "b_ninehund_tycoondeck" then
                key = self.key .. "_alt"
                self.config = { alt = true }
            else
                key = self.key
                self.config = { alt = false, discards = -100 }
            end
            return {key = key}
        end,
        apply = function(self)
            local lejokers = {
                        "j_ninehund_tycoondropper",
                        "j_ninehund_tycoonupgrader_basic",
                        "j_ninehund_tycoonfurnace",
                    }
            if self.config.alt then
                lejokers = {
                    "j_ninehund_tycoondropper",
                    "j_ninehund_tycoonfurnace",
                }
            end
            G.E_MANAGER:add_event(Event({
                func = function()
                    if G.jokers then
                        for i=1, #lejokers do
                            local card = create_card(nil, G.jokers, nil, nil, nil, nil, lejokers[i])
                            card:add_to_deck()
                            G.jokers:emplace(card)
                        end
                        return true
                    end
                end,
            }))
        end
    }

    CardSleeves.Sleeve {
        key = "blandsleeve",
        atlas = "sleeves",
        pos = { x = 2, y = 0 },
        config = { alt = false },
        loc_vars = function(self)
            local key
            if self.get_current_deck_key() == "b_ninehund_blanddeck" then
                key = self.key .. "_alt"
                self.config = { alt = true }
            else
                key = self.key
                self.config = { alt = false }
            end
            return {key = key}
        end,
        apply = function(self)
            G.E_MANAGER:add_event(Event({
                func = function()
                    if G.playing_cards then
                        for k, v in pairs(G.playing_cards) do
                            SMODS.change_base(v,'ninehund_nosuit')
                        end
                        return true
                    end
                end
            }))
        end
    }

    CardSleeves.Sleeve {
        key = "deltarunesleeve",
        atlas = "sleeves",
        pos = { x = 3, y = 0 },
        config = { alt = false },
        loc_vars = function(self)
            local key
            if self.get_current_deck_key() == "b_ninehund_deltarunedeck" then
                key = self.key .. "_alt"
                self.config = { alt = true }
            else
                key = self.key
                self.config = { alt = false }
            end
            return {key = key}
        end,
        apply = function(self)
            if self.config.alt then
                local randEnhancers = {}
                for e, t in pairs(G.P_CENTERS) do
                    if t.set == "Enhanced" then
                        table.insert(randEnhancers,e)
                    end
                end
                G.E_MANAGER:add_event(Event({
                    func = function()
                        if G.playing_cards then
                            for k, v in pairs(G.playing_cards) do
                                v:set_ability(pseudorandom_element(randEnhancers,pseudoseed('reference_no_way')),true,true)
                            end
                            return true
                        end
                    end,
                }))
            else
                local randEditions = {}
                for e, t in pairs(G.P_CENTERS) do
                    if t.set == "Edition" and t.name ~= "Base" then
                        table.insert(randEditions,e)
                    end
                end
                G.GAME.n_darkworld = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        if G.playing_cards then
                            for k, v in pairs(G.playing_cards) do
                                v:set_edition(pseudorandom_element(randEditions,pseudoseed('i_love_fucking_coding_balatro')),true,true)
                            end
                            return true
                        end
                    end,
                }))
            end
        end
    }

    CardSleeves.Sleeve {
        key = "onecardsleeve",
        atlas = "sleeves",
        pos = { x = 4, y = 0 },
        config = { alt = false , dollars = 10},
        loc_vars = function(self)
            local key
            if self.get_current_deck_key() == "b_ninehund_onecarddeck" then
                key = self.key .. "_alt"
                self.config = { alt = true }
            else
                key = self.key
                self.config = { alt = false , dollars = 10}
            end
            return {key = key, vars = { self.config.dollars }}
        end,
        apply = function(self)
            if self.config.alt then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        if G.jokers then
                            for i=1, 5 do
                                local card = create_card(nil, G.jokers, nil, nil, nil, nil, "j_ninehund_onepiece")
                                card:add_to_deck()
                                G.jokers:emplace(card)
                            end
                            return true
                        end
                    end,
                }))
            else
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local lejokers = {
                            "j_ninehund_onepiece",
                            "j_oops"
                        }
                        if G.jokers and G.playing_cards then
                            local chosenone = G.playing_cards[math.random(1,#G.playing_cards)]
                            for k, v in pairs(G.playing_cards) do
                                if v ~= chosenone then
                                    v:start_dissolve(nil,true)
                                end
                            end
                            for i=1, #lejokers do
                                local card = create_card(nil, G.jokers, nil, nil, nil, nil, lejokers[i])
                                card:add_to_deck()
                                G.jokers:emplace(card)
                            end
                            ease_dollars(self.config.dollars)
                            return true
                        end
                    end,
                }))
            end
        end
    }
end