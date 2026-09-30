pro avg_xg_h, np, output, count, arvg
	filenames=output+'XG1/GENERATION_'+strtrim(string(count), 2)+'/'
	xg_h = []
	for i=0, np-1 do begin &$
		restore, output+'XG1/GENERATION_'+strtrim(string(count), 2)+'/TARGET_'+strtrim(string(ulong(i)), 2)+'.dat' &$
		xg_h = [[xg_h], [xg]] &$
	endfor
	xg_h = transpose(xg_h)
	arvg = mean(xg_h, /double, /nan, dimension = 1)	
end 
 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro de_var, DN, BL, BU, NP, fit, count, output
	;gets DN GEN;
	;returns BL BU X0 AZ wt Vg1 xg ug1 NP;
	filenames=output+'XG1/GENERATION_'+strtrim(string(count), 2)+'/'
	file_mkdir, filenames
	for i=0, np-1 do begin &$
		XG=(randomu(seed, dn)*(BU-BL)) + bl &$
		save, xg, filename = filenames+'TARGET_'+strtrim(string(ulong(i)), 2)+'.dat' &$
	endfor
	
	fit=dblarr(NP)
	;fitness score for current generation;
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;creates the mutant vector for each TRIAL vector;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro create_trial, k, NP, DN, BL, BU, UG1, F, CR, count, output
	jump1: &$ 
	;if the current mutation vector is not within bounds it runs this process again;
	r1=0 &$
	r2=0 &$
	r3=0 &$
	While ((r1 EQ r2) OR (r2 EQ r3) OR (r3 EQ r1) OR (r1 EQ k) OR (r2 EQ k) OR (r3 EQ k)) do begin &$
		r1=fix(randomu(seed)*NP) &$
		r2=fix(randomu(seed)*NP) &$
		r3=fix(randomu(seed)*NP) &$
	ENDWHILE &$
	;this creates the random indexes that are mutually different and different from the running index k (NP);
	restore, output+'XG1/GENERATION_'+strtrim(string(count-1), 2)+'/TARGET_'+strtrim(string(ulong(r1)), 2)+'.dat'
	var1 = xg
	restore, output+'XG1/GENERATION_'+strtrim(string(count-1), 2)+'/TARGET_'+strtrim(string(ulong(r2)), 2)+'.dat'
	var2 = xg
	restore, output+'XG1/GENERATION_'+strtrim(string(count-1), 2)+'/TARGET_'+strtrim(string(ulong(r3)), 2)+'.dat'
	var3 = xg
	VG1=var1+F*(var2-var3) &$
	for l=0, DN-1 do begin &$
		if (VG1[l] LT BL[l]) OR (VG1[l] GT BU[l]) then GOTO, jump1 &$
	endfor
	;creates a mutatnt vector for each target vector (NP) that is within bounds;

	;jump2: &$
	rn=randomu(seed,DN)
	;rn is the jth evaluation of a uniform random number generator with outcome from 0 to 1;

	rj=FIX(randomu(seed,DN)*DN)
	;rj is a randomly chosen index of DN;
	
	for j=0,DN-1 do begin &$
		if(rn[j] LE CR) OR (j EQ rj[j]) THEN UG1[j]=VG1[j] &$
	ENDFOR
	;This is the trial vector being formed with the crossover (CR) contraints;
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;MAIN DE FILE;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro main, x, limits, inc, NP, DN, BL, BU, F, Cr, maxgen, optima, output
	
	CONVERG=0.
	COUNT=ulong(0)
	test = file_search(output+'GENERATION_*', count = test_count)
	if test_count eq 0 then begin &$
		de_var, DN, BL, BU, NP, fit, count, output &$
		;;sets up the rotating variables for generation 1;;
		
		for i=0, np-1 do begin &$
			;tic &$
			TARGET_NUM = strtrim(string(ulong(i)), 2) &$
			restore, output+'XG1/GENERATION_'+strtrim(string(count), 2)+'/TARGET_'+target_num+'.dat' &$
						
			test_target = fitness_test_float(xg, limits, x, inc) &$
			;elapse = TOC() &$
			;time_stamp = create_useful_time(elapse) &$
			
			fit[i]=test_target &$
    		print, 'TARGET: ', i, np-1, fit[i] &$
    		;print, time_stamp &$
    	endfor &$
    endif
	save, fit, x, bl, bu, cr, f, np, dn, filename = output+'GENERATION_'+strtrim(string(count), 2)+'.dat'
	while CONVERG eq 0. and count lt maxgen do begin &$
		COUNT++ &$
		filenames=output+'UG1/GENERATION_'+strtrim(string(count), 2)+'/' &$
		file_mkdir, filenames &$
		filenames=output+'XG1/GENERATION_'+strtrim(string(count), 2)+'/' &$
		file_mkdir, filenames &$
		for i = 0, np-1 do begin &$
			;tic &$
			restore, output+'XG1/GENERATION_'+strtrim(string(count-1), 2)+'/TARGET_'+strtrim(string(ulong(i)), 2)+'.dat' &$
			UG1 = xg &$
			create_trial, i, NP, DN, BL, BU, UG1, F, CR, count, output &$
			;creates the mutatnt vector for each target vector (NP) that is within bounds
			;and creates the trial vector being formed with the crossover (CR) contraints;
			
			test_trial = fitness_test_float(ug1, limits, x, inc) &$
			save, ug1, filename = output+'UG1/GENERATION_'+strtrim(string(count), 2)+'/TRIAL_'+strtrim(string(ulong(i)), 2)+'.dat' &$
			;elapse = TOC() &$
			;time_stamp = create_useful_time(elapse) &$
			print, COUNT, ' TRIAL: ', i, np-1, fit[i], test_trial &$
			;print, time_stamp &$
			
			if optima eq 1 then begin &$
				if fit[i] ge test_trial then num = 1 else begin &$
					num = 2 &$
					fit[i] = test_trial &$
				endelse &$
			endif else begin &$
				if fit[i] le test_trial then num = 1 else begin &$
					num = 2 &$
					fit[i] = test_trial &$
				endelse &$
			endelse &$
			
			if num eq 2 then begin &$
				xg = ug1 &$
				save, xg, filename = output+'XG1/GENERATION_'+strtrim(string(count), 2)+'/TARGET_'+strtrim(string(ulong(i)), 2)+'.dat' &$
			endif else file_copy, output+'XG1/GENERATION_'+strtrim(string(count-1), 2)+'/TARGET_'+strtrim(string(ulong(i)), 2)+'.dat',  output+'XG1/GENERATION_'+strtrim(string(count), 2)+'/TARGET_'+strtrim(string(ulong(i)), 2)+'.dat' &$
		endfor &$
		
		tmp=fit[sort(fit)] &$
		IF (abs(tmp[0]-tmp[-1]) lt 0.0001) THEN CONVERG = 1. &$
		save, fit, x, bl, bu, cr, f, np, dn, filename = output+'GENERATION_'+strtrim(string(count), 2)+'.dat' &$
		print, 'GENERATION!', count, MAXGEN, tmp, format='(a11, f20.0, f20.0, '+strtrim(string(fix(np)), 2)+'(f60.8))'  &$
	endWHILE
end		

