--ASRIEL
local asriel_attacks = {
    function()
        display_anim({x=40,y=-40}, "ninehund_att_light", {x=13,y=9}, 0.5)
        for i=1, #G.hand.cards do
            if i % 2 == 0 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.4,
                    func = function()
                        G.hand.cards[i]:damage_card(2);
                        G.ROOM.jiggle = 2
                        play_sound('ninehund_asriel_light', math.random(9,12)*0.1,0.2);
                    return true
                    end
                }))
            end
        end
    end,
    function()
        display_anim({x=0,y=-40}, "ninehund_att_light", {x=-13,y=9}, 0.5)
        for i=#G.hand.cards, 1, -1 do
            if i % 2 == 0 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.4,
                    func = function()
                        G.hand.cards[i]:damage_card(2);
                        G.ROOM.jiggle = 2
                        play_sound('ninehund_asriel_light', math.random(9,12)*0.1,0.2);
                    return true
                    end
                }))
            end
        end
    end,
    function()
        display_anim({x=20,y=0}, "ninehund_att_slash", {x=-8,y=12}, 0.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.4,
            func = function()
                play_sound('ninehund_asriel_swipe', math.random(9,11)*0.1,0.5);
                for i=1, math.floor(#G.hand.cards/2) do
                    G.hand.cards[i]:damage_card(2);
                    G.ROOM.jiggle = 2
                end
                return true
            end
        }))
    end,
    function()
        display_anim({x=50,y=0}, "ninehund_att_slash", {x=8,y=12}, 0.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.4,
            func = function()
                play_sound('ninehund_asriel_swipe', math.random(9,11)*0.1,0.5);
                for i=#G.hand.cards,math.floor((#G.hand.cards/2)+0.5), -1  do
                    G.hand.cards[i]:damage_card(2);
                    G.ROOM.jiggle = 2
                end
                return true
            end
        }))
    end,
    function()
        play_sound('ninehund_asriel_star', math.random(9,11)*0.1,0.5);
        display_anim({x=math.random(-100,100),y=0}, "ninehund_att_star", {x=8,y=8}, 0.1)
        G.ROOM.jiggle = 4
        for i=1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    play_sound('ninehund_asriel_hit', math.random(9,11)*0.1,0.5);
                    pseudorandom_element(G.hand.cards, pseudoseed('attack')):damage_card(2);
                    return true
                end
            }))
        end
    end,
}

