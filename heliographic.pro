;==================================================
; Program: image_correlation.pro
; Description: Generalized tool for projecting disk masked data to heliographic grid of 1800 x 1800, originally created for Nobeyama Dataset,
;              performing correlation studies, and saving
;              results in a modular format.
;
; Author: Open-Source Community Version by Routh et al. (2024)
; GitHub: https://github.com/srinjana-routh/Image-Correlation
;==================================================

function heliographic, data,header

			lon = ((findgen(1801)*0.1)-90) # replicate(1,1801)
			lat = replicate(1,1801) # ((findgen(1801)*0.1)-90)
			wcs = fitshead2wcs(header)
			wcs_convert_to_coord, wcs, coordk, 'hg', lon, lat
			pixel = wcs_get_pixel(wcs, coordk)
			helio = reform( interpolate(data, pixel[0,*,*], pixel[1,*,*] ))

return,helio
end
