-- ctf_range/custom_controls.lua

local player_scope_huds = {}
local player_nominal_zooms = {}

local old_binoculars_update

local function binoculars_override(player)
   local new_zoom_fov = 0
   local w_item = player:get_wielded_item()
   local scope_zoom = w_item:get_definition().ctf_guns_scope_zoom

   if scope_zoom == nil then
      -- No gun equipped? check for binoculars
      if old_binoculars_update ~= nil then
         old_binoculars_update(player)
      end
      if minetest.get_modpath("mcl_core") ~= nil then
         minetest.log("action", "[ctf_ranged] no scope")
         player:set_fov(86.1)
      end
      return
   end

   -- Only set property if necessary to avoid player mesh reload
   if minetest.get_modpath("mcl_core") == nil then
      if player:get_properties().zoom_fov ~= scope_zoom then
         player:set_properties({zoom_fov = scope_zoom})
         return
      end
   else
      --minetest.log("action", "[ctf_ranged] "..player:get_player_name().." fov="..tostring(player:get_fov()))
      if player:get_fov() ~= scope_zoom then
         minetest.log("action", "[ctf_ranged] scope found")
         player:set_fov(scope_zoom, false, 0.1)
         return
      end
   end
end

-- Zooms into view
local function enable_scope(player)
   local w_item = player:get_wielded_item()
   local scope_zoom = w_item:get_definition().ctf_guns_scope_zoom
   if scope_zoom == nil then
      return
   end
   minetest.log("action", "[ctf_ranged] "..player:get_player_name().." zooming in with "..tostring(scope_zoom))
   player:set_fov(scope_zoom, false, 0.1)
end

-- Zooms out of view
local function disable_scope(player)
   player:set_fov(86.1)
end

minetest.register_on_mods_loaded(function()
   minetest.log("action", "[ctf_ranged] Processing controls...")
      local use_binoculars = false
      if minetest.get_modpath("binoculars") then
         use_binoculars = true
         old_binoculars_update = binoculars.update_player_property
         binoculars.update_player_property = binoculars_override
      end

      controls.register_on_press(function(player, control_name)
	    if control_name ~= "zoom" or control_name ~= "RMB" then
	       return
	    end
       if use_binoculars then
	      binoculars_override(player)
       else
         enable_scope(player)
       end
      end)
      controls.register_on_release(function(player, control_name, time)
       if control_name ~= "zoom" or control_name ~= "RMB" then
	       return
	    end
       if use_binoculars then
	      binoculars_override(player)
       else
         disable_scope(player)
       end
      end)

end)

minetest.register_on_joinplayer(function(player)
      player_scope_huds[player:get_player_name()] = player:hud_add({
	    hud_elem_type = "image",
	    alignment = { x=0.0, y=0.0 },
	    position = {x = 0.5, y = 0.5},
	    scale = { x=2, y=2 },
	    text = "rangedweapons_empty_icon.png",
      })
end)

