imgIn = imread('cameraman.tif');

maskIn = false(size(imgIn));
maskIn(50:70,50:200) = true;

img = showoverlay(imgIn, maskIn,'Transparency',80);

mask2 = maskIn';

showoverlay(img, mask2, 'Transparency', 50, 'Color', [0 1 1]);

%%

imgA = imread('cameraman.tif');
imgB = circshift(imgA, [20, 30]);

img = showoverlay(imgA, imgB,'Transparency',50, 'color',[0 1 1]);
imshow(img)

%%

rgbImgIn = imread('coloredChips.png');

maskIn = false(size(rgbImgIn));
maskIn(70:300,150:280,3) = true;
showoverlay(rgbImgIn, maskIn, 'Transparency', 80);

%%

rgbImgIn = imread('coloredChips.png');

maskIn = false([size(rgbImgIn,1), size(rgbImgIn,2)]);
maskIn(70:300,150:280) = true;
showoverlay(rgbImgIn, maskIn, 'Transparency', 80);

%%

rgbImgIn = double(imread('coloredChips.png'));

maskIn = false(size(rgbImgIn));
maskIn(70:300,150:280,2) = true;
showoverlay(rgbImgIn, maskIn, 'Transparency', 80);

%%

rgbImgIn = double(imread('coloredChips.png')) +1000;

maskIn = false(size(rgbImgIn));
maskIn(70:300,150:280,3) = true;
showoverlay(rgbImgIn, maskIn, 'Transparency', 80);