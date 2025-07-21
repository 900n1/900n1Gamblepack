SMODS.Tag{
    key = 'starwalker',
    loc_txt= {
        name = 'The Original',
        text = { 
            "{C:money}Starwalker"
        }
    },
    atlas = 'tags',
    pos = {x = 0, y = 0},
    in_pool = function(self, args)
        return G.GAME.n_darkworld
    end,
    apply = function(self, tag, context)
        tag:yep('+', G.C.MONEY, function()
            local _card = create_card('Joker',G.jokers,nil,nil,nil,nil,'j_ninehund_starwalker');
            _card:add_to_deck()
            _card:start_materialize()
            G.jokers:emplace(_card)
            return true
        end)
        tag.triggered = true
    end,
}

SMODS.Tag{
    key = 'polychromify',
    loc_txt= {
        name = 'Polychromify Tag',
        text = { 
            "A {C:attention}random Joker{} with no {C:dark_edition}Edition{}",
            "will turn {C:rainbow}Polychrome{}"
        }
    },
    atlas = 'tags',
    pos = {x = 1, y = 0},
    apply = function(self, tag, context)
        tag:yep('><', G.C.RAINBOW, function()
            local thelist = {}
            for _, j in pairs(G.jokers.cards) do
                if j.edition == nil then
                    table.insert(thelist,j)
                end
            end
            if #thelist > 0 then
                pseudorandom_element(thelist,pseudoseed('tag')):set_edition("e_polychrome",true)
            end
            return true
        end)
        tag.triggered = true
    end,
}

SMODS.Tag{
    key = 'antimattertag',
    loc_txt= {
        name = 'Antimatter Tag',
        text = { 
            "A {C:attention}random Joker{} with no {C:dark_edition}Edition{}",
            "will turn {C:void}Negative{}"
        }
    },
    atlas = 'tags',
    pos = {x = 2, y = 0},
    apply = function(self, tag, context)
        tag:yep('><', G.C.RAINBOW, function()
            local thelist = {}
            for _, j in pairs(G.jokers.cards) do
                if j.edition == nil then
                    table.insert(thelist,j)
                end
            end
            if #thelist > 0 then
                pseudorandom_element(thelist,pseudoseed('tag')):set_edition("e_negative",true)
            end
            return true
        end)
        tag.triggered = true
    end,
}

SMODS.Tag{
    key = 'sandwichtag',
    loc_txt= {
        name = 'Sandwich Tag',
        text = { 
            "Creates a {C:dark_edition}Construct"
        }
    },
    atlas = 'tags',
    pos = {x = 3, y = 0},
    apply = function(self, tag, context)
        tag:yep('+', G.C.DARK_EDITION, function()
            local card = create_card(nil, G.consumeables, nil, nil, nil, nil, 'c_ninehund_construct')
            card:add_to_deck()
            G.consumeables:emplace(card)
            return true
        end)
        tag.triggered = true
    end,
}

SMODS.Tag{
    key = 'healing',
    loc_txt= {
        name = 'Healing Tag',
        text = { 
            "{C:green}Heals{} all cards",
            "in deck for {C:white,X:green}2"
        }
    },
    atlas = 'tags',
    pos = {x = 4, y = 0},
    apply = function(self, tag, context)
        tag:yep('+', G.C.GREEN, function()
            for _, v in pairs(G.playing_cards) do
                v:heal_card(2,nil,true)
            end
            return true
        end)
        tag.triggered = true
    end,
}