SMODS.Blind	{
    key = 'asriel',
    loc_txt = {
        name = 'God of HYPERDEATH',
        text = { 
            "It's the end, isn't it?"
        }
    },
    boss = {min = 8, max = 64, showdown = true},
    boss_colour = HEX("273133"),
    atlas = "asriel",
    pos = {x = 0, y = 0},
    vars = {},
    dollars = 20,
    no_debuff = true,
    descriptions = {
        "ninehund_bdesc_boss",
        "ninehund_bdesc_gift",
        "ninehund_bdesc_asriel"
    },
    mult = 6,
    remaining_hits = 6,
    starting = true,
    ending = false,
    finalatt = false,
    set_blind = function(self)
        self.remaining_hits = 6
        self.starting = true
        self.ending = false
        self.finalatt = false
        local find = find_joker('j_ninehund_asrieljoker');
        if #find > 0 then
            for _, f in pairs(find) do
                SMODS.debuff_card(f,true,"asriel")
            end
        end
    end,
    drawn_to_hand = function(self)
        if self.starting then
            self.starting = false;
        elseif self.finalatt then
            self.finalatt = false;
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    play_sound('ninehund_asriel_goner', 1,0.5);
                    display_anim({x=0,y=0}, "ninehund_att_goner", {x=32,y=18}, 3, true)
                    change_blind_size(to_big(G.GAME.blind.chips)*to_big(10))
                    for i=1, #G.hand.cards do
                        G.hand.cards[i]:damage_card(0);
                    end
                    return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                timer = "REAL",
                delay = 2.5,
                func = function()
                    display_image({x=0,y=0}, "ninehund_whitescreen", {x = 0, y = 0, sx = 32, sy = 18}, 0)
                    play_sound('ninehund_und_flash', 0.6,0.5);
                    for i=1, #G.hand.cards do
                        G.hand.cards[i].ability.health = 1;
                    end
                    return true
                end
            }))
        else
            pseudorandom_element(asriel_attacks, pseudoseed('attack'))();
        end
    end,
    defeat = function(self)
        G.GAME.nine_musicspeed = 1;
        local find = find_joker('j_ninehund_asrieljoker',true);
        if #find > 0 then
            for _, f in pairs(find) do
                SMODS.debuff_card(f,false,"asriel")
            end
        end
        local _card = create_card('Joker',G.jokers,nil,nil,nil,nil,'j_ninehund_asrieljoker');
        _card:add_to_deck()
        _card:start_materialize()
        G.jokers:emplace(_card)
    end,
    cap_score = function(self, score, deco)
        if not deco then
            if score >= G.GAME.blind.chips and self.remaining_hits > 1 then
                self.remaining_hits = self.remaining_hits - 1
                G.GAME.blind:juice_up(2,2)
                ease_hands_played(math.max(0, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands) - G.GAME.current_round.hands_left,true);
                ease_discard(math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards) - G.GAME.current_round.discards_left,true);
                ease_chips(0);
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.1,
                    blockable = true,
                    func = function()
                        if self.remaining_hits <= 1 then
                            self.ending = true
                            self.finalatt = true
                        end
                        play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                        display_image({x=0,y=0}, "ninehund_whitescreen", {x = 0, y = 0, sx = 32, sy = 18}, 0)
                        return true
                    end
                })) 
                for o = 1, 20 do
                    G.E_MANAGER:add_event(Event({
                        trigger = "before",
                        delay = o*0.01,
                        func = function()
                            ease_background_colour({new_colour = hsvToRgb(((o/3)+(self.remaining_hits*3))/20,1,(20/o)/20,1), special_colour = hsvToRgb(((o/3)+(self.remaining_hits*6))/20,1,1,1), contrast = 2})
                            G.ROOM.jiggle = 20/o
                            return true
                        end
                    })) 
                end
                play_area_status_text(self.remaining_hits.." out of 6 left.", false, 2);
                refresh_deck();
            elseif self.remaining_hits <= 1 then
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.1,
                    blockable = true,
                    func = function()
                        if (to_big(G.GAME.chips) + to_big(score)) >= to_big(G.GAME.blind.chips) then
                            display_image({x=0,y=0}, "ninehund_whitescreen", {x = 0, y = 0, sx = 32, sy = 18}, 1)
                            play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                            self.ending = false;
                            G.GAME.nine_musicspeed = 0.01;
                        end
                        return true
                    end
                })) 
                return score
            else
                play_area_status_text("MISS", false, 2);
            end
        end
        return 0
    end,
}

