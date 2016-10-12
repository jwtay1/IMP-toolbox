function [imageOut, lut] = adjustimage(imageIn,lowVal,highVal)
%ADJUSTIMAGE  Transform the image brightness using lookup table operations
%
%  [IOUT, L] = ADJUSTIMAGE(IIN,LOW,HIGH) does a linear adjustment of the
%  greyscale iamge IIN. The new lookup table is generated as a linear ramp
%  between LOW and HIGH. Values less than LOW are set to LOW, and values
%  higher than HIGH are set to HIGH.

imageIn = double(imageIn);

lut = zeros(1,65536);
lut(1:lowVal) = 0;
lut(lowVal:highVal) = linspace(0,65535,highVal-lowVal + 1);
lut(highVal:end) = 65535;

imageOut = lut(imageIn + 1);

end