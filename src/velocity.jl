#matrix of solar grid lats in radians 
function lat_grid_fc_pa(num_lats::Int=100, num_lon::Int=100)
    ϕ = deg2rad.(range(-90.0, 90.0, length=num_lats))
    A = ThreadsX.collect(ϕ for idx in 1:num_lon)
    return hcat(A...)
end 

function lat_grid_fc(num_lats::Int=100, num_lon::Int=100)
    ϕ = deg2rad.(range(-90.0, 90.0, length=num_lats))
    A = [ϕ for idx in 1:num_lon]
    return hcat(A...)
end 

# rotation period (VELOCITY SCALAR NOT VELOCITY) of patch of star at latitude
# A, B, C are differential rotation coefficients (units are degrees/day)
function rotation_period(ϕ::T; A::T=14.713, B::T=-2.396, C::T=-1.787) where T 
    sinϕ = sin(ϕ)
    #return 360.0/(A + B * sinϕ^2 + C * sinϕ^4)
    return 360/(14.713 - 2.396*sinϕ^2 - 1.787*sinϕ^4)
end

#get velocity scalar for each patch
function v_scalar_pa!(A:: Matrix, out:: Matrix)
	Threads.@threads for i in 1:length(A)
		out[i] = (2*π*sun_radius*cos(A[i]))/(rotation_period(A[i]))
	end
	return
end

function v_scalar!(A:: Matrix, out:: Matrix)
	for i in 1:length(A)
		out[i] = (2*π*sun_radius*cos(A[i]))/(rotation_period(A[i]))
	end
	return
end


#determine pole vector for each patch (removing z component of axis)
function pole_vector_grid_pa!(A::Matrix, b::Vector, out::Matrix)
    Threads.@threads for i in 1:length(A)
        out[i] = b - [0.0, 0.0, A[i][3]]
    end
    return
end 

function pole_vector_grid!(A::Matrix, b::Vector, out::Matrix)
    for i in 1:length(A)
        out[i] = A[i] - [0.0, 0.0, A[i][3]]
        #b - [0.0, 0.0, A[i][3]]# [b[1], -b[2], b[3]] - [A[i][1], 0.0, A[i][3]]
    end
    return
end  

#determine velocity vector of each patch
function v_vector_pa(A::Matrix, B::Matrix, C::Matrix, out::Matrix)
    Threads.@threads for i in 1:length(A)
        cross_product = cross(B[i], [0.0,0.0,sun_radius]) 
        cross_product /= norm(cross_product)
        cross_product *= C[i]
        out[i] = [A[i];cross_product]
    end
    return
end

function v_vector(A::Matrix, B::Matrix, C::Matrix, out::Matrix)
    for i in 1:length(A)
        cross_product = cross(B[i], [0.0,0.0,sun_radius]) 
        cross_product /= norm(cross_product)
        cross_product *= C[i]
        out[i] = [A[i];cross_product]
    end
    return
end

#project each patch velocity vector to line of sight to earth surface 
function projected_pa!(A::Matrix, B:: Matrix, out::Matrix)
    Threads.@threads for i in 1:length(A)
        vel = [A[i][4],A[i][5],A[i][6]]
        angle = dot(B[i], vel) / (norm(B[i]) * norm(vel))
        out[i] = norm(vel) * angle
    end
    return 
end

function projected!(A::Matrix, B:: Matrix, out::Matrix)
    for i in 1:length(A)
        vel = [A[i][4],A[i][5],A[i][6]]
        angle = dot(B[i], vel) / (norm(B[i]) * norm(vel))
        out[i] = -(norm(vel) * angle)
    end
    return 
end