#determine projected distance between two points (solar grid edges and moon center)
function calc_proj_dist2(p1, p2)
    x1 = p1[1]
    x2 = p2[1]
    y1 = atan(p1[2] / x1) 
    y2 = atan(p2[2] / x2)
    z1 = atan(p1[3] / x1)
    z2 = atan(p2[3] / x2)
    return (y1 - y2)^2 + (z1 - z2)^2
end

# Quadratic limb darkening law.	
# Takes μ = cos(heliocentric angle) and LD parameters, u1 and u2.
# u1=0.4, u2=0.26
function quad_limb_darkening(μ::T, u1::T, u2::T) where T
    μ < zero(T) && return 0.0
    return !iszero(μ) * (one(T) - u1*(one(T)-μ) - u2*(one(T)-μ)^2)
end