% clear all
% fclose all
% 
% com = findserial();
% tic
% configureKSC(com,1,'DC','GROUND','OPERATE');
% excitationKSC(com, 1, 10, 'BIPOLAR','REMOTE')%'BIPOLAR', 'LOCAL');
% excitationKSC(com,2,12,'BIPOLAR','LOCAL');
% configureKSC(com,1,'DC','GROUND','OPERATE');
% excitationKSC(com, 1, 10, 'BIPOLAR','REMOTE')%'BIPOLAR', 'LOCAL');
% excitationKSC(com,2,12,'BIPOLAR','LOCAL');
% t1 = toc
% tic
% b = KSC2(com);
% configure(b, 1, 'AC','GROUND','OPERATE');
% b.excitation(1,10,'BIPOLAR','REMOTE');
% excitation(b,2,12,'BIPOLAR','LOCAL');
% configure(b, 1, 'AC','GROUND','OPERATE');
% b.excitation(1,10,'BIPOLAR','REMOTE');
% excitation(b,2,12,'BIPOLAR','LOCAL');
% t2 = toc

b = KSC2.createArray()
