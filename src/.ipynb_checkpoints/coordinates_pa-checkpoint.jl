function frame_transfer_pa(A::Matrix, b::Matrix, out::Matrix)
    """
    transforms between frames - parallel
    
    A: transformation matrix
    b: matrix in initial frame
    out: matrix in desired frame 
    """
    Threads.@threads for i in 1:length(b)
        out[i] = A*b[i]
    end
    return
end

function earth2patch_vectors_pa(A::Matrix, b::Vector, out::Matrix)   
    """
    determines line of sight vector from observer to each cell on grid - parallel

    A: matrix of vectors of barycenter to cells
    b: vector from barycenter to observer
    out: matrix of vectors of observer to each patch 
    """
    Threads.@threads for i in 1:length(A)	
        out[i] = A[i] .- b
    end
    return
end 

function calc_mu_grid_pa!(A::Matrix, B::Matrix, out::Matrix)
    """
    create matrix of mu value for each cell - parallel

    A: matrix of vectors from sun center to cell
    B: matrix of vectors from observer to cell
    out: mu value between A and B
    """
    Threads.@threads for i in 1:length(A)
        out[i] = calc_mu(A[i], B[i])
        end
    return
end	