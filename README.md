--== _LazyPigMultibox  1.12.1 Wow Multiboxing Project ==--


If you have any idea how to improve code or manual section feel free to contribute to this project.
More detailed info can be found in _LazyPigMultibox/Manual directory.

--==Version 1.0

read general_info.txt

--==Version 2.0 

_LazyPig Multibox is now optimized to use with Warlock, Shaman, Paladin and Priest classes - best script support

1) General Improvements
- Greatly Improved GUI
- SmartBuff support
- Fast and Normal healing modes
- Better Event Handler

2) Introduced Sniper Mode (to enable you have to check IMPROVED TARGETING and ACTIVE ENEMY ONLY or ACTIVE NPC ENEMY ONLY) 
- thanks to Sniper Mode we have better pet control in the group, every pet can attack diffrent target using "LazyPigMultibox_SPA" - Expert Mode function or "LPM PET ATTACK" - Novice Mode macro described below

more about Expert and Novice Mode - using_macros_part1.txt


3) added four new functions for best macro efficiency
- LazyPigMultibox_SPA(slave_master_name, icon_index, modifier) --selective pet attack
- LazyPigMultibox_SFL(slave_master_name, task, duration, modifier) -- selective function launch
- LazyPigMultibox_SCS(slave_master_name, spell_name, duration, mana, modifier) -- selective cast spell
- LazyPigMultibox_SUB(slave_master_name, modifier) --selective unit buff


- to use function above you have to enable Sniper Mode(check point 2)
- check using_macros1.txt file for more info
- examples available in _MyCustomFuntions.lua file

4) optimized or added new spells for Paladin, Shaman and Warlock

- Warlock(Drain Soul, Drain Life, Curse of Agony, Curse of Shadows(unique spell), Corruption, Siphon Life, Sacrifice, Suffering, Life Tap, Fel Domination)

- Paladin(Judgement, Seal of wisdom(unique spell), Judgement of wisdom(unique spell), Flash of light, Divine Favor, Blessing of Protection, Divine Shield, Lay on Hands, Hammer of wrath)

- Shaman(Mana Tide Totem, Nature's Swiftness, Lightning Bolt, Chain Lightning, Earth Shock)

5) added new macros for Paladin and Warlock(remember to use macro create button in LPM GUI)

6) Introduced Unique Spell mechanism for certain classes(only one uinque option can be selected for each class in the group - multiple addon instances 

sync)
- Paladin: casting judgement of wisdom - on enemies with health 4x > ours - bosses, hard elites etc..
- Paladin: reverse resurrection - avoid resurrecting same player by other multiboxed healers in the group 
- Shaman: reverse resurrection
- Warlock: Curse of Shadow

7) Greatly Improved LPM TARGET macro
- each use toggles between lowest and highest hp target
- enemy attacking group member prio targeting
- asspull protection(do not target ooc enemies while you are in combat)

8) Greatly improved manual section
- using_macros_part1.txt
- using_macros_part2.txt
- using_smart_buff.txt
- using_quick_heal.txt
- optimzed_class_builds.txt


cheers Ogrisch
