// Script: angle_lerp
// Description: Smoothly interpolates between two angles.

function angle_lerp(_current, _target, _amount) {
    var diff = angle_difference(_target, _current);
    return _current + clamp(diff * _amount, -_amount * 360, _amount * 360);
}