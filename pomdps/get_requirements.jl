# will install the requirements for the notebooks

function add_if_missing(pkg, installed)
    if !in(pkg, installed)
        Pkg.add(pkg)
    end
end

packages = keys(Pkg.installed())

add_if_missing("POMDPs", packages)
add_if_missing("POMDPToolbox", packages)
add_if_missing("POMDPModels", packages)
add_if_missing("ParticleFilters", packages)
add_if_missing("Distributions", packages)
add_if_missing("Interact", packages)

using POMDPs

if !in("QMDP", packages)
    POMDPs.add("QMDP")
end
if !in("POMCPOW", packages)
    Pkg.clone("https://github.com/JuliaPOMDP/POMCPOW.jl.git")
    Pkg.build("POMCPOW")
end
if !in("LaserTag", packages)
    Pkg.clone("https://github.com/zsunberg/LaserTag.jl.git")
    Pkg.build("LaserTag")
end
