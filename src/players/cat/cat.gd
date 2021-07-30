tool
class_name CatPlayer
extends SurfacerPlayer


# Dictionary<Player, boolean>
var current_colliding_computer_players := {}
var just_collided_with_new_computer_player := false


func _process_sounds() -> void:
    if just_triggered_jump:
        Sc.audio.play_sound("cat_jump")
    
    if surface_state.just_left_air:
        Sc.audio.play_sound("cat_land")
    
    if just_collided_with_new_computer_player:
        Sc.audio.play_sound("contact")


func _update_surface_state(preserves_just_changed_state := false) -> void:
    ._update_surface_state(preserves_just_changed_state)
    _check_for_squirrel_collision()


# TODO: Replace with a more accurate/standard collision/mask-layer setup.
func _check_for_squirrel_collision() -> void:
    var collider_half_width_height := movement_params.collider_half_width_height

    var cat_min_half_dimension: float
    var cat_max_half_dimension: float
    if collider_half_width_height.x > collider_half_width_height.y:
        cat_max_half_dimension = collider_half_width_height.x
        cat_min_half_dimension = collider_half_width_height.y
    else:
        cat_max_half_dimension = collider_half_width_height.y
        cat_min_half_dimension = collider_half_width_height.x
    
    # Calculate current computer-player collisions.
    var colliding_computer_players := []
    for computer_player in Sc.utils.get_all_nodes_in_group(
            Su.group_name_computer_players):
        collider_half_width_height = \
                computer_player.movement_params.collider_half_width_height
        
        var cp_min_half_dimension: float
        var cp_max_half_dimension: float
        if collider_half_width_height.x > collider_half_width_height.y:
            cp_max_half_dimension = collider_half_width_height.x
            cp_min_half_dimension = collider_half_width_height.y
        else:
            cp_max_half_dimension = collider_half_width_height.y
            cp_min_half_dimension = collider_half_width_height.x
        
        var distance_squared_collision_threshold: float
        if cat_max_half_dimension > cp_max_half_dimension:
            distance_squared_collision_threshold = \
                    cat_min_half_dimension * cat_min_half_dimension
        else:
            distance_squared_collision_threshold = \
                    cp_min_half_dimension * cp_min_half_dimension
        
        if position.distance_squared_to(computer_player.position) < \
                distance_squared_collision_threshold:
            colliding_computer_players.push_back(computer_player)
    
    # Record whether there were any new collisions this frame.
    just_collided_with_new_computer_player = false
    for computer_player in colliding_computer_players:
        if !current_colliding_computer_players.has(computer_player):
            just_collided_with_new_computer_player = true
    
    # Update the current collision set.
    current_colliding_computer_players.clear()
    for computer_player in colliding_computer_players:
        current_colliding_computer_players[computer_player] = true
