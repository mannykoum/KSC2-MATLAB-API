        
%         %% Setter methods
%         
%         %% coupling setter
%         function self = set.Coupling(self, value)
%             % if value is string, parse into cell array 
%             if ischar(value)
%                 % clear whitespace
%                 value = regexp(value, '\S+', 'match');
%                 value = strjoin(value,'');
%                 value = strsplit(value,',');
%             end
%             
%             if iscell(value)
%                 if length(value) == 2
%                     if ~isempty(value{1})
%                         channel = 1;
%                         coupling = value{1};
%                         coupling = upper(coupling);
%                         
%                         % set coupling (AC, DC)
%                         % only change if different
%                         if ~strcmp(self.Coupling{channel}, coupling) 
%                             fprintf(self.comPORT, [num2str(channel), ':COUPLING = ',...
%                                 coupling]);
%                             verify = (fscanf(self.comPORT, '%s'));
%                             if strcmp(verify, coupling)
%                                 self.Coupling{channel} = coupling;
%                                 self.isUpdated = true;
%                             else
%                                 error(['COMMUNICATION ERROR: COUPLING', '\r'])
%                             end
%                         end
%                     end
%                     if ~isempty(value{2})
%                         channel = 2;
%                         coupling = value{2};
%                         coupling = upper(coupling);
%                         
%                         % set coupling (AC, DC)
%                         % only change if different
%                         if ~strcmp(self.Coupling{channel}, coupling) 
%                             fprintf(self.comPORT, [num2str(channel), ':COUPLING = ',...
%                                 coupling]);
%                             verify = (fscanf(self.comPORT, '%s'));
%                             if strcmp(verify, coupling)
%                                 self.Coupling{channel} = coupling;
%                                 self.isUpdated = true;
%                             else
%                                 error(['COMMUNICATION ERROR: COUPLING', '\r'])
%                             end
%                         end
%                     end   
%                 else
%                     error('Incorrect Usage');
%                 end
%             else
%                 error('Incorrect Usage');
%             end
%         end
% idea for set() with switch and string parsing



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
