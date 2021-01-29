% Author: Waqas Ahmad (waqas.ahmad@miun.se)
% Copyright(c) Realistic 3D Research Group,
%              Mid Sweden University, Sweden
%              http://https://www.miun.se/en/Research/research-centers/stc-researchcentre/about-stc/Research-Groups/Realistic-3D/
% All rights reserved [xx-xx-202x]. Version 1.1

% If you use this code in your research, we kindly ask you to cite the following papers: 
%
% W. Ahmad, M. Ghafoor, A. Tariq, A. Hassan. M. Sjostrom, and R. Olsson,
% "Computationally Efficient Light Field Image Compression using a Multiview HEVC Framework", IEEE Access, 2019.


% A. Hassan, W. Ahmad, M. Ghafoor, K. Qureshi, M. Sjostrom, and R. Olsson,
% "Two dimensional hierarchical bit allocation scheme for Light Field image compression using MV-HEVC", XXX , 2021.

clc
clear all
close all

% BasePath = 'G:\Journal_02_Data\FrameWorkCodes\MIUN_LFCF';
%Navigate to the base path where MatlabScripts are places
BasePath=pwd;

Simulations_Data='D:\CODECS\Waqas\RateControl_Finalization_Work\MatlabScripts_3.0_RC_KQC:\Research\Research_Work\My_Research_Publications\J3- Rate Control in MVHEVC Framework\Package2Upload\MIUN_LFC_RateControl'
%Default path Dataset
PathDataset=strcat(BasePath);
%PathDataset=strcat(BasePath,'\Datasets');
pathEncodingSystem=strcat(BasePath);
pathCompressedMats=strcat(BasePath,'\Compressed_Mats');
%default path MPVS sequences
pathMPVS_Sequences=strcat(BasePath);
%pathMPVS_Sequences=strcat(BasePath,'\MPVS_Sequences_Stanford_Ref');
%Default path cfg
pathCFG=strcat(BasePath);
%pathCFG=strcat(BasePath,'/cfg');

% if ~(exist(pathCFG,'dir'))
%                 mkdir(pathCFG)
% end

%% Select the Input LF and paths

DATASET             = 2;     % Specify the input LF: 1 For Lytro, 
                             %                       2 For Stanford 8 bpp PNG, 
                             %                       3 For Fraunhofer IIS
DATASET_NAMES = ["Lytro" "Stanford" "Fraunhofer_IIS" "HCI"];

Layers =[13 17 11 9]; % Number of Vertical views
Frames =[13 17 33 9]; % Number of Horizontal views

%% Proposed motion optimization flags
Rectified			= 0; %  Enable this flag to perform restricted motion search in horizontal or vertical directions (1D search), otherwise use default motion search (2D search)

LFMotionSearchRange	= 0; %  Enable this flag to adapt search range with respect to maximum motion found in central LF column, otherwise use default search range (64 pixels)
Horizontal_StepSize = 4; %  This flag specifies the horizontal distance(cm) between adjacent cameras/lenses(required if LFMotionSearchRange == 1)
Vertical_StepSize	= 4; %  This flag specifies the vertical distance (cm) between adjacent cameras/lenses (required if LFMotionSearchRange == 1)


%% Indicate the maximum number of predictor reference frames

Max_Pred_Array            = [3 5 5 3];     % This paramter sets the maximum number predictor reference frames used for the generation of prediction structure
                             % Recommended values: 3 for Lytro and HCI LFs
                             %                     5 for Stanford and HDCA LFs

Max_Pred                  = Max_Pred_Array(DATASET);     % This paramter sets the maximum number predictor reference frames used for the generation of prediction structure
                             % Recommended values: 3 for Lytro and HCI LFs
                             %                     5 for Stanford and HDCA LFs

%% Select the required outputs from the framework and Specify folder for saving output

Sequence_Generate   = 0;     % This flag enables the generation of multiView sequences of the selected input LF.(stores in ..\MIUN_LFCF\MPVS_Sequences\)
Config_Write        = 1;     % This flag enables the generation of the configuration file used for LF encoding using MV-HEVC.(stores in ..\MIUN_LFCF\cfg\)
MAT_Generation      = 0;     % This flag enables the generation of the Mat file from Multiple YUV file.(stores in ..\MIUN_LFCF\Compressed_Mats\)
Write_PPM           = 0;     % This flag enables the generation of .PPM files of each decoded views (stores in ..\MIUN_LFCF\Compressed_Mats\)
RateControl         = 1;     % For RateControl is 0 it will use Fixed QP model to distribute Quality among frame as explained in paper []
                             % For RateControl is 1 it will use bit allocation scheme among Light Field views as explain in paper []    
if Sequence_Generate == 1
    fprintf('Select the folder Datasets');
    PathDataset=uigetdir;
    fprintf('Select the folder to save sequences');
    pathMPVS_Sequences=uigetdir;
end
if Config_Write == 1
    fprintf('Select the folder to write config file')
    pathCFG=uigetdir;
end
if MAT_Generation == 1
    fprintf('Select the folder Datasets');
    PathDataset=uigetdir;
    fprintf('Select folder to save Compressed MATS')
    pathCompressedMats=uigetdir;
    
