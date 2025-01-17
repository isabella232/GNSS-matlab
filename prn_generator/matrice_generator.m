%% N Bin shifted and fft'ed - PRN code matrix generator
% Input parameters:
absolute_doppler = 40e3;
doppler_step = 500;
prn_list = linspace(1, 32, 32);
dest_path = 'C:\Users/jf_ju/VM_Shared/GPSL1_matrix/gpsl1_sat';

%**** L1CA ****************************************************************
%---- Example 1: LI C/A (nyquist frequency)
modulation = 'L1CA';
fs = 2.048e6;
prn_chips = 1023;
prn_time = 1e-3;
n_periods = 1;
% generate one period at 2.048 Msps

% Compute internal variables
freq_dopp = linspace(-absolute_doppler,absolute_doppler,(2*absolute_doppler/doppler_step)+1);  % Woodward ambiguity function
%freq_dopp = 0;

 for i=1:length(prn_list)
    [I, Q] = GNSSsignalgen(prn_list(i), modulation, fs, n_periods);
    signal = I + 1j*Q;
    n_chips = length(signal)/fs*prn_chips/prn_time;
    time_s = linspace(0, length(signal)/fs, length(signal));

    % Dopplers, then code_pos, then real/imag
    interleaved_matrice = zeros(length(signal)*2, length(freq_dopp));
    res = zeros(length(signal), length(freq_dopp));


    for k=1:length(freq_dopp)
        fasor = exp(-1j*2*pi*freq_dopp(k).*time_s)';
        FFTedMatrice = conj(fft(fasor.*signal));
        %res(:,k) = ifft(fft(signal).*FFTedMatrice);
        l_2 = 1;
        for l =1:(length(signal))
            interleaved_matrice(l_2, k) = real(FFTedMatrice(l));
            interleaved_matrice(l_2+1, k) = imag(FFTedMatrice(l));
            l_2 = l_2+2;
        end
    end
    
    filename = dest_path + string(prn_list(i)) + '.mat';
    fileID = fopen(filename, 'w');
    fwrite(fileID, interleaved_matrice, 'float32');
    fclose(fileID);
    % save the WAF
end

