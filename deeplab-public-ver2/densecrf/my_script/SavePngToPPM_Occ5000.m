function SavePngToPPM_Occ5000()
% save jpg images as ppm file for cpp
%
is_server = 1;

dataset = 'Occ5000';  %'coco', 'voc2012'
%subSet = 'Occ4000';
subSet = 'UnOcc1000';
if is_server
    if strcmp(dataset, 'Occ5000')
        img_folder  = fullfile('/mnt/data1/kidd/deeplab-v2/data/Occ5000',subSet, '/images');
        save_folder = '/mnt/data1/kidd/deeplab-v2/data/Occ5000/PPMImages';
    elseif strcmp(dataset, 'coco')
        img_folder  = '/rmt/data/coco/JPEGImages';
        save_folder = '/rmt/data/coco/PPMImages';
    end
else
    img_folder = '../img';
    save_folder = '../img_ppm';
end

if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

img_dir = dir(fullfile(img_folder, '*.png'));

for i = 1 : numel(img_dir)
    if(mod(i,1000)==0)
        fprintf(1, 'processing %d (%d)...\n', i, numel(img_dir));
    end
    img = imread(fullfile(img_folder, img_dir(i).name));
    
    img_fn = img_dir(i).name(1:end-4);
    save_fn = fullfile(save_folder, [img_fn, '.ppm']);
    
    imwrite(img, save_fn);
end

end
