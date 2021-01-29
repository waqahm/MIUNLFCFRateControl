setlocal EnableDelayedExpansion 

 @echo off


    echo "Press Any Key to Start the Simulations"
    pause > nul

      
    set W=1024
    set H=1024 
    set InpSeqPath=..\Input_Sequence\
    set PAthEncoder=..\EncoderExe\

    
    mkdir Debug\MyLog

	set /a count=0

    REM set nums=set nums=17825
	REM set nums=89128
    REM 13369344,1782579,356515,89128,17825 
	set nums=13369344,1782579,356515,89128,17825	
    set InputSeq=Tarot

    for %%i in (%nums%) do (

    set /a count+=1
	call EncodingBatch.bat %%i %InputSeq% %W% %H% %InpSeqPath% %PAthEncoder% !count!
    
    )

    echo "Press any Key to Exit the Simulations"
    pause > nul