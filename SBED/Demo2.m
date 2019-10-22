% This code is for our paper "A NOVEL CENTROID UPDATE APPROACH FOR CLUSTERING-BASED SUPERPIXEL
% METHODS AND SUPERPIXEL-BASED EDGE DETECTION".
% You can download our paper on https://arxiv.org/abs/1910.08439.

% Author: Houwang Zhang, School of Automation, 
% China University of Geoscience, China. 
% Released Date: 2019.10.22
% If you have found any bugs, have any suggestions or problems, please contact me at
% Email: zhanghw@cug.edu.cn

close all
clear, clc

Inimg = imread('I.jpg');
% Inimg = imnoise(Inimg, 'poisson');
% Inimg = imnoise(Inimg,'salt & pepper', 0.1);
Inimg = imnoise(Inimg,'gaussian', 0, 0.01);
% Inimg = imnoise(Inimg,'speckle', 0.01);

imag = rgb2gray(Inimg);

figure;imshow(Inimg);
E = SBED(Inimg);
figure;imshow(im2uint8(E));title('Superpixel-based edge detection'); 

BW2 = edge(imag,'sobel', 0.1);
figure;imshow(BW2, []);title('Sobel');

BW3 = edge(imag,'canny', 0.1, 1);
figure;imshow(BW3, []);title('Canny');