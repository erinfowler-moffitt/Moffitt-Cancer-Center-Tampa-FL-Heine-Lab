front_path = '/data/Heine/work/Erin/Do_All/DBT_Energy_2026/'
.run /data/Heine/work/Erin/Do_All/DBT_Energy_2026/PROGRAMS/MASTER_COMPILE_2025.pro
.run /data/Heine/work/Erin/Do_All/DBT_Energy_2026/PROGRAMS/local_compile_2026.pro

nfile = front_path+'DAT/CC_MLO_MERGE_20260824.dat'
;save, n, caco, cview_id_cc, cview_id_mlo, group, covar, ba_pixel_cc, ba_pixel_mlo, syht_cc, syht_mlo, cc_pixel, mlo_pixel, Hologic_cview_pda_CC, hologic_cview_pda_MLO, agd_cc, agd_mlo, filename = nfile
restore, nfile

vol_cc_pixel = cc_pixel
vol_mlo_pixel = mlo_pixel
tmp = cview_id_cc.replace('CPR', 'VPR')
vol_agd_cc = agd_cc
vol_agd_mlo = agd_mlo

nfile = front_path+'DAT/RAW_CC_MLO_MERGE_20260826.dat'
;save, n, caco, raw_id_cc, raw_id_mlo, group, covar, ba_pixel_cc, ba_pixel_mlo, syht_cc, syht_mlo, cc_pixel, mlo_pixel, Hologic_raw_pda_CC, hologic_raw_pda_MLO, agd_cc, agd_mlo, filename = nfile
restore, nfile
;;check out index = 404
id = raw_id_cc.replace('DAT', 'VPR')




n = n_elements(id)
index = fltarr(n)
for i=0, n-1 do begin &$
	trap = where(tmp eq id[i], ct) &$
	index[i] = trap[0] &$
	if ct ne 1 then print, i, ' ', id[i], '	', ct &$
endfor
trap = where(index ne -1, ct)
print, ct

vol_cc_pixel = vol_cc_pixel[index[trap]]
vol_mlo_pixel = vol_mlo_pixel[index[trap]]
vol_agd_cc = vol_agd_cc[index[trap]]
vol_agd_mlo = vol_agd_mlo[index[trap]]

id = id[trap]
caco = caco[trap]
raw_id_cc = raw_id_cc[trap]
raw_id_mlo = raw_id_mlo[trap]
group = group[trap]
covar = covar[trap]
ba_pixel_cc = ba_pixel_cc[trap]
ba_pixel_mlo = ba_pixel_mlo[trap]
syht_cc = syht_cc[trap]
syht_mlo = syht_mlo[trap]
cc_pixel = cc_pixel[trap]
mlo_pixel = mlo_pixel[trap]
Hologic_raw_pda_CC = Hologic_raw_pda_CC[trap]
hologic_raw_pda_MLO = hologic_raw_pda_MLO[trap]
agd_cc = agd_cc[trap]
agd_mlo = agd_mlo[trap]
n = n_elements(trap)
	

front_path = '/data/Heine/work/Erin/Do_All/R01_U01_Volume_List/IMAGES/'
tmp_path='/data/Heine/work/Erin/Do_All/R01_U01_Cview_List/TMP2/'
dat_path = '/data/Heine/work/Erin/Do_All/R01_U01_Volume_List/DAT/'+id+'_newPDA.dat'

results = dblarr(n, 3)
for i=0, n-1 do begin &$
	if file_test(dat_path[i]) eq 1 then begin &$
		print, i, n-1 &$
		restore, dat_path[i] &$
		results[i, 0] = mean(pda[*, 0, 3, 0], /double, /nan) &$
		results[i, 1] = total(pda[*, 0, 3, 1], /double, /nan) &$
		results[i, 2] = total(pda[*, 0, 3, 2], /double, /nan) &$
	endif &$
endfor



rho_cc = Hologic_raw_pda_CC/100.
trap = where(results[*, 2] ne 0)
rho_cc_vol = rho_cc*0.
rho_cc_vol[trap] = results[trap, 1]/results[trap, 2]


;;micron first

