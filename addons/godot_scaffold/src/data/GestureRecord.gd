class_name GestureRecord
extends Node2D

# Array<GestureEventForDebugging>
var recent_gesture_events_for_debugging := []

func _init() -> void:
    name = "GestureRecord"

func _input(event: InputEvent) -> void:
    if (Gs.debug or Gs.playtest) and \
            (event is InputEventScreenTouch or event is InputEventScreenDrag):
        _record_new_gesture_event(event)

func _record_new_gesture_event(event: InputEvent) -> void:
    var gesture_name: String
    if event is InputEventScreenTouch:
        gesture_name = "do" if event.pressed else "up"
    elif event is InputEventScreenDrag:
        gesture_name = "dr"
    else:
        Gs.utils.error()
        return
    var gesture_event := GestureEventForDebugging.new( \
            event.position, \
            gesture_name, \
            Gs.time.elapsed_play_time_actual_sec)
    recent_gesture_events_for_debugging.push_front(gesture_event)
    while recent_gesture_events_for_debugging.size() > \
            Gs.recent_gesture_events_for_debugging_buffer_size:
        recent_gesture_events_for_debugging.pop_back()

class GestureEventForDebugging extends Reference:
    var position: Vector2
    var name: String
    var time_sec: float
    
    func _init( \
            position: Vector2, \
            name: String, \
            time_sec: float) -> void:
        self.position = position
        self.name = name
        self.time_sec = time_sec
    
    func to_string() -> String:
        return "{%s;(%.2f,%.2f);%.3f}" % [
            name,
            position.x,
            position.y,
            time_sec,
        ]
