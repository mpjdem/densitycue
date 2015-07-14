function IMG_phscr = vm_phase_scrambling(IMG)

% The image dimensions need to be powers of 2!
% Original author: Olman lab & Paul Schrater

f = fftshift(fft2(fftshift(IMG))); 
magF = abs(f); phF = angle(f);
passBand = ones(size(f));
vmSigma = 10;

randPh = vonMisesrand(numel(phF),0,vmSigma);
phF_vonMises = angle(exp(1i*(phF + passBand.*reshape(randPh,size(phF)))));
scrambled_ph = real(fftshift(ifft2(fftshift(magF.*exp(1i*caoReflectPhaseSpectrum(phF_vonMises))))));
outDist = sort(IMG(:));
[temp order] = sort(scrambled_ph(:));
scrambled_ph(order) = outDist;

IMG_phscr = scrambled_ph;


function vonrand = vonMisesrand(nrand,mu,sigma)
% Usage:   vonrand = vonMisesrand(nrand,mu,sigma)
%  Returns nrand samples from circular normal (vonMises) distribution,
%  centered at mu with standard deviation sigma.
%
% inverse cumulative method, executed by table lookup with
% linear interpolation.  Written by Paul Schrater 2001
%
% C. Olman: 2006 - imbedded vonMisespdf so only have to keep track of one
% file.

if sigma > 0.25,
	% build sampled cdf
	x = (-pi:2*pi/(2e3):pi);
	pofx = vonMisespdf(x,0,sigma);
	cofx = cumsum(pofx/sum(pofx));
	%
	u = rand(1,nrand);
	vonrand = interp1(cofx,x,u)+mu;
	vonrand = min(max(vonrand,-pi+eps),pi-eps);
else
	vonrand = randn(1,nrand)*sigma +mu;
end	

return

function pofx = vonMisespdf(x,mu,sigma)
% For -pi <= x <= pi
% force x-mu within -pi to pi
y = angle(exp(1i*(x-mu)));
kappa = 1/(sigma)^2;
pofx = exp(kappa*cos(y))/(2*pi*besseli(0,kappa));
return

function reflectim = caoReflectPhaseSpectrum(im)

dims = size(im);
reflectim = im;
% fix the center column
 reflectim(dims(1):-1:(dims(1)/2+2),dims(2)/2+1) = -reflectim(2:dims(1)/2,dims(2)/2+1);
% reflect the 2nd half of the phase spectrum
reflectim(dims(1):-1:2,dims(2):-1:(dims(2)/2+2)) = -im(2:dims(1),2:dims(2)/2);

return