end
%% --------------- Configuration Parameters --------------------------------
%check if path exists
if ~exist(BasePath,'dir')
    msgStr = strcat('Base path "',BasePath,'" does not exist');
    msgbox(msgStr,'Directory Error','error');
    error(msgStr);
end
addpath(genpath('.\'))
configFileName = DATASET_NAMES(DATASET)+'Config.cfg';      %save config file as
QualityLevelFileName = DATASET_NAMES(DATASET)+'(inputTarget).txt';      %save config file as
QP_mat_file_name = "QpMatfile_"+DATASET_NAMES(DATASET);         %Save qp mat file as


%% 
%======== File I/O =====================
FrameRate                     = Frames(DATASET);         %in our proposed rate control scheme we assume frame rate = total no.of frames in single layer

NumberOfLayers                = Layers(DATASET);
NumberOfFrames                = Frames(DATASET);

framesVID=0:NumberOfLayers-1;
FramesPOC=0:NumberOfFrames-1;


%% MV-HEVC config file parameters
%======== Unit definition ================
MaxCUWidth                    = 64;          % Maximum coding unit width in pixel
MaxCUHeight                   = 64;          % Maximum coding unit height in pixel
MaxPartitionDepth             = 4;           % Maximum coding unit depth
QuadtreeTULog2MaxSize         = 5;           % Log2 of maximum transform size for quadtree-based TU coding (2...6)
QuadtreeTULog2MinSize         = 2;           % Log2 of minimum transform size for quadtree-based TU coding (2...6)
QuadtreeTUMaxDepthInter       = 3;
QuadtreeTUMaxDepthIntra       = 3;


%% ---------------- Generate Prediction Level List and GOP structure -----------------------
[POC_Prediction_List,POCArray,POCLevels,noActiveRef,dirRefLayerInd,RefIdcs,DeltaRPS]=Prediction_level_GOP_Assignment(NumberOfFrames,Max_Pred);
if(NumberOfLayers==NumberOfFrames)
    VID_Prediction_List=POC_Prediction_List;
    VIDArray=POCArray;
    VIDLevels=POCLevels;
    noActiveRef_VID=noActiveRef;
else
    [VID_Prediction_List,VIDArray,VIDLevels,noActiveRef_VID,dirRefLayerInd,RefIdcs_notused]=Prediction_level_GOP_Assignment(NumberOfLayers,Max_Pred);
end
disp('.... Prediction structure Generated .....')


%% -------------- Weightage estimation ---------------------------
POC_Levels=max(POCLevels)+1;
Vid_Levels=max(VIDLevels)+1;

for i=1:POC_Levels
    for k=1:Vid_Levels
        WeightMat(POC_Levels-i+1,Vid_Levels-k+1)=max(i,k);
    end
end


%% Parameters structure
P = struct('FrameRate',FrameRate,...
    'NumberOfLayers',NumberOfLayers,...
    'NumberOfFrames',NumberOfFrames,...
    'framesVID',framesVID,...
    'FramesPOC',FramesPOC,...
    'VIDLevels',VIDLevels,...
    'POCLevels',POCLevels,...
    'configFileName',configFileName,...
    'QualityLevelFileName',QualityLevelFileName,...
    'POCArray',POCArray,...
    'VIDArray',VIDArray,...
    'MaxCUWidth',MaxCUWidth,...
    'MaxCUHeight',MaxCUHeight,...
    'MaxPartitionDepth',MaxPartitionDepth,...
    'QuadtreeTULog2MaxSize',QuadtreeTULog2MaxSize,...
    'QuadtreeTULog2MinSize',QuadtreeTULog2MinSize,...
    'QuadtreeTUMaxDepthInter',QuadtreeTUMaxDepthInter,...
    'QuadtreeTUMaxDepthIntra',QuadtreeTUMaxDepthIntra,...
    'QP_mat_file_name',QP_mat_file_name,...
    'VID_Prediction_List',{VID_Prediction_List},...
    'POC_Prediction_List',{POC_Prediction_List},...
    'noActiveRef',noActiveRef,...
    'noActiveRef_VID',noActiveRef_VID,...
    'dirRefLayerInd',{dirRefLayerInd},...
    'MaxQPOffset',8,...
    'RefIdcs',{RefIdcs},...
    'WeightMat',WeightMat,...
    'DeltaRPS',DeltaRPS,...
    'PathDataset',PathDataset,...
    'pathCompressedMats',pathCompressedMats,...
    'pathEncodingSystem',pathEncodingSystem,...
    'Write_PPM',Write_PPM,...
    'pathMPVS_Sequences',pathMPVS_Sequences,...
    'pathCFG',pathCFG,...
    'Rectified',Rectified,...
    'LFMotionSearchRange',LFMotionSearchRange,...
    'Horizontal_StepSize',Horizontal_StepSize,...
    'RateControl',RateControl,...
    'Vertical_StepSize',Vertical_StepSize);


%% Generate Multiple Pseudo Video Sequences for Encoder
if(Sequence_Generate)
    generate_MPVS(DATASET,P);
end

%% Create config file
if(Config_Write)
    generate_Config(P);
end

%% Generate LF MAT file
if(MAT_Generation)    
    generate_MAT(DATASET,P);
end

