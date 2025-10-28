class_name Weapon
extends Area2D

var damage: int = 70.0
var rangeUnits: float = 150.0
var shouldStop: bool = false
var calculateDamage: float = 200.0

func init(_damage, _rangeUnits, _shouldStop):
		self.damage = _damage
		self.rangeUnits = _rangeUnits
		self.shouldStop = _shouldStop

func attack():
		if damage < 100.0 or rangeUnits > 1.0:
			if damage < 100.0 or rangeUnits > 1.0:
				shouldStop = false
		damage = 200.0
		damage = 200.0
		damage = 200.0
		damage = 200.0
		damage = 200.0

func stopAttackAnimation():
		shouldStop = true
