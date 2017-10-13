clear;
is_server = 1;
dataset = 'Occ5000';
post_folder = 'post_none';
is_mat = 1;
debug = 0;
is_argmax = 0;
subset = 'val_unOcc500';
OccNum = {'Occ4000', 'UnOcc1000'};

if(strcmp(subset, 'val_occ2000'))
    OccNum = OccNum{1};
elseif(strcmp(subset, 'val_unOcc500'))
    OccNum = OccNum{2};
end


root_folder = '/mnt/data1/kidd/deeplab-v2/data/Occ5000';
res_root_folder = '/mnt/data1/kidd/deeplab-v2/exper/Occ5000';
output_mat_folder = [res_root_folder, '/features/',...
    'deeplabv2-VGG16/', subset, '/fc8'];
save_result_folder = [res_root_folder, '/res/features/',...
    'deeplabv2-VGG16/', subset, '/fc8/' post_folder];

fprintf(1, 'Saving to %s\n', save_result_folder);

gt_dir = fullfile(root_folder, OccNum, 'annotationsLast');
if strcmp(subset, 'val_all2500')
    %seg_res_dir = [save_root_folder subset];
    %seg_root = fullfile(root_folder, 'VOC2012', 'VOCtrainval');
    gt_dir = fullfile(root_folder, OccNum{1}, 'annotationsLast');
    gt_dir2 = fullfile(root_folder, OccNum{2}, 'annotationsLast');
end

%save_result_folder = fullfile(seg_res_dir, 'Segmentation', [id '_' 'val_occ2000' '_cls']);
%save_result_folder = save_root_folder;

if ~exist(save_result_folder, 'dir')
    mkdir(save_result_folder);
end

%if 0
if is_mat
    load('pascal_seg_colormap.mat');
    output_dir = dir(fullfile(output_mat_folder, '*.mat'));
    
    for i = 1 : numel(output_dir)
        if mod(i, 100) == 0
            fprintf(1, 'processing %d (%d)...\n', i, numel(output_dir));
        end
        data = load(fullfile(output_mat_folder, output_dir(i).name));
        raw_result = data.data;
        raw_result = permute(raw_result, [2 1 3]);%rotate x y
        img_fn = output_dir(i).name(1:end-4);
        img_fn = strrep(img_fn, '_blob_0', '');
        
        
        if strcmp(subset, 'val_all2500')
            try 
                img = imread(fullfile(root_folder, OccNum{1}, 'images', [img_fn, '.png']));
            catch
                img = imread(fullfile(root_folder, OccNum{2}, 'images', [img_fn, '.png']));
            end
        else
            img = imread(fullfile(root_folder, OccNum, 'images', [img_fn, '.png']));
        end
        img_row = size(img, 1);
        img_col = size(img, 2);
        try
            result = raw_result(1:img_row, 1:img_col, :);
        catch
            continue;
        end
        %crop feature to im size
        if ~is_argmax
            [~, result] = max(result, [], 3);
            result = uint8(result) - 1;
        else
            result = uint8(result);
        end
        %convert score to labels
        
        if debug
            try
                gt = imread(fullfile(gt_dir, [img_fn, '.png']));
            catch
                gt = imread(fullfile(gt_dir2, [img_fn, '.png']));
            end
            figure(1),
            subplot(221),imshow(img), title('img');
            subplot(222),imshow(gt, colormap), title('gt');
            subplot(224), imshow(result,colormap), title('predict');
            gtSegDir = [save_result_folder '/gtSegDir'];
            if ~exist(gtSegDir, 'dir')
                mkdir(gtSegDir);
            end
            saveas(gcf, fullfile(gtSegDir, [img_fn '.png']), 'png');
        end
        
        %write seg result with colormap, that means png are not raw png
        %image and is colorful using image software
        imwrite(result, colormap, fullfile(save_result_folder, [img_fn, '.png']));
    end
end

% get iou score
VOCopts.nclasses = 12;
VOCopts.seg.imgsetpath = [root_folder, '/list/%s_id.txt'];
VOCopts.testset = subset;
if(strcmp(subset, 'val_all2500'))
    VOCopts.seg.clsimgpath = [root_folder, '/',  OccNum{1}, '/annotationsLast/%s.png'];
    VOCopts.seg.clsimgpath2 = [root_folder, '/', OccNum{2}, '/annotationsLast/%s.png'];
else
    VOCopts.seg.clsimgpath = [root_folder, '/',  OccNum, '/annotationsLast/%s.png'];
end
VOCopts.seg.clsrespath = [res_root_folder, '/res/features/deeplabv2-VGG16/',...
    subset, '/fc8/', post_folder, '/%s.png'];
VOCopts.classes = {'hair';'face';'up-clothes';'left-arm';'right-arm';'left-hand'; ...
    'right-hand';'left-leg';'right-leg';'left-feet';'right-feet';'accesries'};

if(strcmp(dataset, 'Occ5000'))
    [accuracies, avacc, conf, rawcounts] = MyVOCevalseg_kidd(VOCopts);
    fid = fopen('beforeCRFresult.txt','w');
    fprintf(fid,'%s\n', accuracies,avacc);
    fclose(fid);
else
    fprintf(1, 'This is test set. No evaluation. Just saved as png\n');
end

