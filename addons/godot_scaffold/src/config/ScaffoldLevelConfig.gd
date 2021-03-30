class_name ScaffoldLevelConfig
extends Node

# NOTE: Level config Dictionaries must have the following properties:
# -   name: String: Try to keep this short and memorable.
# -   version: String: Of the form "0.0.1".
# -   priority: int: Must be unique. Earlier levels have lower values.
# -   One of (according to are_levels_scene_based):
#     -   scene_path: String
#     -   script_class: Class

# NOTE: Level config Dictionaries will updated to include the following
#       auto-calculated properties:
# -   id: String
# -   number: int

var are_levels_scene_based: bool
var _level_configs_by_number := {}

func _init(are_levels_scene_based: bool) -> void:
    print("ScaffoldLevelConfig._init")
    self.are_levels_scene_based = are_levels_scene_based

func _ready() -> void:
    _clear_old_version_level_state()
    
    _sanitize_level_configs()
    
    Gs.save_state.set_level_is_unlocked(_level_configs_by_number[1].id, true)

func _sanitize_level_configs() -> void:
    var level_configs_by_priority := {}
    var priorities := []
    for level_id in get_level_ids():
        var config := get_level_config(level_id)
        assert(config.has("name") and config.name is String)
        assert(config.has("version") and config.version is String)
        assert(config.has("priority") and config.priority is int)
        assert(are_levels_scene_based and \
                config.has("scene_path") and \
                config.scene_path is String and \
                !config.has("script_class") or \
                !are_levels_scene_based and \
                config.has("script_class") and \
                !config.has("scene_path"))
        config.id = level_id
        level_configs_by_priority[config.priority] = config
        priorities.push_back(config.priority)
    
    priorities.sort()
    var number := 1
    for priority in priorities:
        var config: Dictionary = level_configs_by_priority[priority]
        config.number = number
        _level_configs_by_number[number] = config
        number += 1

func get_level_config(level_id: String) -> Dictionary:
    Gs.utils.error( \
            "Abstract ScaffoldLevelConfig.get_level_config is not implemented")
    return {}

func get_level_ids() -> Array:
    Gs.utils.error( \
            "Abstract ScaffoldLevelConfig.get_level_ids is not implemented")
    return []

func get_level_version_string(level_id: String) -> String:
    return level_id + "v" + get_level_config(level_id).version

func _clear_old_version_level_state() -> void:
    if Gs.score_version != Gs.save_state.get_score_version():
        Gs.save_state.set_score_version(Gs.score_version)
        Gs.save_state.erase_all_scores()
    
    for level_id in get_level_ids():
        var config := get_level_config(level_id)
        if config.version != Gs.save_state.get_level_version(level_id):
            Gs.save_state.erase_level_state(level_id)
            Gs.save_state.set_level_version(level_id, config.version)

func _get_number_from_version(version: String) -> int:
    var parts := version.split(".")
    assert(parts.size() == 3)
    return int(parts[0]) * 1000000 + int(parts[1]) * 1000 + int(parts[2])

func get_old_unlocked_levels() -> Array:
    var old_unlocked_levels := []
    for level_id in get_level_ids():
        if Gs.save_state.get_level_is_unlocked(level_id):
            old_unlocked_levels.push_back(level_id)
    return old_unlocked_levels

func get_new_unlocked_levels() -> Array:
    var new_unlocked_levels := []
    for level_id in get_level_ids():
        if !Gs.save_state.get_level_is_unlocked(level_id) and \
                _check_if_level_meets_unlock_conditions(level_id):
            new_unlocked_levels.push_back(level_id)
    return new_unlocked_levels

func _check_if_level_meets_unlock_conditions(level_id: String) -> bool:
    return get_unlock_hint(level_id) == ""

func get_unlock_hint(level_id: String) -> String:
    Gs.utils.error( \
            "Abstract ScaffoldLevelConfig.get_unlock_hint is not implemented")
    return "Not yet unlocked" if \
            !Gs.save_state.get_level_is_unlocked(level_id) else \
            ""

func get_next_level_to_unlock() -> String:
    var locked_level_numbers := []
    for level_id in get_level_ids():
        if !Gs.save_state.get_level_is_unlocked(level_id):
            var config := get_level_config(level_id)
            locked_level_numbers.push_back(config.number)
    locked_level_numbers.sort()
    
    if locked_level_numbers.empty():
        return ""
    else:
        return _level_configs_by_number[locked_level_numbers.front()].id

func get_suggested_next_level() -> String:
    Gs.utils.error( \
            "Abstract ScaffoldLevelConfig.get_suggested_next_level " + \
            "is not implemented")
    return _level_configs_by_number[1].id
