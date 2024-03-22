

%% This script is used to read the binary file produced by the DCA1000 and Mmwave Studio
%
% Description:
%   This function parses raw data ...
%
% Syntax:
%   retVal = rawDataParser(fileName, numADCSamples, numADCBits, numRX, isReal)
%
% Input:
%   fileName - The name of the file containing raw data
%   numADCSamples - number of ADC samples per chirp 
%   numADCBits - number of ADC bits per sample 
%   numRX - number of receivers 
%   isReal - set to "true" if real only data, "false" if complex data
%
% Output:
%   retVal - 
%
% Example:
%   retVal = rawDataParser('datafile.bin', 256, 16, 4, true);
%


function [retVal] = rawDataParser(fileName, ...
                                  numADCSamples, ...
                                  numADCBits, ...
                                  numRX, ...
                                  isReal)

    fid = fopen(fileName,'r');          % open file for binary read acces 
    adcData = fread(fid, 'int16');      % read .bin file


    % if 12 or 14 bits ADC per sample compensate for sign extension
    if numADCBits ~= 16
        l_max = 2^(numADCBits-1)-1;
        adcData(adcData > l_max) = adcData(adcData > l_max) - 2^numADCBits;
    end

    fclose(fid);                        % close file 
    fileSize = size(adcData, 1);        % return file size 

    % real data reshape, filesize = numADCSamples*numChirps
    if isReal
        numChirps = fileSize / numADCSamples / numRX;
        LVDS = zeros(1, fileSize);
        LVDS = reshape(adcData, numADCSamples*numRX, numChirps);  %create column for each chirp
        LVDS = LVDS.'; %each row is data from one chirp
    else
        % for complex data
        % filesize = 2 * numADCSamples*numChirps
        numChirps = fileSize/2/numADCSamples/numRX;
        LVDS = zeros(1, fileSize/2);
        %combine real and imaginary part into complex data
        %read in file: 2I is followed by 2Q
        counter = 1;
        for i=1:4:fileSize-1
            LVDS(1,counter) = adcData(i) + sqrt(-1) * adcData(i+2); 
            LVDS(1,counter+1) = adcData(i+1) + sqrt(-1) * adcData(i+3); 
            counter = counter + 2;
        end
      
        LVDS = reshape(LVDS, numADCSamples*numRX, numChirps);   % create column for each chirp
        LVDS = LVDS.'; % each row is data from one chirp
    end

    % organize data per RX
    adcData = zeros(numRX,numChirps*numADCSamples);
    for row = 1:numRX
        for i = 1: numChirps
            adcData(row, (i-1)*numADCSamples+1:i*numADCSamples) = LVDS(i, (row1)*numADCSamples+1:row*numADCSamples);
        end
    end
    
    retVal = adcData; % return receiver data
    % retVal = fid;
end
