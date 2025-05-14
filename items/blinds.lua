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
        name = 'God of Hyperdeath',
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
    mult = 2,
    remaining_hits = 6,
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