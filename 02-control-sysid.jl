Pkg.add("OrdinaryDiffEq")
Pkg.add("PyPlot")
Pkg.checkout("DiffEqBase")
Pkg.checkout("OrdinaryDiffEq")
Pkg.update()

include("../PolynomialMatrices.jl/src/PolynomialMatrices.jl")
include("../SystemsBase.jl/src/SystemsBase.jl")
include("../ControlToolbox.jl/src/ControlToolbox.jl")
include("../IdentificationToolbox.jl/src/IdentificationToolbox.jl")

using PolynomialMatrices
using SystemsBase
using ControlToolbox
using IdentificationToolbox

using DiffEqBase, OrdinaryDiffEq
using Plots
pyplot();






J = 0.01
b = 0.1
K = 0.01
R = 1
L = 0.5
s = tf([0,1], 1)
Ptf = K/((J*s+b)*(L*s+R)+K^2)

step(Ptf)



A = [-b/J   K/J
    -K/L   -R/L]
B = [0 1/L].'
C = [1.   0]
D = 0.
Pss = ss(A,B,C,D)


bode(Pss)

Pmimo = ss(randn(100,100), randn(100,2), randn(2,100), zeros(2,2))

### generate data

immutable Sinosoid
    f::Vector
    δ::Vector

    (::Type{Sinosoid})(f::Vector, δ::Vector) = (@assert length(f) == length(δ); new(f, δ))
    (::Type{Sinosoid})(f::Vector) = new(f, 2π*randn(length(f)))
    (::Type{Sinosoid})() = new(logspace(-1,0,50), 2π*randn(50))
    (s::Sinosoid)(t::Real) = sum(map((f,t,δ)->sin(2π*f*t + δ), s.f, fill(t, size(s.f)), s.δ))
    (s::Sinosoid)(t::AbstractArray) = map(s, t)
end

u = Sinosoid()
t = linspace(0,100,1000)
plot(t, u(t))

sln = simulate(Pss, (0., 5); input = (t,x)->u(t,x))
plot(sln)

### read data

data, header = readcsv("collected-data.csv", header=true)

u = data[:,2].'; y = data[:,3].';
zdata = iddata(y,u)

# discretize
Ts = 0.05
Pssd, xomap = c2d(Pss, Ts, Discretization.ZOH()) # ZOH by default

discretizer = Discretization.Bilinear()
discretizer(Pss, Ts)

# plot response from both



# identify Ptf and Pss

# convert to ss and tf

zeros(Ptf)

z = zeros(Pss)
p = poles(Pss)


scatter(real(p), imag(p), markershape = :xcross)
scatter!(real(z), imag(z))


# Frequency evaluation
Pss(4)                # Pss(s = 4)
freqresp(Pss, 4.0)    # Pss(s = 4im)


testmatrix = randn(5,5,5)

Pss(testmatrix)

Pmimo(testmatrix)

# boderesponse

fvec = reshape(collect(linspace(0,1000,100)),1,1,100)
resp = freqresp(Pss, fvec)
bresp = SystemsBase.BodeResponse(fvec[:], abs(resp), angle(resp))

plot(bresp)
