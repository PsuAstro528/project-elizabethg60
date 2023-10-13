#determine projected distance between two points (solar grid edges and moon center)
function calc_proj_dist2(p1, p2)
    x1 = p1[1]
    x2 = p2[1]
    y1 = atan(p1[2] / norm(p1))
    y2 = atan(p2[2] / norm(p2))
    z1 = atan(p1[3] / norm(p1))
    z2 = atan(p2[3] / norm(p2))
    return (y1 - y2)^2.0 + (z1 - z2)^2.0
end

# Quadratic limb darkening law.	
# Takes μ = cos(heliocentric angle) and LD parameters, u1 and u2.
# u1=0.4, u2=0.26
function quad_limb_darkening(μ::T, u1::T, u2::T) where T
    μ < zero(T) && return 0.0
    return !iszero(μ) * (one(T) - u1*(one(T)-μ) - u2*(one(T)-μ)^2)
end

#projection of proper motion velocity 
function projected2!(A::Vector, B:: Vector, C:: Matrix, out::Matrix)	
    for i in 1:length(C)
        earth_angle = dot(C[i], A) / (norm(C[i]) * norm(A))
        earth_projected =  norm(A) * earth_angle

        patch_angle = dot(C[i], B) / (norm(C[i]) * norm(B))
        patch_projected =  norm(B) * patch_angle
            
        out[i] = earth_projected + patch_projected
    end
    return 
end