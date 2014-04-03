function LazyPigMultibox_Rogue(dps, dps_pet, heal, rez, buff)
	
	if dps then
		--Smart_Skill()
		castBladeFlurry()
		Adrenaline()
		Smart_Slice()
		castSinisterStrike()
		castAttack()
	end	
	
	if buff then
		LazyPigMultibox_UnitBuff();
	end

end