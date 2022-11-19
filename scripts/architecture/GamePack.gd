extends Resource
class_name GamePack

## Class for game packs (bundles of content)
## that can be loaded by Star Engine
## to offer additional content.

@export_category("GamePack")

## The display name of this pack
@export var display_name = "New Game"
## The id of this pack
@export var id = "new_game"
@export var version = "1.0.0"
@export var star_engine_version = "alpha"
## The bundle id of this pack.
## [br][br]
## A bundle is a collection of packs
## that work together (part of the same game).
@export var bundle_id = "new_game"
## Whether this is a 'core' pack, which
## adds the bulk content of a game...
## or an extra back which adds content
## like scenes, dialogue, sidequests.
## [br][br]
## If a pack is a main pack, and there are many
## main packs located in the packs folder,
## a game select screen will appear.
@export var is_core_pack = true
