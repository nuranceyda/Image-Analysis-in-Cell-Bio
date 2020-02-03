%Conditions
greenthresh = 0.26;
bluethresh = 0.2;
resize = 0.5;

%Load the image
file = 'C:\Users\nuran\Documents\Nuran_Matlab\Nuran_06102019\Different Stiffnesses\20x22000composite-1.png';
[filepath,name,ext] = fileparts(file);
img = imread(file);

%Resize image by 0.5
img = imresize(img, resize);
figure('Name','Original Image');
imshow(img);

%Separate green channel
green = img(:,:,2);
green = im2double(green);
green = imbinarize(green,greenthresh);
green = bwareaopen(green, 100);
figure('Name','Green Channel');
imshow(green);

%Separate blue channel
blue=img(:,:,3);
blue=im2double(blue);
blue=imbinarize(blue,bluethresh);
blue = bwareaopen(blue,100);
figure('Name','Blue Channel');
imshow(blue);

%Distance Transform
Dt = -bwdist(~green);
figure('Name', 'Distance Transform');
imshow(Dt,[]);
%Displays image according to scaling

%Watershed Transform
Wd = watershed(Dt);
figure('Name', 'Over-Segmented Watershed');
imshow(label2rgb(Wd));
%Displays with colormap

green2 = green;
%Apply Watershed to image
green2(Wd == 0) = 0;
figure('Name', 'Over-Segmented Image');
imshow(green2);

%Use nuclei as mask
mask = blue;
figure('Name', 'Mask');
imshowpair(green,mask,'blend');

%Impose nuclei as minimum
Dt2 = imimposemin(Dt,mask);
figure ('Name', 'Distance Transform with Imposed Minimums');
imshow(Dt2,[]);

%Apply Watershed
Wd2 = watershed(Dt2);
figure('Name', 'Watershed');
imshow(label2rgb(Wd2));

%Fill image dots on original
green = ~bwareaopen(~green, 1000);
pimg = green;

%Apply watershed with imposed minimi
pimg(Wd2 == 0) = 0;
figure('Name', 'Processed Image');
imshow(pimg);

%Extract centroid of nuclei
statsb = regionprops('table',blue,'Centroid', 'MajorAxisLength');
centrb = statsb.Centroid;
diameterb = statsb.MajorAxisLength;
%Filter small diameters if necessary
centrb = [centrb(diameterb>15,1) centrb(diameterb>15,2)];

%Extract metrics of actin
statsg = regionprops('table',pimg,'Centroid','BoundingBox','Area', 'MajorAxisLength', 'MinorAxisLength');
major = statsg.MajorAxisLength;
area = statsg.Area;
statsg = statsg((major>15 & area>300),:);
%Filter metrics that are too small

%Re-extract metrics
boundingboxg = statsg.BoundingBox;
areag = statsg.Area;
majorg = statsg.MajorAxisLength;
minorg = statsg.MinorAxisLength;
centrg = statsg.Centroid;

%Plot metrics on image
figure('Name', 'Image with Metrics');
imshow(pimg); hold on;
plot(centrb(:,1),centrb(:,2), 'b+');
for n = 1:numel(majorg)
    line([centrg(n,1), centrg(n,1)], [centrg(n,2)+minorg(n)/2 , centrg(n,2)-minorg(n)/2],'LineWidth',1);
    line([centrg(n,1)+majorg(n)/2, centrg(n,1)-majorg(n)/2], [centrg(n,2), centrg(n,2)],'LineWidth',1);
end
plot(centrg(:,1),centrg(:,2), 'g+');

%Gather metric data
areagm = mean(areag);
areaerror = std(areag)/sqrt(length(areag));
ratio = majorg./minorg;
ratiom = mean(ratio);
ratioerror = std(ratio)/sqrt(length(ratio));
count = length(centrb);
data = {name,areagm,areaerror,ratiom,ratioerror,count,resize,greenthresh,bluethresh};

%Input into Excel File
%filename = 'Cell Metrics';
%xlswrite(filename,data,1,'A3');

%Syntax for plotting with a loop
%center = regionprops(img, 'Centroid');
%for x = 1:numel(centr)
    %plot(center(x).Centroid(1),center(x).Centroid(2), 'r+');
%end

           