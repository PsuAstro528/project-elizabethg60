#matrix of solar grid lats in radians 
function lat_grid_fc(num_lats::Int=100, num_lon::Int=100)
    ϕ = deg2rad.(range(-90.0, 90.0, length=num_lats))
    A = [ϕ for idx in 1:num_lon]
    return hcat(A...)
end

# rotation period (VELOCITY SCALAR NOT VELOCITY) of patch of star at latitude
# A, B, C are differential rotation coefficients (units are degrees/day)
function rotation_period(ϕ::T; A::T=14.713, B::T=-2.396, C::T=-1.787) where T
    @assert -π/2 <= ϕ <= π/2
    sinϕ = sin(ϕ)
    return 360.0/(A + B * sinϕ^2.0 + C * sinϕ^4.0)
end

#get velocity scalar for each patch
function v_scalar!(A:: Matrix, out:: Matrix)
	for i in 1:length(A)
		per = rotation_period(A[i])
		out[i] = (2*π*sun_radius*cos(A[i]))/per
	end
	return
end

#determine pole vector for each patch (removing z component of axis)
function pole_vector_grid!(A::Matrix, b::Vector, out::Matrix)
    for i in 1:length(A)
        out[i] = b - [0.0, 0.0, A[i][3]]
    end
    return
end

#determine velocity vector of each patch
function v_vector!(A::Matrix, B::Matrix, C::Matrix, out::Matrix)
    for i in 1:length(A)
        #vel = cross(A[i],B[i])
        vel = cross(B[i],A[i])
        vel_norm = norm(vel)
        unit = vel / vel_norm
        velocity = unit.*C[i]
        out[i] = [A[i];velocity]
    end
    return
end

#project each patch velocity vector to line of sight to earth surface 
function projected!(A::Matrix, B:: Matrix, out::Matrix)
    for i in 1:length(A)
        vel = [A[i][4],A[i][5],A[i][6]]
        angle = dot(B[i], vel) / (norm(B[i]) * norm(vel))
        out[i] = norm(vel) * angle
    end
    return 
end