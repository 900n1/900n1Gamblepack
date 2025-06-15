SMODS.Consumable{
    key = 'deaikh',
    set = 'amalgams',
    loc_txt = {
        name = 'Deaikh',
        text = {
          'Convert the {C:attention}leftmost{} Joker into the {C:attention}rightmost{} Joker',
          '{C:inactive}(Weird how this works right?)',
        },
    },
    atlas = 'amalgam', 
    cost = 4,
    unlocked = true,
    discovered = true, 
    pos = {x = 1, y = 0},
    config = {},
    can_use = function(self,card)
        if G and G.jokers then
            if G.jokers.cards[1] ~= nil and G.jokers.cards[#G.jokers.cards] ~= nil and #G.jokers.cards >= 2 then
                return true
            end
        end
        return false
    end,
    use = function(self,card,area,copier)
        G.jokers.cards[1]:start_dissolve(nil, true)
        local _card = copy_card(G.jokers.cards[#G.jokers.cards])
        _card:add_to_deck()
        _card:start_materialize()
        G.jokers:emplace(_card)
    end,
}

SMODS.Consumable{
    key = 'emprehant',
    set = 'amalgams',
    loc_txt = {
        name = 'Emprehant',
        text = {
          'Enhances {C:attention}#1#{} selected',
          'cards into {C:attention}Extra Bonus Cards{}',
        },
    },
    atlas = 'amalgam', 
    cost = 4,
    unlocked = true,
    discovered = true, 
    pos = {x = 3, y = 1},
    config = { extra = { count = 2 } },
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.m_ninehund_multchip
        return {vars = {center.ability.extra.count}}
    end,
    can_use = function(self,card)
        return (#G.hand.highlighted <= card.ability.extra.count and #G.hand.highlighted > 0)
    end,
    use = function(self,card,area,copier)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.5,
            func = function()
                play_sound('tarot1', 1,1)
                card:juice_up()
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do --flips cards
            local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip();
                    play_sound('card1', percent);
                    G.hand.highlighted[i]:juice_up(0.3, 0.3);
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do --unflips cards
            local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                     G.hand.highlighted[i]:flip();
                     G.hand.highlighted[i]:set_ability(G.P_CENTERS.m_ninehund_multchip);
                     play_sound('tarot2', percent, 0.6);
                     G.hand.highlighted[i]:juice_up(0.3, 0.3);
                     return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all();
            return true
        end })) --unselects cards
        delay(0.5)
    end,
}

SMODS.Consumable{
    key = 'fuckingnuke',
    set = 'Tarot',
    loc_txt = {
        name = 'Loss',
        text = {
          'Go on, {E:1}take a guess on what it does.{}',
          '{C:green}#1# in 10 chance.'
        },
    },
    atlas = 'custom', 
    cost = 2,
    unlocked = true,
    discovered = true, 
    pos = {x = 1, y = 0},
    config = {},
    loc_vars = function(self,info_queue,center)
        return {vars = {G.GAME.probabilities.normal}}
    end,
    can_use = function(self,card)
        return (#G.hand.cards >= 1)
    end,
    use = function(self,card,area,copier)
        for o = 1, 60 do
            G.E_MANAGER:add_event(Event({
                trigger = "before",
                delay = 1/o,
                func = function()
                    card:juice_up(o/100,o/100)
                    play_sound('tarot1', 1.2 * (o/20),1)
                    return true
                end
            })) 
        end
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.2,
            func = function()
                display_image({x=0,y=0}, "ninehund_whitescreen", {x = 0, y = 0, sx = 32, sy = 18}, 1)
                play_sound('ninehund_boom',0.5)
                G.ROOM.jiggle = 100
                for k = 1, #G.hand.cards do
                    if pseudorandom(pseudoseed('wild')) < G.GAME.probabilities.normal / 10 then
                        G.hand.cards[k]:set_edition("e_negative",true);
                    else
                        G.hand.cards[k]:start_dissolve(nil, true);
                    end
                end
                return true
            end
        })) 
    end,
}

