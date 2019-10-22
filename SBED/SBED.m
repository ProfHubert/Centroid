function E = SBED(Inimg)       
    
% This code is for our paper "A NOVEL CENTROID UPDATE APPROACH FOR CLUSTERING-BASED SUPERPIXEL
% METHODS AND SUPERPIXEL-BASED EDGE DETECTION".
% You can download our paper on https://arxiv.org/abs/1910.08439.

% Author: Houwang Zhang, School of Automation, 
% China University of Geoscience, China. 
% Released Date: 2019.10.22
% If you have found any bugs, have any suggestions or problems, please contact me at
% Email: zhanghw@cug.edu.cn

% Inimg is the image to be processed, K is the number of output superpixels, it should be set as 1500.
% C is the compactness factor for superpixel generation, it should be set as 30 for noisy environment, 
% 10 for noise-free environment. G_low and G_high should be set as 0.1 and 0.8, respectively.
% E is the output edge.

    K = 1500; C = 30;
    [label, numlabel] = Centroid_SLIC(Inimg, K, C);

    [nRows, nCols] = size(label);
    img = uint8(zeros(nRows, nCols));

    % detect the edge of superpixel

    label = label + 1;
    label_near = cell(numlabel, 1);
    edge_label = zeros(nRows, nCols);

    for m = 1:nRows
        for n = 1:nCols
            L = label(m,n);
            Y = L;
            count = 0;
            minx = max(m-1, 1); 
            maxx = min(m+1, nRows);
            miny = max(n-1,1);
            maxy = min(n+1,nCols);
            for u = minx:maxx
                for v = miny:maxy
                    if(label(u, v) ~= L)
                        count = count+1;
                        label_near{L, :} = [label_near{L, :}, label(u, v)];
                        Y = label(u, v);
                    end
                    if(count == 2)
                        break;
                    end
                end
                if(count == 2)
                    break;
                end
            end
            if(count == 2)
                img(m, n) = 255; 
                edge_label(m, n, 1) = 10000 * L + Y;
            end
        end
    end

    for i = 1:numlabel
        label_near{i, :} = unique(label_near{i, :});
    end

    % project to CIELAB

    cform = makecform('srgb2lab');
    lab_he = applycform(Inimg, cform);
    lab_he = double(lab_he);

    % compute centers

    center = zeros(numlabel, 3);

    ct = numlabel;
    c1 = zeros(ct, 1);
    ct_l = zeros(ct, 1);
    ct_a = zeros(ct, 1);
    ct_b = zeros(ct, 1);

    for k = 1:nRows
        for g = 1:nCols
            i = label(k, g);
            c1(i) = c1(i)+1; 
            ct_l(i) = ct_l(i)+lab_he(k,g,1);
            ct_a(i) = ct_a(i)+lab_he(k,g,2);
            ct_b(i) = ct_b(i)+lab_he(k,g,3);
        end
    end

    for i=1:ct
        center(i,1) = fix(ct_l(i)/c1(i));
        center(i,2) = fix(ct_a(i)/c1(i));
        center(i,3) = fix(ct_b(i)/c1(i));
    end

    % compute distance map

    adj = zeros(numlabel, numlabel);
    for i = 1:numlabel
        neighbor = label_near{i, :};
       for j = 1 : length(neighbor)
           adj(i, neighbor(j)) = 1;
       end
    end

    map = zeros(numlabel, numlabel);
    count = 0;

    for i = 1:numlabel
       for j = i : numlabel

           if adj(i, j) == 0
               continue;
           end

           Dc = (abs(center(i, 1) - center(j, 1)) + abs(center(i, 2) - center(j, 2)) + abs(center(i, 3)-center(j, 3)));

           map(i, j) = Dc;
           count = count + 1;

       end
    end

    meandistance = sum(sum(map)) / count;

    % accoring to the distance and sobel operator remove the false edges

    imag = rgb2gray(Inimg);        
    [high,width] = size(imag);   
    F2 = double(imag);        
    U = double(imag);       
    uSobel = imag;
    for i = 2:high - 1  
        for j = 2:width - 1

            if img(i, j) == 0
                uSobel(i,j) = 0;
                continue;
            end

            Gx = (U(i+1,j-1) + 2*U(i+1,j) + F2(i+1,j+1)) - (U(i-1,j-1) + 2*U(i-1,j) + F2(i-1,j+1));
            Gy = (U(i-1,j+1) + 2*U(i,j+1) + F2(i+1,j+1)) - (U(i-1,j-1) + 2*U(i,j-1) + F2(i+1,j-1));
            uSobel(i,j) = sqrt(Gx^2 + Gy^2);
        end
    end 

    pixel_state = zeros(nRows, nCols); u = uSobel;
    G_high = max(max(uSobel)) * 0.8;
    for m = 1:nRows
        for n = 1:nCols
            if uSobel(m, n) > G_high
                pixel_state(m, n) = 255;
            end  
        end
    end

    for i = 1:numlabel
        for j = i:numlabel
            if adj(i, j) == 0
                continue;
            end

            if map(i, j) < meandistance * 1
                [x1, y1] = find(edge_label == 10000 * i + j);
                uSobel(x1, y1) = 0;
                [x2, y2] = find(edge_label == 10000 * j + i);
                uSobel(x2, y2) = 0;
            end

        end
    end

    % remove the isolated pixels

    G_low = max(max(uSobel)) * 0.1;

    for m = 1:nRows
        for n = 1:nCols


            if img(m, n) == 0
                continue;
            end

            if pixel_state(m, n) == 255
                uSobel(m, n) = u(m, n);
            end

            if uSobel(m, n) < G_low
                uSobel(m, n) = 0;
            end    


        end
    end

    E = uSobel;
    uSobel(uSobel ~= 0) = 1;

    for m = 1:nRows
        for n = 1:nCols

            minx = max(m-1, 1);
            maxx = min(m+1, nRows);
            miny = max(n-1,1);
            maxy = min(n+1,nCols);

            sumG = uSobel(minx, n) + uSobel(minx, miny) + uSobel(minx, maxy) + uSobel(m, miny) + uSobel(m, maxy) + uSobel(maxx, n) + uSobel(maxx, miny) + uSobel(maxx, maxy); 
            if sumG < 2 
                E(m, n) = 0;
            end

        end
    end

end