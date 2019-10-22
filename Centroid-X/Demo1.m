% This code is for our paper "A NOVEL CENTROID UPDATE APPROACH FOR CLUSTERING-BASED SUPERPIXEL
% METHODS AND SUPERPIXEL-BASED EDGE DETECTION".
% You can download our paper on https://arxiv.org/abs/1910.08439.

% Author: Houwang Zhang, School of Automation, 
% China University of Geoscience, China. 
% Released Date: 2019.10.22
% If you have found any bugs, have any suggestions or problems, please contact me at
% Email: zhanghw@cug.edu.cn

clear, clc;
close all;


img = imread('01.jpg');

% img = imnoise(img, 'poisson');
% img = imnoise(img,'salt & pepper', 0.1);
img = imnoise(img,'gaussian', 0, 0.01);
% img = imnoise(img,'speckle', 0.01);

ratio = 0.3;
compactness = 30;
superpixelNum = 600;

tic
label = LSC(img, superpixelNum, ratio);
toc
DisplaySuperpixel(label, img, 'LSC');

tic
labels = Centroid_LSC(img, superpixelNum, ratio);
toc
DisplaySuperpixel(labels, img, 'Centroid-LSC');

tic
[label, ~] = SLIC(img, superpixelNum, compactness);
toc
DisplaySuperpixel(label, img, 'SLIC');

tic
[labels, ~] = Centroid_SLIC(img, superpixelNum, compactness);
toc
DisplaySuperpixel(labels, img, 'Centroid-SLIC');

tic
[label, ~] = SNIC(img, superpixelNum, compactness);
toc
DisplaySuperpixel(label, img, 'SNIC');

tic
[labels, ~] = Centroid_SNIC(img, superpixelNum, compactness);
toc
DisplaySuperpixel(labels, img, 'Centroid-SNIC');