cd('C:\Users\nuran\OneDrive\UNC Chapel Hill\Polacheck Lab\Nuran_Matlab\DLL4-6-28-19\Process');
direct = dir;
n=numel(direct); 
intensity = zeros((n-2)/2,1);
cellcount = zeros((n-2)/2,1);
names1 = strings((n-2)/2,1);
names2 = strings((n-2)/2,1);
z = 1;

for i = 1:2:n
    if direct(i).bytes < 2000 
    else
    img = imread(direct(i).name);
    img2 = imread(direct(i+1).name);
    name1 = direct(i).name;
    name2 = direct(i+1).name;
    names1(z) = name1;
    names2(z) = name2;
    
    img = imresize(img, 0.3);
    img = imadjust(img);
    %figure('Name', 'DAPI');
    %imshow(img);

    %Adjust Background
    nuclei = strel('disk',13);
    background = imopen(img,nuclei);
    img = img - background;
    %figure('Name', 'DAPI Adjusted Background');
    %imshow(img);

    %Convert to Binary
    img = imbinarize(img,0.18);
    img = bwareaopen(img,50);
    %figure('Name', 'DAPI Binary');
    %imshow(img);

    %Watershed
    Dt = -bwdist(~img);
    mask = imextendedmin(Dt,0.5);
    %figure('Name', 'DAPI Mask');
    %imshowpair(img,mask,'blend');
    Dt = imimposemin(Dt,mask);
    Wd = watershed(Dt);
    %figure('Name', 'DAPI Watershed');
    %imshow(label2rgb(Ld2));
    img = ~bwareaopen(~img, 10);
    img(Wd == 0) = 0;
    %figure('Name', 'DAPI Processed');
    %imshow(img);

    %Extract Image Notch
    img2 = imresize(img2, 0.3);
    img2 = imadjust(img2);
    img2 = im2double(img2);
    figure('Name', 'Cleaved Notch');
    imshow(img2);

    %Apply Mask
    img2(img == 0) = 0;
    %figure('Name', 'Notch Mask');
    %imshow(img2);

    %Metrics of DAPI
    stats = regionprops('table',img,'Centroid');
    center = stats.Centroid;

    %Proccessed Cleaved Image with Metrics
    figure('Name', 'Processed');
    imshow(img2); hold on;
    plot(center(:,1),center(:,2), 'r+');

    %Intensity Values
    intensitysum = sum(sum(img2));
    intensitymean = intensitysum/length(center);
    intensity(z) = intensitymean;
    cellcount(z) = length(center);
    z = z + 1;
    end
end

cd('C:\Users\nuran\OneDrive\UNC Chapel Hill\Polacheck Lab\Nuran_Matlab');
T = table(names1,names2,cellcount,intensity);
filename = 'CleavedNotchIntensity6_28.xlsx';
writetable(T,filename);