# ExprTools

[![Build Status](https://travis-ci.org/cstjean/ExprTools.jl.svg?branch=master)](https://travis-ci.org/cstjean/ExprTools.jl)

[![Coverage Status](https://coveralls.io/repos/cstjean/ExprTools.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/cstjean/ExprTools.jl?branch=master)

[![codecov.io](http://codecov.io/github/cstjean/ExprTools.jl/coverage.svg?branch=master)](http://codecov.io/github/cstjean/ExprTools.jl?branch=master)

## Function definitions

`splitdef(def)` matches a function definition of the form

```julia
function name{params}(args; kwargs)::rtype where {whereparams}
   body
end

and returns `Dict(:name=>..., :args=>..., etc.)`. The definition can be rebuilt by
calling `MacroTools.combinedef(dict)`, or explicitly with

```julia
rtype = get(dict, :rtype, :Any)
all_params = [get(dict, :params, [])..., get(dict, :whereparams, [])...]
:(function $(dict[:name]){$(all_params...)}($(dict[:args]...);
                                            $(dict[:kwargs]...))::$rtype
      $(dict[:body])
  end)
```

A useful pattern is to get the dict from `splitdef`, modify it, then pass it to
`combinedef`. 

`splitarg(arg)` matches function arguments (whether from a definition or a function call)
such as `x::Int=2` and returns `(arg_name, arg_type, default)`. `default` is `nothing`
when there is none. For example:

```julia
> map(splitarg, (:(f(a=2, x::Int=nothing, y))).args[2:end])
3-element Array{Tuple{Symbol,Symbol,Any},1}:
 (:a, :Any, 2)       
 (:x, :Int, :nothing)
 (:y, :Any, nothing)
```
