# ABetterPlayerTooltip
![An example of the tooltip](https://github.com/piergerlofsdonia/ABetterPlayerTooltip/blob/master/ABetterTooltip.png)

Designed to act as a replacement for the generic player tooltip, the ABPTT frame shows player name, class, guild details, player-versus-player rank, and level in a compact form (see: above).

## Installation:
1. Clone the repo.
2. Move the ABPTT folder to your <WoW Location>/Interface/Addons folder.
3. Restart WoW to init the new files.
  
## Usage:
The addon will automatically initalise the tooltip frame and reveal it when a player is targeted or hovered-over. There are, however, some configuration options available:
* To disable the 'mouseover' functionality, use the chat command `/nomo` or `/nomouseover`
* To change the time window in which the tooltip displays, use the chat command `/ttf <time value>` or `/ttfade <time value>` (e.g. `/ttf 10` to change the window fade interval to 10 seconds.
* To change the position of the tooltip, or permanently show it, use the chat command `/abptt` or `ttmove` or just `/tt`. Once you have positioned the tooltip, use the same command to set the frame back to being non-interactive. 
* To disable the tooltip entirely use the chat command `/ttd` or `/ttdisable`, re-use the command to re-enable the tooltip.
