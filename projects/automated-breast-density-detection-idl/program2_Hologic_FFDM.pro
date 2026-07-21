.run /data/Heine/work/Erin/Do_All/SDN_CVIEW_2DINT_2025/Programs/GITHUB_CODE/local_compile.pro ;<-- RUN THE LOCAL COMPILE!
file='/data/Heine/work/Erin/Do_All/R01_U01_FFDM_List/DAT/BASIC_INFORMATION_DS667_20200117.dat';;A dat file that holds IDNs (a string array with our study ID names).
restore, file

front_path = '/data/Heine/work/Erin/Do_All/R01_U01_FFDM_List/IMAGES/';;This is a folder that we created with the .dcm images saved in gray-scale floating .tiff format the masks (0/1) images that helps us locate the breast area saved in .png format.
rpath = front_path+idns[*, 0]+'.tiff';raw FFDM #####_DAT_#CC
ppath = front_path+idns[*, 1]+'.tiff';clinical FFDM #####_PRO_#CC
fpath = front_path+idns[*, 1]+'.png';Mask (the clinical is created from the raw image and use the same mask because they are the same image in two representation)



sig1=[0.1, 0.01, 0.001, 0.0001, 0.00001, 0.000001, 0.0000001, 0.00000001];The sigmas we use in the detection alogrithm (can be changed)
sig2=sig1
box = 4. ;The box size used for the search window. (can be changed)
sa = 5. ;;the Signal averaging amount (can be changed)

save_path = '/data/Heine/work/Erin/Do_All/R01_U01_FFDM_List/DAT/'; a new location of your choice to store the information output from the alogrithm
nfile = save_path+'PDA_SA5_Box4_20260721_Hologic_FFDM.dat'

m1 = n_elements(sig1)
m2 = n_elements(sig2)
pda = dblarr(n, m1, m2, 4);;to store the percent density information
;[#, *, *, *] ; Participant
;[*, #, *, *] ; sigma 1
;[*, *, #, *] ; sigma 2
;[*, *, *, #] ;image type and p value (see below for p)


filt = dblarr(box, box)+(box)^(-2.);;the filter is based on the box size defined above
var = dblarr(n, 4, 2);;to store the V stochastic information

for i=0, n-1 do begin &$
	if file_test(rpath[i]) eq 1 and pda[i, 0, 0, 0] eq 0. then begin &$
		r = double(read_tiff(rpath[i])) &$
		p = read_tiff(ppath[i]) &$
		full = float(read_png(fpath[i])) &$
		b1 = where(full ne 0, ba, complement = b0) &$
		seg = dilate_erode_seg(full, 0.98) &$
		lseg = dilate_erode_seg(full, 0.90) &$
		seg[b0] = 0. &$
		b2 = where(seg ne 0) &$
		sz = size(full) &$
		
		sim1 = smooth(r, 7) &$
		sim2 = smooth(p, 7) &$
		
		;The raw image transformation;;
		sim1 = (16383. - sim1)*seg &$
  		sim1=sim1/max(sim1[b2]) &$
  		k=alog(16000.0) &$
  		sim1=exp(k*sim1^2) &$
		
		nrsa1 = dblarr(sz[1], sz[2]) &$
		nrsa2 = nrsa1 &$
		nrsa3 = nrsa1 &$
		nrsa4 = nrsa1 &$
		for j = 0, sa-1 do begin &$
		  nrsa1 = nrsa1 + (randomn(seed, sz[1], sz[2], /double)*sim1)^2. &$ ;;p = 1 (p can change)
		  nrsa2 = nrsa2 + (randomn(seed, sz[1], sz[2], /double)*sqrt(sim1))^2. &$ ;; = p = 1/2 (p can change)
		  nrsa3 = nrsa3 + (randomn(seed, sz[1], sz[2], /double)*sim2)^2. &$ ;;p = 1 (p can change)
		  nrsa4 = nrsa4 + (randomn(seed, sz[1], sz[2], /double)*sqrt(sim2))^2. &$ ;; = p = 1/2 (p can change)
		endfor &$
		nrsa1 = nrsa1/double(sa) &$
		nrsa2 = nrsa2/double(sa) &$
		nrsa3 = nrsa3/double(sa) &$
		nrsa4 = nrsa4/double(sa) &$
		var_r1 = convol(nrsa1, filt)*seg &$
		var_r2 = convol(nrsa2, filt)*seg &$
		var_p1 = convol(nrsa3, filt)*seg &$
		var_p2 = convol(nrsa4, filt)*seg &$
		
		;*RAW images have an edge effect, this get_dense_FFDM_raw uses a slightly more eroded image to get around this issue.
		pda[i, *, *, 0] = get_dense_FFDM_raw(sim1, full, lseg, nrsa1, sig1, sig2, var_r1, box, sa, flag) &$
		pda[i, *, *, 1] = get_dense_FFDM_raw(sim1, full, lseg, nrsa2, sig1, sig2, var_r2, box, sa, flag) &$ ;replace DF1 with noise1
		;im1 = get_dense_return_image_2025(sim1, full, nrsa1, sig1[1], sig2[1], var_r, box, sa, flag) &$;<- this program can return as the output if you want to look at a specific sigma1/sigma2 density detection;
		
    	pda[i, *, *, 2] = get_dense_2025(sim2, full, nrsa3, sig1, sig2, var_p1, box, sa, flag) &$
    	pda[i, *, *, 3] = get_dense_2025(sim2, full, nrsa4, sig1, sig2, var_p2, box, sa, flag) &$
		
		var[i, 0, *] = [mean(nrsa1[b2], /double, /nan), stddev(nrsa1[b2], /double, /nan)] &$
		var[i, 1, *] = [mean(nrsa2[b2], /double, /nan), stddev(nrsa2[b2], /double, /nan)] &$
		var[i, 2, *] = [mean(nrsa3[b2], /double, /nan), stddev(nrsa3[b2], /double, /nan)] &$
		var[i, 3, *] = [mean(nrsa4[b2], /double, /nan), stddev(nrsa4[b2], /double, /nan)] &$
		
		
		save, idns, pda, var, filename = nfile &$
	endif &$
	print, i, n-1, reform(pda[i, 0, 0, *]) &$
endfor