SMODS.Blind	{
    key = 'fear',
    loc_txt = {
        name = 'FEAR',
        text = { 
            "All I did... was try to save you..."
        }
    },
    boss = {min = -9999, max = -9999, showdown = true},
    boss_colour = HEX("45105A"),
    atlas = "blocktales_blinds",
    pos = {x = 0, y = 2},
    vars = {},
    dollars = 7,
    no_debuff = true,
    no_reroll = true,
    descriptions = {
        "ninehund_bdesc_boss",
        "ninehund_bdesc_mysteryunlock",
        "ninehund_bdesc_noreroll",
        "ninehund_bdesc_fear"
    },
    mult = 6,
    remaining_hits = 3,
    resetting = false,
    ending = false,
    set_blind = function(self)
        self.remaining_hits = 3
        self.resetting = false
        self.ending = false
        for k,v in pairs(G.jokers.cards) do
            v:flip()
        end
        n_makeImage(
            "blindeffect","feareffect",
            ninehund.constants.CS.x, ninehund.constants.CS.y, 0,
            6, 6,
            function(self)
                if G.GAME.blind.config.blind.ending then
                    self.alpha = lerp(self.alpha,0,2*ninehund.dt)
                else
                    self.alpha = lerp(self.alpha,1,0.05*ninehund.dt)
                end
                self.frame = n_nextFrame(4,4,G.TIMERS.REAL)
            end,
            true, 1,
            {
                frames = 4,
                px = 320, py = 180
            },
            {
                alpha = 0
            }
        )
    end,
    defeat = function(self)
        G.GAME.nine_musicspeed = 1;
        for k,v in pairs(G.jokers.cards) do
            SMODS.debuff_card(v,false,"fear")
        end
        n_removeImage('blindeffect')
    end,
    cap_score = function(self, score, deco)
        if not deco then
            if to_big(score) + to_big(G.GAME.chips) >= G.GAME.blind.chips and self.remaining_hits > 1 then
                self.remaining_hits = self.remaining_hits - 1
                self.resetting = true
                G.GAME.blind:juice_up(2,2)
                ease_hands_played(math.max(0, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands) - G.GAME.current_round.hands_left,true);
                ease_discard(math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards) - G.GAME.current_round.discards_left,true);
                ease_chips(0);
                play_area_status_text(self.remaining_hits.." out of 3 left.", false, 2);
                refresh_deck();
                return 0
            elseif self.remaining_hits <= 1 then
                if (to_big(G.GAME.chips) + to_big(score)) >= to_big(G.GAME.blind.chips) then
                    self.ending = true;
                    G.E_MANAGER:add_event(Event({
                        trigger = "before",
                        delay = 0.1,
                        blockable = true,
                        func = function()
                                display_image({x=0,y=0}, "ninehund_whitescreen", {x = 0, y = 0, sx = 32, sy = 18}, 1)
                                play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                                G.GAME.nine_musicspeed = 0;
                            return true
                        end
                    })) 
                end
            end
        end
        return score
    end,
    drawn_to_hand = function(self)
        if self.resetting then
            self.resetting = false;
            ease_chips(0);
        end
    end,
    stay_flipped = function(self, area, card)
        return true
    end,
    press_play = function(self)
        for k,v in pairs(G.jokers.cards) do
            SMODS.debuff_card(v,false,"fear")
        end
        local currentjokers = {}
        for k, v in ipairs(G.jokers.cards) do currentjokers[#currentjokers+1] = v end
        local chosenjokers = {}
        pseudoshuffle(currentjokers, pseudoseed('attack'))
        for i=1, math.max(1,math.floor(#currentjokers/4)) do
            chosenjokers[i] = currentjokers[i]
        end
        for k, v in pairs(chosenjokers) do
            SMODS.debuff_card(v,true,"fear")
        end
    end,
    on_click = function(self, x, y)
        if G.CONTROLLER.hovering.target and G.CONTROLLER.hovering.target.config.center ~= nil then
            if G.CONTROLLER.hovering.target.config.center.set == "Default" then
                pseudoshuffle(G.hand.cards,pseudoseed('lmao'))
            end
        end
    end
}

SMODS.Blind	{
    key = 'greed',
    loc_txt = {
        name = 'GREED',
        text = { 
            "You really fell for it!"
        }
    },
    boss = {min = -9999, max = -9999, showdown = true},
    boss_colour = HEX("C8A24A"),
    atlas = "blocktales_blinds",
    pos = {x = 0, y = 0},
    vars = {},
    dollars = 0,
    no_debuff = true,
    no_reroll = true,
    descriptions = {
        "ninehund_bdesc_boss",
        "ninehund_bdesc_mysteryunlock",
        "ninehund_bdesc_noreroll",
        "ninehund_bdesc_greed"
    },
    mult = 6,
    remaining_hits = 3,
    resetting = false,
    ending = false,
    target = nil,
    set_blind = function(self)
        self.remaining_hits = 3
        self.resetting = false
        self.ending = false
        self.target = nil
        n_makeImage(
            "blindeffect","greedeffect",
            ninehund.constants.CS.x, 9999, 0,
            3, 3,
            function(self)
                if G.GAME.blind.config.blind.target ~= nil then
                    self.x = (self.SSTable.px*2)+(G.GAME.blind.config.blind.target.children.center.CT.x*G.GAME.blind.config.blind.target.children.center.scale.x)
                    self.y = lerp(self.y,(self.SSTable.px*5)+(G.GAME.blind.config.blind.target.children.center.CT.y*G.GAME.blind.config.blind.target.children.center.scale.y),5*ninehund.dt)
                else
                    self.y = lerp(self.y,ninehund.constants.WS.y*2,5*ninehund.dt)
                end
                self.frame = n_nextFrame(4,4,G.TIMERS.REAL)
            end,
            true, 1,
            {
                frames = 4,
                px = 71, py = 380
            }
        )
    end,
    defeat = function(self)
        G.GAME.nine_musicspeed = 1;
        for k, v in pairs(G.playing_cards) do
            SMODS.debuff_card(v,false,"greed")
        end
        n_removeImage('blindeffect')
        ease_dollars(-G.GAME.dollars/2, true)
    end,
    cap_score = function(self, score, deco)
        if not deco then
            if to_big(score) + to_big(G.GAME.chips) >= G.GAME.blind.chips and self.remaining_hits > 1 then
                self.remaining_hits = self.remaining_hits - 1
                self.resetting = true
                G.GAME.blind:juice_up(2,2)
                ease_hands_played(math.max(0, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands) - G.GAME.current_round.hands_left,true);
                ease_discard(math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards) - G.GAME.current_round.discards_left,true);
                ease_chips(0);
                play_area_status_text(self.remaining_hits.." out of 3 left.", false, 2);
                refresh_deck();
                return 0
            elseif self.remaining_hits <= 1 then
                self.ending = true;
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.1,
                    blockable = true,
                    func = function()
                        if (to_big(G.GAME.chips) + to_big(score)) >= to_big(G.GAME.blind.chips) then
                            display_image({x=0,y=0}, "ninehund_whitescreen", {x = 0, y = 0, sx = 32, sy = 18}, 1)
                            play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                            G.GAME.nine_musicspeed = 0;
                        end
                        return true
                    end
                })) 
            end
        end
        return score
    end,
    drawn_to_hand = function(self)
        if self.resetting then
            self.resetting = false;
            ease_chips(0);
        end
        self.target = pseudorandom_element(G.hand.cards, pseudoseed('attack'))
        self.target.ability.forced_selection = true
        G.hand:add_to_highlighted(self.target)
    end,
    press_play = function(self)
        SMODS.debuff_card(self.target,true,"greed")
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 1,
            func = function()
                self.target = nil
                return true
            end
        })) 
    end,
    on_discard = function(self, card)
        if card == self.target then
            self.target = nil
            return true
        end
    end
}

