;==================================================
; Program: image_correlation.pro
; Description: Generalized tool for analyzing solar FITS data, originally created for Nobeyama Dataset,
;              performing correlation studies, and saving
;              results in a modular format.
;
; Author: Open-Source Community Version by Routh et al. (2025)
; GitHub: https://github.com/srinjana-routh/Image-Correlation
;==================================================

pro image_correlation, $
    data_dir = data_dir, $
    output_dir = output_dir, $
    year = year

    if n_elements(data_dir) eq 0 then data_dir = '/path/to/FITS/data/'
    if n_elements(output_dir) eq 0 then output_dir = '/path/to/output/'
    if n_elements(year) eq 0 then year = 1992

    filelist = file_search(data_dir, '*.fits', count = n_files)
    print, 'Number of FITS files found:', n_files

    ; MID-LATITUDE BINS (MODIFY THEM ACCORDING TO THE EXTENT IN LATITUDE REQUIRED)
    
    thetamid = [-52.5:52.5:5.0]

    ; OUTPUT FILES
    
    phi_file     = output_dir + 'phi_' + strtrim(string(year), 2) + '.dat'
    yshift_file  = output_dir + 'yshift_' + strtrim(string(year), 2) + '.dat'
    omega_file   = output_dir + 'omega_' + strtrim(string(year), 2) + '.dat'
    corr_file    = output_dir + 'corr_' + strtrim(string(year), 2) + '.dat'
    excl_file    = output_dir + 'excluded_' + strtrim(string(year), 2) + '.dat'
    edge_file    = output_dir + 'edge_excluded_' + strtrim(string(year), 2) + '.dat'

    openw, 5, phi_file
    openw, 6, yshift_file
    openw, 2, omega_file
    openw, 3, corr_file
    openw, 4, excl_file
    openw, 7, edge_file

    ; WRITE HEADERS
    
    printf, 5, format = '(%"Time \t\t\t dt \t\t", $)'
    printf, 6, format = '(%"Time \t\t\t dt \t\t", $)'
    printf, 2, format = '(%"Time \t\t\t dt \t\t", $)'
    printf, 3, format = '(%"Time \t\t\t dt \t\t", $)'
    
    printf, 5, format = '(22(f10.3))', thetamid		;(MODIFY 22 ACCORDING TO THE NUMBER OF MID-LATITUDES)
    printf, 6, format = '(22(f10.3))', thetamid
    printf, 2, format = '(22(f10.3))', thetamid
    printf, 3, format = '(22(f10.3))', thetamid

    ; -- CORE DATA PROCESSING LOGIC GOES HERE --
    for k = 0, n_files do begin
    
	     ; ADJUSTMENTS IN THE TIMESTAMP FORMAT TO UNIFY THEM ACCORDING TO CDS FORMAT (SKIP IF YOUR DATASET HAS UNIFORM TIMESTAMPS)
	     
		error1 = 0
		error2 = 0
		data1 = mrdfits(file[k],0,header1)
		freq1 = fxpar(header1,'obs-freq')
		
		if k eq n_files-1 then break else begin
		  	
			data2 = mrdfits(file[k+1],0,header2)
			freq2 = fxpar(header2,'obs-freq')

			date1 = STRSPLIT(fxpar(header1,'date-obs'), '/', /EXTRACT)  
			date2 = STRSPLIT(fxpar(header2,'date-obs'), '/', /EXTRACT)  
		
			catch,error1
			if error1 ne 0 then begin 
				date1 = STRSPLIT(fxpar(header1,'date-obs'), '-', /EXTRACT)
				cds_date1 = STRING(date1[2],'-',date1[1],'-',date1[0]) 
				print,cds_date1
				catch,/cancel
			endif else begin
				cds_date1 = STRING(date1[2],'-',date1[1],'-',date1[0]) 
				print,cds_date1
				catch,/cancel
			endelse
			
			catch,error2
			if error2 ne 0 then begin 
				date2 = STRSPLIT(fxpar(header2,'date-obs'), '-', /EXTRACT)
				cds_date2 = STRING(date2[2],'-',date2[1],'-',date2[0]) 
				print,cds_date1
				catch,/cancel
			endif else begin
				cds_date2 = STRING(date2[2],'-',date2[1],'-',date2[0]) 
				catch,/cancel
			endelse
			
			tk = cds_date1 + ' ' + fxpar(header1,'time-obs')
		  	tk1 = cds_date2 + ' ' + fxpar(header2,'time-obs')
	  		dt = (abs(anytim2tai(tk)-anytim2tai(tk1)))/86400
	  		
	  		if dt ge 362 then begin
		  		tk = strmid(tk, 6, 4) + '-' + strmid(tk, 3, 2) + '-' + strmid(tk, 0, 2) + strmid(tk, 10, 12)
		  		tk1 = strmid(tk1, 6, 4) + '-' + strmid(tk1, 3, 2) + '-' + strmid(tk1, 0, 2) + strmid(tk1, 10, 12)
		  		dt = (abs(anytim2tai(tk)-anytim2tai(tk1)))/86400
	  		endif
	  		
	  		print, tk
	  		print,tk1
	  		
	  		; SANITY CHECK TO SEE THAT THE SEQUENTIAL IMAGE PAIRS ARE AMPLY SEPERATED AND ALIGNED (SKIP IF YOUR DATASET HAS UNIFORM ALIGNMENT AND TIME INTERVALS)
	  		
			if fxpar(header1,'CRVAL1') eq 0 and fxpar(header1,'CRVAL2') eq 0 and fxpar(header2,'CRVAL1') eq 0 and fxpar(header2,'CRVAL2') eq 0 and dt le 1.10  and freq1 eq freq2 then begin
			

				r = fxpar(header1,'SOLR')/fxpar(header1,'CDELT1')
				q = 0.97*r

				
			;MASKING THE DISK

				c1 = fxpar(header1,'CRPIX1')
				c2 = fxpar(header1,'CRPIX2')
				disk = shift(dist(512,512),c1,c2)
				l = where(disk gt q)
				ndata1 = data1
				ndata2 = data2
				ndata1[l] = !Values.F_NaN
				ndata2[l] = !Values.F_NaN

					
		  		
			;CONVERTING TO HELIOGRAPHIC COORDINATES
				
				helio1 = heliographic(ndata1,header1)
				helio2 = heliographic(ndata2,header2)

			  		
			;CORRELATION AT DIFFERENT LATITUDE BANDS
	 	        	
	 	        	  xshift = []
	 	        	  yshift = []
				  omega = []
				  mcorr = []
				  edge_arr=[]
				  plateau_arr=[]
				  
				for a = 300,1350,50 do begin ;-THETA TO +THETA (IN PIXELS; MODIFY THEM ACCORDING TO THE EXTENT IN LATITUDE REQUIRED)
				              
			  	  		b = a + 150
			  	  		
			;SANITY CHECK IF THE THETAM VALUES ARE PROGRESSING IN THE RIGHT DIRECTION AND SPACING
				
					  	p = (a*0.1)-90
					  	s = (b*0.1)-90
					  	thetam = (p + s)/2
					  	
					  	print,p,s,thetam 
					  	
					  	
				;CROPPING THE TWO IMAGES
			  	
					  	im1 = helio1(350:1450,a:b)
					  	im2 = helio2(350:1450,a:b)
					  	
				;CORRELATING THE TWO IMAGES	  	
					  	
				  	  	offset = (14.381-(2.72*sin(thetam*!dtor)^2))*(dt/0.1)	;INITIAL VALUES FROM JHA ET AL (2021)
				  	  	
				  		correl = correl_images(im2,im1,xshift=30,yshift=15,xoffset_b=offset)
				    		corrmat_analyze,correl,xs,ys,max_corr,xoff_init=offset,yoff_init=0,edge,plateau
				    		
				 ;SANITY CHECK IF THE CORRELATION COEFFICIENT IS ON THE EDGE OF THE DISTRIBUTION OR PLATEAU	
				 	
				    if edge eq 1 or plateau eq 1 then begin 
					print, "Edge or Plateau is observed."
					if edge eq 1 then begin
					edge_arr = [edge_arr,edge]
					endif else begin
					plateau_arr = [plateau_arr,plateau]
					endelse
				
				endif	
					
				;CALCULATING THE SIDEREAL OMEGA
				
						phi = (xs*0.1)
				  		synomega = phi/dt
						strdate = str2utc(tk,/external)
						y = strdate.year
						m = strdate.month
						d = strdate.day
						hh = strdate.hour
						mm = strdate.minute
						sidomega = synomega + siderial_corr(y,m,d,hh,mm)
						
						xshift = [xshift,phi]
						yshift = [yshift,ys*0.1]
						omega = [omega,sidomega]
						mcorr = [mcorr,max_corr]
						edge_arr = [edge_arr,edge]
						plateau_arr = [plateau_arr,plateau]
					
					endfor
					printf,5,tk,dt,xshift,format='(a20, f10.3, 22(f10.3))'
					printf,6,tk,dt,yshift,format='(a20, f10.3, 22(f10.3))'
	 	        	 	printf,2,tk,dt,omega,format='(a20, f10.3, 22(f10.3))'
	 	        	  	printf,3,tk,dt,mcorr,format='(a20, f10.3, 22(f10.3))'
	 	        	  	printf,7,tk,dt,edge_arr,format='(a20, f10.3, 22(f10.3))'
	 	        	  	printf,8,tk,dt,plateau_arr,format='(a20, f10.3, 22(f10.3))'
	 	        	  	
				endif else begin

					printf,4,format = '(%"%f \t \t %s \t \t %s")',dt,file[k],file[k+1]

			  	endelse
				
	  	   	endelse
endfor
close,/all
end

