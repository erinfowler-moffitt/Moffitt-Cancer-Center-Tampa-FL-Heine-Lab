.run /data/Heine/work/Erin/Do_All/RETIRE/HARVARD_MAYO_MAP/PROGRAMS/MASTER_COMPILE_2019.pro
.run /data/Heine/work/Erin/Do_All/RETIRE/HARVARD_MAYO_MAP/PROGRAMS/master_run_measures_2019.pro
file='/data/Heine/work/Erin/Do_All/R01_U01_FFDM_List/DAT/BASIC_INFORMATION_DS667_20200117.dat'
restore, file

front_path = '/data/Heine/work/Erin/Do_All/R01_U01_FFDM_List/IMAGES/'
rpath = front_path+idns[*, 0]+'.tiff'
fpath = front_path+idns[*, 0]+'.png'
bpath = front_path+idns[*, 0]+'_box.tiff'
save_path = '/data/Heine/work/Erin/Do_All/R01_U01_FFDM_List/DAT/'
txt_path = '/data/Heine/work/Erin/Do_All/R01_U01_FFDM_List/TXT/'
masterfile = save_path+'DS667_Master_Measures.dat'
restore, masterfile
;;save, n, idns, header_raw, header_proc, covar, caco, group, fname, ba, v, vl, fourier, laws, cooccur, correlation, diffusion, wavelet, wavelet_kernal, wave_mag, wave_mag_kernal, filename = masterfile

help, ba, v, vl, fourier, laws, cooccur, correlation, diffusion, wavelet, wavelet_kernal, wave_mag, wave_mag_kernal
;BA              DOUBLE    = Array[1334]
;V               DOUBLE    = Array[1334, 6, 20]
;VL              DOUBLE    = Array[1334, 6, 20]
;FOURIER         DOUBLE    = Array[1334, 87]
;LAWS            DOUBLE    = Array[1334, 25, 3]
;COOCCUR         DOUBLE    = Array[1334, 11, 5, 2]
;CORRELATION     DOUBLE    = Array[1334, 7, 2, 50]
;DIFFUSION       DOUBLE    = Array[1334, 200]
;WAVELET         DOUBLE    = Array[1334, 21, 4, 2]
;WAVELET_KERNAL  DOUBLE    = Array[1334, 21, 4, 2]
;WAVE_MAG        DOUBLE    = Array[1334, 21, 7]
;WAVE_MAG_KERNAL DOUBLE    = Array[1334, 21, 7]
segs = reverse(((findgen(20)+1.)*5.)/100.)
n = n_elements(ba)
x_seed = dblarr(n, 3)
x_seed[*, 0] = ba*(0.007^2.)
x_seed[*, 1] = v[*, 5, 5] ;V75
x_seed[*, 2] = v[*, 2, 5] ;SKEWNESS!
file = '/data/Heine/work/Erin/Do_All/Syn_Data_Exp_2023/DAT/Data_3VAR_INFO.dat'
save, x_seed, filename = file



.run /data/Heine/work/Erin/MASTER_MODULES/pcomp.pro
.run /data/Heine/work/Erin/Do_All/M4M_MAY2021/PROGRAMS/MASTER_COMPILE_2021.pro
.run /data/Heine/work/Erin/Do_All/M4M_MAY2021/PROGRAMS/local_at1.pro
.run /data/Heine/work/Erin/Do_All/M4M_MAY2021/PROGRAMS/DE_COMPILE_single.pro
.run /data/Heine/work/Erin/Do_All/M4M_MAY2021/PROGRAMS/MMD_Compile.pro
.run /data/Heine/work/Erin/Do_All/M4M_DEC2020/PROGRAMS/local_compile_fastcheck.pro
file = '/data/Heine/work/Erin/Do_All/Syn_Data_Exp_2023/DAT/Data_3VAR_INFO.dat'
restore, file
sz = size(x_seed)
mini = min(x_seed, dimension = 1, max = maxi)
limits = [[mini], [maxi]]
inc = dblarr(sz[2])+1.
diff = ((median(x_seed, dimension = 1, /double)-limits[*, 0])/inc)+1


for i=0, sz[2]-1 do begin &$
	while diff[i] lt 100 do begin &$
		inc[i] = inc[i]/10. &$
		diff = ((median(x_seed, dimension = 1, /double)-limits[*, 0])/inc)+1 &$
	endwhile &$
