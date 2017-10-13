%%evalute the seg results after CRF post processing
%function EvalCRFresults_kidd_Occ5000()
clear;
subset = 'val_unOcc500';
gtSeg = 1;
debug = 0;
bi_w = 4;
bi_x_std = 65;
bi_r_std = 3;
pos_w = 2;
pos_x_std = 2;
post_folder = sprintf('post_densecrf_W%d_XStd%d_RStd%d_PosW%d_PosXStd%d', bi_w, bi_x_std, bi_r_std, pos_w, pos_x_std);
OccNum = {'Occ4000', 'UnOcc1000'};

if(strcmp(subset, 'val_occ2000'))
    OccNum = OccNum{1};
elseif(strcmp(subset, 'val_unOcc500'))
    OccNum = OccNum{2};
end

%figure im, gt and seg_crf
root_folder = '/mnt/data1/kidd/deeplab-v2/data/Occ5000';
exper_root_folder = '/mnt/data1/kidd/deeplab-v2/exper/Occ5000';
save_result_folder = [exper_root_folder, '/res/features/',...
    'deeplabv2-VGG16/', subset, '/fc8/' post_folder];

gt_dir = fullfile(root_folder, OccNum, 'annotationsLast');
if strcmp(subset, 'val_all2500')
    %seg_res_dir = [save_root_folder subset];
    %seg_root = fullfile(root_folder, 'VOC2012', 'VOCtrainval');
    gt_dir = fullfile(root_folder, OccNum{1}, 'annotationsLast');
    gt_dir2 = fullfile(root_folder, OccNum{2}, 'annotationsLast');
end

segCRFdir = [exper_root_folder, '/res/features/deeplabv2-VGG16/',...
    subset, '/fc8/', post_folder, '/*.png'];
segCRFlist = dir(segCRFdir);
segCRFdir = segCRFdir(1:end-6);

load('pascal_seg_colormap.mat');

if gtSeg
    for i = 1:length(segCRFlist);
        result = imread(fullfile(segCRFdir,segCRFlist(i).name));
        
        img_fn = segCRFlist(i).name(1:end-4);
        if strcmp(subset, 'val_all2500')
            try
                img = imread(fullfile(root_folder, OccNum{1}, 'images', [img_fn, '.png']));
            catch
                img = imread(fullfile(root_folder, OccNum{2}, 'images', [img_fn, '.png']));
            end
        else
            img = imread(fullfile(root_folder, OccNum, 'images', [img_fn, '.png']));
        end
        
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
    end
end
%VOCopts set
VOCopts.nclasses = 12;
VOCopts.seg.imgsetpath = [root_folder, '/list/%s_id.txt'];
VOCopts.testset = subset;
if(strcmp(subset, 'val_all2500'))
    VOCopts.seg.clsimgpath = fullfile(root_folder, OccNum{1}, '/annotationsLast/%s.png');
    VOCopts.seg.clsimgpath2 = fullfile(root_folder, OccNum{2}, '/annotationsLast/%s.png');
else
    VOCopts.seg.clsimgpath = fullfile(root_folder, OccNum, '/annotationsLast/%s.png');
end
VOCopts.seg.clsrespath = [exper_root_folder, '/res/features/deeplabv2-VGG16/',...
    subset, '/fc8/', post_folder, '/%s.png'];
VOCopts.classes = {'hair';'face';'up-clothes';'left-arm';'right-arm';'left-hand'; ...
    'right-hand';'left-leg';'right-leg';'left-feet';'right-feet';'accesries'};

%get scores
[accuracies, avacc, conf, rawcounts] = MyVOCevalseg_kidd(VOCopts);
fid = fopen('CRFresultOcc5000.txt','w');
fprintf(fid,'%s\n', accuracies,avacc);
fclose(fid);
%end
