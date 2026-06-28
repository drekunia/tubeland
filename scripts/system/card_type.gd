## Shared enum for all card types in the game.
## Referenced by CardPickup, PlayerController, and CardHUD.
class_name CardType

enum Type {
	ELEVATE,   ## Upward burst — escape vertical threats
	GODSPEED,  ## Horizontal dash in facing direction — cover ground fast
	FIREBALL,  ## Full 3D dash toward the crosshair — aim and rocket yourself
}
