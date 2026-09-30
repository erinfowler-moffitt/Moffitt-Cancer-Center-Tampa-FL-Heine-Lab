function create_useful_time, result
	seconds = result mod 60.
	tmp2 = (result-seconds)/60. ;; minutes 
	if tmp2 gt 0 then begin &$
  		minutes = tmp2 mod 60. &$
  		tmp3 = (tmp2-minutes)/60. &$ ;; hours 
  		if tmp3 gt 0. then hours = tmp3 else hours = 0.&$
	endif else begin &$
  		minutes = 0. &$
		hours = 0. &$
	endelse
	
	output = 'Hours: '+strtrim(string(hours), 2)+' Minutes: '+strtrim(string(minutes), 2)+' Seconds: '+strtrim(string(seconds), 2)
	return, output
end


function create_DH_matrix, par, intl_cov
	H = (intl_cov)*0.
	sz = size(h)
	for i=0, sz[1]-1 do begin &$
  		H[i, i] = par[i] &$
	endfor
	return, H
end

function create_H_matrix, par, intl_cov
	H = (intl_cov)*0.
	sz = size(h)
	d = 0
	for i=0, sz[1]-1 do begin &$
  		n = n_elements(H[i, i:sz[1]-1]) &$
  		H[i, i:sz[1]-1] = par[d:d+n-1] &$
  		H[i:sz[1]-1, i] = par[d:d+n-1] &$
  		;print, i, i, sz[1]-1, d, d+n-1 &$
  		d = d+n &$
	endfor
  	
  	return, H
end

pro create_lx, sz, limits, mx, sx, x0, lx
	lx = !null
	;ct = 0
	if sz[0] gt 1 then begin &$
		x0 = dblarr(sz[2]) &$
		for i=0, sz[2]-1 do begin &$
			check = 1 &$
			while check ne 0 do begin &$
				x0[i] = (randomn(seed)*sx[i])+mx[i] &$
				if x0[i] ge limits[i, 0] and x0[i] le limits[i, 1] then check = 0 &$
				;ct++ &$
			endwhile &$
		endfor &$
	endif else begin &$
		check = 1 &$
		while check ne 0 do begin &$
			x0 = (randomn(seed)*sx)+mx &$
			if x0 ge limits[0, 0] and x0 le limits[0, 1] then check = 0 &$
			;ct++ &$
		endwhile &$
	endelse &$
	lx = (fltarr(sz[1]) + 1.) # x0
	;print, ct &$
end

pro create_var_d, w, hinv, sz, var
	var = dblarr(sz[1])
	if sz[0] gt 1 then for i=0, sz[2]-1 do var += (w[*, i]*Hinv[i, i]*w[*, i]) else var = w*Hinv[0]*w
end

pro create_var, w, hinv, sz, var
	var = dblarr(sz[1])
	if sz[0] gt 1 then begin &$
		for i=0, sz[2]-1 do begin &$
			for j=0, sz[2]-1 do var += (w[*, i]*Hinv[i, j]*w[*, j]) &$
		endfor &$
	endif else var = w*Hinv*w
end



function KS_pvalue, alam
eps1 = double(0.001)
eps2 = double(0.00000001)

fac = 2.0
sum = 0.0
termbf = 0.0
a2 = -2.0*alam^2.
for j=1, 100 do begin &$
	term = fac*exp(a2*j^2.) &$
	sum += term &$
	if (abs(term) le eps1*termbf) or (abs(term) le eps2*sum) then return, sum &$
	fac = (-1.)*fac &$
	termbf = abs(term) &$
endfor
sum = 1.0
return, sum
end

function KS_test, data1, data2, D
n1 = n_elements(data1)
en1 = double(n1)
n2 = n_elements(data2)
en2 = double(n2)

d1 = data1[sort(data1)]
d2 = data2[sort(data2)]

d = 0.0
j1 = 1.0
j2 = 1.0
fn1 = 0.0
fn2 =0.0

while (j1 le n1) and (j2 le n2) do begin &$
	if (d1[j1-1] le d2[j2-1]) then begin &$
		j1++ &$
		fn1 = j1/en1 &$
	endif else begin &$
		j2++ &$
		fn2 = j2/en2 &$
	endelse &$
	d = abs(fn2-fn1) > d &$
endwhile

