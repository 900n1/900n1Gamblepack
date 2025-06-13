--MAIN CODE, ALL FUNCTIONS AND ASSETS WILL BE PLACED HERE

if not ninehund then
	ninehund = {}
end

local mod_path = "" .. SMODS.current_mod.path
ninehund.path = mod_path

ninehund.VH = {} --var holder! really only used for temporary varaible storage or whatever idk!
ninehund.tycoon_space = 0 --for tycoon jokers!
ninehund.tycoon_limit = 5 --limit for how many tycoon jokers don't take up a joker slot

ninehund.ticks = 0 --a trick yahiamice used for ticking calculations
ninehund.dtcounter = 0

function Card:speak(text, col) --from Jen's Alamac
	if type(text) == 'table' then text = text[math.random(#text)] end
	card_eval_status_text(self, 'extra', nil, nil, nil, {message = text, colour = col or G.C.FILTER})
end

--funny talisman
to_big = to_big or function(num)
    return num
end

--LERRP!!!
function lerp(a,b,t) return a * (1-t) + b * t end

function Card:getSuit()
    return self.base.suit
end

local PCranksSpecial = {
    [11] = "Jack",
    [12] = "Queen",
    [13] = "King",
    [14] = "Ace"
}
function Card:getRank()
    if self.base.id > 10 and self.base.id < 15 then
        return PCranksSpecial[self.base.id]
    end
    return tostring(self.base.id)
end

local PCranksSuff = {
    [10] = "T",
    [11] = "J",
    [12] = "Q",
    [13] = "K",
    [14] = "A"
}

function Card:getS_R()
    local suit_prefix = string.sub(self.base.suit, 1, 1)
    if self.base.suit == "ninehund_nosuit" then
        suit_prefix = "ninehund_N"
    end
    local rank_suffix = self.base.id
    if rank_suffix > 9 and rank_suffix < 15 then
        rank_suffix = PCranksSuff[rank_suffix]
    end
    return suit_prefix.. "_" ..rank_suffix
end

function make_card(suitrank, enhancement, hand, num, secset)
    if enhancement == nil then
        return create_playing_card({front = G.P_CARDS[suitrank]}, hand, nil, num, {secset});
    end
    return create_playing_card({front = G.P_CARDS[suitrank], center = G.P_CENTERS[enhancement]}, hand, nil, num, {secset});
end

function change_blind_size(newsize, instant) --also from Jen's Alamac, sorry
	newsize = to_big(newsize)
	G.GAME.blind.chips = newsize
	local chips_UI = G.hand_text_area.blind_chips
	if instant then
		G.GAME.blind.chip_text = number_format(newsize)
		G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
		G.HUD_blind:recalculate() 
		chips_UI:juice_up()
		play_sound('chips2')
	else
		G.E_MANAGER:add_event(Event({func = function()
			G.GAME.blind.chip_text = number_format(newsize)
			G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
			G.HUD_blind:recalculate() 
			chips_UI:juice_up()
			play_sound('chips2')
		return true end }))
	end
end

function align_layer(card, layer) --from Balatro discord, Numbuh214
    v = card.children[layer]
    if v ~= nil then
      v.states.hover = card.states.hover
      v.states.click = card.states.click
      v.states.drag = card.states.drag
      v.states.collide.can = false
      v:set_role({major = card, role_type = 'Glued', draw_major = card})
    end
end

local set_spritesref = Card.set_sprites --based from Cryptid code
function Card:set_sprites(_center, _front)
    set_spritesref(self, _center, _front)
	if _center and _center.soul_pos and _center.soul_pos.extra9 then
        self.children.center = Sprite(
			self.T.x,
			self.T.y,
			self.T.w,
			self.T.h,
			G.ASSET_ATLAS[_center.atlas or _center.set],
			_center.pos
		)
		self.children.floating_sprite = Sprite(
			self.T.x,
			self.T.y,
			self.T.w,
			self.T.h,
			G.ASSET_ATLAS[_center.atlas or _center.set],
			_center.soul_pos
		)
        self.children.float2 = Sprite(
			self.T.x,
			self.T.y,
			self.T.w,
			self.T.h,
			G.ASSET_ATLAS[_center.atlas or _center.set],
			_center.soul_pos.extra9
		)
		align_layer(self,"center")
        align_layer(self,"floating_sprite")
        align_layer(self,"float2")
	end
end

function removepopup()
    -- copied from G.FUNCS.overlay_menu just to remove the pop-in anim
    if G.OVERLAY_MENU then G.OVERLAY_MENU:remove() end
    G.CONTROLLER.locks.frame_set = true
    G.CONTROLLER.locks.frame = true
    G.CONTROLLER.cursor_down.target = nil
    G.CONTROLLER:mod_cursor_context_layer(G.NO_MOD_CURSOR_STACK and 0 or 1)
    G.OVERLAY_MENU = UIBox{
        definition = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
            {n=G.UIT.R, config={align = "cm", colour = G.C.CLEAR}, nodes={
                {n=G.UIT.O, config={object = G.nine_image}},
            }},
        }},
        config = {
            align = "cm",
            offset = {x = 0, y = 0},
            major = G.ROOM_ATTACH,
            bond = 'Strong',
        }
    }
