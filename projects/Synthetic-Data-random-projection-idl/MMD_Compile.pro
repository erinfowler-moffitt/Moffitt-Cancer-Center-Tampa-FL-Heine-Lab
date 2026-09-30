pro mmd_same_sample_size, m, x, y, mmd, extrabit

x = double(x)
y = double(y)

mmd = double(0.)
for i = 0, m-1 do begin &$
  for j = 0, m-1 do begin &$
    if i ne j then begin &$
      tmp1 = x[i, *] # transpose(x[j, *]) &$
      tmp2 = y[i, *] # transpose(y[j, *]) &$
      tmp3 = x[i, *] # transpose(y[j, *]) &$
      tmp4 = x[j, *] # transpose(y[i, *]) &$
      mmd = mmd + tmp1 + tmp2 - tmp3 - tmp4 &$
    endif &$
  endfor &$
endfor
mmd = mmd / (m*(m-1))

extrabit = double(0.)
for i = 0, m-1 do begin &$
  tmp1 = x[i, *] # transpose(x[i, *]) &$
  tmp2 = y[i, *] # transpose(y[i, *]) &$
  tmp3 = x[i, *] # transpose(y[i, *]) &$
  extrabit = extrabit + tmp1 + tmp2 - (2.*tmp3) &$
endfor
extrabit = extrabit / (m*(m-1))

end

function make_k, d, h, z

front_math = (2.*(!Dpi))^(-0.5*d)
hdet = determ(h, /double)^(-0.5)
hinv = invert(h)
;;x is already differenced.

tmp = transpose(z) ## hinv
tmp2 = tmp ## z
tmp3 = exp(-0.5*tmp2[0])

;k = front_math*hdet*tmp3
k = tmp3
return, k
end


function find_k, d, h, m, x

k = double(0.)
for i = 0, m-1 do begin &$
  for j = 0, m-1 do begin &$
    if i ne j then begin &$
      k1 = make_k(d, h, x[i, *]-x[j, *]) &$
      ;print, k, k1 &$
      k = k > k1 &$
      ;print, k &$
    endif &$
  endfor &$
endfor
return, k

end


function make_h_diff, x_seed, x_syn
x = [x_seed, x_syn]
sz = size(x)

v = dblarr(sz[2])
for k=0, sz[2]-1 do begin &$
	diff = [] &$
	for i = 0, sz[1]-2 do begin &$
		diff = [diff, abs(x[i+1:sz[1]-1, k] - x[i, k])] &$
		;for j=i+1, sz[1]-1 do diff = [diff, abs(x[i, k] - x[j, k])] &$
	endfor &$
	v[k] = median(diff, /double) &$
endfor

h = dblarr(sz[2], sz[2])
for i=0, sz[2]-1 do h[i, i] = v[i]^2.

return, h
end



function make_h_diff_seedonly, x_seed, x_syn
x = x_seed
sz = size(x)

v = dblarr(sz[2])
for k=0, sz[2]-1 do begin &$
	diff = [] &$
	for i = 0, sz[1]-2 do begin &$
		diff = [diff, abs(x[i+1:sz[1]-1, k] - x[i, k])] &$
		;for j=i+1, sz[1]-1 do diff = [diff, abs(x[i, k] - x[j, k])] &$
	endfor &$
	v[k] = median(diff, /double) &$
endfor

h = dblarr(sz[2], sz[2])
for i=0, sz[2]-1 do h[i, i] = v[i]^2.

return, h
end

function make_h_same, x_seed, x_syn
x = [x_seed, x_syn]
sz = size(x)
diff = []
for i=0, sz[1]-2 do begin &$
	for j = i+1, sz[1]-1 do begin &$
		num = 0. &$
		for k=0, sz[2]-1 do num = num + (x[i, k] - x[j, k])^2. &$
		diff = [diff, sqrt(num)] &$
	endfor &$
endfor
v = median(diff, /double)

h = dblarr(sz[2], sz[2])
for i=0, sz[2]-1 do h[i, i] = v^2.

return, h
end



function make_h_same_seedonly, x_seed, x_syn
x = x_seed
sz = size(x)
diff = []
for i=0, sz[1]-2 do begin &$
	for j = i+1, sz[1]-1 do begin &$
		num = 0. &$
		for k=0, sz[2]-1 do num = num + (x[i, k] - x[j, k])^2. &$
		diff = [diff, sqrt(num)] &$
	endfor &$
endfor
v = median(diff, /double)

h = dblarr(sz[2], sz[2])
for i=0, sz[2]-1 do h[i, i] = v^2.

return, h
end


pro mmd_same_sample_size2, d, h, m, x, y, mmd, extrabit

x = double(x)
y = double(y)

mmd = double(0.)
for i = 0, m-1 do begin &$
  for j = 0, m-1 do begin &$
    if i ne j then begin &$
      k1 = make_k(d, h, x[i, *]-x[j, *]) &$
      k2 = make_k(d, h, y[i, *]-y[j, *]) &$
      k3 = make_k(d, h, x[i, *]-y[j, *]) &$
      k4 = make_k(d, h, x[j, *]-y[i, *]) &$
      mmd = mmd + k1 + k2 - k3 - k4 &$
    endif &$
  endfor &$
endfor
mmd = mmd / (m*(m-1))

extrabit = double(0.)
for i = 0, m-1 do begin &$
  k1 = make_k(d, h, x[i, *]-x[i, *]) &$
  k2 = make_k(d, h, y[i, *]-y[i, *]) &$
  k3 = make_k(d, h, x[i, *]-y[i, *]) &$
  extrabit = extrabit + k1 + k2 - (2.*k3) &$
endfor
extrabit = extrabit / (m*(m-1))

end

