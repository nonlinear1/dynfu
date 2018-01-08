package.cpath = package.cpath .. ";/homes/dig15/df/dynfu/include/dynfu/utils/terra/?.so"
require 'luadq'

-- energy specifciation

local D,N = Dim("D",0), Dim("N",1)

local translations = Unknown("translations",opt_float3,{D},0)
local rotations = Unknown("rotations",opt_float4,{D},1)
local transformationWeights = Array("transformationWeights",opt_float8,{N},2)

local canonicalVertices = Array("canonicalVertices",opt_float3,{N},3)
local canonicalNormals = Array("canonicalNormals",opt_float3,{N},4)

local liveVertices = Array("liveVertices",opt_float3,{N},5)
local liveNormals = Array("liveNormals",opt_float3,{N},6)

local tukeyBiweights = Array("tukeyBiweights",opt_float,{N},7)

local G = Graph("dataGraph", 8,
                    "v", {N}, 9,
                    "w", {N}, 10, -- transformation weights
                    "n0", {D}, 11,
                    "n1", {D}, 12,
                    "n2", {D}, 13,
                    "n3", {D}, 14,
                    "n4", {D}, 15,
                    "n5", {D}, 16,
                    "n6", {D}, 17,
                    "n7", {D}, 18)

local nodes = { 0, 1, 2, 3, 4, 5, 6, 7 }
local totalTranslation = 0
local totalRotation = luadq.rotation_plucker(0, {0, 0, 0}, {0, 0, 0})

for _,i in ipairs(nodes) do
  totalTranslation = totalTranslation + transformationWeights(G.w)(i) * translations(G["n"..i])

  local nodeRotation = rotations(G["n"..i])
  -- totalRotation = luadq.rotation_plucker(nodeRotation(0), {nodeRotation(1), nodeRotation(2), nodeRotation(3)}, {0, 0, 0})
end

Energy(sqrt(tukeyBiweights(G.v)) * (liveVertices(G.v) - canonicalVertices(G.v) - totalTranslation))
