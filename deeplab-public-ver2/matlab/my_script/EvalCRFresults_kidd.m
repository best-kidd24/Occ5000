%%evalute the seg results after CRF post processing
function EvalCRFresults_kidd()
    seg_root = '/mnt/data1/kidd/deeplab-v2/data/pascal/VOCdevkit/VOC2012/VOCtrainval';
    seg_res_dir = ['/mnt/data1/kidd/deeplab-v2/exper/voc12/res/features/' ...
    'deelab_largeFOV/val/fc8/post_densecrf_W4_XStd121_RStd5_PosW3_PosXStd3/results/VOC2012/'];
    trainset = 'train_aug';
    testset = 'val';
    id = 'comp6';
    VOCopts = GetVOCopts(seg_root, seg_res_dir, trainset, testset, 'VOC2012');
    [accuracies, avacc, conf, rawcounts] = MyVOCevalseg(VOCopts, id);
    fid = fopen('CRFresult.txt','w');
    fprintf(fid,'%s\n', accuracies,avacc);
    fclose(fid);
end