en = sqrt(en1*en2/(en1+en2))
prob = KS_pvalue((en+0.12+(0.11/en))*d) 
return, prob
end




function fitness_test_int, par_H, limits, x

	x_seed = x
	syn_num = 1000000.
	sz = size(x_seed)
	n = sz[1]
	
	if sz[0] eq 2 then begin &$
		x_syn = dblarr(syn_num, sz[2]) &$
		diff = limits[*, 1]-limits[*, 0]+1 &$
	endif else begin &$
		x_syn = dblarr(syn_num) &$
		diff = limits[1]-limits[0]+1 &$
	endelse
	H = par_H
	
	if sz[0] eq 2 then begin &$
		for i = 0, sz[2]-1 do begin &$
			lx = dindgen(diff[i], start = limits[i, 0], increment = 1) &$
			y = lx*0. &$
			for j = 0, n-1 do begin &$
				W1=(lx-x_seed[j, i])^2. &$
				var1=(w1/h[i]) &$
				y=y+exp((-1.)*(var1)) &$ ;;<-- one patient at EVERY combination
			endfor &$
			y=y/double(n) &$
			fx2=y/total(y, /double, /nan) &$
			cumfx = total(Fx2, /cumulative, /double) &$
			cum_index = randomu(seed, syn_num) &$
			for j=0L, syn_num-1 do begin &$
				trap = where(cumfx gt cum_index[j], ct) &$
				x_syn[j, i] = lx[trap[0]] &$
			endfor &$
		endfor &$
		x_syn = round(x_syn) &$
		x_syn = [double(x_syn), x_seed] &$
		dsum = 0. &$
		for i=0, sz[2]-1 do begin &$
			prob = KS_test(reform(x_seed[*, i]), reform(x_syn[*, i]), D) &$
			dsum = dsum+d &$
			;print, D, Prob, format = '(2(f20.8))' &$
		endfor &$
		d = dsum &$
	endif else begin &$
		lx = dindgen(diff, start = limits[0], increment = 1) &$
		y = lx*0. &$
		for j = 0, n-1 do begin &$
			W1=(lx-x_seed[j])^2. &$
			var1=(w1/h[0]) &$
			y=y+exp((-1.)*(var1)) &$ ;;<-- one patient at EVERY combination
		endfor &$
		y=y/double(n) &$
		fx2=y/total(y, /double, /nan) &$
		cumfx = total(Fx2, /cumulative, /double) &$
		cum_index = randomu(seed, syn_num) &$
		for j=0L, syn_num-1 do begin &$
			trap = where(cumfx gt cum_index[j], ct) &$
			x_syn[j] = lx[trap[0]] &$
		endfor &$
		x_syn = round(x_syn) &$
		x_syn = [double(x_syn), x_seed] &$
		prob = KS_test(x_seed, x_syn, D) &$
	endelse

	return, D
end



