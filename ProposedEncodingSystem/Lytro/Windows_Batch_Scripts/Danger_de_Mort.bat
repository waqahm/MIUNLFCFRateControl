setlocal EnableDelayedExpansion 

 @echo off


    echo "Press Any Key to Start the Simulations"
    pause > nul

      
    set W=624
    set H=434 
    set InpSeqPath=..\Input_Sequence\
    set PAthEncoder=..\EncoderExe\
    set ratio=5
    
    mkdir Debug\MyLog

	set /a count=0

    set nums=5085937,678125,135625,33906,6781
    
    set InputSeq=Danger_de_Mort
    
    for %%i in (%nums%) do (

    set /a count+=1
	call EncodingBatch.bat %%i %InputSeq% %W% %H% %InpSeqPath% %PAthEncoder% !count!
    
    )

    echo "Press any Key to Exit the Simulations"
    pause > nul