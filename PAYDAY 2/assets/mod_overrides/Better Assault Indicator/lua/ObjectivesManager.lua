--[[
    Code is not executed
    It may used in the future
]]

local function IsLevelSupported(level_id)
    return BAI:IsOr(level_id, "man", "mad")
end

local function GetNumberOfObjectivesToCheck(level_id)
    if level_id == "man" then
        return 1
    elseif level_id == "mad" then
        return 2
    else
        return 0
    end
end

local function GetLevelObjectivesToCheck(level_id)
    if level_id == "man" then
        return "heist_man11"
    elseif level_id == "mad" then
        return { "heist_mad_11", "heist_mad_12" }
    else
        return nil
    end
end

local function IsEndlessAssaultNonOverridable(level_id)
    --return level_id == "man"
    return true
end

local function IsDelay(level_id)
    return level_id == "mad"
end

local function Delay(level_id)
    return level_id == "mad" and 2 or 0
end

local function TriggerEndlessAssault(dont_override)
    managers.hud:StartEndlessAssaultClient(dont_override)
end

local function IterateObjectives()
    local level_id = Global.game_settings.level_id
    local activated = false
    for _, v in pairs(GetLevelObjectivesToCheck(level_id)) do
        if managers.objectives._active_objectives[v] then
            activated = true
            TriggerEndlessAssault(IsEndlessAssaultNonOverridable(level_id))
            break
        end
    end
    if not activated then
        local function GetObjectivesInString(objectives)
            local n = #objectives
            local s = ""
            for i, v in ipairs(objectives) do
                s = s .. v
                if i + 1 == n then
                    s = s .. " and " .. objectives[i + 1]
                    break
                else
                    s = s .. ", "
                end
            end
            return s
        end
        log(string.format("[BAI - ObjectivesManager] Objectives %s are not active", GetObjectivesInString(GetLevelObjectivesToCheck(level_id))))
    end
end

local _f_load = ObjectivesManager.load
function ObjectivesManager:load(data)
    _f_load(self, data)
    local state = data.ObjectivesManager

    if state and not managers.hud:GetBAIHost() then
        local level_id = Global.game_settings.level_id
        if IsLevelSupported(level_id) then
            if GetNumberOfObjectivesToCheck(level_id) > 1 then
                if IsDelay(level_id) then
                    BAI:DelayCall("EndlessAssaultCheckDelay", Delay(level_id), IterateObjectives)
                else
                    IterateObjectives()
                end
            else
                if self._active_objectives[GetLevelObjectivesToCheck(level_id)] then
                    TriggerEndlessAssault(IsEndlessAssaultNonOverridable(level_id))
                else
                    log(string.format("[BAI - ObjectivesManager] Objective %s is not active", GetLevelObjectivesToCheck(level_id)))
                end
            end
        else
            log(string.format("[BAI - ObjectivesManager] Level %s is not supported! Aborting", level_id))
        end
    end

	--[[if state then
		self._completed_objectives_ordered = state.completed_objectives_ordered

		for name, save_data in pairs(state.objective_map) do
			local objective_data = self._objectives[name]

			if save_data.active then
				if save_data.countdown then
					self:activate_objective_countdown(name, {
						current_amount = save_data.current_amount,
						amount = save_data.amount
					})
				else
					self:activate_objective(name, {
						current_amount = save_data.current_amount,
						amount = save_data.amount
					})
				end

				for sub_id, completed in pairs(save_data.sub_objective) do
					if completed then
						self:complete_sub_objective(name, sub_id, {})
					end
				end
			end

			if save_data.complete then
				self._completed_objectives[name] = objective_data
			end

			if save_data.read then
				self._read_objectives[name] = true
			end
		end
	end]]
end