.run /data/Heine/work/Erin/Do_All/SDN_CVIEW_2DINT_2025/Programs/GITHUB_CODE/local_compile.pro ;<-- RUN THE LOCAL COMPILE!
file='/data/Heine/work/Erin/Do_All/R01_U01_Cview_List/DAT/Measures_DS426_20200107.dat';;A dat file that holds IDNs (a string array with our study ID names).
restore, file

front_path = '/data/Heine/work/Erin/Do_All/R01_U01_Cview_List/IMAGES/';;This is a folder that we created with the .dcm images saved in gray-scale floating .tiff format the masks (0/1) images that helps us locate the breast area saved in .png format.
rpath = front_path+idns[*, 2]+'.tiff' ;clinical DBT C-View #####_SYN_#CC
fpath = front_path+idns[*, 2]+'.png' ;Mask 

sig1=[0.1, 0.01, 0.001, 0.0001, 0.00001, 0.000001, 0.0000001, 0.00000001] ;The sigmas we use in the detection alogrithm (can be changed)
sig2=sig1
box = 2. ;The box size used for the search window. (can be changed)
sa = 5. ;;the Signal averaging amount (can be changed)
save_path = '/data/Heine/work/Erin/Do_All/R01_U01_Cview_List/DAT/'; a new location of your choice to store the information output from the alogrithm
nfile = save_path+'PDA_SA5_Box2_20260721_Hologic_DBT.dat'

m1 = n_elements(sig1)
m2 = n_elements(sig2)
pda = dblarr(n, m1, m2, 4)  ;;to store the percent density information
;[#, *, *, *] ; Participant
;[*, #, *, *] ; sigma 1
;[*, *, #, *] ; sigma 2
;[*, *, *, #] ;image type and p value (see below for p)

filt = dblarr(box, box)+(box)^(-2.) ;;the filter is based on the box size defined above
var = dblarr(n, 4, 2) ;;to store the V stochastic information
for i=0, n-1 do begin &$
	if file_test(rpath[i]) eq 1 and pda[i, 0, 0] eq 0. then begin &$
		r = read_tiff(rpath[i]) &$
		full = read_png(fpath[i]) &$
		b1 = where(full ne 0, ba, complement = b0) &$
		seg = dilate_erode_seg(full, 0.98) &$
		seg[b0] = 0. &$
		sz = size(full) &$
		b2 = where(seg ne 0) &$
		
		sim1 = smooth(r, 7) &$
		
		nrsa1 = dblarr(sz[1], sz[2]) &$
		nrsa2 = nrsa1 &$
		for j = 0, sa-1 do begin &$
		  nrsa1 = nrsa1 + (randomn(seed, sz[1], sz[2], /double)*sim1)^2. &$ ;;p = 1 (p can change)
		  nrsa2 = nrsa2 + (randomn(seed, sz[1], sz[2], /double)*sqrt(sim1))^2. &$ ;; = p = 1/2 (p can change)
		endfor &$
		nrsa1 = nrsa1/double(sa) &$
		nrsa2 = nrsa2/double(sa) &$
		var_r1 = convol(nrsa1, filt)*seg &$
		var_r2 = convol(nrsa2, filt)*seg &$


    	pda[i, *, *, 0] = get_dense_2025(sim1, full, nrsa1, sig1, sig2, var_r1, box, sa, flag) &$
    	pda[i, *, *, 1] = get_dense_2025(sim1, full, nrsa2, sig1, sig2, var_r2, box, sa, flag) &$
    	
    	var[i, 0, *] = [mean(nrsa1[b2], /double, /nan), stddev(nrsa1[b2], /double, /nan)] &$
		var[i, 1, *] = [mean(nrsa2[b2], /double, /nan), stddev(nrsa2[b2], /double, /nan)] &$
		
		save, idns, pda, var, filename = nfile &$
	endif &$
	print, i, n-1, reform(var[i, *]) &$
endfor