SMODS.Consumable{
    key = 'construct',
    set = 'Spectral',
    loc_txt = {
        name = 'Construct',
        text = {
          'Combines {C:attention}#1#{} selected',
          'cards into a {C:attention}Sandwich{}',
        },
    },
    atlas = 'custom', 
    cost = 8,
    unlocked = true,
    discovered = true, 
    pos = {x = 0, y = 0},
    config = { extra = { count = 5 } },
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.m_ninehund_sandwichcard
        return {vars = {center.ability.extra.count}}
    end,
    can_use = function(self,card)
        return (#G.hand.highlighted <= card.ability.extra.count and #G.hand.highlighted > 1)
    end,
    use = function(self,card,area,copier)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.5,
            func = function()
                play_sound('tarot1', 1,1)
                card:juice_up()
                return true
            end
        }))
        local _cardsets = {};
        for i = 1, #G.hand.highlighted do --flips cards
            _cardsets[i] = {
                G.hand.highlighted[i]:getS_R(),
                SMODS.get_enhancements(G.hand.highlighted[i]),
                G.hand.highlighted[i].edition,
                G.hand.highlighted[i].seal
            };
            local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip();
                    play_sound('card1', percent);
                    return true
                end
            }))
        end
        delay(0.2)
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.2,
            func = function()
                for i = 1, #G.hand.highlighted do
                    G.hand.highlighted[i]:start_dissolve(nil, true);
                end
            return true
        end }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                local _sandwich = make_card("H_2", "m_ninehund_sandwichcard", G.hand, nil, G.C.SECONDARY_SET.Spectral)
                _sandwich.ability["Scards"] = _cardsets;
            return true
        end }))
        delay(0.5)
        if G.GAME.used_vouchers['v_ninehund_sandwichfunc'] == nil then
            local lacard = Card(area.T.x + area.T.w/2 - G.CARD_W/2, area.T.y + area.T.h/2-G.CARD_H/2, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS["v_ninehund_sandwichfunc"],{bypass_discovery_center = true, bypass_discovery_ui = true})
            lacard.cost=0
            lacard.shop_voucher=false
            lacard:redeem()
            G.E_MANAGER:add_event(Event({
                delay = 0,
                func = function() 
                    lacard:start_dissolve()
                return true
            end}))
        end
    end,
}

ninehund.bossblindtable = {
    {
        key = 'bl_ninehund_asriel',
        sprite = {
            name = 'asrielshrug',
            sx = 0, sy = 4,
            func = function(self)
                self.id = self.id + (1*ninehund.dt)
                self.y = (ninehund.constants.CS.y) + (math.cos(self.id*2)*20)
                self.frame = n_nextFrame(self.totalframes,6,self.id)
                if ninehund.VH.d == 3 then
                    self.sx = lerp(self.sx,1.5,10*ninehund.dt)
                    self.sy = lerp(self.sy,1.5,10*ninehund.dt)
                elseif ninehund.VH.d == 4 then
                    self.sx = lerp(self.sx,0,10*ninehund.dt)
                    self.sy = lerp(self.sy,10,10*ninehund.dt)
                    if self.sx < 0.01 then
                        n_removeImage("lol",true)
                    end
                end
            end, 
            sheet = {
                frames = 4,
                px = 207, py = 240
            }
        },
        sound = function()
            play_sound('ninehund_asriel_goner', 1,0.5);
        end
    }
}