cc_pixel_um = double(cc_pixel*1000.)
vol_cc_pixel_um = double(vol_cc_pixel*10000.)

;;then meters

cc_pixel_m = cc_pixel_um*(10.^(-6))
vol_cc_pixel_m = vol_cc_pixel_um*(10.^(-6))

slice_m = 0.001

DA_cc = rho_cc*cc_pixel_m*cc_pixel_m ;; in m^2
DA_cc_vol = rho_cc_vol*vol_cc_pixel_m*vol_cc_pixel_m*slice_M


;;height is currently in mm

syht_cc_m = double(syht_cc/1000.)

dv_cc = ba_pixel_cc*DA_cc*syht_cc_m
dv_cc_vol = results[*, 2]*DA_cc_vol

mg_cc = dv_cc*1040.
mg_cc_vol = dv_cc_vol*1040.

;;ADG already in mGy.
eg_cc = agd_cc*mg_cc
eg_cc_vol = vol_agd_cc*mg_cc_vol

trap = where(eg_cc_vol ne 0. and eg_cc ne 0., complement = bad)

print, correlate(eg_cc[trap], eg_cc_vol[trap])

slope = regress(eg_cc[trap], eg_cc_vol[trap], const = c, yfit = ypred)

error = (eg_cc_vol[trap]-ypred)^2.
error = total(error, /double, /nan)
s = sqrt(error/(n_elements(trap)-2))
sos = (eg_cc[trap]-mean(eg_cc[trap], /double, /nan))^2.
sos = total(sos, /double, /nan)
se = s/sqrt(sos)
print, ';slope = ', slope[0], ' (', slope[0]-(1.96*se), ', ', slope[0]+(1.96*se), ')'
;slope =       0.79644459 (      0.73699437,       0.85589481)

xi = alog(eg_cc[trap])
yi = alog(eg_cc_vol[trap])
log_log_slope = regress(xi, yi, const = log_log_c)

error = (yi-ypred)^2.
error = total(error, /double, /nan)
s = sqrt(error/(n_elements(trap)-2))
sos = (xi-mean(xi, /double, /nan))^2.
sos = total(sos, /double, /nan)
se = s/sqrt(sos)
print, ';slope = ', log_log_slope[0], ' (', log_log_slope[0]-(1.96*se), ', ', log_log_slope[0]+(1.96*se), ')'
;slope =        1.0883648 (      0.68521082,        1.4915188)



window, 0
plot, eg_cc[trap], eg_cc_vol[trap], psym = 4


window, 2
plot, alog(eg_cc[trap]), alog(eg_cc_vol[trap]), psym = 4



print, tm_test(eg_cc[trap], eg_cc_vol[trap], /paired), tm_test(alog(eg_cc[trap]), alog(eg_cc_vol[trap]), /paired)





marg = [0.2, 0.2, 0.1, 0.1]
graphic = plot(xi, yi, layout = [1, 1, 1], dimension = [900,900], margin = marg, xtitle = '$log(E_g) raw FFDM CC$', ytitle = '$log(E_g) Volume (DBT) CC$', yrange = [-10, 5], xrange = [-10, 5], linestyle = 6, symbol = 'o', sym_size = 0.25)
graphic.save, '/data/Heine/work/Erin/Do_All/DBT_Energy_2026/FIGURES/Figure3a_energy_raw_CC_20260826.jpeg'




xi_mg = alog(mg_cc[trap])
yi_mg = alog(mg_cc_vol[trap])
print, min([xi_mg, yi_mg]), max([xi_mg, yi_mg])
marg = [0.2, 0.2, 0.1, 0.1]
graphic = plot(xi_mg, yi_mg, layout = [1, 1, 1], dimension = [900,900], margin = marg, xtitle = '$log(M_g) raw FFDM CC$', ytitle = '$log(M_g) Volume (DBT) CC$', yrange = [-10, 5], xrange = [-10, 5], linestyle = 6, symbol = 'o', sym_size = 0.25)
graphic.save, '/data/Heine/work/Erin/Do_All/DBT_Energy_2026/FIGURES/Figure3b_Dense_tissue_mass_raw_CC_20260826.jpeg'






