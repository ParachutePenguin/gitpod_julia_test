using Pkg

Pkg.add("HTTP")
Pkg.add("CSV")
Pkg.add("Gumbo")
Pkg.add("Plots")
Pkg.add("Cascadia")
Pkg.add("DataFrames")

using HTTP, CSV, Gumbo, Plots, Cascadia, Serialization, DataFrames

res = HTTP.get("http://daweb.ism.ac.jp/yosoku/materials/PF-example-data.txt")
#data = CSV.read(IOBuffer(res.body))
strdat = read(IOBuffer(res.body), String)

u = split(strdat)
cnt = size(u)[1]
xs = zeros(Float32,cnt)
parse(Float32,u[1])

for i = 1:cnt
  xs[i] = parse(Float32,u[i])
  end
  
plot(xs)