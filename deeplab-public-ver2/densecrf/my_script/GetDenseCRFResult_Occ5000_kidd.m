function GetDenseCRFResult_Occ5000_kidd()% compute the densecrf result (.bin) to png
%
clear
%addpath('/mnt/data1/kidd/deeplab-v2/deeplab-public-ver2/matlab/my_script');
load('./pascal_seg_colormap.mat');
%SetupEnv;
bi_w = 4;
bi_x_std = 65;
bi_r_std = 3;
pos_w = 2;
pos_x_std = 2;

dataset = 'Occ5000';
feature_name = 'features';
model_name = 'deeplabv2-VGG16';
testset = 'val_unOcc500';
feature_type = 'fc8';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% You do not need to change values below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
post_folder = sprintf('post_densecrf_W%d_XStd%d_RStd%d_PosW%d_PosXStd%d', bi_w, bi_x_std, bi_r_std, pos_w, pos_x_std);

map_folder = fullfile('/mnt/data1/kidd/deeplab-v2/exper', dataset, 'res', feature_name, model_name, testset, feature_type, post_folder);

save_folder = map_folder;

map_dir = dir(fullfile(map_folder, '*.bin'));

fprintf(1,' saving to %s\n', save_folder);


for i = 1 : numel(map_dir)
    if(mod(i,100) == 0)
		fprintf(1, 'processing %d (%d)...\n', i, numel(map_dir));
	end
    map = LoadBinFile(fullfile(map_folder, map_dir(i).name), 'int16');
    
    img_fn = map_dir(i).name(1:end-4);
    imwrite(uint8(map), colormap, fullfile(save_folder, [img_fn, '.png']));
end
end
