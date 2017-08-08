%Cell counting
%set path
folder = uigetdir;
files = dir(folder);
files(1:2) = [];
files([files.isdir]) = [];
file_names = {files.name};

%%
%load image

[s,ok] = listdlg('ListString',file_names, 'ListSize', [200 600]);
if ok
    img = imread(fullfile(folder, file_names{s}));
end


%%
%separate channels-need only green channel for analysis but have both green and blue in images

 %(:,:,1) is indexing notation, 
                  %telling MATLAB to pull the all x, all y, and only the 1st z
 % Green channel
green = img(:,:,2);
figure,
imshow(green);

%% contrast enhancement green channel
SE  = strel('Disk',4,4);
greenec = imsubtract(imadd(green,imtophat(green,SE)),imbothat(green,SE));
imshow(greenec)

%% binarize GREEN channel
factor = 1.75;
glvl = graythresh(greenec);
gbw = imbinarize(greenec,glvl*factor);
imshow(gbw)

%% Clean up small dendrites in GREEN binary image
SE  = strel('disk',9);
gbw = imopen(gbw, SE);
imshowpair(green,gbw)


%% watershed

bw = get_watershed(gbw,1);
bw = imfill(bw,'holes');
bw = get_watershed(bw,.5); % try watershed again
imshowpair(green, imfuse(gbw, bw),'montage')



%% Regionprops

rp = regionprops('table', bw);
histogram(rp.Area,10)
mean_2D_area = mean(rp.Area) + 2*std(rp.Area);

non_overlapping_areas = rp.Area(rp.Area < mean_2D_area); % use logical array to return only areas smaller that the mean + 2*Sd

average_cell_area = mean(non_overlapping_areas);
num_cells_corrected = sum(rp.Area) ./ average_cell_area;
num_cells = height(rp); 
fprintf('Number of cells found = %d\n', num_cells_corrected)