endfor
;DATASET = 'REAL_X'
;i=2
;num = strtrim(string(i+1), 2)
;output = '/data/Heine/work/Erin/Do_All/Syn_Data_Exp_2023/DE_FILES/'+DATASET+'_AT'+num+'/'
;if file_test(output) eq 0 then file_mkdir, output
;dn = 1.
;bl = dblarr(dn)+0.00000001
;bu = variance(reform(x_seed[*, i]), /double, /nan)*4.
;NP=dn*1000.
;F=0.5
;CR=0.5
;maxgen=30.
;optima = -1.
;main, reform(x_seed[*, i]), reform(limits[i, *]), inc[i], NP, DN, BL, BU, F, Cr, maxgen, optima, output
syn_num = long(1000000)
DATASET = 'REAL_X'
h = dblarr(sz[2])
x_syn = dblarr(syn_num+sz[1], sz[2])
h_mean = dblarr(sz[2])
for i=0, sz[2]-1 do begin &$
	num = strtrim(string(i+1), 2) &$
	output = '/data/Heine/work/Erin/Do_All/Syn_Data_Exp_2023/DE_FILES/'+DATASET+'_AT'+num+'/' &$
	gather_hfiles, output, hfiles, ct, count &$
	ids = file_basename(hfiles) &$
	ids = ids.replace('.dat', '') &$
	grab0 = dblarr(1000) &$
	grab1 = dblarr(1000) &$
	ct = ct < 30 &$
	for loc=0, 1000-1 do begin &$
		restore, filename = output+'XG1/'+ids[0]+'/TARGET_'+strtrim(string(loc), 2)+'.dat' &$
		grab0[loc] = xg &$
		restore, filename = output+'XG1/'+ids[ct-1]+'/TARGET_'+strtrim(string(loc), 2)+'.dat' &$
		grab1[loc] = xg &$
	endfor &$
	restore, hfiles[ct-1] &$
	mini = min(fit, loc) &$
	h[i] = grab1[loc] &$
	h_mean[i] = mean(grab1, /double, /nan) &$
	if ct eq 30 then tmp = fitness_solve_float(h_mean[i], reform(limits[i, *]), reform(x_seed[*, i]), inc[i]) else tmp = fitness_solve_float(h[i], reform(limits[i, *]), reform(x_seed[*, i]), inc[i]) &$
	x_syn[*, i] = [tmp, reform(x_seed[*, i])] &$
endfor



y_seed = x_seed*0.
for i=0, sz[2]-1 do begin &$
  restore, '/data/Heine/work/Erin/Do_All/RETIRE/HARVARD_MAYO_MAP/DAT/TARGET_SCALE.dat' &$
  target = (target - mean(target, /double, /nan))/stddev(target, /double, /nan) &$
  warp = x_syn[*, i] &$
  scale_factor1 = (max(warp)-min(warp))/5000. &$
  scale_factor0 = target_scale &$
  tmp = get_mapp(target, warp, scale_factor0, scale_factor1, map_wtt) &$
  nwarp=(x_seed[*, i]-min(x_syn[*, i]))/scale_factor1 &$
  y_seed[*, i] = map_wtt[nwarp] &$

  restore, '/data/Heine/work/Erin/Do_All/RETIRE/HARVARD_MAYO_MAP/DAT/TARGET_SCALE.dat' &$
  target = (target - mean(target, /double, /nan))/stddev(target, /double, /nan) &$
  scale_factor0 = (max(x_syn[*, i])-min(x_syn[*, i]))/5000. &$
  scale_factor1 = target_scale &$
  tmp = get_mapp(x_syn[*, i], target, scale_factor0, scale_factor1, map_ttw) &$
endfor
 
 

print, ';', correlate(x_seed[*, 0], x_seed[*, 1]), correlate(x_seed[*, 0], x_seed[*, 2]), correlate(x_seed[*, 1], x_seed[*, 2]) &$
print, ';', correlate(y_seed[*, 0], y_seed[*, 1]), correlate(y_seed[*, 0], y_seed[*, 2]), correlate(y_seed[*, 1], y_seed[*, 2]) 
;     -0.10403533     0.077950794      0.40815168
;     -0.14509643    -0.022742716      0.30778512

yx = mean(y_seed, /double, dimension = 1)
ys = stddev(y_seed, /double, dimension = 1)
print, ';', yx &$
print, ';', ys
;   -0.0017665934    -0.010645650   -0.0069046109
;       1.0005795       1.0062328       1.0076135

