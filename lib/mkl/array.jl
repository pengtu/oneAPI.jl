export oneSparseMatrixCSR

abstract type oneAbstractSparseArray{Tv, Ti, N} <: AbstractSparseArray{Tv, Ti, N} end
const oneAbstractSparseVector{Tv, Ti} = oneAbstractSparseArray{Tv, Ti, 1}
const oneAbstractSparseMatrix{Tv, Ti} = oneAbstractSparseArray{Tv, Ti, 2}

mutable struct oneSparseMatrixCSR{Tv, Ti} <: oneAbstractSparseMatrix{Tv, Ti}
    handle::matrix_handle_t
    rowPtr::oneVector{Ti}
    colVal::oneVector{Ti}
    nzVal::oneVector{Tv}
    dims::NTuple{2,Int}
    nnz::Ti
end

Base.length(A::oneSparseMatrixCSR) = prod(A.dims)
Base.size(A::oneSparseMatrixCSR) = A.dims

function Base.size(A::oneSparseMatrixCSR, d::Integer)
    if d == 1 || d == 2
        return A.dims[d]
    else
        throw(ArgumentError("dimension must be 1 or 2, got $d"))
    end
end

SparseArrays.nnz(A::oneSparseMatrixCSR) = A.nnz
SparseArrays.nonzeros(A::oneSparseMatrixCSR) = A.nzVal

for (gpu, cpu) in [:oneSparseMatrixCSR => :SparseMatrixCSC]
    @eval Base.show(io::IOContext, x::$gpu) =
        show(io, $cpu(x))

    @eval function Base.show(io::IO, mime::MIME"text/plain", S::$gpu)
        xnnz = nnz(S)
        m, n = size(S)
        print(io, m, "×", n, " ", typeof(S), " with ", xnnz, " stored ",
                  xnnz == 1 ? "entry" : "entries")
        if !(m == 0 || n == 0)
            println(io, ":")
            io = IOContext(io, :typeinfo => eltype(S))
            if ndims(S) == 1
                show(io, $cpu(S))
            else
                # so that we get the nice Braille pattern
                Base.print_array(io, $cpu(S))
            end
        end
    end
end