front_path = '/data/Heine/work/Erin/Do_All/DBT_Energy_2026/'
.run /data/Heine/work/Erin/Do_All/DBT_Energy_2026/PROGRAMS/MASTER_COMPILE_2025.pro
.run /data/Heine/work/Erin/Do_All/DBT_Energy_2026/PROGRAMS/local_compile_2026.pro

nfile = front_path+'DAT/CC_MLO_MERGE_20260824.dat'
;save, n, caco, cview_id_cc, cview_id_mlo, group, covar, ba_pixel_cc, ba_pixel_mlo, syht_cc, syht_mlo, cc_pixel, mlo_pixel, Hologic_cview_pda_CC, hologic_cview_pda_MLO, agd_cc, agd_mlo, filename = nfile
restore, nfile

vol_cc_pixel = cc_pixel
vol_mlo_pixel = mlo_pixel
tmp = cview_id_mlo.replace('CPR', 'VPR')
vol_agd_cc = agd_cc
vol_agd_mlo = agd_mlo

nfile = front_path+'DAT/RAW_CC_MLO_MERGE_20260826.dat'
;save, n, caco, raw_id_cc, raw_id_mlo, group, covar, ba_pixel_cc, ba_pixel_mlo, syht_cc, syht_mlo, cc_pixel, mlo_pixel, Hologic_raw_pda_CC, hologic_raw_pda_MLO, agd_cc, agd_mlo, filename = nfile
restore, nfile
;;check out index = 404
id = raw_id_mlo.replace('DAT', 'VPR')




n = n_elements(id)
index = fltarr(n)
for i=0, n-1 do begin &$
	trap = where(tmp eq id[i], ct) &$
	index[i] = trap[0] &$
	if ct ne 1 then print, i, ' ', id[i], '	', ct &$
endfor
trap = where(index ne -1, ct)
print, ct

vol_cc_pixel = vol_cc_pixel[index[trap]]
vol_mlo_pixel = vol_mlo_pixel[index[trap]]
vol_agd_cc = vol_agd_cc[index[trap]]
vol_agd_mlo = vol_agd_mlo[index[trap]]

id = id[trap]
caco = caco[trap]
raw_id_cc = raw_id_cc[trap]
raw_id_mlo = raw_id_mlo[trap]
group = group[trap]
covar = covar[trap]
ba_pixel_cc = ba_pixel_cc[trap]
ba_pixel_mlo = ba_pixel_mlo[trap]
syht_cc = syht_cc[trap]
syht_mlo = syht_mlo[trap]
cc_pixel = cc_pixel[trap]
mlo_pixel = mlo_pixel[trap]
Hologic_raw_pda_CC = Hologic_raw_pda_CC[trap]
hologic_raw_pda_MLO = hologic_raw_pda_MLO[trap]
agd_cc = agd_cc[trap]
agd_mlo = agd_mlo[trap]
n = n_elements(trap)

front_path = '/data/Heine/work/Erin/Do_All/R01_U01_Volume_List/IMAGES/'
tmp_path='/data/Heine/work/Erin/Do_All/R01_U01_Cview_List/TMP2/'
dat_path = '/data/Heine/work/Erin/Do_All/R01_U01_Volume_List/DAT/'+id+'_newPDA.dat'

results = dblarr(n, 3)
for i=0, n-1 do begin &$
	if file_test(dat_path[i]) eq 1 then begin &$
		print, i, n-1 &$
		restore, dat_path[i] &$
		results[i, 0] = mean(pda[*, 0, 3, 0], /double, /nan) &$
		results[i, 1] = total(pda[*, 0, 3, 1], /double, /nan) &$
		results[i, 2] = total(pda[*, 0, 3, 2], /double, /nan) &$
	endif &$
endfor



rho_mlo = Hologic_raw_pda_mlo/100.
trap = where(results[*, 2] ne 0)
rho_mlo_vol = rho_mlo*0.
rho_mlo_vol[trap] = results[trap, 1]/results[trap, 2]


;;micron first
mlo_pixel_um = double(mlo_pixel*1000.)
vol_mlo_pixel_um = double(vol_mlo_pixel*1000.)

;;then meters

