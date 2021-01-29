#!/bin/bash
#echo OFF
#echo "Press Any Key to Start the Simulations"
#read -p
inp=Danger_de_Mort #'Bikes','Danger_de_Mort','Stone_Pillars_Outside','Fountain_Vincent2'
W=624	
H=434
frameToencode=14
Sequences=13

XT=TR_
slash=/

Codec=MV-HEVC\

YUV=.yuv

US=_
Mult=x
Res=$US$W$Mult$H.yuv
XT=QP_
equalto==
ICMESTR=$inp
RESSTR=$US$W$Mult$H
FolderPath=$PWD
spc=" " 

counter=0
Ratio_List=(5 4 3 2 1)
QP_List=(3521 17603 70412 352060 2640456)
#echo $QP_List

for qp in "${QP_List[@]}" 
 do

ratio=${Ratio_List[$counter]}

echo "****** Running Bitrate $qp Input $inp with Ratio $ratio ***********"

counter=$((counter+1))
configFile=Lytro_RC_config_2020.cfg
PathEncoder=../EncoderExe/
configPath=../ConfigFile/$configFile
InputFilePath=../Input_Sequence/$ICMESTR/
outputFoldername=../OutputFilesLinux/Output_$inp
RDInfoFilePath=../OutputFilesLinux/Output_$inp/RD_$qp.txt

Expno=$XT$qp$slash
ReconFilePath=$outputFoldername$slash$Expno

UND=_Ratio_
EXP=$XT$qp

BIN=.bit
TXT=.txt
LogFile=$outputFoldername/$EXP$TXT
BinFile=$ReconFilePath$EXP$BIN

mkdir $outputFoldername
chmod 750 $outputFoldername
mkdir $ReconFilePath

# Defining a list of variable to specify input MVPS
List=(7 4 1 6 5 3 2 10 13 8 9 11 12) 

# setting input and recon command handles
ArgnameInput=--InputFile_
ArgnameRecon=--ReconFile_
CfgFile=$FolderPath$ConfigName

count=0
for i in "${List[@]}" 
 do

Inputname=$InputFilePath$i$Res
Reconname=$ReconFilePath$i$Res

arghandle=$ArgnameInput$count
arghandleRecon=$ArgnameRecon$count

InpArg=$arghandle$equalto$Inputname
ReconArg=$arghandleRecon$equalto$Reconname

num1=$num1$spc$InpArg
num2=$num2$spc$ReconArg


count=$(($count+1))
done

mkdir MyLog
 
$PathEncoder./ProposedTAppEncoderStatic -c $configPath -b $BinFile -wdt $W -hgt $H -f $frameToencode --TargetBitrate=$qp --RatioNo=$ratio  $num1 $num2 > $LogFile

$PathEncoder./PSNR_YUV $W  $H $frameToencode $Sequences $qp $InputFilePath $ReconFilePath $RDInfoFilePath 

done