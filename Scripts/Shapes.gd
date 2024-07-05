extends Node

func get_circle_points(rad:int, many_points:int = 36):
    var points = []
    for point in range(many_points+1):
        var angle = point * 2*PI / many_points;
        var x = rad * cos(angle)
        var y = rad * sin(angle)
        points.append(Vector2(x,y))
    return points

func get_half_torus_points(in_rad:int, out_rad:int, many_points:int = 18):
    var points = []

    for point in range(many_points+1):
        var angle = point * PI / many_points;
        var x = in_rad * cos(angle)
        var y = in_rad * sin(angle)
        points.append(Vector2(x,y))
	
    for point in range(many_points, -1,-1):
        var angle = point * PI / many_points;
        var x = out_rad * cos(angle)
        var y = out_rad * sin(angle)
        points.append(Vector2(x,y))

    return points

func get_any_degree_torus_points(in_rad:int, out_rad:int, circle_deg:int):
    var points = []
    var many_points:int = circle_deg / 10
    for point in range(many_points+1):
        var angle = point * deg_to_rad(circle_deg) / many_points;
        var x = in_rad * cos(angle)
        var y = in_rad * sin(angle)
        points.append(Vector2(x,y))
	
    for point in range(many_points, -1,-1):
        var angle = point * deg_to_rad(circle_deg) / many_points;
        var x = out_rad * cos(angle)
        var y = out_rad * sin(angle)
        points.append(Vector2(x,y))
    
    return points


func get_lance_points(lance_long:int, lance_width:int):
    var points = []

    points.append(Vector2(lance_width, 0))
    points.append(Vector2(-lance_width, 0))
    points.append(Vector2(int(-lance_width*0.6), lance_long))
    points.append(Vector2(int(lance_width*0.6), lance_long))
    return points