end

-- ripped from https://github.com/Mysthaps/LobotomyCorp (with permission...., hi myst lol), modified to be used as a function for image display
-- legacy image display, i'd rather use this for simpler things, the downside is it gets in the way of the menu
function display_image(pos, atlas, cframe, duration)
    G.nine_image_show = true
    G.nine_image_timer = 0
    G.nine_image_runtime = duration
    G.nine_image_anim = false
    G.nine_image_trans = 1
    G.nine_image = Sprite(0, 0, cframe.sx, cframe.sy, G.ASSET_ATLAS[atlas], pos)
    G.nine_image.states.drag.can = false
    G.nine_image.draw_self = function(self, overlay)
        if not self.states.visible then return end
        if self.sprite_pos.x ~= self.sprite_pos_copy.x or self.sprite_pos.y ~= self.sprite_pos_copy.y then
            self:set_sprite_pos(self.sprite_pos)
        end
        prep_draw(self, 1)
        love.graphics.scale(1/(self.scale.x/self.VT.w), 1/(self.scale.y/self.VT.h))
        love.graphics.setColor({1, 1, 1, G.nine_image_trans})
        love.graphics.draw(
            self.atlas.image,
            self.sprite,
            cframe.x, cframe.y,
            0,
            self.VT.w/(self.T.w),
            self.VT.h/(self.T.h)
        )
        love.graphics.pop()
        add_to_drawhash(self)
        self:draw_boundingrect()
        if self.shader_tab then love.graphics.setShader() end
    end
    removepopup()
end

function display_anim(pos, atlas, size, duration, loop)
    G.nine_image_show = true
    G.nine_image_timer = 0
    G.nine_image_runtime = duration
    G.nine_image_anim = true
    G.nine_image_trans = 1
    G.nine_image = AnimatedSprite(0, 0, size.x, size.y, G.ANIMATION_ATLAS[atlas], {0,0}, true)
    G.nine_image.offset_seconds = G.TIMERS.REAL
    G.nine_image.loop = loop
    G.nine_image.states.drag.can = false
    G.nine_image.draw_self = function(self, overlay)
        if not self.states.visible then return end
        prep_draw(self, 1)
        love.graphics.scale(1/(self.scale.x/self.VT.w), 1/(self.scale.y/self.VT.h))
        love.graphics.setColor({1, 1, 1, G.nine_image_trans})
        love.graphics.draw(
            self.atlas.image,
            self.sprite,
            pos.x, pos.y,
            0,
            self.VT.w/(self.T.w),
            self.VT.h/(self.T.h)
        )
        love.graphics.pop()
    end
    removepopup()
end

function AnimatedSprite:custom_animate(fps)
    if self.current_animation.current ~= (self.current_animation.frames - 1) or self.loop then
        local new_frame = math.floor(fps*(G.TIMERS.REAL - self.offset_seconds))%self.current_animation.frames
        if new_frame ~= self.current_animation.current then
            self.current_animation.current = new_frame
            self.frame_offset = math.floor(self.animation.w*(self.current_animation.current))
            self.sprite:setViewport( 
                self.frame_offset,
                self.animation.h*self.animation.y,
                self.animation.w,
                self.animation.h)
        end
    end
end

--custom colors lol!!
G.C.RAINBOW = {0,0,0,1}
G.C.VOID = {0,0,0,1}
local ninecolors = {
    rainbow = {0,0,0,1}
}

