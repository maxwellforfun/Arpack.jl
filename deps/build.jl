using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libarpack"], :Arpack),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaLinearAlgebra/ArpackBuilder/releases/download/v3.5.0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/ArpackBuilder.aarch64-linux-gnu.tar.gz", "4c98c0add12387448c801e07e05b24ea5b943458b3a479faffb90e57803eae4b"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/ArpackBuilder.arm-linux-gnueabihf.tar.gz", "e22e63113be4fb507edb252958e83a2f53ed44e2b1a533e64005e44990955607"),
    Linux(:i686, :glibc) => ("$bin_prefix/ArpackBuilder.i686-linux-gnu.tar.gz", "22cac108038fae3f5e0aabd343aee361d588110750cbad538f350fcf7a1d0b52"),
    Windows(:i686) => ("$bin_prefix/ArpackBuilder.i686-w64-mingw32.tar.gz", "0d2ad9002b697d3ea84fd0ab0dd9ec48bb71675de9616fcaf05b96f7b94f8360"),
    MacOS(:x86_64) => ("$bin_prefix/ArpackBuilder.x86_64-apple-darwin14.tar.gz", "43da2199dfe15bb8ca5c020906ff011d3f56fd1deb00686bac61b9ad421cfd29"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/ArpackBuilder.x86_64-linux-gnu.tar.gz", "e33ae398966b20e1f783690de35e5ed08a69311209000077b564188e14069726"),
    Windows(:x86_64) => ("$bin_prefix/ArpackBuilder.x86_64-w64-mingw32.tar.gz", "e51094c837556379a408690ad699be7ba53ba64b2e7aa1b806418da3e68ccfc9"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
