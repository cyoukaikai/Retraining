function ContinueOrTerminate_A() 

    m=input('Do you want to continue, Y/N [Y]:','s');
    if (m=='N' || m=='n')
        disp('you chose to quit.');
        return;
    else 
        disp('you chose to continue.');
    end
