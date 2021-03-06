mythicmobs_levelscale_patch:
  type: world
  debug: true
  vanilla_replacements: SKELETON1|HUSK1|ZOMBIE1|SPIDER1|CAVE_SPIDER1|ENDERMAN1|CREEPER1|ENDERMAN1_VOIDWORM|HUSK1_BURNING|VINDICATOR1|PILLAGER1|HUSK1_MAGGOTS|SILVERFISH1|WOLF1|POLAR_BEAR1|PANDA1|STRAY1|STRAYWOLF1|DROWNED1|PHANTOM1|EVOKER1|CAVE_SPIDER1|SLIME1|VEX1|GUARDIAN1|ELDER_GUARDIAN1
  events:
    on player damaged by skeleton|drowned|stray bukkit_priority:highest:
      - if <context.damager.is_mythicmob>:
        - if <script.data_key[vanilla_replacements].contains[<context.damager.mythicmob.internal_name>]>:
          - determine <context.damager.mythicmob.level.mul[4]>

    on player knocks back entity:
      - if <context.entity.is_mythicmob>:
        # % ████████ [ allows knockback enchant to still work ] ████████
        - if <player.item_in_hand.is_enchanted> && <player.item_in_hand.enchantments.contains[knockback]>:
          - stop
        # % ████████ [ roll a random number to compare to mob level ] ████████
        - define chance <util.random.int[1].to[10]>
        # % ████████ [ gives a 10% chance to ignore mob knockback adjust the .to[] value to adjust the chance. if its greater than mob level, it stops the script] ████████
        - if <[chance]> > <context.entity.mythicmob.level>:
          - stop
        - determine cancelled

    on mythicmob mob spawns:
      - if <script[mythicmobs_levelscale_patch].data_key[vanilla_replacements].contains[<context.mob.internal_name>]>:
        - wait 2t
        # % ████████ [ Grab the base stats ] ████████
        - define mob_level <context.mob.level>
        - define base_speed <context.entity.speed>
        - define base_armor <context.mob.armor>
        # ^ ████████ [ calculate the modifiers ] ████████
        - define speed_modifier <[mob_level].mul[0.01]>
        - define armor_modifier <[mob_level].mul[2]>
        - wait 2t
        # ^ ████████ [ adjust the stats ] ████████
        - adjust <context.entity> speed:<[base_speed].add[<[speed_modifier]>]>
        - adjust <context.entity> armor_bonus:<[base_armor].add[<[armor_modifier]>]>