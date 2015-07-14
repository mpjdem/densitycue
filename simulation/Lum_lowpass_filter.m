function image_filter_apply = Lum_lowpass_filter(a, d0)

% Smooth the original stimulus display (a) in the frequency domain
% by applying a Gaussian low-pass filter mask centered on the DC component
% with a standard deviation of d0 cycles per image.

    [m n]=size(a);
    f_transform=fft2(a);
    f_shift=fftshift(f_transform);
    p=m/2;
    q=n/2;
    for i=1:m
        for j=1:n
            distance=sqrt((i-p)^2+(j-q)^2);
            low_filter(i,j)=exp(-(distance)^2/(2*(d0^2)));
        end
    end
    filter_apply=f_shift.*low_filter;
    image_orignal=ifftshift(filter_apply);
    image_filter_apply=abs(ifft2(image_orignal));

end