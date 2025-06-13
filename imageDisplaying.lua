--THE THING THAT HANDLES ALL IMAGE LOADING AND DISPLAYING OR WHATVEER
--SPECIAL CREDITS TO THE YAHIAMICE'S YAHIMOD BECAUSE IM LEARNING HOW TO DO THIS BASED ON HIS MOD

if not ninehund["nine_imagetable"] then
    ninehund.imagetable = {
        loaded = {},
        images = {},
        frames = {}
    }
end

--you gotta love the constant measurement lookup table for these things
local xscale = love.graphics.getWidth()/1920
local yscale = love.graphics.getHeight()/1080
ninehund.constants = {
    CS = {x = love.graphics.getWidth()/2, y = love.graphics.getHeight()/2},
    WS = {x = love.graphics.getWidth(), y = love.graphics.getHeight()}
}

--function from yahimod
function n_LoadIMAGE(name)
    local full_path = ninehund.path.."customimages/"..name..".png"
    local file_data = assert(NFS.newFileData(full_path),("[900] epic file_data fail"))
    local tempimagedata = assert(love.image.newImageData(file_data),("[900] epic tempimagedata fail"))
    return (assert(love.graphics.newImage(tempimagedata),("[900] epic love.graphic.newImage fail")))
end

--also from yahimod but really modified, used to load in quads for image drawing
function n_LoadSpriteSheet(name,frames,px,py)
    if ninehund.imagetable.loaded[name] == nil then ninehund.imagetable.loaded[name] = n_LoadIMAGE(name) end
    ninehund.imagetable.frames[name] = {}
    for i = 1, frames do
        table.insert(ninehund.imagetable.frames[name],love.graphics.newQuad((i-1)*px, 0, px, py, ninehund.imagetable.loaded[name]))
    end
end

function n_makeImage(key,name,_x,_y,_r,_sx,_sy,_func,_sprite,_frame,_SStable,extras)
    if ninehund.imagetable.loaded[name] == nil then ninehund.imagetable.loaded[name] = n_LoadIMAGE(name) end
    if _sprite and ninehund.imagetable.frames[name] == nil then
        n_LoadSpriteSheet(name,_SStable.frames,_SStable.px,_SStable.py)
    end
    local maketable = {
        key = key,
        name = name,
        image = ninehund.imagetable.loaded[name],
        x = _x, y = _y, r = _r,
        sx = xscale*_sx, sy = yscale*_sy,
        ox = _sprite and _SStable.px/2 or ninehund.imagetable.loaded[name]:getWidth()/2,
        oy = _sprite and _SStable.py/2 or ninehund.imagetable.loaded[name]:getHeight()/2,
        alpha = 1,
        func = _func, --function(self)
        sprite = _sprite or false,
        frame = _frame or 1,
        totalframes = _sprite and _SStable.frames or 1,
        SSTable = _SStable,
    }
    if extras then
        for k, v in pairs(extras) do
            maketable[k] = v
        end
    end
    table.insert(ninehund.imagetable.images,maketable)
    --print("created "..key.." image using "..name..".png")
end

function n_nextFrame(totalframes,fps,timer)
    return (math.floor(fps*timer)%totalframes)+1
end

function n_removeImage(key,all,id)
    if all then 
        ninehund.imagetable.images = {} 
        --print("removed all images")
        return
    end

    if id then
        for i, e in pairs(ninehund.imagetable.images) do
            if e.key == key and e.id == id then
                table.remove(ninehund.imagetable.images,i)
                --print("removed "..key.." image "..id)
                return
            end
        end
        return
    end

    for i, e in pairs(ninehund.imagetable.images) do
        if e.key == key then
            table.remove(ninehund.imagetable.images,i)
            return
        end
    end
end

function n_detectImage(key,id)
    if id then
        for i, e in pairs(ninehund.imagetable.images) do
            if e.key == key and e.id == id then
                return i
            end
        end
        return
    end

    for i, e in pairs(ninehund.imagetable.images) do
        if e.key == key then
            return i
        end
    end
    return
end

--original love.draw hook, it does the job if you don't mind images going over the menu
--[[local imfeelingit = love.draw
function love.draw()
    imfeelingit()
    if #ninehund.imagetable.images > 0 then
        if G.STAGE == G.STAGES.MAIN_MENU then --terminate at main menu
            ninehund.imagetable.images = {}
            print("cleared all images")
        end
        for k, v in pairs(ninehund.imagetable.images) do
            love.graphics.setColor(1, 1, 1, v.alpha)
            love.graphics.draw(v.image, v.x, v.y, v.r, v.sx, v.sy, v.ox, v.oy)
            if v.func ~= nil then
                v.func(v)
            end
        end
    end
end]]