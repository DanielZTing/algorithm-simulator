class_name BubbleSort
extends ComparisonSort

const NAME = "BUBBLE SORT"
const ABOUT = """
Bubble sort iterates through the array and looks at each pair of
elements, swapping them if they are out of order. When it has gone
through the entire array without swapping a single pair, it has
finished. Though simple to understand, bubble sort is hopelessly
inefficient on all but the smallest of arrays.
"""
const CONTROLS = """
If the two highlighted elements are out of order, hit LEFT ARROW to swap
them. Otherwise, hit RIGHT ARROW to continue.
"""

const ACTIONS = {
    "SWAP": "Left",
    "CONTINUE": "Right",
}
var _index = 0 # First of two elements being compared
var _end = array.size # Beginning of sorted subarray
var _swapped = false

func _init(array).(array):
    pass

func next(action):
    if array.at(_index) > array.at(_index + 1):
        if action != null and action != ACTIONS.SWAP:
            return emit_signal("mistake")
        array.swap(_index, _index + 1)
        _swapped = true
    elif action != null and action != ACTIONS.CONTINUE:
        return emit_signal("mistake")
    _index += 1
    # Prevent player from having to spam tap through the end
    if _index + 1 == _end:
        if not _swapped or _end == 2: # Stop if only one element left
            emit_signal("done")
        _index = 0
        _end -= 1
        _swapped = false

func get_effect(i):
    if i == _index or i == _index + 1:
        return EFFECTS.HIGHLIGHTED
    if i >= _end:
        return EFFECTS.DIMMED
    return EFFECTS.NONE