local loclolc = loc_colour
function loc_colour(_c, _default)
    if not G.ARGS.LOC_COLOURS then
        loclolc()
    end
    G.ARGS.LOC_COLOURS.rainbow = G.C.RAINBOW
    G.ARGS.LOC_COLOURS.void = G.C.VOID
    return loclolc(_c, _default)
end

local game_updateref = Game.update
function Game.update(self, dt)
    ninehund.dt = dt
    ninehund.dtcounter = ninehund.dtcounter+dt

    while ninehund.dtcounter >= 0.010 do
        ninehund.ticks = ninehund.ticks + 1
        ninehund.dtcounter = ninehund.dtcounter - 0.010
        if G.GAME.blind and not self.OVERLAY_MENU then G.GAME.blind:per_tick(ninehund.ticks) end
    end

    if G.nine_image_show then
        if G.nine_image_anim == true then
            G.nine_image:custom_animate(20)
        end
        G.nine_image_timer = G.nine_image_timer + dt
        if G.nine_image_timer >= G.nine_image_runtime then 
            G.nine_image_trans = (G.nine_image_runtime + 1) - G.nine_image_timer
        end
        if G.nine_image_trans <= 0 then
            G.nine_image_trans = 0
            G.nine_image_show = false
            G.SETTINGS.paused = false
            if G.OVERLAY_MENU then G.OVERLAY_MENU:remove() end
        end
    end

    if G.GAME.blind then
        if G.GAME.blind.config.blind.no_debuff then 
            G.GAME.blind.disabled = nil 
        end
        if G.GAME.blind.config.blind.key == "bl_ninehund_asriel" and G.GAME.blind.config.blind.ending == true then
            G.ROOM.jiggle = 2
            ease_background_colour({new_colour = hsvToRgb(G.TIMERS.REAL*0.4,1,0.8,1), special_colour = hsvToRgb(G.TIMERS.REAL*0.5,1,1,1), contrast = 2})
        end
    end

    --WHY DOES IT WORK LIKE THIS
    ninecolors.rainbow = hsvToRgb(G.TIMERS.REAL*0.2,1,0.8,1)
    self.C.RAINBOW[1] = ninecolors.rainbow[1]
    self.C.RAINBOW[2] = ninecolors.rainbow[2]
    self.C.RAINBOW[3] = ninecolors.rainbow[3]

    self.C.VOID[1] = 0.2*(1+math.sin(self.TIMERS.REAL*1.5))
    self.C.VOID[2] = 0.2*(1+math.sin(self.TIMERS.REAL*1.5 + 2))
    self.C.VOID[3] = 0.2*(1+math.sin(self.TIMERS.REAL*1.5 + 4))

    game_updateref(self, dt)
end

local insane_hook = G.FUNCS.evaluate_play
function G.FUNCS.evaluate_play(e)
    SMODS.calculate_context({sandwich = true, full_hand = G.play.cards}); --sandwich must come first!
    SMODS.calculate_context({but_first = true, full_hand = G.play.cards});
    insane_hook(e)

    --setting the most_played_poker_hand value
    local _handname, _played, _order = 'High Card', -1, 100
    for k, v in pairs(G.GAME.hands) do
        if v.played > _played or (v.played == _played and _order > v.order) then
            _played = v.played
            _handname = k
        end
    end
    G.GAME.current_round.most_played_poker_hand = _handname
    G.nine_hrtmadness = 1
end

local peak_hook = SMODS.always_scores
function SMODS.always_scores(card)
    if card.ability["is_sandwiched"] then
        return true
    end
    peak_hook(card)
end

--from Cryptid
function Blind:cap_score(score, deco)
	if not self.disabled then
		local obj = self.config.blind
		if obj.cap_score and type(obj.cap_score) == "function" then
			return obj:cap_score(score, deco)
		end
	end
	return score
end


function force_set_blind(key) --copied from DebugPlus, however it is similar to the original Balatro code
    local par = G.blind_select_opts.boss.parent
    G.GAME.round_resets.blind_choices.Boss = key

    G.blind_select_opts.boss:remove()
    G.blind_select_opts.boss = UIBox {
        T = {par.T.x, 0, 0, 0},
        definition = {
            n = G.UIT.ROOT,
            config = {
                align = "cm",
                colour = G.C.CLEAR
            },
            nodes = {UIBox_dyn_container({create_UIBox_blind_choice('Boss')}, false,
                get_blind_main_colour('Boss'), mix_colours(G.C.BLACK, get_blind_main_colour('Boss'), 0.8))}
        },
        config = {
            align = "bmi",
            offset = {
                x = 0,
                y = G.ROOM.T.y + 9
            },
            major = par,
            xy_bond = 'Weak'
        }
    }
    par.config.object = G.blind_select_opts.boss
    par.config.object:recalculate()
    G.blind_select_opts.boss.parent = par
    G.blind_select_opts.boss.alignment.offset.y = 0

    for i = 1, #G.GAME.tags do
        if G.GAME.tags[i]:apply_to_run({
            type = 'new_blind_choice'
        }) then
            break
        end
    end