function fitness_test_float, par_H, limits, x, inc

	x_seed = x
	syn_num = 1000000.
	sz = size(x_seed)
	n = sz[1]
	
	if sz[0] eq 2 then begin &$
		x_syn = dblarr(syn_num, sz[2]) &$
		diff = ((limits[*, 1]-limits[*, 0])/inc)+1 &$
	endif else begin &$
		x_syn = dblarr(syn_num) &$
		diff = ((limits[1]-limits[0])/inc)+1 &$
	endelse
	H = par_H
	
	if sz[0] eq 2 then begin &$
		for i = 0, sz[2]-1 do begin &$
			lx = dindgen(diff[i], start = limits[i, 0], increment = inc[i]) &$
			y = lx*0. &$
			for j = 0, n-1 do begin &$
				W1=(lx-x_seed[j, i])^2. &$
				var1=(w1/h[i]) &$
				y=y+exp((-.5)*(var1)) &$ ;;<-- one patient at EVERY combination
			endfor &$
			y=y/double(n) &$
			fx2=y/total(y, /double, /nan) &$
			cumfx = total(Fx2, /cumulative, /double) &$
			cum_index = randomu(seed, syn_num) &$
			for j=0L, syn_num-1 do begin &$
				trap = where(cumfx gt cum_index[j], ct) &$
				x_syn[j, i] = lx[trap[0]] &$
			endfor &$
		endfor &$
		;x_syn = round(x_syn) &$
		;x_syn = [double(x_syn), x_seed] &$
		index_test = floor(randomu(seed, sz[1])*syn_num) &$
		dsum = 0. &$
		for i=0, sz[2]-1 do begin &$
			prob = KS_test(reform(x_seed[*, i]), reform(x_syn[index_test, i]), D) &$
			dsum = dsum+d &$
			;print, D, Prob, format = '(2(f20.8))' &$
		endfor &$
		d = dsum &$
	endif else begin &$
		lx = dindgen(diff, start = limits[0], increment = inc) &$
		y = lx*0. &$
		for j = 0, n-1 do begin &$
			W1=(lx-x_seed[j])^2. &$
			var1=(w1/h[0]) &$
			y=y+exp((-.5)*(var1)) &$ ;;<-- one patient at EVERY combination
		endfor &$
		y=y/double(n) &$
		fx2=y/total(y, /double, /nan) &$
		cumfx = total(Fx2, /cumulative, /double) &$
		cum_index = randomu(seed, syn_num) &$
		for j=0L, syn_num-1 do begin &$
			trap = where(cumfx gt cum_index[j], ct) &$
			x_syn[j] = lx[trap[0]] &$
		endfor &$
		;x_syn = round(x_syn) &$
		;x_syn = [double(x_syn), x_seed] &$
		index_test = floor(randomu(seed, sz[1])*syn_num)
		prob = KS_test(x_seed, x_syn[index_test], D) &$
	endelse

	return, D
end


function fitness_solve_int, par_H, limits, x

	x_seed = x
	syn_num = 1000000.
	sz = size(x_seed)
	n = sz[1]
	
	if sz[0] eq 2 then begin &$
		x_syn = dblarr(syn_num, sz[2]) &$
		diff = limits[*, 1]-limits[*, 0]+1 &$
	endif else begin &$
		x_syn = dblarr(syn_num) &$
		diff = limits[1]-limits[0]+1 &$
	endelse
	H = par_H
	
	if sz[0] eq 2 then begin &$
		for i = 0, sz[2]-1 do begin &$
			lx = dindgen(diff[i], start = limits[i, 0], increment = 1) &$
			y = lx*0. &$
			for j = 0, n-1 do begin &$
				W1=(lx-x_seed[j, i])^2. &$
				var1=(w1/h[i]) &$
				y=y+exp((-1.)*(var1)) &$ ;;<-- one patient at EVERY combination
			endfor &$
			y=y/double(n) &$
			fx2=y/total(y, /double, /nan) &$
			cumfx = total(Fx2, /cumulative, /double) &$
			cum_index = randomu(seed, syn_num) &$
			for j=0L, syn_num-1 do begin &$
				trap = where(cumfx gt cum_index[j], ct) &$
				x_syn[j, i] = lx[trap[0]] &$
			endfor &$
		endfor &$
		x_syn = round(x_syn) &$
		x_syn = [double(x_syn), x_seed] &$
		dsum = 0. &$
		for i=0, sz[2]-1 do begin &$
			prob = KS_test(reform(x_seed[*, i]), reform(x_syn[*, i]), D) &$
			dsum = dsum+d &$
			;print, D, Prob, format = '(2(f20.8))' &$
		endfor &$
		d = dsum &$
	endif else begin &$
		lx = dindgen(diff, start = limits[0], increment = 1) &$
		y = lx*0. &$
		for j = 0, n-1 do begin &$
			W1=(lx-x_seed[j])^2. &$
			var1=(w1/h[0]) &$
			y=y+exp((-1.)*(var1)) &$ ;;<-- one patient at EVERY combination
		endfor &$
		y=y/double(n) &$
		fx2=y/total(y, /double, /nan) &$
		cumfx = total(Fx2, /cumulative, /double) &$
		cum_index = randomu(seed, syn_num) &$
		for j=0L, syn_num-1 do begin &$
			trap = where(cumfx gt cum_index[j], ct) &$
			x_syn[j] = lx[trap[0]] &$
		endfor &$
		x_syn = round(x_syn) &$
		x_syn = [double(x_syn), x_seed] &$
		prob = KS_test(x_seed, x_syn, D) &$
	endelse

	return, x_syn
end