SMODS.Blind	{
    key = 'solitude',
    loc_txt = {
        name = 'SOLITUDE',
        text = { 
            "As I watch you descend",
            "into the void with me..."
        }
    },
    boss = {min = -9999, max = -9999, showdown = true},
    boss_colour = HEX("234B91"),
    atlas = "blocktales_blinds",
    pos = {x = 0, y = 1},
    vars = {},
    dollars = 7,
    no_debuff = true,
    no_reroll = true,
    descriptions = {
        "ninehund_bdesc_boss",
        "ninehund_bdesc_mysteryunlock",
        "ninehund_bdesc_noreroll",
        "ninehund_bdesc_solitude"
    },
    mult = 6,
    remaining_hits = 5,
    ending = false,
    resetting = false,
    eyeopen = true,
    gamespeed = 16,
    eyecount = 0,
    set_blind = function(self)
        self.remaining_hits = 5
        self.ending = false
        self.resetting = false
        self.eyeopen = true
        self.eyecount = 0
        self.gamespeed = G.SETTINGS.GAMESPEED
    end,
    defeat = function(self)
        G.GAME.nine_musicspeed = 1;
        for k, v in pairs(G.playing_cards) do
            SMODS.debuff_card(v,false,"solitude")
        end
        G.E_MANAGER:add_event(Event({
            func = function()
                G.SETTINGS.GAMESPEED = self.gamespeed
                return true
            end
        })) 
        n_removeImage('blindeffect',true)
    end,
    cap_score = function(self, score, deco)
        if not deco then
            if to_big(score) + to_big(G.GAME.chips) >= G.GAME.blind.chips and self.remaining_hits > 1 then
                self.remaining_hits = self.remaining_hits - 1
                self.resetting = true
                G.GAME.blind:juice_up(2,2)
                ease_hands_played(math.max(0, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands) - G.GAME.current_round.hands_left,true);
                ease_discard(math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards) - G.GAME.current_round.discards_left,true);
                ease_chips(0);
                play_area_status_text(self.remaining_hits.." out of 5 left.", false, 2);
                refresh_deck();
                return 0
            elseif self.remaining_hits <= 1 then
                self.ending = true;
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.1,
                    blockable = true,
                    func = function()
                        if (to_big(G.GAME.chips) + to_big(score)) >= to_big(G.GAME.blind.chips) then
                            display_image({x=0,y=0}, "ninehund_whitescreen", {x = 0, y = 0, sx = 32, sy = 18}, 1)
                            play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                            G.GAME.nine_musicspeed = 0;
                        end
                        return true
                    end
                })) 
            end
        end
        return score
    end,
    drawn_to_hand = function(self)
        if self.resetting then
            self.resetting = false;
            ease_chips(0);
        end
        self.eyeopen = true
    end,
    press_play = function(self)
        self.eyeopen = false
        local alarmed = false
        for _, v in pairs(ninehund.imagetable.images) do
            if v.key == "blindeffect" and v.active then
                alarmed = true
            end
        end
        if alarmed then
            for k, v in pairs(G.hand.highlighted) do
                SMODS.debuff_card(v,true,"solitude")
            end
        end
        G.E_MANAGER:add_event(Event({
            func = function()
                G.SETTINGS.GAMESPEED = self.gamespeed
                return true
            end
        })) 
    end,
    on_discard = function(self, card)
        self.eyeopen = false
        local alarmed = false
        for _, v in pairs(ninehund.imagetable.images) do
            if v.key == "blindeffect" and v.active then
                alarmed = true
            end
        end
        if alarmed then
            SMODS.debuff_card(card,true,"solitude")
        end
    end,
    per_tick = function(self, t)
        if not self.ending and self.eyeopen then 
            G.SETTINGS.GAMESPEED = 1
            if math.fmod(t,100) == 0 and math.random() < 0.5  then
                for i=1, math.random(1,3) do
                    self.eyecount = self.eyecount + 1
                    play_sound('crumple2', math.random(9,11)*0.1,1);
                    n_makeImage(
                        "blindeffect","solitudeeffect",
                        (ninehund.constants.CS.x+(n_randrange(0.45)*ninehund.constants.WS.x)), (ninehund.constants.CS.y-(math.random()*0.35*ninehund.constants.WS.y)), 0,
                        1, 1,
                        function(self)
                            if G.GAME.blind.config.blind.key ~= "bl_ninehund_solitude" then n_removeImage("blindeffect",nil,self.id) end
                            self.timer = self.timer + ninehund.dt
                            if self.close then
                                self.active = false
                                if self.frame == 11 then 
                                    n_removeImage("blindeffect",nil,self.id) 
                                else
                                    self.frame = n_nextFrame(5,8,self.timer)+6
                                end
                            else
                                if self.frame < 5 then
                                    self.frame = n_nextFrame(5,8,self.timer)
                                else
                                    self.active = true
                                    self.frame = n_nextFrame(3,4,self.timer)+4
                                end
                            end
                        end,
                        true, 1,
                        {
                            frames = 11,
                            px = 119, py = 82
                        }, 
                        {
                            id = self.eyecount,
                            timer = 0,
                            close = false,
                            active = false
                        }
                    )
                end
            end
        end
    end,
    on_click = function(self, x, y)
        local alarmed = false
        for _, v in pairs(ninehund.imagetable.images) do
            if v.key == "blindeffect" then
                if CheckCollision(v.x-v.ox,v.y-v.oy,v.SSTable.px,v.SSTable.py,x,y,2,2) and not v.close then 
                    v.close = true
                    v.timer = 0
                    play_sound('crumple1', math.random(9,11)*0.1,1);
                end
                if v.active then
                    alarmed = true
                end
            end
        end
        if G.CONTROLLER.hovering.target and G.CONTROLLER.hovering.target.config.center ~= nil then
            if G.CONTROLLER.hovering.target.config.center.set == "Default" and alarmed then
                for k, v in pairs(G.hand.cards) do
                    v:damage_card(1)
                end
            end
        end
    end
}

