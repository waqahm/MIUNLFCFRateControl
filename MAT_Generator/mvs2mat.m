function  [res]=mvs2mat(path_input_YUV,path_output_Mat,W,H,NoOfLayers,NoOfFrames,POCArray,ViewIDArray,DATASET,qp,path_logFile,path_input_db,Write_PPM)
res=0;
if(DATASET==1)
    POC=[1:NoOfFrames]; % Here POC are defined note One dummy frame is added
    VeiwID=[1:NoOfLayers]; % Here View ID's are defined
elseif(DATASET==2) % For Stanford 8bpp Tarot image
    listing=dir(path_input_db);
    POC=[1:NoOfFrames]; % Here POC are defined note One dummy frame is added
    VeiwID=[1:NoOfLayers]; % Here View ID's are defined
else
    POC=[0:NoOfFrames-1]; % Here POC are defined note One dummy frame is added
    VeiwID=[0:NoOfLayers-1]; % Here View ID's are defined
end

%---------------- Compressed Size calculation -----------------------------
BitFilepath=sprintf('%s\\QP_%d.bit',path_input_YUV,qp);
BitFile=dir(BitFilepath);
RATE=BitFile.bytes;
clear BitFile

% Removing the bits consumed by athe dummy frames which we added in the start of each layer. 
LogFilepath=sprintf('%s\\QP_%d.txt',path_logFile,qp);

% Estimating Bits of each frame and Re-arranging according to decoding order
% [ bits_Grid ] = logfilebits_LF_Grid( LogFilepath,NoOfLayers,NoOfFrames );
% [bits_LF_Grid]=ReArrangeBitsGrid(bits_Grid,POCArray+1,ViewIDArray+1);
%--------------------------------------------------------------------------
for i=1:NoOfLayers
    LF(i,:,:,:,:)= loadFileYuv(sprintf('%s%d_%dx%d.yuv',path_input_YUV,i,W,H), W, H,1:NoOfFrames,DATASET);
end

    mkdir(path_output_Mat)
    for v=1:size(LF,1)
        for f=1:size(LF,2)
            
            % Compressed view is upscaled to 10 bpp from 8 bpp 
            A_dec=uint8(squeeze(LF(v,f,:,:,:)));
           [A_dec_10bit] =UpScale8To10bit(double(A_dec));
            
            % Reading ground truth from Lytro and HDCA Dataset
            if(DATASET~=2) % Handling the case for Lytro and HDCA Datasets
                filename=sprintf('%s%03d_%03d.ppm',path_input_db,POC(f),VeiwID(v));
                A_ref=imread(filename);
                [A_refs_10bit] =UpScale16To10bit(double(A_ref));
            else
                % Hanlding the case for Stanford Dataset
                filename=listing(POC(f)+2+((VeiwID(v)-1)*17)).name;
                NameWithPath=sprintf('%s%s',path_input_db,filename);
                A_ref=imread(NameWithPath);
                [A_refs_10bit] =UpScale8To10bit(double(A_ref));
            end
            
            [Y_PSNR YUV_PSNR Y_SSIM]=QM_View(A_refs_10bit,A_dec_10bit,10,10);
            
            Y_PSNR_MAT(f,v)=Y_PSNR;
            YUV_PSNR_MAT(f,v)=YUV_PSNR;
            Y_SSIM_MAT(f,v)=Y_SSIM;
            
            if(Write_PPM)
                if(DATASET==2) % Stanford Dataset has 8 bpp ground truth views
                    imwrite(A_dec, sprintf('%s\\PPM\\%03d_%03d.ppm', path_output_Mat, v-1, f-1), 'MaxValue', 255);
                else
                    [A_dec] =UpScale8To10bit(double(A_dec));% Lytro and Franhoufer HDCA Datasets have 10 bpp ground truth views
                    imwrite(A_dec, sprintf('%s\\PPM\\%03d_%03d.ppm', path_output_Mat, v-1, f-1), 'MaxValue', 1023);
                end
            end
            
        end
    end
% Estimating mean PSNR and SSIM
PSNR_Y_mean = mean(Y_PSNR_MAT(:));
PSNR_YUV_mean = mean(YUV_PSNR_MAT(:));
SSIM_mean = mean(Y_SSIM_MAT(:));
PSNR_Y_mean
% Storing the Rate distortion information in mat file
save(sprintf('%s_PSNR',path_output_Mat),'RATE','PSNR_Y_mean','PSNR_YUV_mean','SSIM_mean','Y_PSNR_MAT');
% save(sprintf('%s_PSNR',path_output_Mat),'RATE','PSNR_Y_mean','PSNR_YUV_mean','SSIM_mean','Y_PSNR_MAT','bits_LF_Grid');
% Storing the 4D LF structure and Rate distortion information in mat file
% save(sprintf('%s',path_output_Mat),'LF','RATE','PSNR_Y_mean','PSNR_YUV_mean','SSIM_mean','-v7.3');

clear LF
res=1;
end