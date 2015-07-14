ccc;

AssertOpenGL;  
PTBscreens=Screen('Screens');
PTBscreenN=2;

PTBwhite=WhiteIndex(PTBscreenN);
PTBblack=BlackIndex(PTBscreenN);
[PTBwnd,PTBrect]=Screen('OpenWindow', PTBscreenN, PTBblack);

n = input('Number of luminance levels to test?');
PTBwhite=WhiteIndex(PTBscreenN);
PTBblack=BlackIndex(PTBscreenN);
lums_th = round(linspace(PTBblack,PTBwhite,n));

% Measure the luminances manually
lums_val = zeros(1,n);
[PTBcx,PTBcy] = RectCenter(PTBrect);
lumrect = [PTBcx-200 PTBcy-200 PTBcx+200  PTBcy+200];
for i = 1:length(lums_th)
    Screen('FillRect',PTBwnd,lums_th(i),lumrect);
    Screen('Flip',PTBwnd);    
    lums_val(i) = input('Measured value?');
end

Screen('Flip',PTBwnd);

% Normalize to 0->1
lums_th_norm = (lums_th-PTBblack)/(PTBwhite-PTBblack);
lums_val_norm = (lums_val-lums_val(1))/(lums_val(end)-lums_val(1));

% Fit a power function y = x^a
opt = fitoptions('Method','NonlinearLeastSquares','Startpoint',1);
f = fittype('x^a','options',opt);
m = fit(lums_th_norm', lums_val_norm', f);
cf = coeffvalues(m);

% Save the model to a file
save lut.mat lums_th lums_th_norm lums_val lums_val_norm cf

Screen('CloseAll');