using ExprTools
using Base.Test

macro splitcombine(fundef) # should be a no-op
    dict = splitdef(fundef)
    esc(ExprTools.combinedef(dict))
end

let
    # Ideally we'd compare the result against :(function f(x)::Int 10 end),
    # but it fails because of :line and :block differences
    @test ExprTools.longdef1(:(f(x)::Int = 10)).head == :function
    # That test would belong in MacroTools.jl
    #@test shortdef(:(function f(x)::Int 10 end)).head != :function
    @test map(splitarg, (:(f(a=2, x::Int=nothing, y, args...))).args[2:end]) ==
        [(:a, :Any, false, 2), (:x, :Int, false, :nothing),
         (:y, :Any, false, nothing), (:args, :Any, true, nothing)]
    @test splitarg(:(::Int)) == (nothing, :Int, false, nothing)

    @splitcombine foo(x) = x+2
    @test foo(10) == 12
    @splitcombine add(a, b=2; c=3, d=4)::Float64 = a+b+c+d
    @test add(1; d=10) === 16.0
    @splitcombine fparam{T}(a::T) = T
    @test fparam([]) == Vector{Any}
    immutable Orange end
    @splitcombine (::Orange)(x) = x+2
    @test Orange()(10) == 12
    if VERSION >= v"0.6.0"
        include_string("""
        @splitcombine fwhere(a::T) where T = T
        @test fwhere(10) == Int
        """)
    end
end

