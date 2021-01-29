setlocal EnableDelayedExpansion

@ECHO OFF
REM cls

REM ---------------- USer Input  MEnu ------------------------

set qp=%~1
set SEQNO=%~2
set W=%~3
set H=%~4
set SeqPath=%~5
set PathEncoder=%~6
set ratio=%~7

set XT=QP_
set slash=\
SET Exp=!XT!!qP!
set Expno=!XT!!QP!!slash!
set ICMESTR=%SEQNO%
set RESSTR=_%W%x%H%
set FolderPath=%~dp0


@Echo **********  Running Bitrate %qp% Input %SEQNO% with Ratio %ratio% ************
@Echo ******************************************************

set ConfigName=..\ConfigFile\LytroConfig.cfg

set InputFolder=!ICMESTR!!slash!

set Res=_%W%x%H%.yuv
set count=0
set NoOfSeq=13
set SourceWidth=%W%
set SourceHeight=%H%
set frameToencode=14

REM Define the layers of MVPS as an input for MVHEVC
set LIST=(l0 l1 l2 l3 l4 l5 l6 l7 l8 l9 l10 l11 l12)

Set l0=7
Set l1=4
Set l2=1
Set l3=6
Set l4=5
Set l5=3
Set l6=2
Set l7=10
Set l8=13
Set l9=8
Set l10=9
Set l11=11
Set l12=12


REM ------------------------------------------------------------



echo OFF
set Input=I_

set BinFolder=..\OutputFilesWindows\Output_%ICMESTR%\
set OutFolder=..\OutputFilesWindows\OutputofExperiments\
mkdir !BinFolder!
mkdir !OutFolder!

set Codec=MV-HEVC\
set BIN=.bit
set TXT=.txt
set YUV=.yuv


set InpSeqPath=%SeqPath%%InputFolder%

REM Paths where files will be generated

set CfgFile=!FolderPath!!ConfigName!
set ReconFilePath=%FolderPath%%BinFolder%%Expno%
set OutputFile=!FolderPath!!BinFolder!!EXP!!TXT!
@ ECHO !ReconFilePath!
mkdir !ReconFilePath!

set BinFile=!ReconFilePath!!EXP!!BIN!

@ECHO ON
@echo !BinFile!
@ECHO OFF


REM Here Input and reconstruction files command is created for encoder
for %%G in %LIST% do (

set ArgnameInput=--InputFile_
set ArgnameRecon=--ReconFile_

set arghandle=!ArgnameInput!!count!
set arghandleRecon=!ArgnameRecon!!count!

set /a count+=1

set Inputname= !Input!!count!

set equalto==

set Fname=-17
set NameFile=!count!!Fname!
REM echo !Fname!
set spc= 

set Inputname=!FolderPath!%InpSeqPath%!%%G!%Res%

set Reconname=%ReconFilePath%!%%G!%Res%

set InpArg=!arghandle!!equalto!!Inputname!

set ReconArg=!arghandleRecon!!equalto!!Reconname!

set  InputCommand= !InputCommand!!InpArg!!Spc!

set  ReconCommand= !ReconCommand!!ReconArg!!Spc!


echo ON

echo OFF
)

cd !PathEncoder!

ProposedTAppEncoder.exe -c !CfgFile!  -b !BinFile! !ReconCommand! -wdt !SourceWidth! -hgt !SourceHeight! -f !frameToencode!  !InputCommand! --TargetBitrate=!qP! --RatioNo=!ratio! > !OutputFile!


cd\
set returnPath=!FolderPath!
cd returnpath

