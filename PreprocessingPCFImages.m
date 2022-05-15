%Convert to gray and enhancement
clear

dir = dir('C:\Users\aspartan\Downloads\Regression\Beads\Beads Images 1-10V\8v\*.jpg');
sd = size(dir);
s = sd(1,1);
kk = 1;
while(kk<=200)
    
BWnobord =  imread(['C:\Users\aspartan\Downloads\Regression\Beads\Beads Images 1-10V\8v\',dir(kk).name]);
I = im2gray(imread(['C:\Users\aspartan\Downloads\Regression\Beads\Beads Images 1-10V\8v\',dir(kk).name]));
[~,threshold] = edge(I,'sobel');fudgeFactor = 0.5;
BWs = edge(I,'sobel',threshold * fudgeFactor);

% Create two perpindicular linear structuring elements by using strel function.

se90 = strel('line',3,90);
se0 = strel('line',3,0);
se1 = strel('disk',1,4);

% Dilate the binary gradient mask using the vertical structuring element followed by the horizontal structuring element. The imdilate function dilates the image.

BWsdil = imdilate(BWs,[se90 se0]);
BWsdil = imopen(BWsdil,se1);


% To fill these holes, use the imfill function.
BWdfill = imfill(BWsdil,'holes');

% Any objects that are connected to the border of the image can be removed using the imclearborder function
BWnobord = imclearborder(BWdfill,1);
BWnobord = imclose(BWnobord,se1);
BWnobord(:,:,3) = BWnobord;

% write image to file
mkdir('C:\Users\aspartan\Downloads\Regression\Beads\Beads Images 1-10V\8v\temp');
cd('C:\Users\aspartan\Downloads\Regression\Beads\Beads Images 1-10V\8v\temp');
filename = sprintf('%s_%d.%s','sample',kk,'jpg');
imwrite(BWnobord,filename);

kk=kk+1;

end