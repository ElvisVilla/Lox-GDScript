# GDBraces / GDScript with { }
This project is a GDscript implementation of the Lox programing lenguage from "Crafting Interpreters" by Robert Nystrom.

## Motivation:
This project tries to solve one mising flavor in GDScript and that is, the possibility of using braces { } instead of identation,

Other features that will come to GDBraces are:
- Extension methods
- Trailing Closures:
```
  func ready() {
    # Trailing closures for annonymous functions / Callables
    area.areaEntered { area in
      print(area)
    }

    # current Callable Sintax
    area.area_entered(func(area):
      print(area) \
    )
  }
```
- C ternary sintax
```
  currentDefense = isShielded ? increasedDefense : reducedDefense
```
- 


## Goal (Not all the sintax is already implemented):
```
class Player : CharacterBody2D {

  var speed : float
  var damage: int

  // get property
  var isMoving : bool {
    return velocity != Vector.ZERO
  }

  // get set property
  var health: int = 100 {
    get {
      return self.health
    }
    set(value) { 
      self.health = value
    }
  }

  func move(direction: Vector2, delta: float) -> void {
    velocity += direction * speed * delta
  }

  func process(delta: float) {

    var direction = Input.getVector("ui_left", "ui_right", "ui_up", "ui_down")    
    move(direction, delta)
    moveAndSlide()
  }

}

```