SMODS.Consumable{
    key = 'undertaleref',
    set = 'Tarot',
    loc_txt = {
        name = 'Barrier',
        text = {
          'Randomly summons a',
          '{E:1,C:rainbow} Special Boss Blind'
        },
    },
    atlas = 'custom', 
    cost = 2,
    unlocked = true,
    discovered = true, 
    pos = {x = 2, y = 0},
    config = {},
    can_use = function(self,card)
        return not G.GAME.blind.in_blind and not G.P_BLINDS[G.GAME.round_resets.blind_choices.Boss].no_reroll
    end,
    use = function(self,card,area,copier)
        local chosenboss = pseudorandom_element(ninehund.bossblindtable,pseudoseed('barrier'))
        ninehund.VH.a = 1000
        ninehund.VH.b = 2
        ninehund.VH.c = 1
        ninehund.VH.d = 0
        G.GAME.nine_musicspeed = 0.5
        n_makeImage(
            "souls","balatroblindsouls",
            ninehund.constants.CS.x, ninehund.constants.CS.y, 0,
            3, 3,
            function(self)
                ninehund.VH.c = ninehund.VH.c + ninehund.dt
                if ninehund.VH.d == 0 then
                    ninehund.VH.a = lerp(ninehund.VH.a,200,2*ninehund.dt)
                    ninehund.VH.b = lerp(ninehund.VH.b,1,0.2*ninehund.dt)
                    G.ROOM.jiggle = 0.5
                    if ninehund.VH.a < 210 then
                        ninehund.VH.d = 1
                    end
                elseif ninehund.VH.d == 1 then
                    ninehund.VH.a = lerp(ninehund.VH.a,0,0.2*ninehund.dt)
                    ninehund.VH.b = ninehund.VH.b * (1 + (0.3*ninehund.dt))
                    G.ROOM.jiggle = 3
                    if ninehund.VH.a < 100 then
                        ninehund.VH.d = 2
                    end
                elseif ninehund.VH.d == 2 then
                    ninehund.VH.a = lerp(ninehund.VH.a,0,2*ninehund.dt)
                    ninehund.VH.b = ninehund.VH.b * (1 + (0.3*ninehund.dt))
                    G.ROOM.jiggle = 10
                    if ninehund.VH.a < 10 then
                        ninehund.VH.d = 3
                        G.ROOM.jiggle = 35
                    end
                elseif ninehund.VH.d == 3 then
                    ninehund.VH.a = lerp(ninehund.VH.a,1000,ninehund.dt)
                    ninehund.VH.b = ninehund.VH.b * (1 + (0.3*ninehund.dt))
                    self.alpha = lerp(self.alpha,0,2*ninehund.dt)
                    self.sx = lerp(self.sx,10,2*ninehund.dt)
                    self.sy = lerp(self.sy,10,2*ninehund.dt)
                    if ninehund.VH.a > 900 then
                        ninehund.VH.d = 4
                    end
                end
            end,
            true, 1,
            {
                frames = 7,
                px = 34, py = 34
            }
        )

        for i=2, 7 do 
            n_makeImage(
                "souls","balatroblindsouls",
                ninehund.constants.CS.x, ninehund.constants.CS.y, 0,
                3, 3,
                function(self)
                    self.x = (ninehund.constants.CS.x) + (math.sin((ninehund.VH.c * ninehund.VH.b) + ((self.id / 6) * 2 * math.pi))*ninehund.VH.a)
                    self.y = (ninehund.constants.CS.y) + (math.cos((ninehund.VH.c * ninehund.VH.b) + ((self.id / 6) * 2 * math.pi))*-ninehund.VH.a)
                end,
                true, i,
                {
                    frames = 7,
                    px = 34, py = 34
                },
                {
                    id = i - 1
                }
            )
        end
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.2,
            func = function()
                play_sound('introPad1',1,1)
                play_sound('splash_buildup',3,0.5)
                force_set_blind(chosenboss.key);
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.2,
            func = function()
                if ninehund.VH.d == 3 then
                    play_sound('whoosh_long',1,1)
                    play_sound('explosion_release1',1,0.5)
                    play_sound('magic_crumple2',1,2)
                    play_sound('ninehund_boom',0.8)
                    n_makeImage(
                        "blindshow",chosenboss.sprite.name,
                        ninehund.constants.CS.x, ninehund.constants.CS.y, 0,
                        chosenboss.sprite.sx, chosenboss.sprite.sy,
                        chosenboss.sprite.func,
                        true, 1,
                        chosenboss.sprite.sheet,
                        {
                            id = 0
                        }
                    )
                    chosenboss.sound()
                    return true
                end
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.2,
            func = function()
                if ninehund.VH.d == 4 then
                    G.GAME.nine_musicspeed = 1
                    return true
                end
            end
        }))
    end,
}

SMODS.Consumable{
    key = 'krisknife',
    set = 'nine_items',
    loc_txt = {
        name = "Kris' Knife",
        text = {
          'Opens a {C:void,S:1}Dark Fountain{}.'
        },
    },
    atlas = 'itemCards', 
    cost = 8,
    unlocked = true,
    discovered = true, 
    pos = {x = 0, y = 0},
    soul_pos = {x = 0, y = 1},
    config = {},
    can_use = function(self,card)
        return not G.GAME.blind.in_blind and not G.P_BLINDS[G.GAME.round_resets.blind_choices.Boss].no_reroll
    end,
    use = function(self,card,area,copier)
        card.children.floating_sprite:set_sprite_pos({x=10,y=10})
    end,
}