function fitness_solve_float, par_H, limits, x, inc

	x_seed = x
	syn_num = 1000000.
	sz = size(x_seed)
	n = sz[1]
	
	if sz[0] eq 2 then begin &$
		x_syn = dblarr(syn_num, sz[2]) &$
		diff = ((limits[*, 1]-limits[*, 0])/inc)+1 &$
	endif else begin &$
		x_syn = dblarr(syn_num) &$
		diff = ((limits[1]-limits[0])/inc)+1 &$
	endelse
	H = par_H
	
	if sz[0] eq 2 then begin &$
		for i = 0, sz[2]-1 do begin &$
			lx = dindgen(diff[i], start = limits[i, 0], increment = inc[i]) &$
			y = lx*0. &$
			for j = 0, n-1 do begin &$
				W1=(lx-x_seed[j, i])^2. &$
				var1=(w1/h[i]) &$
				y=y+exp((-.5)*(var1)) &$ ;;<-- one patient at EVERY combination
			endfor &$
			y=y/double(n) &$
			fx2=y/total(y, /double, /nan) &$
			cumfx = total(Fx2, /cumulative, /double) &$
			cum_index = randomu(seed, syn_num) &$
			for j=0L, syn_num-1 do begin &$
				trap = where(cumfx gt cum_index[j], ct) &$
				x_syn[j, i] = lx[trap[0]] &$
			endfor &$
		endfor &$
		dsum = 0. &$
		index_test = floor(randomu(seed, sz[1])*syn_num)
		for i=0, sz[2]-1 do begin &$
			prob = KS_test(reform(x_seed[*, i]), reform(x_syn[index_test, i]), D) &$
			dsum = dsum+d &$
			;print, D, Prob, format = '(2(f20.8))' &$
		endfor &$
		d = dsum &$
	endif else begin &$
		lx = dindgen(diff, start = limits[0], increment = inc) &$
		y = lx*0. &$
		for j = 0, n-1 do begin &$
			W1=(lx-x_seed[j])^2. &$
			var1=(w1/h[0]) &$
			y=y+exp((-.5)*(var1)) &$ ;;<-- one patient at EVERY combination
		endfor &$
		y=y/double(n) &$
		fx2=y/total(y, /double, /nan) &$
		cumfx = total(Fx2, /cumulative, /double) &$
		cum_index = randomu(seed, syn_num) &$
		for j=0L, syn_num-1 do begin &$
			trap = where(cumfx gt cum_index[j], ct) &$
			x_syn[j] = lx[trap[0]] &$
		endfor &$
		;x_syn = round(x_syn) &$
		;x_syn = [x_syn, x_seed] &$
		index_test = floor(randomu(seed, sz[1])*syn_num) &$
		prob = KS_test(x_seed, x_syn[index_test], D) &$
	endelse

	return, x_syn
end


function remove_missing_with_mean, covar, idns, caco
	sz = size(covar)
	new = strarr(sz[1], sz[2]+2)
	
	covar_file = '/data/Heine/work/Erin/Do_All/M4M_PCA_Kernel/TXT/GE_R01_U01_Log_20201028.txt'
	master_covar = read_sas_txt(covar_file)
	tags = master_covar[0, *]
	master_covar=master_covar[1:*, *]
	master_covar[*, 0] = master_covar[*, 0].replace('R', 'N')
	
	index = fltarr(sz[1])
	for i=0, sz[1]-1 do begin &$
		trap = where(master_covar[*, 0] eq strmid(idns[i, 0], 0, 5), ct) &$
		;print, i, '	', strmid(idns[i, 0], 0, 5), '	', ct, trap &$
		index[i] = trap[0] &$
	endfor
	
	new[*, 0:15] = covar
	new[*, 16:17] = master_covar[index, 14:15]
	
	sz = size(new)
	ca = where(caco eq 1, complement = co, n1, ncomplement = n2)
	for i=0, sz[2]-1 do begin &$
		trap1 = where(new[ca, i] eq '-999', complement = keep1, mis1) &$
		trap2 = where(new[co, i] eq '-999', complement = keep2, mis2) &$
		if mis1 gt 0 then new[ca[trap1], i] = mean(double(new[ca[keep1], i]), /double, /nan) &$
		if mis2 gt 0 then new[co[trap2], i] = mean(double(new[co[keep2], i]), /double, /nan) &$
	endfor
	
	return, new
end

