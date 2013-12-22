function LazyPigMultibox_Mage(dps, dps_pet, heal, rez, buff)
	local locked = Zorlen_isChanneling() or Zorlen_isCasting()
	
	if locked  then
		return true
	end
	
	if dps then
		if not locked then		
			if Zorlen_IsSpellKnown("Frostbolt") then
				castFrostbolt();
			else	
				castFireball();
			end	
		end	
	end	
	
	if buff then
		LazyPigMultibox_UnitBuff();
	end
end