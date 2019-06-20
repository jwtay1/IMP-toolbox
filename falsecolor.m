function varargout = falsecolor(baseimage, varargin)
%SHOWOVERLAY    Plot an overlay mask on an image
%
%  SHOWOVERLAY(IMAGE,MASK,COLOR) will plot an overlay specified by a binary
%  MASK on the IMAGE. The color of the overlay is specified using a three
%  element vector COLOR.
%
%  Example:
%
%    mainImg = imread('cameraman')
%
%
%  Downloaded from http://cellmicroscopy.wordpress.com

%Color specs
r = [1 0 0];
g = [0 1 0];
b = [0 0 1];
c = [0 1 1];
m = [1 0 1];
y = [1 1 0];
k = [1 1 1];


%Make composite false color images

%Normalize image to make similar intensities

%Combine images according to ratio, i.e. if 2 images, then 50% and 50%, if
%3 then 33%, 33%, 33%

%Input should be (baseimage, matrixin, color)

%if matrix in is a mask (define as only consisting of 0 and 1 or if it's
%logical or boolean), then 

%Can test by saying 
% bb = (aa == 1) | (aa == 0);
% answer = all(bb) - will be 1 if aa consists only of 1's and 0's and 0
% otherwise


basealpha = 1;
maskalpha = 0.1;

if ~exist('color','var')
    color = [1 1 1]; %Default color of the overlay
end
    
if size(baseimage,3) == 3
   red = baseimage(:,:,1);
   green = baseimage(:,:,2);
   blue = baseimage(:,:,3);
   
elseif size(baseimage,3) == 1
    red = baseimage;
    green = baseimage;
    blue = baseimage;
    
else
    error('Image should be either NxNx1 (greyscale) or NxNx3 (rgb)')
end

%Make sure the mask is binary (anything non-zero becomes true)
mask = (mask ~= 0);

if isinteger(baseimage)
    maxInt = intmax(class(baseimage));
else
    maxInt = 1;
end

red(mask) = color(1) .* maxInt;
green(mask) = color(2) .* maxInt;
blue(mask) = color(3) .* maxInt;

%Concatenate the output
outputImg = cat(3,red,green,blue);

if nargout == 0
    imshow(outputImg,[])
else
    varargout{1} = outputImg;
end