mlo_pixel_m = mlo_pixel_um*(10.^(-6))
vol_mlo_pixel_m = vol_mlo_pixel_um*(10.^(-6))

slice_m = 0.001

DA_mlo = rho_mlo*mlo_pixel_m*mlo_pixel_m ;; in m^2
DA_mlo_vol = rho_mlo_vol*vol_mlo_pixel_m*vol_mlo_pixel_m*slice_M


;;height is currently in mm

syht_mlo_m = double(syht_mlo/1000.)

dv_mlo = ba_pixel_mlo*da_mlo*syht_mlo_m
dv_mlo_vol = results[*, 2]*DA_mlo_vol

mg_mlo = dv_mlo*1040.
mg_mlo_vol = dv_mlo_vol*1040.

;;ADG already in mGy.
eg_mlo = agd_mlo*mg_mlo
eg_mlo_vol = vol_agd_mlo*mg_mlo_vol

trap = where(eg_mlo_vol ne 0. and eg_mlo ne 0., complement = bad)

print, correlate(eg_mlo[trap], eg_mlo_vol[trap])
slope = regress(eg_mlo[trap], eg_mlo_vol[trap], const = c, yfit = ypred)

error = (eg_mlo_vol[trap]-ypred)^2.
error = total(error, /double, /nan)
s = sqrt(error/(n_elements(trap)-2))
sos = (eg_mlo[trap]-mean(eg_mlo[trap], /double, /nan))^2.
sos = total(sos, /double, /nan)
se = s/sqrt(sos)
print, ';slope = ', slope[0], ' (', slope[0]-(1.96*se), ', ', slope[0]+(1.96*se), ')'
;slope =       0.84642952 (      0.82645306,       0.86640599)
xi = alog(eg_mlo[trap])
yi = alog(eg_mlo_vol[trap])
log_log_slope = regress(xi, yi, const = log_log_c)

error = (yi-ypred)^2.
error = total(error, /double, /nan)
s = sqrt(error/(n_elements(trap)-2))
sos = (xi-mean(xi, /double, /nan))^2.
sos = total(sos, /double, /nan)
se = s/sqrt(sos)
print, ';slope = ', log_log_slope[0], ' (', log_log_slope[0]-(1.96*se), ', ', log_log_slope[0]+(1.96*se), ')'
;slope =        1.0354852 (      0.71132521,        1.3596451)


print, min(xi), max(xi), min(yi), max(yi)

window, 0
plot, eg_mlo[trap], eg_mlo_vol[trap], psym = 4


window, 2
plot, alog(eg_mlo[trap]), alog(eg_mlo_vol[trap]), psym = 4



print, tm_test(eg_mlo[trap], eg_mlo_vol[trap], /paired), tm_test(alog(eg_mlo[trap]), alog(eg_mlo_vol[trap]), /paired)


marg = [0.2, 0.2, 0.1, 0.1]
graphic = plot(xi, yi, layout = [1, 1, 1], dimension = [900,900], margin = marg, xtitle = '$log(E_g) raw FFDM MLO$', ytitle = '$log(E_g) Volume (DBT) MLO$', yrange = [-10, 5], xrange = [-10, 5], linestyle = 6, symbol = 'o', sym_size = 0.25)
graphic.save, '/data/Heine/work/Erin/Do_All/DBT_Energy_2026/FIGURES/Figure4a_energy_RAW_MLO_20260825.jpeg'





xi_mg = alog(mg_mlo[trap])
yi_mg = alog(mg_mlo_vol[trap])
print, min([xi_mg, yi_mg]), max([xi_mg, yi_mg])
marg = [0.2, 0.2, 0.1, 0.1]
graphic = plot(xi_mg, yi_mg, layout = [1, 1, 1], dimension = [900,900], margin = marg, xtitle = '$log(M_g) raw FFDM MLO$', ytitle = '$log(M_g) Volume (DBT) MLO$', yrange = [-10, 5], xrange = [-10, 5], linestyle = 6, symbol = 'o', sym_size = 0.25)
graphic.save, '/data/Heine/work/Erin/Do_All/DBT_Energy_2026/FIGURES/Figure4b_Dense_tissue_mass_raw_MLO_20260826.jpeg'




