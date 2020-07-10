--Spawns everything correctly without doing any networking (which we don't need) and without bs
function ManageSpawnedUnits:spawn_bainscript(unit_id, align_obj_name, unit)
	local align_obj = self._unit:get_object(Idstring(align_obj_name))
	local spawn_unit

	if type_name(unit) == "string" then
		local spawn_pos = align_obj:position()
		local spawn_rot = align_obj:rotation()

		spawn_unit = safe_spawn_unit(Idstring(unit), spawn_pos, spawn_rot)
		spawn_unit:unit_data().parent_unit = self._unit
	elseif unit then
		spawn_unit = unit
	else
		return
	end

	self._unit:link(Idstring(align_obj_name), spawn_unit, spawn_unit:orientation_object():name())
	self._spawned_units[unit_id] = {align_obj_name = align_obj_name, unit = spawn_unit}
end

function ManageSpawnedUnits:link_bainscript(joint_table, unit_id, unit)
	if self._spawned_units[unit_id] then
		return
	end

	if not self[joint_table] then
		print("[ManageSpawnedUnits] No table named:", joint_table, "in unit file:", self._unit:name())
		return
	end

	if not unit_id then
		log("[ManageSpawnedUnits] param2", "nil:\n", self._unit:name())
		return
	end

	if not unit then
		log("[ManageSpawnedUnits] param3", "nil:\n", self._unit:name())
		return
	end

	self:spawn_bainscript(unit_id, self[joint_table][1], unit)
	self:_link_joints(unit_id, joint_table)

	local spawned_unit = self._spawned_units[unit_id] and self._spawned_units[unit_id].unit
	if spawned_unit and spawned_unit:base() and spawned_unit:base().on_unit_link_successful then
		spawned_unit:base():on_unit_link_successful(self._unit)
	end
end