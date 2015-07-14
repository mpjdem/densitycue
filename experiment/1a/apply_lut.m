function IMGc = apply_lut(IMG,lims)

if ~exist('lut.mat','file')
    IMGc = IMG;
else
    
    if exist('lims','var')
        if ~isa(IMG,'double')
           IMG = double(IMG); 
        end
        
        IMG = (IMG-lims(1)) / (lims(2)-lims(1));

    end
    
    load('lut.mat','cf')
    IMGc = nthroot(IMG,cf);   
    
    if exist('lims','var')
        IMGc = (IMGc*(lims(2)-lims(1)))+lims(1);
    end
    
end