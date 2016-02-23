---
layout: post
title: Load C library in Julia
author: <a href="http://panlanfeng.github.com/">Lanfeng</a>
---

It is very convenient to load C or C++ library in julia. It is no more than just run a `ccall` function. There is no need to write any additional C code to wrap it up as long as the C library is sharable. Here we use the `Yeppp` package as an illustration.

First download the C++ library Yeppp! and make sure that libyeppp.so (or .dylib or .dll) file is available on the system library search path or in the current directory.

Then the following julia function will call adding function in Yeppp!.

~~~ julia
function add!(res::Array{Float64}, x::Array{Float64}, y::Array{Float64})
    assert(length(x) == length(y))
    n = length(x)
    const status = ccall( (:yepCore_Add_V64fV64f_V64f, libyeppp), Cint, (Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Culong), x, y, res, n)
    status != 0 && error("yepCore_Add_V64fV64f_V64f: error: ", status)
    res
end
~~~
where `:yepCore_Add_V64fV64f_V64f` is the function name and `libyeppp` is the library name.

Since a similar definition is applicable for many other functions in Yeppp!, I wrote a macro to map many more into julia.

~~~ julia
macro yepppfunsAA_A(fname, libname, BT)
    errorname = libname * ": error: "
    quote 
        global $(fname)
        function $(fname)(res::Array{$(BT)}, x::Array{$(BT)}, y::Array{$(BT)})
            n = length(x)
            assert(n == length(y) == length(res))
            
            const status = ccall( ($(libname), libyeppp), Cint, (Ptr{$(BT)}, Ptr{$(BT)}, Ptr{$(BT)}, Culong), x, y, res, n)
            status != 0 && error($(errorname), status)
            res
        end
    end 
end 
@yepppfunsAA_A add! "yepCore_Add_V64fV64f_V64f" Float64
@yepppfunsAA_A multiply! "yepCore_Multiply_V64fV64f_V64f" Float64
~~~

This will automatically define `add!`, `multiply!` and more julia functions.
