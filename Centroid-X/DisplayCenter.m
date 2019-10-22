function DisplayCenter(label, img)

    label = label + 1;
    [nRows, nCols, ~]=size(img);
    
    image = img;
        for m=1:nRows
        for n=1:nCols
            L=label(m,n);
            count=0;
            minx=max(m-1,1);
            maxx=min(m+1,nRows);
            miny=max(n-1,1);
            maxy=min(n+1,nCols);
            for u=minx:maxx
                for v=miny:maxy
                    if(label(u,v)~=L)
                        count=count+1;
                    end
                    if(count==2)
                        break;
                    end
                end
                if(count==2)
                    break;
                end
            end
            if(count==2)
                image(m,n,:)=0;
            end
        end
    end

    % compute centers

    numlabel = length(unique(label));
    center = zeros(numlabel, 5);

    ct = numlabel;
    c1 = zeros(ct, 1);
    ct_x = zeros(ct, 1);
    ct_y = zeros(ct, 1);
    ct_l = zeros(ct, 1);
    ct_a = zeros(ct, 1);
    ct_b = zeros(ct, 1);

    for k = 1:nRows
        for g = 1:nCols
            i = label(k, g);
            c1(i) = c1(i)+1; %c1为每个类的总点数
            ct_x(i) = ct_x(i)+k; %计算每个类的x总点值
            ct_y(i) = ct_y(i)+g;
            ct_l(i) = ct_l(i) + double(img(k,g,1));
            ct_a(i) = ct_a(i) + double(img(k,g,2));
            ct_b(i) = ct_b(i) + double(img(k,g,3));
        end
    end

    for i=1:ct
        center(i,4) = fix(ct_x(i)/c1(i));
        center(i,5) = fix(ct_y(i)/c1(i));
        center(i,1) = fix(ct_l(i)/c1(i));
        center(i,2) = fix(ct_a(i)/c1(i));
        center(i,3) = fix(ct_b(i)/c1(i));
    end
    
    for i = 1:numlabel
        x = center(i, 4);
        y = center(i, 5);
%         for a = 1:10
%             for b = 1:10
%                 img(x ,y, 1) = 0;
%                 img(x ,y, 2) = 0;
%                 img(x ,y, 3) = 0;
%             end
%         end
        
         a = 8; b = 8;
         image((x - a):(x + a) ,(y - b):(y + b), 1) = 255;
         image((x - a):(x + a) ,(y - b):(y + b), 2) = 255;
         image((x - a):(x + a) ,(y - b):(y + b), 3) = 0;

         a = 6; b = 6;
         image((x - a):(x + a) ,(y - b):(y + b), 1) = center(i,1);
         image((x - a):(x + a) ,(y - b):(y + b), 2) = center(i,2);
         image((x - a):(x + a) ,(y - b):(y + b), 3) = center(i,3);

    end
    

    figure;
    imshow(image);
    imwrite(image,'result.bmp')
    
end