end

local blindBGcolors = {
    bl_ninehund_asriel = {new_colour = HEX("000000"), special_colour = HEX("FFFFFF"), contrast = 2},
    bl_ninehund_fear = {new_colour = HEX("000000"), special_colour = HEX("45105A"), contrast = 2},
    bl_ninehund_greed = {new_colour = HEX("000000"), special_colour = HEX("C8A24A"), contrast = 2},
    bl_ninehund_hatred = {new_colour = HEX("000000"), special_colour = HEX("7C0503"), contrast = 2},
    bl_ninehund_solitude = {new_colour = HEX("000000"), special_colour = HEX("234B91"), contrast = 2}
}

local ease_background_colour_blindref = ease_background_colour_blind
function ease_background_colour_blind(state, blind_override)
    if G.GAME.blind then
        if blindBGcolors[G.GAME.blind.config.blind.key] then
            ease_background_colour(blindBGcolors[G.GAME.blind.config.blind.key])
            return
        end
    end
    ease_background_colour_blindref(state, blind_override)
end

function hsvToRgb(h, s, v, a)
    local r, g, b

    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);

    i = i % 6

    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    local color = {r, g, b, a}
    return color
end

function refresh_deck()
    G.FUNCS.draw_from_discard_to_deck()
    G.FUNCS.draw_from_hand_to_deck()
    G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = 1,
        blockable = false,
        func = function()
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    G.deck:shuffle(G.GAME.blind.config.blind.key..'_refresh')
                    G.deck:hard_set_T()
                return true
                end
            }))
        return true
        end
    }))
end

G.localization.descriptions.Other['health'] = {
    text = {
        "{X:mult,C:white}Health:{C:mult} #1#/#2#"
    }
}

local gen_card_old = generate_card_ui --code taken from https://github.com/art-muncher/Card-Value-Display
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end,card)
    full_UI_table = gen_card_old(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end,card)
    if card and card.ability then
        local desc_nodes = full_UI_table.main
        if card.ability.health ~= nil and card.ability.max_health ~= nil then
            localize{type = 'other', key = 'health', nodes = desc_nodes, vars = {card.ability.health,card.ability.max_health}}
        end
    end
    return full_UI_table
end

function Card:damage_card(dmg)
    if self.ability.health ~= nil and self.ability.max_health ~= nil then
        if dmg ~= 0 then
            if dmg > 0 then
                SMODS.calculate_context({card_damaged = self});
            end
            self:juice_up(-1,-1);
            if self.config.center_key == 'm_glass' then
                self.ability.health = self.ability.health - (dmg*3);
                if self.ability.health <= 0 then
                    G.E_MANAGER:add_event(Event({
                        trigger = "after",
                        delay = 0.2,
                        func = function()
                            self:shatter();
                            return true
                        end
                    })) 
                end
                SMODS.calculate_effect({ message = "-" ..(dmg*3).." !", colour = G.C.MULT, instant = true}, self)
            else
                self.ability.health = self.ability.health - dmg;
                if self.ability.health <= 0 then
                    G.E_MANAGER:add_event(Event({
                        trigger = "after",
                        delay = 0.2,
                        func = function()
                            self:start_dissolve(nil, true);
                            return true
                        end
                    })) 
                end
                SMODS.calculate_effect({ message = "-" ..dmg, colour = G.C.MULT, instant = true}, self)
            end
        end
    else
        self.ability.max_health = self.base.nominal;
        self.ability.health = self.ability.max_health;
        self:damage_card(dmg);
    end
end

