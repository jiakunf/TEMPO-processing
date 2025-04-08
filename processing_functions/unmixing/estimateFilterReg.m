
%%

function w = estimateFilterReg(x1, x2, wn, dn, varargin)
% x1 = w(*)x2        
    if(mod(wn,2) == 0) wn = wn+1; end
    
    options = defaultOptions();
    if(~isempty(varargin))
        options = getOptions(options, varargin);
    end

    if(length(wn) > 1)
        W = wn;
        wn = length(wn);
    else
        W = hann(wn);
    end
    
    nt = length(x1);
        
    indxs = (1:dn:(nt-wn)) + (0:(wn-1))';
    U1fall = fft(W.*x1(indxs), wn);
    U2fall = fft(W.*x2(indxs), wn);

    u12f = mean(U1fall.*conj(U2fall),2);
    u22f = mean(U2fall.*conj(U2fall),2);
    u11f = mean(U1fall.*conj(U1fall),2);

    if(isempty(options.noise_levels))
        options.noise_levels = [...
            sqrt(median(u11f(round(3/8*wn):round(5/8*wn)))/wn/mean(W.^2, 1)),...
            sqrt(median(u22f(round(3/8*wn):round(5/8*wn)))/wn/mean(W.^2, 1))];
    end

    xn1 = randn(size(x1))*options.noise_levels(1);
    xn2 = randn(size(x2))*options.noise_levels(2);
    u12noise = mean( fft(W.*xn1(indxs), wn).*conj( fft(W.*xn2(indxs), wn)),2);

    s1 = u12f./(u22f+options.eps*mean(abs(u12noise)));
%     s1 = u12f./(u22f+options.eps*mean(abs(u22f)));
    % s2 = u11f./(u12f+options.eps*mean(abs(u12f)));
    s = s1;

    w = real(fftshift(ifft(s)));
end

function options = defaultOptions()
    options.noise_levels = []; % std of the gaussian noise in x1 and x2 
    options.eps = 1; % factor to suppres everything below poisson noise level
end