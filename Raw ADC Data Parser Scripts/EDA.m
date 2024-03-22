
% Parameters based on mmWave sensor configuration 

filename = "capture_test.bin";  % The name of the file containing raw data
numADCSamples = 256;    % number of ADC samples per chirp 
numADCBits = 16;        % number of ADC bits per sample 
numRX = 4;              % number of receivers 
isReal = false;         % set to "true" if real only data, "false" if complex data



retval = rawDataParser(filename, numADCSamples, numADCBits, numRX, isReal);
size(retval)

