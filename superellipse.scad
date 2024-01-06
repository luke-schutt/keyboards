module superellipse(n, n1, n2, a, b) {
    nx = is_undef(n1) ? n : n1;
    ny = is_undef(n2) ? n : n2;
    polygon([for (t = [0 : min($fa, 360 / $fn) : 360]) [
        (abs(cos(t)) ^ (2 / nx)) * a * (cos(t) >= 0 ? 1 : -1),
        (abs(sin(t)) ^ (2 / ny)) * b * (sin(t) >= 0 ? 1 : -1)
    ]]);
}