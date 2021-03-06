mutable struct Trie{T}
    value::T
    children::Dict{Char,Trie{T}}
    is_key::Bool

    function Trie{T}() where T
        self = new{T}()
        self.children = Dict{Char,Trie{T}}()
        self.is_key = false
        self
    end

    function Trie{T}(ks, vs) where T
        t = Trie{T}()
        for (k, v) in zip(ks, vs)
            t[k] = v
        end
        return t
    end

    function Trie{T}(kv) where T
        t = Trie{T}()
        for (k,v) in kv
            t[k] = v
        end
        return t
    end
end

Trie() = Trie{Any}()
Trie(ks::AbstractVector{K}, vs::AbstractVector{V}) where {K<:AbstractString,V} = Trie{V}(ks, vs)
Trie(kv::AbstractVector{Tuple{K,V}}) where {K<:AbstractString,V} = Trie{V}(kv)
Trie(kv::AbstractDict{K,V}) where {K<:AbstractString,V} = Trie{V}(kv)
Trie(ks::AbstractVector{K}) where {K<:AbstractString} = Trie{Nothing}(ks, similar(ks, Nothing))

function setindex!(t::Trie{T}, val::T, key::AbstractString) where T
    node = t
    for char in key
        if !haskey(node.children, char)
            node.children[char] = Trie{T}()
        end
        node = node.children[char]
    end
    node.is_key = true
    node.value = val
end

function getindex(t::Trie, key::AbstractString)
    node = subtrie(t, key)
    if node != nothing && node.is_key
        return node.value
    end
    throw(KeyError("key not found: $key"))
end

function subtrie(t::Trie, prefix::AbstractString)
    node = t
    for char in prefix
        if !haskey(node.children, char)
            return nothing
        else
            node = node.children[char]
        end
    end
    node
end

function haskey(t::Trie, key::AbstractString)
    node = subtrie(t, key)
    node != nothing && node.is_key
end

function get(t::Trie, key::AbstractString, notfound)
    node = subtrie(t, key)
    if node != nothing && node.is_key
        return node.value
    end
    notfound
end

function keys(t::Trie, prefix::AbstractString="", found=AbstractString[])
    if t.is_key
        push!(found, prefix)
    end
    for (char,child) in t.children
        keys(child, string(prefix,char), found)
    end
    found
end

function keys_with_prefix(t::Trie, prefix::AbstractString)
    st = subtrie(t, prefix)
    st != nothing ? keys(st,prefix) : []
end

# The state of a TrieIterator is a pair (t::Trie, i::Int),
# where t is the Trie which was the output of the previous iteration
# and i is the index of the current character of the string.
# The indexing is potentially confusing;
# see the comments and implementation below for details.
struct TrieIterator
    t::Trie
    str::AbstractString
end

# At the start, there is no previous iteration,
# so the first element of the state is undefined.
# We use a "dummy value" of it.t to keep the type of the state stable.
# The second element is 0
# since the root of the trie corresponds to a length 0 prefix of str.
start(it::TrieIterator) = (it.t, 0)

function next(it::TrieIterator, state::Tuple)
    t, i = state
    i == 0 && return it.t, (it.t, 1)

    t = t.children[it.str[i]]
    return (t, (t, i + 1))
end

function done(it::TrieIterator, state::Tuple)
    t, i = state
    i == 0 && return false
    i == length(it.str) + 1 && return true
    return !(it.str[i] in keys(t.children))
end

path(t::Trie, str::AbstractString) = TrieIterator(t, str)
Compat.IteratorSize(::Type{TrieIterator}) = Base.SizeUnknown()
