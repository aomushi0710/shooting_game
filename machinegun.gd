@tool
extends Bullet
class_name BulletMachinegun

@onready var color_node = $Color

@export var bullet_color: Color:
	set(value):
		bullet_color = value
		if color_node:
			color_node.modulate = value

func _ready() -> void:
	super()
	color_node.play()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	velocity = Vector2.RIGHT * bullet_speed * BULLET_SPEED_SCALE
	
	if move_and_slide():
		_handle_collision()

## 弾が衝突した時に呼ばれる関数。[br]
## プレイヤーの弾が敵に当たった(あるいはその逆)時、ダメージを与えつつ弾は消滅する。
func _handle_collision() -> void:
	var collision := get_last_slide_collision() ## 衝突した当たり判定そのもの
	var collider := collision.get_collider() ## 衝突した当たり判定を持つ親ノード
	
	if collider is Player:
		collider.take_damage(damage, false)
	
	elif collider is CharacterBase:
		collider.take_damage(damage)
	
	queue_free()
