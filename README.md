# Base Libs
----
Base libs is a collection of the most essential libraries - vectors, lines, math, etc - for game development in Lua.

# Vec.lua
----
Vec.lua is a vector class library for game development. It is designed to be loaded like so:

```
local Vec = require("Vec")(VECTOR)
```

The function returned by `Vec` returns a local vector lib object, assigns the vector lib object to any variable arguments, and assigns the vector lib object to global context items to locations defined by any string arguments. This vector lib object can then be used to define new vector objects, like so:

```
local vec = Vec(0,0)
```

The new vector has an x component of 0 and a y component of 0. The local variable foo becomes the new vector object, and can now be used as such.
The vector library currently supports the following operations through metamethods:

>* (`+`) addition
* (`-`) subtraction
* (`*`) multiplication
* (`/`) division
* (`%`) modulus
* (`^`) power *(this is done vie lua's core ^ operator, which may function differently depending on the implementation)*
* (`..`) dot product
* (`==`) equality check
* (`>`/`<`) greater-than/less-than check
* (`>=`/`<=`) greater-than-or-equal-to/less-than-or-equal-to check
* (`tostring()`) `tostring` function usage

All the math operations return a new vector with the result, thus potentially impacting performance.
The following functions and properties are also supported:

>* `vec.a` returns the angle of the vector from the origin *(`math.atan2(vec.y,vec.x)`)*
* `vec.l` returns the length of the vector *(can be slow when used repeatedly due to use of `math.sqrt()`)*
* `vec.n` returns a unit vector of the same angle *(make suse of `vec.l`, beware!)*
* `vec.max` returns the largest component of the vector *(uses `>`, so negative numbers are considered smaller)*
* `vec.min` returns the smallest component of the vector *(uses `<`, so negative numbers are considered smaller)*
* `vec.r` returns a vector with the components reversed
* `vec.abs` returns a vector with absolute values of the components

>* `vec:dist(vec2)` returns the distance between the vectors
* `vec:copy(dx,dy)` `vec:copy(dv)` copies vec, adding either the delta x and y or the delta vector.
* `vec:dec(vec2)` garbageless shorthand for `vec = vec - vec2`
* `vec:add(vec2)` garbageless shorthand for `vec = vec + vec2`
* `vec:mul(vec2)` garbageless shorthand for `vec = vec * vec2`
* `vec:div(vec2)` garbageless shorthand for `vec = vec / vec2`
* `vec:mod(vec2)` garbageless shorthand for `vec = vec % vec2`
* `vec:set(vec2)` copies the values of vec2 into vec

* `vec:del()` garbage recycling for vec; pushes vec onto the reuse stack for future vectors to save RAM.

# Rec.lua
----
Rec.lua is a rectangle class library which functions very similarly to Vec.lua, and in fact requires Vec.lua to work. Upon load, it will attempt to load Vec from multiple sources, or use it if there's already a global \_VECTOR variable defined.
Rec.lua is loaded the same as Vec.lua

The constructor is also similar:

```
local rec = Rec(0,0,10,10)
```

This creates an axis-aligned rectangle object with its top left corner (bottom left if you're not using inverted y coords) at 0,0 and a width and height of 10 and 10.
These components can be accessed as `rect.x`, `rect.y`, `rect.w`, and `rect.h` respectively.

Rectangle objects support the following properties, which can be both read and written, having operations for both:

>* `rec.l` the left side of the rectangle - returns x, sets x
* `rec.r` the right side of the rectangle - returns x + w, sets x (with offset of w)
* `rec.t` the top side of the rectangle (in inv y) - returns y, sets y
* `rec.b` the bottom side of the rectangle (in inv y) - returns y + h, sets y (with offset of h)
* `rec.mx` the middle x coordinate of the rectangle - returns x + w/2, sets x (with offset of w/2)
* `rec.my` the middle y coordinate of the rectangle - returns y + h/2, sets y (with offset of h/2)
* `rec.pos` the top left vector of the rectangle (in inv y)
* `rec.pos` the top left vector of the rectangle (in inv y)
* `rec.pos1` the top left vector of the rectangle (in inv y)
* `rec.pos2` the top right vector of the rectangle (in inv y)
* `rec.pos3` the bottom right vector of the rectangle (in inv y)
* `rec.pos4` the bottom left vector of the rectangle (in inv y)
* `rec.pos5` the middle vector of the rectangle
* `rec.dims` the dimensions of the rectangle in vector form

The following methods are, of course, read-only:

>* `rec:intersect(rec2)` AABB true/false intersection check
* `rec:relate(rec2)` AABB distances - all negative for intersection, returns: left, right, up, down
* `rec:fullIntersect(rec2)` returns true/false intersection and results from relate
* `rec:intersection(rec2)` *should* return a rectangle representing the intersected area between the two rectangles.
* `rec:expelDir(rec2)` returns direction for AABB expulsion - 1,2,3 or 4 for left, right, up, and down respectively.
* `rec:expel(rec2)` pushes rec out of rec2 in basic AABB manner (nearest side expulsion)
* `rec:fit(rec2, true)` trims rec to fit inside rec2 - if second arg is true, will return a *copy* of rec rather than change the original
* `rec:copy(dx,dy,dw,dh,mod)` copies rec. Will apply deltas if given, will copy unofficial values into `mod` if given a table, and will use the `mod` table rather than create or recycle a new one.
* `rec:multiply(val)` multiplies all values in rec by val, returns a new rectangle with the result.
* `for v in rec:iter(rec2)` iterates rec2 through rec in "stamp" fashion. Developed for use in grid/list-style menus. V is the rectangle representing the current space.
* `rec:regressB(vec)` I'll... update this as soon as I actually remember what the heck this is for...
* `rec:regress(rec2,vec)` This too.

>* `rec:del()` recycles rec in similar fashion to the Vec library