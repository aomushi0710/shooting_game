extends RefCounted
class_name ParamID

enum ID { ## パラメータの一覧とそのID
	NONE = -1,
	# 以下、基礎パラメータ
	HP, ## 体力
	DAMAGE, ## 攻撃力
	MOVE_SPEED, ## 移動速度
	PENETRATION, ## 貫通力
	BULLET_SPEED, ## 弾速
	FIRE_RATE, ## 連射力
	LIFE_TIME, ## 持続時間
	# 以下、固有パラメータ
	PELLET_COUNT = 100, ## 散弾数(ショットガン専用)
	EXPLOSION_RADIUS, ## 爆発半径(ミサイル専用)
	HOMING_STRENGTH, ## 追尾力(ホーミング専用)
	LASER_WIDTH, ## レーザー幅(レーザー専用)
}
