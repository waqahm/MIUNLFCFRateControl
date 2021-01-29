setlocal EnableDelayedExpansion

@ECHO OFF
cls

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


@Echo **********  Running QP %qp% Input %SEQNO% with Ratio %ratio% ************
@Echo ******************************************************

set ConfigName=..\ConfigFile\StanfordConfig.cfg

set InputFolder=!ICMESTR!!slash!

set Res=_%W%x%H%.yuv
set count=0
set NoOfSeq=17
set SourceWidth=%W%
set SourceHeight=%H%
set frameToencode=18

set LIST=(l0 l1 l2 l3 l4 l5 l6 l7 l8 l9 l10 l11 l12 l13 l14 l15 l16)

Set l0=9
Set l1=5
Set l2=1
Set l3=7
Set l4=3
Set l5=8
Set l6=6
Set l7=4
Set l8=2
Set l9=13
Set l10=17
Set l11=11
Set l12=15
Set l13=10
Set l14=12
Set l15=14
Set l16=16

REM ------------------------------------------------------------



echo OFF
set Input=I_

set BinFolder=..\OutputFilesWindows\Output_%ICMESTR%\
set OutFolder=..\OutputFilesWindows\OutputofExperiments\


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
set BatchFolder=BatchFiles4Experiments
set returnPath=!FolderPath!
cd returnpath

