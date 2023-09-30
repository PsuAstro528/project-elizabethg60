function get_xyz(ρ::T, ϕ::T, θ::T) where T
    # pre-compute trig quantitites
    sinϕ = sin(ϕ)
    sinθ = sin(θ)
    cosϕ = cos(ϕ)
    cosθ = cos(θ)

    # now get cartesian coords
    x = ρ * cosϕ * cosθ
    y = ρ * cosϕ * sinθ
    z = ρ * sinϕ
    return Vector{Float64}([x, y, z])
end

function get_xyz_for_surface(ρ::T; num_lats::Int=100, num_lons::Int=100) where T
    # get grids of polar and azimuthal angles
    ϕ = deg2rad.(range(-90.0, 90.0, length=num_lats))
    θ = deg2rad.(range(0.0, 360.0, length=num_lons))'
    return get_xyz.(ρ, ϕ, θ)
end

function frame_transfer!(A::Matrix, b::Matrix)
    for i in 1:length(b)
        b[i] .= A*b[i]
    end
    return
end

function earth2patch_vectors!(A::Matrix, b::Vector, out::Matrix)
    for i in 1:length(A)	
        out[i] = A[i] .- b
    end
    return
end 

function calc_mu(xyz::Vector, O⃗::Vector)
    return dot(O⃗, xyz) / (norm(O⃗) * norm(xyz))
end

function calc_mu_grid!(A::Matrix, B::Matrix, out::Matrix)
    for i in 1:length(A)
        out[i] = calc_mu(A[i], B[i])
        end
    return
end	