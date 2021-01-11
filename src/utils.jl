argdeg(z) = atan(imag(z),real(z))*180/π

merge_pdfs(inputfiles, outputfile) = 
    run(`pdftk $(inputfiles) cat output $(outputfile)`)
