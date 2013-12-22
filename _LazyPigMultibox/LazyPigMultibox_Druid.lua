function LazyPigMultibox_Druid(dps, dps_pet, heal, rez, buff)
	
	local locked = Zorlen_isChanneling() or Zorlen_isCasting()
	
	if locked then
		return true
	end
	
	if heal then

	end
	
	if dps then

	end
	
	if buff then
		LazyPigMultibox_UnitBuff();
	end
end