function generate_ui_cardarea_thing(cards) --ripped from UI_definitions
    local cardarea = CardArea(
        2,2,
        3.5*G.CARD_W, --xpadding
        0.75*G.CARD_H, --ypadding
        {card_limit = 0, type = 'play', highlight_limit = 0})
      for k, v in ipairs(cards) do
          local card = Card(0,0, 0.75*G.CARD_W, 0.75*G.CARD_H, G.P_CARDS[v[1]], G.P_CENTERS.c_base)
          cardarea:emplace(card)
      end
    
      return {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, r = 0.1}, nodes={
        {n=G.UIT.C, config={align = "cm"}, nodes={
          {n=G.UIT.O, config={object = cardarea}}
        }}
      }}
end

function generate_sandiwch_cards(Scards)
    local cardarea = CardArea(
        2,2,
        math.min(3.5*G.CARD_W,G.CARD_W*#Scards), --xpadding
        0.75*G.CARD_H, --ypadding
        {card_limit = 0, type = 'play', highlight_limit = 0})

    if #Scards > 0 then
        for x=1, #Scards do
            local funnycard = make_card(Scards[x][1],nil, cardarea, nil, G.C.SECONDARY_SET.Spectral)
            ease_value(funnycard.T, 'scale',-0.2,nil,'REAL',true,0.1)
            for a, m in pairs(Scards[x][2]) do
                if m then
                    funnycard:set_ability(G.P_CENTERS[tostring(a)]);
                end
            end
            if Scards[x][3] ~= nil and Scards[x][3]["key"] ~= nil then
                funnycard:set_edition(Scards[x][3]["key"],true,true);
            end
            if Scards[x][4] ~= nil then
                funnycard:set_seal(Scards[x][4],true,true);
            end
        end
    end
    
      return {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, r = 0.1}, nodes={
        {n=G.UIT.C, config={align = "cm"}, nodes={
          {n=G.UIT.O, config={object = cardarea}}
        }}
      }}
end

local bosshooklol = G.FUNCS.reroll_boss
function G.FUNCS.reroll_boss(e)
    if G.P_BLINDS[G.GAME.round_resets.blind_choices.Boss].no_reroll then
        if not n_detectImage("NOREROLLNOTIF") then
            n_makeImage(
                "NOREROLLNOTIF","unskippable",
                ninehund.constants.CS.x, ninehund.constants.CS.y, 0,
                2, 2,
                function(self)
                    self.timer = self.timer + ninehund.dt
                    if self.timer < 2 then
                        self.alpha = lerp(self.alpha,1,2*ninehund.dt)
                    else
                        if self.alpha > 0.02 then
                            self.alpha = lerp(self.alpha,0,2*ninehund.dt)
                        else
                            n_removeImage("NOREROLLNOTIF")
                        end
                    end
                end,
                nil, nil, nil,
                {
                    timer = 0,
                    alpha = 0
                }
            )
        end
        return
    end
    bosshooklol(e)
end

-- from cryptid/items/misc_joker.lua
local lcpref = Controller.L_cursor_press
function Controller:L_cursor_press(x, y)
    lcpref(self, x, y)
    if G and G.jokers and G.jokers.cards and not G.SETTINGS.paused then
        SMODS.calculate_context({ cry_press = true })
    end
    if G.GAME.blind then
        G.GAME.blind:on_click(x,y)
    end
end

function Blind:on_click(x,y)
	if not self.disabled then
		local obj = self.config.blind
		if obj.on_click and type(obj.on_click) == "function" then
			obj:on_click(x,y)
		end
	end
end

function Blind:on_discard(card)
	if not self.disabled then
		local obj = self.config.blind
		if obj.on_discard and type(obj.on_discard) == "function" then
			return obj:on_discard(card)
		end
	end
end

function Blind:per_tick(t)
	if not self.disabled then
		local obj = self.config.blind
		if obj.per_tick and type(obj.per_tick) == "function" then
			return obj:per_tick(t)
		end
	end
end