VAR1 = ((fltarr(SZ[1])+1) # yx)
VAR2 = ((fltarr(SZ[1])+1) # ys)
y_seed_mr = (y_seed - VAR1)/var2
tmp1 = mean(y_seed_mr, /double, dimension = 1)
tmp2 = stddev(y_seed_mr, /double, dimension = 1)
print, ';', tmp1 &$
print, ';', tmp2
;   4.9498137e-17  -1.0324075e-16   6.3646406e-17
;       1.0000000       1.0000000       1.0000000

restore, '/data/Heine/work/Erin/Do_All/RETIRE/HARVARD_MAYO_MAP/DAT/TARGET_SCALE.dat'
target = (target - mean(target, /double, /nan))/stddev(target, /double, /nan)
prob_y1 = ks_test(y_seed_mr[*, 0], target, d)
prob_y2 = ks_test(y_seed_mr[*, 1], target, d)
prob_y3 = ks_test(y_seed_mr[*, 2], target, d)
print, ';', prob_y1, prob_y2, prob_y3
;     0.972486     0.996588     0.649299


t_seed = transpose(pcomp(transpose(y_seed_mr), coefficients = rate, /covariance, /double))
;t_seed = (y_seed_mr # og_rate)
tmp1 = mean(t_seed, /double, dimension = 1)
ts = stddev(t_seed, dimension = 1)
print, ';', tmp1 &$
print, ';', ts &$
print, ';', ts^2. &$
print, ';', (ts^2.)*100./total((ts^2.)) &$
print, ';', correlate(t_seed[*, 0], t_seed[*, 1]), correlate(t_seed[*, 0], t_seed[*, 2]), correlate(t_seed[*, 1], t_seed[*, 2])
;  -3.4496810e-17  -2.0785472e-17  -4.0801112e-17
;       1.1616580      0.99120531      0.81735108
;       1.3494493      0.98248797      0.66806278
;       44.981642       32.749599       22.268759
;  -8.5624525e-18  -3.3466952e-16  -2.1826464e-17
x_fake_seed = x_syn
x_h = h
x_h_mean = h_mean
save, x_fake_seed, x_seed, y_seed, y_seed_mr, rate, t_seed, x_h, x_h_mean, filename = file



.run /data/Heine/work/Erin/MASTER_MODULES/pcomp.pro
.run /data/Heine/work/Erin/Do_All/M4M_MAY2021/PROGRAMS/MASTER_COMPILE_2021.pro
.run /data/Heine/work/Erin/Do_All/M4M_MAY2021/PROGRAMS/local_at1.pro
.run /data/Heine/work/Erin/Do_All/M4M_MAY2021/PROGRAMS/DE_COMPILE_single.pro
.run /data/Heine/work/Erin/Do_All/M4M_MAY2021/PROGRAMS/MMD_Compile.pro
.run /data/Heine/work/Erin/Do_All/M4M_DEC2020/PROGRAMS/local_compile_fastcheck.pro
file = '/data/Heine/work/Erin/Do_All/Syn_Data_Exp_2023/DAT/Data_3VAR_INFO.dat'
restore, file

mini = min(t_seed, dimension = 1, max = maxi)
limits = [[mini], [maxi]]
sz = size(t_seed)
inc = dblarr(sz[2])+1.
diff = ((median(t_seed, dimension = 1, /double)-limits[*, 0])/inc)+1

for i=0, sz[2]-1 do begin &$
	while diff[i] lt 100 do begin &$
		inc[i] = inc[i]/10. &$
		diff = ((median(t_seed, dimension = 1, /double)-limits[*, 0])/inc)+1 &$
	endwhile &$
endfor

;DATASET = 'REAL_T'
;i = 2
;num = strtrim(string(i+1), 2)
;output = '/data/Heine/work/Erin/Do_All/Syn_Data_Exp_2023/DE_FILES/'+DATASET+'_AT'+num+'/'
;if file_test(output) eq 0 then file_mkdir, output
;dn = 1.
;bl = dblarr(dn)+0.00000001
;bu = variance(reform(t_seed[*, i]), /double, /nan)*4.
;NP=dn*1000.
;F=0.5
;CR=0.5
;maxgen=30.
;optima = -1.
;main, reform(t_seed[*, i]), reform(limits[i, *]), inc[i], NP, DN, BL, BU, F, Cr, maxgen, optima, output
syn_num = long(1000000)
DATASET = 'REAL_T'
h = dblarr(sz[2])
t_syn = dblarr(syn_num+sz[1], sz[2])
h_mean = dblarr(sz[2])
for i=0, sz[2]-1 do begin &$
	num = strtrim(string(i+1), 2) &$
	output = '/data/Heine/work/Erin/Do_All/Syn_Data_Exp_2023/DE_FILES/'+DATASET+'_AT'+num+'/' &$
	gather_hfiles, output, hfiles, ct, count &$
	ids = file_basename(hfiles) &$
	ids = ids.replace('.dat', '') &$
	grab0 = dblarr(1000) &$
	grab1 = dblarr(1000) &$
	ct = ct < 30 &$
	for loc=0, 1000-1 do begin &$
		restore, filename = output+'XG1/'+ids[0]+'/TARGET_'+strtrim(string(loc), 2)+'.dat' &$
		grab0[loc] = xg &$
		restore, filename = output+'XG1/'+ids[ct-1]+'/TARGET_'+strtrim(string(loc), 2)+'.dat' &$
		grab1[loc] = xg &$
	endfor &$
	restore, hfiles[ct-1] &$
	mini = min(fit, loc) &$
	h[i] = grab1[loc] &$
	h_mean[i] = mean(grab1, /double, /nan) &$
	if ct eq 30 then tmp = fitness_solve_float(h_mean[i], reform(limits[i, *]), reform(t_seed[*, i]), inc[i]) else tmp = fitness_solve_float(h[i], reform(limits[i, *]), reform(t_seed[*, i]), inc[i]) &$
	t_syn[*, i] = [tmp, reform(t_seed[*, i])] &$
	PRINT, MIN(T_syn[*, i]), min(t_seed[*, i]), max(T_syn[*, i]), max(t_seed[*, i]) &$
endfor
t_h = h
t_h_mean = h_mean
file = '/data/Heine/work/Erin/Do_All/Syn_Data_Exp_2023/DAT/Data_3VAR_INFO.dat'
save, x_fake_seed, x_seed, y_seed, y_seed_mr, rate, t_seed, t_syn, x_h, x_h_mean, t_h, t_h_mean, filename = file

sz_syn = size(t_syn)
tmp1 = mean(t_syn, /double, dimension = 1)
tmp2 = stddev(t_syn, /double, dimension = 1)
print, tmp1, tmp2

y_syn_mr = (t_syn # invert(rate))
tmp1 = mean(y_syn_mr, /double, dimension = 1)
tmp2 = stddev(y_syn_mr, /double, dimension = 1)
print, tmp1, tmp2

VAR3 = ((fltarr(sz_syn[1])+1) # tmp1)
VAR4 = ((fltarr(sz_syn[1])+1) # tmp2)
y_syn = (y_syn_mr - var3)/var4
tmp1 = mean(y_syn, /double, dimension = 1)
tmp2 = stddev(y_syn, /double, dimension = 1)
print, tmp1, tmp2

x_syn = y_syn*0.
for i=0, sz[2]-1 do begin &$
  restore, '/data/Heine/work/Erin/Do_All/RETIRE/HARVARD_MAYO_MAP/DAT/TARGET_SCALE.dat' &$
  target = (target - mean(target, /double, /nan))/stddev(target, /double, /nan) &$
  scale_factor0 = (max(x_fake_seed[*, i])-min(x_fake_seed[*, i]))/5000. &$
  scale_factor1 = target_scale &$
  tmp = get_mapp(x_fake_seed[*, i], target, scale_factor0, scale_factor1, map_ttw) &$
  nwarp=(y_syn[*, i]-min(target))/scale_factor1 &$
  x_syn[*, i] = map_ttw[nwarp] &$ 
endfor

file = '/data/Heine/work/Erin/Do_All/Syn_Data_Exp_2023/DAT/Data_3VAR_INFO.dat'
save, x_fake_seed, x_seed, x_syn, y_seed, y_seed_mr, y_syn, rate, t_seed, t_syn, x_h, x_h_mean, t_h, t_h_mean, filename = file


hist1 = float(histogram(t_seed[*, 0], nbins = 60, location = x1))
hist2 = float(histogram(t_seed[*, 1], nbins = 60, location = x2))
hist3 = float(histogram(t_seed[*, 2], nbins = 60, location = x3))
hist4 = float(histogram(t_syn[*, 0], nbins = 60, location = x4))
hist5 = float(histogram(t_syn[*, 1], nbins = 60, location = x5))
hist6 = float(histogram(t_syn[*, 2], nbins = 60, location = x6))
hist1 = hist1/total(hist1)
hist2 = hist2/total(hist2)
hist3 = hist3/total(hist3)
hist4 = hist4/total(hist4)
hist5 = hist5/total(hist5)
hist6 = hist6/total(hist6)
xmi1 = min([x1, x4], max = xma1)
x1r = (xma1-xmi1)/10.
ymi1 = min([hist1, hist4], max = yma1)
y1r = (yma1-ymi1)/10.
xmi2 = min([x2, x5], max = xma2)
x2r = (xma2-xmi2)/10.
ymi2 = min([hist2, hist5], max = yma2)
y2r = (yma2-ymi2)/10.
xmi3 = min([x3, x6], max = xma3)
x3r = (xma3-xmi3)/10.
ymi3 = min([hist3, hist6], max = yma3)
y3r = (yma3-ymi3)/10.
marg = [0.1, 0.05, 0.05, 0.1]
graphic = plot(x1, hist1, title = '$t_1 seed$', xtitle = '$t_1 seed$', ytitle = 'relative frequency', layout = [3, 2, 1], xrange = [xmi1-x1r, xma1+x1r], yrange = [0.-y1r, yma1+y1r], dimension = [1000, 1000], margin = marg)
graphic = plot(x4, hist4, title = '$t_1 synthetic$', xtitle = '$t_1 synthetic$', ytitle = 'relative frequency', layout = [3, 2, 4], xrange = [xmi1-x1r, xma1+x1r], yrange = [0.-y1r, yma1+y1r], /current, margin = marg)
graphic = plot(x2, hist2, title = '$t_2 seed$', xtitle = '$t_2 seed$', ytitle = 'relative frequency', layout = [3, 2, 2], xrange = [xmi2-x2r, xma2+x2r], yrange = [0-y2r, yma2+y2r], /current, margin = marg)
graphic = plot(x5, hist5, title = '$t_2 synthetic$', xtitle = '$t_2 synthetic$', ytitle = 'relative frequency', layout = [3, 2, 5], xrange = [xmi2-x2r, xma2+x2r], yrange = [0-y2r, yma2+y2r], /current, margin = marg)
graphic = plot(x3, hist3, title = '$t_3 seed$', xtitle = '$t_3 seed$', ytitle = 'relative frequency', layout = [3, 2, 3], xrange = [xmi3-x3r, xma3+x3r], yrange = [0-y3r, yma3+y3r], /current, margin = marg)
graphic = plot(x6, hist6, title = '$t_3 synthetic$', xtitle = '$t_3 synthetic$', ytitle = 'relative frequency', layout = [3, 2, 6], xrange = [xmi3-x3r, xma3+x3r], yrange = [0-y3r, yma3+y3r], /current, margin = marg)
graphic.save, '/data/Heine/work/Erin/Do_All/Syn_Data_Exp_2023/FIGURES/T_ALL_3var_20240725.jpeg'

hist1 = float(histogram(y_seed_mr[*, 0], nbins = 60, location = x1))
hist2 = float(histogram(y_seed_mr[*, 1], nbins = 60, location = x2))
hist3 = float(histogram(y_seed_mr[*, 2], nbins = 60, location = x3))
hist4 = float(histogram(y_syn[*, 0], nbins = 60, location = x4))
hist5 = float(histogram(y_syn[*, 1], nbins = 60, location = x5))
hist6 = float(histogram(y_syn[*, 2], nbins = 60, location = x6))
hist1 = hist1/total(hist1)
hist2 = hist2/total(hist2)
hist3 = hist3/total(hist3)
hist4 = hist4/total(hist4)
hist5 = hist5/total(hist5)
hist6 = hist6/total(hist6)
xmi1 = min([x1, x4], max = xma1)
x1r = (xma1-xmi1)/10.
ymi1 = min([hist1, hist4], max = yma1)
y1r = (yma1-ymi1)/10.
xmi2 = min([x2, x5], max = xma2)
x2r = (xma2-xmi2)/10.
ymi2 = min([hist2, hist5], max = yma2)
y2r = (yma2-ymi2)/10.
xmi3 = min([x3, x6], max = xma3)
x3r = (xma3-xmi3)/10.
ymi3 = min([hist3, hist6], max = yma3)
y3r = (yma3-ymi3)/10.
marg = [0.1, 0.05, 0.05, 0.1]
graphic = plot(x1, hist1, title = '$y_1 seed$', xtitle = '$y_1 seed$', ytitle = 'relative frequency', layout = [3, 2, 1], xrange = [xmi1-x1r, xma1+x1r], yrange = [0.-y1r, yma1+y1r], dimension = [1000, 1000], margin = marg)
graphic = plot(x4, hist4, title = '$y_1 synthetic$', xtitle = '$y_1 synthetic$', ytitle = 'relative frequency', layout = [3, 2, 4], xrange = [xmi1-x1r, xma1+x1r], yrange = [0.-y1r, yma1+y1r], /current, margin = marg)
graphic = plot(x2, hist2, title = '$y_2 seed$', xtitle = '$y_2 seed$', ytitle = 'relative frequency', layout = [3, 2, 2], xrange = [xmi2-x2r, xma2+x2r], yrange = [0-y2r, yma2+y2r], /current, margin = marg)
graphic = plot(x5, hist5, title = '$y_2 synthetic$', xtitle = '$y_2 synthetic$', ytitle = 'relative frequency', layout = [3, 2, 5], xrange = [xmi2-x2r, xma2+x2r], yrange = [0-y2r, yma2+y2r], /current, margin = marg)
graphic = plot(x3, hist3, title = '$y_3 seed$', xtitle = '$y_3 seed$', ytitle = 'relative frequency', layout = [3, 2, 3], xrange = [xmi3-x3r, xma3+x3r], yrange = [0-y3r, yma3+y3r], /current, margin = marg)
graphic = plot(x6, hist6, title = '$y_3 synthetic$', xtitle = '$y_3 synthetic$', ytitle = 'relative frequency', layout = [3, 2, 6], xrange = [xmi3-x3r, xma3+x3r], yrange = [0-y3r, yma3+y3r], /current, margin = marg)
graphic.save, '/data/Heine/work/Erin/Do_All/Syn_Data_Exp_2023/FIGURES/Y_ALL_3var_20240725.jpeg'

hist1 = float(histogram(x_seed[*, 0], nbins = 60, location = x1))
hist2 = float(histogram(x_seed[*, 1], nbins = 60, location = x2))
hist3 = float(histogram(x_seed[*, 2], nbins = 60, location = x3))
hist4 = float(histogram(x_syn[*, 0], nbins = 60, location = x4))
hist5 = float(histogram(x_syn[*, 1], nbins = 60, location = x5))
hist6 = float(histogram(x_syn[*, 2], nbins = 60, location = x6))
hist1 = hist1/total(hist1)
hist2 = hist2/total(hist2)
hist3 = hist3/total(hist3)
hist4 = hist4/total(hist4)
hist5 = hist5/total(hist5)
hist6 = hist6/total(hist6)
xmi1 = min([x1, x4], max = xma1)
x1r = (xma1-xmi1)/10.
ymi1 = min([hist1, hist4], max = yma1)
y1r = (yma1-ymi1)/10.
xmi2 = min([x2, x5], max = xma2)
x2r = (xma2-xmi2)/10.
ymi2 = min([hist2, hist5], max = yma2)
y2r = (yma2-ymi2)/10.
xmi3 = min([x3, x6], max = xma3)
x3r = (xma3-xmi3)/10.
ymi3 = min([hist3, hist6], max = yma3)
y3r = (yma3-ymi3)/10.
marg = [0.1, 0.05, 0.05, 0.1]
graphic = plot(x1, hist1, title = '$x_1 seed$', xtitle = '$x_1 seed$', ytitle = 'relative frequency', layout = [3, 2, 1], xrange = [xmi1-x1r, xma1+x1r], yrange = [0.-y1r, yma1+y1r], dimension = [1000, 1000], margin = marg)
graphic = plot(x4, hist4, title = '$x_1 synthetic$', xtitle = '$x_1 synthetic$', ytitle = 'relative frequency', layout = [3, 2, 4], xrange = [xmi1-x1r, xma1+x1r], yrange = [0.-y1r, yma1+y1r], /current, margin = marg)
graphic = plot(x2, hist2, title = '$x_2 seed$', xtitle = '$x_2 seed$', ytitle = 'relative frequency', layout = [3, 2, 2], xrange = [xmi2-x2r, xma2+x2r], yrange = [0-y2r, yma2+y2r], /current, margin = marg)
graphic = plot(x5, hist5, title = '$x_2 synthetic$', xtitle = '$x_2 synthetic$', ytitle = 'relative frequency', layout = [3, 2, 5], xrange = [xmi2-x2r, xma2+x2r], yrange = [0-y2r, yma2+y2r], /current, margin = marg)
graphic = plot(x3, hist3, title = '$x_3 seed$', xtitle = '$x_3 seed$', ytitle = 'relative frequency', layout = [3, 2, 3], xrange = [xmi3-x3r, xma3+x3r], yrange = [0-y3r, yma3+y3r], /current, margin = marg)
graphic = plot(x6, hist6, title = '$x_3 synthetic$', xtitle = '$x_3 synthetic$', ytitle = 'relative frequency', layout = [3, 2, 6], xrange = [xmi3-x3r, xma3+x3r], yrange = [0-y3r, yma3+y3r], /current, margin = marg)
graphic.save, '/data/Heine/work/Erin/Do_All/Syn_Data_Exp_2023/FIGURES/X_ALL_3var_20240725.jpeg'

sz_seed = size(x_seed)
sz_syn = size(x_syn)
x_KST = fltarr(1000, sz_seed[2])
y_KST = fltarr(1000, sz_seed[2])
t_KST = fltarr(1000, sz_seed[2])
for i=0, sz_seed[2]-1 do begin &$
	for j=0, 1000-1 do begin &$
		index = floor(randomu(seed, sz_seed[1])*sz_syn[1]) &$
		prob = ks_test(x_seed[*, i], x_syn[index, i], d) &$
		x_kst[j, i] = prob &$
		prob = ks_test(y_seed_mr[*, i], y_syn[index, i], d) &$
		y_kst[j, i] = prob &$
		prob = ks_test(t_seed[*, i], t_syn[index, i], d) &$
		t_kst[j, i] = prob &$
		;print, i, j &$
	endfor &$
endfor
for i=0, sz_seed[2]-1 do begin &$
	trap = where(x_kst[*, i] gt 0.05, ct) &$
	print, ';X '+strtrim(string(i), 2), '	', ct/10., mean(x_kst[*, i], /double, /nan) &$
	trap = where(y_kst[*, i] gt 0.05, ct) &$
	print, ';Y '+strtrim(string(i), 2), '	', ct/10., mean(y_kst[*, i], /double, /nan) &$
	trap = where(t_kst[*, i] gt 0.05, ct) &$
	print, ';T '+strtrim(string(i), 2), '	', ct/10., mean(t_kst[*, i], /double, /nan) &$
endfor
;X 0	      92.0000      0.43678721
;X 1	      99.1000      0.68796903
;X 2	      97.8000      0.58705985
;Y 0	      93.6000      0.44907560
;Y 1	      98.9000      0.67354241
;Y 2	      99.3000      0.60392147
;T 0	      99.6000      0.67437170
;T 1	      99.5000      0.65214984
;T 2	      99.6000      0.66262883

sz_seed = size(x_seed)
sz = size(x_seed)
sz_syn = size(x_syn)
;;COVARIANCE TESTS!
index = floor(randomu(seed, sz_seed[1])*sz_syn[1])
x_syn3 = x_syn[index, *]
y_syn3 = y_syn[index, *]
t_syn3 = t_syn[index, *]

Ht = correlate(transpose(t_seed), /covariance)
Hy = correlate(transpose(y_seed_mr), /covariance)
Hx = correlate(transpose(x_seed), /covariance)
Hts = correlate(transpose(t_syn3), /covariance)
Hys = correlate(transpose(y_syn3), /covariance)
Hxs = correlate(transpose(x_syn3), /covariance)
cov_seed = dblarr(1000., sz_seed[2], sz_seed[2])
cov_syn = cov_seed
for i=0, 1000-1 do begin &$
	ind1 = floor(randomu(seed, sz[1])*sz_syn[1]) &$
	cov_syn[i, *, *] = correlate(transpose(x_syn[ind1, *]), /covariance) &$
	ind2 = floor(randomu(seed, sz[1])*sz_seed[1]) &$
	cov_seed[i, *, *] = correlate(transpose(x_seed[ind2, *]), /covariance) &$
endfor

lower_seed = dblarr(sz_seed[2], sz_seed[2])
upper_seed = dblarr(sz_seed[2], sz_seed[2])
lower_syn = dblarr(sz_seed[2], sz_seed[2])
upper_syn = dblarr(sz_seed[2], sz_seed[2])
hx2 = hx*0.
dum = min(abs(((findgen(1000)+1)*100./1000.)-2.5), p1)
dum = min(abs(((findgen(1000)+1)*100./1000.)-97.5), p2)
for i=0, sz[2]-1 do begin &$
  for j=i, sz[2]-1 do begin &$
    tmp1 = reform(cov_seed[*, i, j]) &$
    tmp2 = tmp1[sort(tmp1)] &$
    lower_seed[i, j] = tmp2[p1[0]] &$
    lower_seed[j, i] = tmp2[p1[0]] &$
    upper_seed[i, j] = tmp2[p2[0]] &$
    upper_seed[j, i] = tmp2[p2[0]] &$
    tmp3 = reform(cov_syn[*, i, j]) &$
    tmp4 = tmp3[sort(tmp3)] &$
    hx2[i, j] = mean(cov_syn[*, i, j], /double, /nan) &$
    hx2[j, i] = mean(cov_syn[*, i, j], /double, /nan) &$
    lower_syn[i, j] = tmp4[p1[0]] &$
    lower_syn[j, i] = tmp4[p1[0]] &$
    upper_syn[i, j] = tmp4[p2[0]] &$
    upper_syn[j, i] = tmp4[p2[0]] &$
    print, i, j, tmp2[p1[0]], tmp4[p1[0]], tmp2[p2[0]], tmp4[p2[0]] &$
  endfor &$
endfor

for i=0, sz[2]-1 do begin &$
	for j=i, sz[2]-1 do begin &$
		;if hx[i, j] ge lower_syn[i, j] and hx[i, j] le upper_syn[i, j] then print, ';Pass '+strtrim(string(i), 2)+' '+strtrim(string(j), 2) else print, ';Fail '+strtrim(string(i), 2)+' '+strtrim(string(j), 2) &$
		if hx[i, j] lt lower_syn[i, j] or hx[i, j] gt upper_syn[i, j] then print, ';Fail '+strtrim(string(i), 2)+' '+strtrim(string(j), 2) &$
	endfor &$
endfor



var1 = hx
var2 = lower_syn
var3 = upper_syn
var23 = dblarr(sz_seed[2], sz_seed[2]*2)
index1 = indgen(sz_seed[2])*2
index2 = (indgen(sz_seed[2])*2)+1
for i=0, sz_seed[2]-1 do begin &$
	var23[i, index1] = var2[i, *] &$
	var23[i, index2] = var3[i, *] &$
endfor
var4 = correlate(transpose(x_seed))
neg = where(var4 lt 0)



dum = strtrim(string(reverse(indgen(sz_seed[2])+1)), 2)
file = '/data/Heine/work/Erin/Do_All/Syn_Data_Exp_2023/TXT/X_Covariance_20240725.txt'
openw, 1, file, /append
i=0
printf, 1, var1[i, *], format = '('+dum[i]+'(e25.2))'
form = '('+dum[i]+'( " (", e10.2, ", ", e10.2, ")" ))'
printf, 1, var23[i, *], format = form
print, var1[i, *], format = '('+dum[i]+'(e25.2))' &$
form = '('+dum[i]+'( " (", e10.2, ", ", e10.2, ")" ))' &$
print, var23[i, *], format = form &$
for i = 1, sz_seed[2]-1 do begin &$
	printf, 1, var4[i, 0:i-1], format = '('+dum[sz[2]-1-i]+'(e25.2), $)' &$
	printf, 1, var1[i, i:*], format = '('+dum[i]+'(e25.2))' &$
	printf, 1, var23[i, *], format = form &$
	print, var4[i, 0:i-1], format = '('+dum[sz[2]-1-i]+'(e25.2), $)' &$
	print, var1[i, i:*], format = '('+dum[i]+'(e25.2))' &$
	print, var23[i, *], format = form &$
endfor
close, 1

cov_seed = dblarr(1000., sz_seed[2], sz_seed[2])
cov_syn = cov_seed
for i=0, 1000-1 do begin &$
	ind1 = floor(randomu(seed, sz[1])*sz_syn[1]) &$
	cov_syn[i, *, *] = correlate(transpose(y_syn[ind1, *]), /covariance) &$
	ind2 = floor(randomu(seed, sz[1])*sz_seed[1]) &$
	cov_seed[i, *, *] = correlate(transpose(y_seed_mr[ind2, *]), /covariance) &$
endfor

lower_seed = dblarr(sz_seed[2], sz_seed[2])
upper_seed = dblarr(sz_seed[2], sz_seed[2])
lower_syn = dblarr(sz_seed[2], sz_seed[2])
upper_syn = dblarr(sz_seed[2], sz_seed[2])
hy2 = hy*0.
for i=0, sz[2]-1 do begin &$
  for j=i, sz[2]-1 do begin &$
    tmp1 = reform(cov_seed[*, i, j]) &$
    tmp2 = tmp1[sort(tmp1)] &$
    lower_seed[i, j] = tmp2[p1[0]] &$
    lower_seed[j, i] = tmp2[p1[0]] &$
    upper_seed[i, j] = tmp2[p2[0]] &$
    upper_seed[j, i] = tmp2[p2[0]] &$
    tmp3 = reform(cov_syn[*, i, j]) &$
    tmp4 = tmp3[sort(tmp3)] &$
    hy2[i, j] = mean(cov_syn[*, i, j], /double, /nan) &$
    hy2[j, i] = mean(cov_syn[*, i, j], /double, /nan) &$
    lower_syn[i, j] = tmp4[p1[0]] &$
    lower_syn[j, i] = tmp4[p1[0]] &$
    upper_syn[i, j] = tmp4[p2[0]] &$
    upper_syn[j, i] = tmp4[p2[0]] &$
    print, i, j, tmp2[p1[0]], tmp2[p2[0]], tmp4[p1[0]], tmp4[p2[0]] &$
  endfor &$
endfor


for i=0, sz[2]-1 do begin &$
	for j=i, sz[2]-1 do begin &$
		;if hx[i, j] ge lower_syn[i, j] and hx[i, j] le upper_syn[i, j] then print, ';Pass '+strtrim(string(i), 2)+' '+strtrim(string(j), 2) else print, ';Fail '+strtrim(string(i), 2)+' '+strtrim(string(j), 2) &$
		if hy[i, j] lt lower_syn[i, j] or hy[i, j] gt upper_syn[i, j] then print, ';Fail '+strtrim(string(i), 2)+' '+strtrim(string(j), 2) &$
	endfor &$
endfor



var1 = hy
var2 = lower_syn
var3 = upper_syn
var23 = dblarr(sz_seed[2], sz_seed[2]*2)
index1 = indgen(sz_seed[2])*2
index2 = (indgen(sz_seed[2])*2)+1
for i=0, sz_seed[2]-1 do begin &$
	var23[i, index1] = var2[i, *] &$
	var23[i, index2] = var3[i, *] &$
endfor
var4 = correlate(transpose(y_seed_mr))
neg = where(var4 lt 0)



dum = strtrim(string(reverse(indgen(sz_seed[2])+1)), 2)
file = '/data/Heine/work/Erin/Do_All/Syn_Data_Exp_2023/TXT/Y_Covariance_20240725.txt'
openw, 1, file, /append
i=0
printf, 1, var1[i, *], format = '('+dum[i]+'(e25.2))'
form = '('+dum[i]+'( " (", e10.2, ", ", e10.2, ")" ))'
printf, 1, var23[i, *], format = form
print, var1[i, *], format = '('+dum[i]+'(e25.2))' &$
form = '('+dum[i]+'( " (", e10.2, ", ", e10.2, ")" ))' &$
print, var23[i, *], format = form &$
for i = 1, sz_seed[2]-1 do begin &$
	printf, 1, var4[i, 0:i-1], format = '('+dum[sz[2]-1-i]+'(e25.2), $)' &$
	printf, 1, var1[i, i:*], format = '('+dum[i]+'(e25.2))' &$
	printf, 1, var23[i, *], format = form &$
	print, var4[i, 0:i-1], format = '('+dum[sz[2]-1-i]+'(e25.2), $)' &$
	print, var1[i, i:*], format = '('+dum[i]+'(e25.2))' &$
	print, var23[i, *], format = form &$
endfor
close, 1


cov_seed = dblarr(1000., sz_seed[2], sz_seed[2])
cov_syn = cov_seed
for i=0, 1000-1 do begin &$
	ind1 = floor(randomu(seed, sz[1])*sz_syn[1]) &$
	cov_syn[i, *, *] = correlate(transpose(t_syn[ind1, *]), /covariance) &$
	ind2 = floor(randomu(seed, sz[1])*sz_seed[1]) &$
	cov_seed[i, *, *] = correlate(transpose(t_seed[ind2, *]), /covariance) &$
endfor

lower_seed = dblarr(sz_seed[2], sz_seed[2])
upper_seed = dblarr(sz_seed[2], sz_seed[2])
lower_syn = dblarr(sz_seed[2], sz_seed[2])
upper_syn = dblarr(sz_seed[2], sz_seed[2])
ht2 = ht*0.
for i=0, sz[2]-1 do begin &$
  for j=i, sz[2]-1 do begin &$
    s = stddev(cov_seed[*, i, j], /double, /nan) &$
    lower_seed[i, j] = (ht[i, j] - (1.96*s)) < (ht[i, j] + (1.96*s)) &$
    lower_seed[j, i] = (ht[j, i] - (1.96*s)) < (ht[j, i] + (1.96*s)) &$
    upper_seed[i, j] = (ht[i, j] + (1.96*s)) > (ht[i, j] - (1.96*s)) &$
    upper_seed[j, i] = (ht[j, i] + (1.96*s)) > (ht[j, i] - (1.96*s)) &$
    s = stddev(cov_syn[*, i, j], /double, /nan) &$
    ht2[i, j] = mean(cov_syn[*, i, j], /double, /nan) &$
    ht2[j, i] = mean(cov_syn[*, i, j], /double, /nan) &$
    lower_syn[i, j] = (ht2[i, j] - (1.96*s)) < (ht2[i, j] + (1.96*s)) &$
    lower_syn[j, i] = (ht2[j, i] - (1.96*s)) < (ht2[j, i] + (1.96*s)) &$
    upper_syn[i, j] = (ht2[i, j] + (1.96*s)) > (ht2[i, j] - (1.96*s)) &$
    upper_syn[j, i] = (ht2[j, i] + (1.96*s)) > (ht2[j, i] - (1.96*s)) &$
  endfor &$
endfor


for i=0, sz[2]-1 do begin &$
	for j=i, sz[2]-1 do begin &$
		;if hx[i, j] ge lower_syn[i, j] and hx[i, j] le upper_syn[i, j] then print, ';Pass '+strtrim(string(i), 2)+' '+strtrim(string(j), 2) else print, ';Fail '+strtrim(string(i), 2)+' '+strtrim(string(j), 2) &$
		if ht[i, j] lt lower_syn[i, j] or ht[i, j] gt upper_syn[i, j] then print, ';Fail '+strtrim(string(i), 2)+' '+strtrim(string(j), 2) &$
	endfor &$
endfor


var1 = ht
var2 = lower_syn
var3 = upper_syn
var23 = dblarr(sz_seed[2], sz_seed[2]*2)
index1 = indgen(sz_seed[2])*2
index2 = (indgen(sz_seed[2])*2)+1
for i=0, sz_seed[2]-1 do begin &$
	var23[i, index1] = var2[i, *] &$
	var23[i, index2] = var3[i, *] &$
endfor
var4 = correlate(transpose(t_seed))
neg = where(var4 lt 0)



dum = strtrim(string(reverse(indgen(sz_seed[2])+1)), 2)
file = '/data/Heine/work/Erin/Do_All/Syn_Data_Exp_2023/TXT/T_Covariance_20240725.txt'
openw, 1, file, /append
i=0
printf, 1, var1[i, *], format = '('+dum[i]+'(e25.2))'
form = '('+dum[i]+'( " (", e10.2, ", ", e10.2, ")" ))'
printf, 1, var23[i, *], format = form
print, var1[i, *], format = '('+dum[i]+'(e25.2))' &$
form = '('+dum[i]+'( " (", e10.2, ", ", e10.2, ")" ))' &$
print, var23[i, *], format = form &$
for i = 1, sz_seed[2]-1 do begin &$
	printf, 1, var4[i, 0:i-1], format = '('+dum[sz[2]-1-i]+'(e25.2), $)' &$
	printf, 1, var1[i, i:*], format = '('+dum[i]+'(e25.2))' &$
	printf, 1, var23[i, *], format = form &$
	print, var4[i, 0:i-1], format = '('+dum[sz[2]-1-i]+'(e25.2), $)' &$
	print, var1[i, i:*], format = '('+dum[i]+'(e25.2))' &$
	print, var23[i, *], format = form &$
endfor
close, 1


