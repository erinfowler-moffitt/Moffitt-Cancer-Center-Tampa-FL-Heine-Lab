pro gather_hfiles, output, hfiles, ct, count
hfiles=file_search(output+'GENERATION_*.dat', count = ct)
count = file_basename(hfiles)
count = count.replace('GENERATION_', '')
count = long(count.replace('.dat', ''))
index = sort(count)
hfiles = hfiles[index]
count = count[index]
end

pro hfile_info, output, hfiles, count, ct, d_best, par, min_avg, ds, avg_ds
par = dblarr(ct, 23)
min_avg = dblarr(ct, 10, 2)
Ds = dblarr(ct, 100, 10)
avg_ds = dblarr(ct, 10)
for i=0, ct-1 do begin &$
	restore, hfiles[i] &$
	mini = min(fit, loc) &$
	print, mini, loc, abs((5000.*100./accepts[loc])), mean(abs((5000.*100./accepts))) &$
	restore, filename = output+'/XG1/GENERATION_'+strtrim(string(count[i]), 2)+'/TARGET_'+strtrim(string(ulong(loc)), 2)+'.dat' &$
	par[i, *] = [xg, xg_sx, fit[loc], abs((5000.*100./accepts[loc])), mean(abs((5000.*100./accepts)))] &$
	min_avg[i, *, 0] = xg &$
	avg = [] &$
	for j=0, 100-1 do begin &$
		restore, filename = output+'/XG1/GENERATION_'+strtrim(string(count[i]), 2)+'/TARGET_'+strtrim(string(ulong(j)), 2)+'.dat' &$
		avg = [[avg], [xg]] &$
		DS[i, j, *] = d &$
		tmp = reform(ds[i, j, *]) &$
		trap = where(tmp le d_best, ct) &$
		if ct ge 7 then print, i+1, j, loc, ct &$
	endfor &$
	avg_ds[i, *] = mean(reform(ds[i, *, *]), dimension = 1) &$
	min_avg[i, *, 1] = mean(avg, /double, /nan, dimension = 2) &$
endfor
end



pro grab_syn_data, nfile, hfile, minmaxran, syn_num, newx
restore, nfile
sz = size(x)
restore, hfile
output = file_dirname(hfile)+'/'
id = file_basename(hfile)
id = id.replace('.dat', '')


case minmaxran of &$
	'min': begin &$
		tmp = min(fit, loc) &$
		print, minmaxran, ' min', loc &$	
	end &$
	'max': begin &$
		tmp = max(fit, loc) &$
		print, minmaxran, ' max', loc &$
	end &$
	'ran': begin &$
		m = n_elements(fit) &$
		loc = floor(randomu(seed, 1)*m) &$
		print, minmaxran, ' ran', loc &$
	end &$
	else: begin &$
		loc = fix(minmaxran) &$
		print, minmaxran, ' TOLD', loc &$
	end &$
endcase &$
restore, filename = output+'XG1/'+id+'/TARGET_'+strtrim(string(loc), 2)+'.dat'

mx = mean(x, dimension=1, /double, /nan)
sz = size(x)
par_H = xg
par_sx = xg_sx
if sz[0] gt 1 then begin &$
	h = dblarr(sz[2], sz[2]) &$
	for i = 0, sz[2]-1 do h[i, i] = par_H[i] &$
	hinv = invert(h) &$
endif else begin &$
	h = par_H &$
	hinv = 1./h &$
endelse


create_lx, sz, limits, mx, par_SX, x0, lx
w = lx - x
create_var_d, w, hinv, sz, var
fx0 = mean(exp((-.5)*(var)), /double, /nan)

counter = 0.
num = []
ct = 1.
newx = []
while counter lt syn_num do begin &$
	create_lx, sz, limits, mx, par_SX, x1, lx &$
	w = lx - x &$
	create_var_d, w, hinv, sz, var &$
	fx1 = mean(exp((-0.5)*(var)), /double, /nan) &$
	alpha = fx1/fx0 &$
	u = randomu(seed, 1) &$
	if u le alpha then begin &$
		fx0 = fx1 &$
		mx = x1 &$
		newx = [[newx], [x1]] &$
		counter++ &$
		num = [num, ct] &$
		ct = 1. &$
	endif else ct++ &$
	;print, counter &$
endwhile

newx = transpose(newx)
end

pro The_Test, x, sz, rate, newx, syn_num, mmd, thresh_control, ds, probs
T_SEED = x
X_SEED = x # invert(rate)

Ht = correlate(transpose(t_seed), /covariance)
Hx = correlate(transpose(X_SEED), /covariance)

T_SYN1 = newx
X_SYN1 = newx # invert(rate)

index = floor(randomu(seed, sz[1])*syn_num)
x_syn2 = X_SYN1[index, *]
t_syn2 = t_syn1[index, *]


Ht2 = correlate(transpose(t_syn2), /covariance)
Hx2 = correlate(transpose(x_syn2), /covariance)

hdiff = make_h_same_seedonly(x_seed, x_syn2)

h = hdiff
BIG_K_CONTROL = find_k(sz[2], h, sz[1], x_seed)
thresh_control = 4.*BIG_K_CONTROL*sqrt(alog(0.05^(-1.)))/sqrt(sz[1])
mmd_same_sample_size2, sz[2], h, sz[1], X_SEED, x_syn2, mmd, extrabit
if mmd lt thresh_control then print, 'Pass.', mmd, thresh_control else print, 'Fail.', mmd, thresh_control
ds = dblarr(sz[2])
probs = ds
for i=0, sz[2]-1 do begin &$
	prob = KS_test(reform(t_seed[*, i]), reform(T_SYN2[*, i]), D) &$
	print, D, Prob, format = '(2(f20.8))' &$
	ds[i] = d &$
	probs[i]= prob &$
endfor
end


pro The_Test_t, x, sz, rate, newx, syn_num, mmd, thresh_control, ds, probs
T_SEED = x
X_SEED = x # invert(rate)

Ht = correlate(transpose(t_seed), /covariance)
Hx = correlate(transpose(X_SEED), /covariance)

T_SYN1 = newx
X_SYN1 = newx # invert(rate)

index = floor(randomu(seed, sz[1])*syn_num)
x_syn2 = X_SYN1[index, *]
t_syn2 = t_syn1[index, *]


Ht2 = correlate(transpose(t_syn2), /covariance)
Hx2 = correlate(transpose(x_syn2), /covariance)

hdiff = make_h_diff(t_seed, t_syn2)

h = hdiff
BIG_K_CONTROL = find_k(sz[2], h, sz[1], t_seed)
thresh_control = 4.*BIG_K_CONTROL*sqrt(alog(0.05^(-1.)))/sqrt(sz[1])
mmd_same_sample_size2, sz[2], h, sz[1], t_SEED, t_syn2, mmd, extrabit
if mmd lt thresh_control then print, 'Pass.', mmd, thresh_control else print, 'Fail.', mmd, thresh_control
ds = dblarr(sz[2])
probs = ds
for i=0, sz[2]-1 do begin &$
	prob = KS_test(reform(t_seed[*, i]), reform(T_SYN2[*, i]), D) &$
	print, D, Prob, format = '(2(f20.8))' &$
	ds[i] = d &$
	probs[i]= prob &$
endfor
end