SMODS.Blind	{
    key = 'hatred',
    loc_txt = {
        name = 'HATRED',
        text = { 
            "FOR I AM THE SCOURGE OF EVERYONE",
            "THAT YOU CANNOT HIDE."
        }
    },
    boss = {min = -9999, max = -9999, showdown = true},
    boss_colour = HEX("7C0503"),
    atlas = "blocktales_blinds",
    pos = {x = 0, y = 3},
    vars = {},
    dollars = 10,
    no_debuff = true,
    no_reroll = true,
    descriptions = {
        "ninehund_bdesc_boss",
        "ninehund_bdesc_mysteryunlock",
        "ninehund_bdesc_noreroll",
        "ninehund_bdesc_hatred"
    },
    mult = 10,
    remaining_hits = 3,
    resetting = false,
    ending = false,
    playinghand = false,
    set_blind = function(self)
        self.remaining_hits = 3
        self.resetting = false
        self.ending = false
        self.playinghand = false
        local find = find_joker('j_ninehund_asrieljoker');
        if #find > 0 then
            for _, f in pairs(find) do
                SMODS.debuff_card(f,true,"hatred")
                f:flip()
            end
        end
        n_makeImage(
            "blindeffect","hatredeffect",
            ninehund.constants.CS.x, ninehund.constants.CS.y, 0,
            1.5, 1.5,
            function(self)
                if G.GAME.blind.config.blind.ending then
                    self.alpha = lerp(self.alpha,0,2*ninehund.dt)
                else
                    self.alpha = lerp(self.alpha,0.8,0.5*ninehund.dt)
                end
                self.frame = n_nextFrame(4,8,G.TIMERS.REAL)
            end,
            true, 1,
            {
                frames = 4,
                px = 1280, py = 720
            },
            {
                alpha = 0
            }
        )
    end,
    defeat = function(self)
        G.GAME.nine_musicspeed = 1;
        for k, v in pairs(G.playing_cards) do
            SMODS.debuff_card(v,false,"hatred")
        end
        n_removeImage('blindeffect')
        local find = find_joker('j_ninehund_asrieljoker',true);
        if #find > 0 then
            for _, f in pairs(find) do
                SMODS.debuff_card(f,false,"hatred")
            end
        end
    end,
    cap_score = function(self, score, deco)
        if not deco then
            if to_big(score) + to_big(G.GAME.chips) >= G.GAME.blind.chips and self.remaining_hits > 1 then
                self.remaining_hits = self.remaining_hits - 1
                self.resetting = true
                G.GAME.blind:juice_up(2,2)
                ease_hands_played(math.max(0, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands) - G.GAME.current_round.hands_left,true);
                ease_discard(math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards) - G.GAME.current_round.discards_left,true);
                ease_chips(0);
                play_area_status_text(self.remaining_hits.." out of 3 left.", false, 2);
                refresh_deck();
                change_blind_size(to_big(G.GAME.blind.chips)*to_big(5))
                return 0
            elseif self.remaining_hits <= 1 then
                if (to_big(G.GAME.chips) + to_big(score)) >= to_big(G.GAME.blind.chips) then
                    self.ending = true;
                    G.E_MANAGER:add_event(Event({
                        trigger = "before",
                        delay = 0.1,
                        blockable = true,
                        func = function()
                                display_image({x=0,y=0}, "ninehund_whitescreen", {x = 0, y = 0, sx = 32, sy = 18}, 1)
                                play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                                G.GAME.nine_musicspeed = 0;
                            return true
                        end
                    })) 
                end
            end
        end
        return score
    end,
    drawn_to_hand = function(self)
        if self.resetting then
            self.resetting = false;
            ease_chips(0);
        end
        self.playinghand = false
    end,
    press_play = function(self)
        self.playinghand = true
        SMODS.debuff_card(pseudorandom_element(G.hand.highlighted, pseudoseed('attack')),true,"hatred")
    end,
    per_tick = function(self, t)
        if not self.ending and not self.playinghand then 
            if math.fmod(t,300) == 0 then
                for k, v in pairs(G.hand.cards) do
                    v:damage_card(1)
                end
            end
        end
    end
}