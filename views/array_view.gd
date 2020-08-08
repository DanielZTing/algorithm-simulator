"""
Visualization of an array as rectangles of varying heights.
"""

class_name ArrayView
extends ViewportContainer

const ANIM_DURATION = 0.1

var _tween = Tween.new()
var _level: ComparisonSort
var _rects = []
var _positions = []
var _viewport = Viewport.new()
var _pointer = null
var _pointer_size: int
onready var _separation = 128 / _level.array.size

func _init(level):
    _level = level
    stretch = true
    _viewport.usage = Viewport.USAGE_2D
    add_child(_level) # NOTE: This is necessary for it to read input
    add_child(_tween) # NOTE: This is necessary for it to animate
    add_child(_viewport)

func _ready():
    yield(get_tree(), "idle_frame")
    var unit_width = rect_size.x / _level.array.size
    _pointer_size = max((unit_width - _separation) / 4, 2)
    # Keep track of accumulated pixel error from integer division
    var error = float(rect_size.x) / _level.array.size - unit_width
    var accumulated = 0
    var x = 0
    _level.connect("mistake", get_parent(), "flash")
    var width = unit_width - _separation
    var height = rect_size.y - _pointer_size * 2
    for i in range(_level.array.size):
        var rect = Polygon2D.new()
        if accumulated >= 1:
            x += 1
            accumulated -= 1
        rect.polygon = [
            Vector2(0, 0),
            Vector2(0, height),
            Vector2(width, height),
            Vector2(width, 0),
        ]
        accumulated += error
        rect.position = Vector2(x, rect_size.y)
        _positions.append(x)
        x += unit_width
        _rects.append(rect)
        _viewport.add_child(rect)
    _level.array.connect("swapped", self, "_on_ArrayModel_swapped")
    _level.array.connect("sorted", self, "_on_ArrayModel_sorted")
    if _level.has_method("get_pointer"):
        _pointer = Polygon2D.new()
        _pointer.polygon = [
            Vector2(width / 2, _pointer_size),
            Vector2(width / 2 - _pointer_size, 0),
            Vector2(width / 2 + _pointer_size, 0),
        ]
        _pointer.color = GlobalTheme.BLUE
        _viewport.add_child(_pointer)

func _process(delta):
    if _pointer != null:
        var pointed = _level.get_pointer()
        var height = rect_size.y - _pointer_size * 2
        _pointer.position = Vector2(_rects[pointed].position.x,
            height - _level.array.frac(pointed) * height)
        if _level.done:
            _pointer.queue_free()
    for i in range(_rects.size()):
        if _level.done:
            _rects[i].color = ComparisonSort.EFFECTS.NONE
        else:
            _rects[i].color = _level.get_effect(i)
        _rects[i].scale.y = -_level.array.frac(i)

func _on_ArrayModel_swapped(i, j):
    var time = ANIM_DURATION * (1 + float(j - i) / _level.array.size)
    _tween.interpolate_property(
        _rects[i], "position:x", null, _positions[j], time)
    _tween.interpolate_property(
        _rects[j], "position:x", null, _positions[i], time)
    var temp = _rects[i]
    _rects[i] = _rects[j]
    _rects[j] = temp
    _tween.start()

func _on_ArrayModel_sorted(i, j):
    for x in range(i, j):
        _rects[x].position.y = 0
    for x in range(i, j):
        _tween.interpolate_property(
            _rects[x], "position:y", null, rect_size.y, ANIM_DURATION)
    _tween.start()