--love2d collisition??!?1
function CheckCollision(x1,y1,w1,h1,x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

--why the fuck not, returns a random value between -1 and 1
--mult just multiplies the value by the number which indicates the intensity of the range
function n_randrange(mult)
    return (math.random()+math.random(-1,0))*(mult or 1)
end

ninehund.bossrush = false
ninehund.bossPending = {
    bosses = {},
    current = 0,
    win = nil
}

local bossWinFanfare = {
    ["pendant"] = function()
        local find = find_joker('j_ninehund_necklace')
        if #find > 0 then
            G.E_MANAGER:add_event(Event({
                func = function()
                    n_makeImage(
                        "purifiedsoul","purified",
                        ninehund.constants.CS.x, ninehund.constants.CS.y, 0,
                        2, 2,
                        function(self)
                            self.timer = self.timer + ninehund.dt
                            if self.timer < 4 then
                                self.alpha = lerp(self.alpha,1,5*ninehund.dt)
                            else
                                if self.alpha > 0.02 then
                                    self.alpha = lerp(self.alpha,0,2*ninehund.dt)
                                else
                                    n_removeImage("purifiedsoul")
                                end
                            end
                        end,
                        nil, nil, nil,
                        {
                            timer = 0,
                            alpha = 0
                        }
                    )
                    play_sound('whoosh_long',1,1)
                    play_sound('explosion_release1',1,0.5)
                    play_sound('magic_crumple2',1,2)
                    find[1].children.center:set_sprite_pos({x=2,y=0})
                    find[1]:juice_up()
                    find[1].ability.extra.pure = true
                    return true
                end
            })) 
        end
    end
}

local idontlikethewaythegameworks = get_new_boss
function get_new_boss()
    if ninehund.bossrush then
        if  ninehund.bossPending.current >= #ninehund.bossPending.bosses then
            if ninehund.bossPending.win ~= nil then
                bossWinFanfare[ninehund.bossPending.win]()
            end
            ninehund.bossrush = false
            ninehund.bossPending.win = nil
            ninehund.bossPending.current = 0
        else
            ninehund.bossPending.current = ninehund.bossPending.current + 1
            return ninehund.bossPending.bosses[ninehund.bossPending.current]
        end
    end
    return idontlikethewaythegameworks()
end

local thisisgettingannoying = G.FUNCS.start_run
G.FUNCS.start_run = function(e, args) 
    ninehund.bossPending = {
        bosses = {},
        current = 0,
        win = nil
    }
    ninehund.bossrush = false
    thisisgettingannoying(e,ars)
end

--===========RESOURCES============

-- from Cryptid, for drawing the third layer in cards, modified to liking and hopefully not clash with cryptid's own third layer
SMODS.DrawStep({
	key = "float2",
	order = 59,
	func = function(self)
		if
			self.config.center.soul_pos
			and self.config.center.soul_pos.extra9
			and (self.config.center.discovered or self.bypass_discovery_center)
		then
			local scale_mod = 0.07
			local rotate_mod = 0.02*math.cos(1.219*G.TIMERS.REAL) + 0.00*math.cos((G.TIMERS.REAL)*math.pi*5)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^2
			self.children.float2:draw_shader(
				"dissolve",
				0,
				nil,
				nil,
				self.children.center,
				scale_mod,
				rotate_mod,
				nil,
				0.1 + 0.03*math.cos(1.8*G.TIMERS.REAL),
				nil,
				0.6
			)
			self.children.float2:draw_shader(
				"dissolve",
				nil,
				nil,
				nil,
				self.children.center,
				scale_mod,
				rotate_mod
			)
		end
	end,
	conditions = { vortex = false, facing = "front" },
})
SMODS.draw_ignore_keys.float2 = true

--====BLIND DESCRIPTIONS=====
--from https://github.com/Mysthaps/LobotomyCorp ripped straight out of it lol
--aperently a lib mod does the same effect
function info_from_desc(blind_desc)
    local width = 6
    local desc_nodes = {}
    localize{type = 'descriptions', key = blind_desc, set = "BlindDesc", nodes = desc_nodes, vars = {}}
    local desc = {}
    for _, v in ipairs(desc_nodes) do
        desc[#desc+1] = {n=G.UIT.R, config={align = "cl"}, nodes=v}
    end
    return 
    {n=G.UIT.R, config={align = "cl", colour = lighten(G.C.GREY, 0.4), r = 0.1, padding = 0.05}, nodes={
        {n=G.UIT.R, config={align = "cl", padding = 0.05, r = 0.1}, nodes = localize{type = 'name', key = blind_desc, set = "BlindDesc", name_nodes = {}, vars = {}}},
        {n=G.UIT.R, config={align = "cl", minw = width, minh = 0.4, r = 0.1, padding = 0.05, colour = desc_nodes.background_colour or G.C.WHITE}, nodes={{n=G.UIT.R, config={align = "cm", padding = 0.03}, nodes=desc}}}
    }}
end

function create_UIBox_blind_desc(blindD)
    local desc_lines = {}
    for _, v in ipairs(blindD) do
        desc_lines[#desc_lines+1] = info_from_desc(v)
    end
    return
    {n=G.UIT.ROOT, config = {align = 'cm', colour = lighten(G.C.JOKER_GREY, 0.5), r = 0.1, emboss = 0.05, padding = 0.05}, nodes={
        {n=G.UIT.R, config={align = "cm", emboss = 0.05, r = 0.1, minw = 2.5, padding = 0.05, colour = G.C.GREY}, nodes={
            {n=G.UIT.C, config = {align = "lm", padding = 0.1}, nodes = desc_lines}
        }}
    }}
end

local blind_hoverref = Blind.hover
function Blind.hover(self)
    if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then 
        if not self.hovering and self.states.visible and self.children.animatedSprite.states.visible then
            if self.config.blind.descriptions then
                G.blind_desc = UIBox{
                    definition = create_UIBox_blind_desc(self.config.blind.descriptions),
                    config = {
                        major = self,
                        parent = nil,
                        offset = {
                            x = 0.15,
                            y = 0.2 + 0.38*#self.config.blind.descriptions,
                        },  
                        type = "cr",
                    }
                }
                G.blind_desc.attention_text = true
                G.blind_desc.states.collide.can = false
                G.blind_desc.states.drag.can = false
                if self.children.alert then
                    self.children.alert:remove()
                    self.children.alert = nil
                end
            end
        end
    end
    blind_hoverref(self)
end

local blind_stop_hoverref = Blind.stop_hover
function Blind.stop_hover(self)
    if G.blind_desc then
        G.blind_desc:remove()
        G.blind_desc = nil
    end
    blind_stop_hoverref(self)
end

--=====ASSETS======

local atlas_list = {
    Jokers = {'Jokers',71,95},
    amalgam = {'amalgam',71,95},
    crk = {'crk',71,95},
    supernatural = {'supernatural',71,95},
    custom = {'creative',71,95},
    enhance = {'enhance',71,95},
    vouchers = {'vouchers',71,95},
    whitescreen = {'white',1280,720},
    jesus = {'hispower',640,360},
    hrt = {'hrt',71,95},
    nosuit_lc = {'nosuit_lc',71,95},
    nosuit_hc = {'nosuit_hc',71,95},
    suiticon_lc = {'suiticon_lc',18,18},
    suiticon_hc = {'suiticon_hc',18,18},
    tycoon = {'tycoon',71,95},
    necklace = {'necklace',71,95},


    asriel = {'asrielBlind',34,34,true,21},
    att_light = {'att_light',296,203,true,17},
    att_slash = {'asrielslash',123,161,true,9},
    att_star = {'starboom',292,292,true,5},
    att_goner = {'hypergoner',640,360,true,8},

    blocktales_blinds = {'blocktalesBlind',34,34,true,16}
}

--load atlases
for k, v in pairs(atlas_list) do
    local atlas = {
        key = k,
        path = v[1]..".png",
        px = v[2],
        py = v[3]
    }
    if v[4] then
        atlas.atlas_table = "ANIMATION_ATLAS"
        atlas.frames = v[5]
    end
    SMODS.Atlas(atlas)
end

local sound_list = {
    rah = "rah",
    boom = "boom",
    asriel_light = "mus_sfx_a_lithit2",
    asriel_swipe = "mus_sfx_swipe",
    asriel_star = "mus_sfx_star",
    asriel_hit = "snd_bomb",
    und_explode = "mus_explosion",
    und_flash = "mus_sfx_eyeflash",
    asriel_goner = "mus_sfx_hypergoner_laugh",
    bell = "bell",

    hrt_bulletn = "hrt_bulletn",
    hrt_comely = "hrt_comely",
    hrt_cyan = "hrt_cyan",
    hrt_doorknob = "hrt_doorknob",
    hrt_downtown = "hrt_downtown",
    hrt_garbage = "hrt_garbage",
    hrt_jovial = "hrt_jovial",
    hrt_legacy = "hrt_legacy",
    hrt_lightning = "hrt_lightning",
    hrt_mysterious = "hrt_mysterious",
    hrt_nighttime = "hrt_nighttime",
    hrt_resolute = "hrt_resolute",
    hrt_superstitional = "hrt_superstitional",
    horse = "horse"
}

--load sounds
for k, v in pairs(sound_list) do
    SMODS.Sound({
        key = k,
        path = v..".ogg",
    })
end

--===MUSIC===
SMODS.Sound({
	key = 'music_hopes_and_dreams',
	path = 'hopes_and_dreams.ogg',
    pitch = 1,
    sync = false,
    select_music_track = function()
        return (G.GAME and G.GAME.blind and G.GAME.blind.config.blind.key == "bl_ninehund_asriel") and 1e6 or false
    end,
})

SMODS.Sound({
	key = 'music_save_the_world',
	path = 'save_the_world.ogg',
    pitch = 1,
    sync = false,
    select_music_track = function()
        return (G.GAME and G.GAME.blind and G.GAME.blind.config.blind.key == "bl_ninehund_asriel" and G.GAME.blind.config.blind.ending == true) and 1e9 or false
    end,
})

SMODS.Sound({
	key = 'music_greed',
	path = 'blocktales_greed.ogg',
    pitch = 1,
    sync = false,
    select_music_track = function()
        return (G.GAME and G.GAME.blind and G.GAME.blind.config.blind.key == "bl_ninehund_greed") and 1e6 or false
    end,
})
SMODS.Sound({
	key = 'music_solitude',
	path = 'blocktales_solitude.ogg',
    pitch = 1,
    sync = false,
    select_music_track = function()
        return (G.GAME and G.GAME.blind and G.GAME.blind.config.blind.key == "bl_ninehund_solitude") and 1e6 or false
    end,
})
SMODS.Sound({
	key = 'music_fear',
	path = 'blocktales_fear.ogg',
    pitch = 1,
    sync = false,
    select_music_track = function()
        return (G.GAME and G.GAME.blind and G.GAME.blind.config.blind.key == "bl_ninehund_fear") and 1e6 or false
    end,
})
SMODS.Sound({
	key = 'music_hatred',
	path = 'blocktales_hatred.ogg',
    pitch = 1,
    sync = false,
    select_music_track = function()
        return (G.GAME and G.GAME.blind and G.GAME.blind.config.blind.key == "bl_ninehund_hatred") and 1e6 or false
    end,
})

SMODS.Rarity {
	key = 'fusion',
	loc_txt = {
		name = 'Fusion'
	},
	badge_colour = HEX('63BBE1'),
    default_weight = 0.1,
    pools = {
        ["Joker"] = true,
    }
}

SMODS.Rarity {
	key = 'icon',
	loc_txt = {
		name = 'Icon Series'
	},
	badge_colour = HEX('dcdcdc'),
    default_weight = 0.02,
    pools = {
        ["Joker"] = true,
    }
}

SMODS.Rarity {
	key = 'super',
	loc_txt = {
		name = 'Supernatural'
	},
	badge_colour = HEX('d10020'),
    default_weight = 0,
}

SMODS.ObjectType({
	key = "Fusions",
	default = "j_reserved_parking",
	cards = {},
	inject = function(self)
		SMODS.ObjectType.inject(self)
	end,
})

SMODS.Suit{
    key = "nosuit",
    card_key = "N",
    pos = {y = 0},
    ui_pos = {x = 0, y = 0},
    lc_atlas = "nosuit_lc",
    hc_atlas = "nosuit_hc",
    lc_ui_atlas = "suiticon_lc",
    hc_ui_atlas = "suiticon_hc",
    lc_colour = G.C.GREY,
    hc_colour = G.C.VOID,
    in_pool = function(self, args)
        return false
    end
}

SMODS.ConsumableType{
    key = 'amalgams',

    collection_rows = {4,5},
    primary_colour = HEX('7D3951'),
    secondary_colour = G.C.DARK_EDITION,
    loc_txt = {
        collection = 'Amalgamate Cards', 
        name = 'Amalgam',
        undiscovered = {
            name = 'Hidden Amalgam',
            text = {'Amalgam not synthesized'} 
        }
    },
    shop_rate = 0.1, --rate in shop out of 100
}

--AND FINALLY:
--Load Library Files, shout out to yahiamice for where he got this code in his mod so i can finally separate my main lua file
print("[900n1] lets load the image display functions!")
local IDfunc, IDerr = SMODS.load_file("imageDisplaying.lua")
if IDerr then
    error(IDerr) 
end
IDfunc()

local files = NFS.getDirectoryItems(mod_path .. "items")
for _, file in ipairs(files) do
	print("[900n1] loading le " .. file)
	local f, err = SMODS.load_file("items/" .. file)
	if err then
		error(err) 
	end
	f()
end