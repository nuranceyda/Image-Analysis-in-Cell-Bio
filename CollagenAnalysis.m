%Load Images
path1 = 'C:\Users\nuran\OneDrive\UNC Chapel Hill\Polacheck Lab\Linda_Images\DAPI112519\dapi-112519-40x-22000pa.tif'
path2 = 'C:\Users\nuran\OneDrive\UNC Chapel Hill\Polacheck Lab\Linda_Images\Actin112519\actin-112519-40x-22000pa.tif'
[filepath,name,ext] = fileparts(path2);
img = imread(path1);
img2 = imread(path2);
resize = 0.5;
img = imresize(img, resize);
img2 = imresize(img2, resize);
figure ('Name','Original Image Actin'); imshow(img2);
%img2 = adapthisteq(img2);

figure('Name','Original Image DAPI');
imshow(img);

figure('Name','Equalized Image Actin');
imshow(img2);

%Separate blue channel
bluethresh = 0.25;
blue=im2double(img);
blue=imbinarize(blue, bluethresh);
blue = bwareaopen(blue,100);
figure('Name','Dapi');
imshow(blue);

%Separate green channel
greenthresh = 0.21;
green = im2double(img2);
green = imbinarize(green,greenthresh);
green = bwareaopen(green,100);
figure('Name','Actin');
imshow(green);

%Distance Transform
Dt = -bwdist(~green);

%Use nuclei as mask
mask = blue;
%figure('Name', 'Mask');
%imshowpair(green,mask,'blend');

%Impose nuclei as minimum
Dt2 = imimposemin(Dt,mask);
%figure ('Name', 'Distance Transform with Imposed Minimums');
%imshow(Dt2,[]);

%Apply Watershed with Imposed Minimi
Wd2 = watershed(Dt2);
%figure('Name', 'Watershed');
%imshow(label2rgb(Wd2));

%Fill image dots on original
green = ~bwareaopen(~green, 1000);

%Apply watershed with imposed minimi
green(Wd2 == 0) = 0;
%imshow(green);

%Extract centroid of nuclei
statsb = regionprops('table',blue,'Centroid', 'MajorAxisLength', 'Area','Perimeter');
centrb = statsb.Centroid;
diameterb = statsb.MajorAxisLength;
areab = statsb.Area;
perimeterb = statsb.Perimeter;
roundnessb = 4*pi.*areab./perimeterb.^2;

%Extract metrics of actin
statsg = regionprops('table',green,'Centroid','Area', 'Perimeter', 'MajorAxisLength', 'MinorAxisLength');
statsg = statsg((roundnessb>.80),:);
areag = statsg.Area;
majorg = statsg.MajorAxisLength;
minorg = statsg.MinorAxisLength;
centrg = statsg.Centroid;
perimeterg = statsg.Perimeter;

%Plot metrics on image
figure('Name', 'Image with Metrics');
imshow(green); hold on;
plot(centrb(:,1),centrb(:,2), 'b+');
for n = 1:numel(majorg)
    line([centrg(n,1), centrg(n,1)], [centrg(n,2)+minorg(n)/2 , centrg(n,2)-minorg(n)/2],'LineWidth',1);
    line([centrg(n,1)+majorg(n)/2, centrg(n,1)-majorg(n)/2], [centrg(n,2), centrg(n,2)],'LineWidth',1);
end
plot(centrg(:,1),centrg(:,2), 'g+');

areagm = mean(areag);
areaerror = std(areag)/sqrt(length(areag));
ratio = majorg./minorg;
ratiom = mean(ratio);
ratioerror = std(ratio)/sqrt(length(ratio));
count = length(centrg);
roundness = 4*pi.*areag./perimeterg.^2;
roundnessm = mean(roundness);
roundnesserror = std(roundness)/sqrt(length(roundness));
datamen = "Quality";
data = {filepath,name,count,areagm,areaerror,ratiom,ratioerror,roundnessm,roundnesserror,resize,greenthresh,bluethresh, datamen};

%Input into Excel File
filename = 'Linda_Analysis.xlsx';
xlswrite(filename,data,1,'A6');