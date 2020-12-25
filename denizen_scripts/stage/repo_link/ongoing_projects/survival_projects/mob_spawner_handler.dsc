mob_spawner_fragment:
  type: item
  material: prismarine_shard
  display name: <&b>Spawner Fragment
  debug: true
  mechanisms:
    custom_model_data: 1

mob_spawner_reinforced_fragment:
  type: item
  material: fire_charge
  display name: <&b>Reinforced Spawner Fragment
  debug: true
  mechanisms:
    custom_model_data: 3
  lore:
  - <&e>A very sturdy spawner shard.
  recipes:
    1:
      hide_in_recipebook: false
      type: shapeless
      output_quantity: 1
      input: mob_spawner_fragment|mob_spawner_fragment

mob_spawner_frame:
  type: item
  debug: true
  material: prismarine_shard
  display name: <&b>Spawner Frame
  mechanisms:
    custom_model_data: 2
  lore:
  - <&e>Capable of holding back immense power.
  recipes:
    1:
      hide_in_recipebook: false
      type: shaped
      output_quantity: 1
      input:
      - mob_spawner_fragment|mob_spawner_reinforced_fragment|mob_spawner_fragment
      - mob_spawner_fragment|mob_spawner_reinforced_fragment|mob_spawner_fragment
      - mob_spawner_fragment|mob_spawner_reinforced_fragment|mob_spawner_fragment

mob_spawner_core_uncharged:
  type: item
  material: fire_charge
  display name: <&b>Spawner Core (Uncharged)
  mechanisms:
    custom_model_data: 1
  lore:
  - <&c>This core seems dull and lifeless.
  debug: true
  recipes:
    1:
      hide_in_recipebook: false
      type: shaped
      output_quantity: 1
      input:
      - mob_spawner_fragment|mob_spawner_fragment|mob_spawner_fragment
      - mob_spawner_fragment|mob_spawner_fragment|mob_spawner_fragment
      - mob_spawner_fragment|mob_spawner_fragment|mob_spawner_fragment

mob_spawner_core_charged:
  debug: false
  type: item
  material: fire_charge
  display name: <&b>Spawner Core (Charged)
  mechanisms:
    custom_model_data: 2
    hides: all
  enchantments:
  - LUCK_OF_THE_SEA:1
  lore:
  - <&d>This core hums and pulses with power.
  recipes:
    1:
      hide_in_recipebook: false
      type: shaped
      output_quantity: 1
      input:
      - emerald|diamond|emerald
      - diamond|mob_spawner_core_uncharged|diamond
      - emerald|diamond|emerald

mob_spawner_completed:
  debug: false
  type: item
  material: spawner
  display name: <&a>Pig<&b> Spawner
  flags:
    mob: pig
  recipes:
    1:
      hide_in_recipebook: false
      type: shaped
      output_quantity: 1
      input:
      - mob_spawner_frame|mob_spawner_frame|mob_spawner_frame
      - mob_spawner_frame|mob_spawner_core_charged|mob_spawner_frame
      - mob_spawner_frame|mob_spawner_frame|mob_spawner_frame

mob_spawner_events:
  type: world
  debug: true
  events:
    on player places mob_spawner_completed:
    # - [check if item is valid]
    - if !<context.item_in_hand.has_flag[mob]>:
      - determine passively cancelled
      - narrate "<&4>This item was not marked correctly when created, please contact staff to claim a replacement."
      - stop
    - else:
      # - [set the entity type of the spawner]
      - define type <context.item_in_hand.flag[mob]>
      - wait 1t
      - adjust <context.location> spawner_type:<[type]>
      - flag server <context.location.simple>.spawner

    on player breaks spawner:
    # - [check for enchantment/item type]
    - if !<player.item_in_hand.enchantments.contains[silk_touch]> || !<player.item_in_hand.material.name.contains[pickaxe]>:
      - determine passively cancelled
      - ratelimit <player> 2s
      - actionbar "<&4>You must have silk touch pickaxe to break this!"
      - playsound <player.location> sound:entity_villager_no volume:2
    - else:
      # - [if vanilla spawner, give fragments]
      - if !<server.has_flag[<context.location.simple>.spawner]>:
          - determine <item[mob_spawner_fragment].with[quantity=25]>
      # - [ if not, give spawner with entity type attached]
      - else if <server.has_flag[<context.location.simple>.spawner]>:
        - define Type <context.location.spawner_type.entity_type.to_titlecase>
        - determine "<item[mob_spawner_completed].with_flag[mob:<[type]>].with[display_name=<&a><[Type]><&b> Spawner]>"
        - flag server <context.location.simple>.spawner:!
      - else:
      # - [ if neither, something bork and get halp]
        - determine passively cancelled
        - narrate "<&4>This location was not marked correctly when the spawner was placed. Contact staff to claim a spawner replacement please."

    on spawner spawns entity:
    # - [check if vanilla spawner and stop if so]
    - if !<server.has_flag[<context.spawner_location.simple>.spawner]>:
      - stop
    - else:
      # - [check if the counter mob exists already]
      - if !<server.has_flag[<context.spawner_location.simple>.spawner_mob_tracker]>:
        # # [flag the entity as 1 stack]
        - flag <context.entity> spawner_counter:1
        # # [flag the entity with the location it was spawned at to clear on death]
        - flag <context.entity> spawned_by:<context.spawner_location.simple>
        # # [flag the server with the mob's uuid to track it down later to add more stacks]
        - flag server <context.spawner_location.simple>.spawner_mob_tracker:<context.entity.uuid>
        # # [ nuke mob ai and set name for server lag reduction]
        - adjust <context.entity> has_ai:false
        - adjust <context.entity> "custom_name:<&b>Pacified <context.entity.entity_type.to_titlecase> (<&e><context.entity.flag[spawner_counter]>)"
      - else:
        # - [if the mob already exists, we just want to add a stack to the counter, not spawn an additional entity]
        - determine passively cancelled
        # # [retrieve the UUID of the mob set previously, and increase the counter by 1 and then rename the mob]
        - flag <server.flag[<context.spawner_location.simple>.spawner_mob_tracker]> spawner_counter:++
        - adjust <context.entity> "custom_name:<&b>Pacified <context.entity.entity_type.to_titlecase> (<&e><context.entity.flag[spawner_counter]>)"

    on entity dies flagged:spawned_by:
    # - [if the mob isn't flagged, or has 1 stack (less than 2) let it die]
    - if <context.entity.flag[spawner_counter]||0> < 2:
      - flag server <context.spawner_location.simple>.spawner_mob_tracker:!
      - stop
    - else:
      # # [let the mob drop its drops]
      - drop <context.drops>
      # # [stop the death]
      - determine passively cancelled
      # # [ decrease counter, heal to full, rename to update stacks on mob]
      - flag <context.entity> spawner_counter:--
      - heal <context.entity>
      - adjust <context.entity> "custom_name:<&b>Pacified <context.entity.entity_type.to_titlecase> (<&e><context.entity.flag[spawner_counter]>)"
