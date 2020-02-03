%Load the image
file = 'C:\Users\nuran\OneDrive\UNC Chapel Hill\Polacheck Lab\Nuran_Matlab\Bautch\C3-MAX_SUN2 KD flow_0001.png';
[filepath,name,ext] = fileparts(file);
img = imread(file);
img = imadjust(img);

%{
[x,y] = meshgrid(0:0.2:2,0:0.2:2);
u = cos(x).*y;
v = sin(x).*y;
figure
quiver(x,y,u,v)
%}

figure('Name','Original Image');
imshow(img);
title('Original Image of Flow');

img = im2double(img);
img = imbinarize(img, 0.5);
img = bwareaopen(img,5);

figure('Name','Binary Image');
imshow(img);
title('Binary Image of Flow');

%Extract Metrics
stats = regionprops('table',img,'Centroid','Area', 'MajorAxisLength', 'MinorAxisLength', 'Orientation');
major = stats.MajorAxisLength;
area = stats.Area;
center = stats.Centroid;
minor = stats.MinorAxisLength;
orientation = stats.Orientation;
aspect = major./minor;
count = length(area);

%{
%Plot Metrics on Image
figure('Name', 'Image with Metrics');
imshow(img); hold on;
plot(center(:,1),center(:,2), 'b+');
for n = 1:numel(major)
    line([center(n,1), center(n,1)], [center(n,2)+minor(n)/2 , center(n,2)-minor(n)/2],'LineWidth',1);
    line([center(n,1)+major(n)/2, center(n,1)-major(n)/2], [center(n,2), center(n,2)],'LineWidth',1);
end
%}

figure('Name', 'Histogram Area');
histogram(area,'BinLimits',[0 100],'BinWidth', 5);
title('Histogram of Area - Flow');
xlabel('Area(Pixels)');
ylabel('Frequency');
figure('Name', 'Histogram Aspect Ratio');
histogram(aspect);
ylabel('Frequency');
xlabel('Aspect Ratio');
title('Histogram of Aspect Ratio - Flow');
figure('Name', 'Orientation');

for i = 1:length(orientation)
    if orientation(i)>90&&orientation(i)<270
        orientation(i) = orientation(i)+180;
    end
end
orientation = deg2rad(orientation);

polarhistogram(orientation);
rlim([0 150]);
set(gca,'RTick',0:50:150);
title('Polar Histogram of Orientation - Flow');

%{
figure('Name', 'Quiver');
imshow(img); hold on;
quiver(center(:,1),center(:,2),major,minor);
figure('Name', 'Boxplot');
%boxplot(area,'Notch','on','Labels',{'Area'});
%boxplot(aspect,'Notch','on','Labels',{'Aspect'});
%}

cc = bwconncomp(img);
L = labelmatrix(cc);
rgb = label2rgb(L,'jet','k', 'shuffle');
figure('Name','Color');
imshow(rgb);
title('RGB Image of Flow');

area2 = area;
aspect2 = aspect;
orientation2 = orientation;
count2 = count;

AverageArea = mean(area2);
SEarea = std(area2)/sqrt(length(area2));
AverageAspectRatio = mean(aspect2);
SEaspect = std(aspect2)/sqrt(length(aspect2));
AverageOrientation = mean(orientation2);
SEorientation = std(orientation2)/sqrt(length(orientation2));
PaxicillinCount = count2;

AverageValuesforFlow = table(PaxicillinCount,AverageArea,SEarea,AverageAspectRatio,SEaspect,AverageOrientation,SEorientation);

%%%%%%%%%%%%%%%%%%%%%%%%%%

file = 'C:\Users\nuran\OneDrive\UNC Chapel Hill\Polacheck Lab\Nuran_Matlab\Bautch\C3-MAX_SUN2 KD Static_0002.png';
[filepath,name,ext] = fileparts(file);
img = imread(file);
img = imadjust(img);

