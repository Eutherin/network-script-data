single_sleep_script:
  type: world
  debug: false
  time_change_duration_in_ticks: 60
  events:
    on player enters bed:
      - announce "<&6><player.display_name> <&e>went to bed. Sweet Dreams!"
      - ratelimit <player.world> 10s
      - define increment <world[mainland].time.sub[24000].abs.div[<script[single_sleep_script].data_key[time_change_duration_in_ticks]>].round_up>
      - repeat <script[single_sleep_script].data_key[time_change_duration_in_ticks]>:
        - adjust <world[mainland]> time:<world[mainland].time.add[<[increment]>]>
        - wait 1t
      - if <world[mainland].thundering>:
        - adjust <world[mainland]> thundering:false