figure('Name','Original Image');
imshow(img);
title('Original Image of Static');

img = im2double(img);
img = imbinarize(img, 0.5);
img = bwareaopen(img,5);

figure('Name','Binary Image');
imshow(img);
title('Binary Image of Static');

%Extract Metrics
stats = regionprops('table',img,'Centroid','Area', 'MajorAxisLength', 'MinorAxisLength', 'Orientation');
major = stats.MajorAxisLength;
area = stats.Area;
center = stats.Centroid;
minor = stats.MinorAxisLength;
orientation = stats.Orientation;
aspect = major./minor;
count = length(area);

%[x,y] = meshgrid(center(:,1),center(:,2));
%[u,v] = meshgrid(major,minor);

%{
%Plot Metrics on Image
figure('Name', 'Image with Metrics');
imshow(img); hold on;
plot(center(:,1),center(:,2), 'b+');
for n = 1:numel(major)
    line([center(n,1), center(n,1)], [center(n,2)+minor(n)/2 , center(n,2)-minor(n)/2],'LineWidth',1);
    line([center(n,1)+major(n)/2, center(n,1)-major(n)/2], [center(n,2), center(n,2)],'LineWidth',1);
end
%}

figure('Name', 'Histogram Area');
histogram(area,'BinLimits',[0 100],'BinWidth', 5);
title('Histogram of Area - Static');
xlabel('Area(Pixels)');
ylabel('Frequency');

figure('Name', 'Histogram Aspect Ratio');
histogram(aspect);
title('Histogram of Aspect Ratio - Static');
xlabel('Aspect Ratio');
ylabel('Frequency');

for i = 1:length(orientation)
    if orientation(i)>90&&orientation(i)<270
        orientation(i) = orientation(i)+180;
    end
end
orientation = deg2rad(orientation);

figure('Name', 'Orientation');
polarhistogram(orientation);
title('Polar Histogram of Orientation - Static');
rlim([0 150]);
set(gca,'RTick',0:50:150);


figure('Name', 'Boxplots');
%{
figure('Name', 'Quiver');
imshow(img); hold on;
quiver(x,y,u,v);
figure('Name', 'Boxplot');
%}

subplot(2,2,1);
boxplot(area2,'Notch','on','Labels','Flow');
title('Boxplot of Area - Flow');
ylabel('Area(Pixels)');
ylim([0 100]);
set(gca,'YTick',0:20:100);
subplot(2,2,2);
boxplot(area,'Notch','on','Labels','Static');
title('Boxplot of Area - Static');
ylabel('Area(Pixels)');
ylim([0 100]);
set(gca,'YTick',0:20:100);
subplot(2,2,3);
boxplot(aspect2,'Notch','on','Labels','Flow');
title('Boxplot of Aspect Ratio - Flow');
ylabel('Aspect Ratio');
subplot(2,2,4);
boxplot(aspect,'Notch','on','Labels','Static');
title('Boxplot of Aspect Ratio - Static');
ylabel('Aspect Ratio');

figure('Name','Barplot of Paxillin Count');
bar(categorical({'Flow','Static'}),[count2 count]);
title('Barplot of Paxillin Count - Flow and Static');
ylabel('Paxillin Count');

cc = bwconncomp(img);
L = labelmatrix(cc);
rgb = label2rgb(L,'jet','k', 'shuffle');
figure('Name','Color');
imshow(rgb);
title('RGB Image of Static');

AverageArea = mean(area);
SEarea = std(area)/sqrt(length(area));
AverageAspectRatio = mean(aspect);
SEaspect = std(aspect)/sqrt(length(aspect));
AverageOrientation = mean(orientation);
SEorientation = std(orientation)/sqrt(length(orientation));
PaxicillinCount = count;

AverageValuesforStatic = table(PaxicillinCount,AverageArea,SEarea,AverageAspectRatio,SEaspect,AverageOrientation,SEorientation);




