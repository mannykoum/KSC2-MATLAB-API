%% Class for the KSC2. Includes API and error handling.
% @author: Emmanuel Koumandakis (emmanuel@kulite.com)
% Based on the MATLAB API developed by Haig Norian and Adam Hurst
classdef KSC2 < handle % matlab.mixin.SetGet
    
    % most properties are Capitalized to comply with MATLAB Styling
    % apart from SN, comPORT, isUpdated and printable, all other 
    % properties are cell arrays of length 2 (1 cell/channel)
    properties (SetAccess = protected)
        comPORT
        SN
        Printable = false;
        isUpdated = false; % an object is updated if its current state is 
                           % different than the saved state
        Coupling 
        ShieldMode
        OperationMode
        FilterType
        FrequencyCutoff
        Postgain
        Pregain
        ExcitationVoltage
        ExcitationType
        SenseMode
        CompensationSwitch
        ResonantFrequency
        QualityFactor
        OverloadIn
        OverloadOut
        OverloadOutLimit
    end
    
    %% Methods
    methods
        
        % Constructor
        function self = KSC2(COM, pr)
            if (nargin == 0)
                COM = findserial();
            elseif (nargin == 2)
                self.Printable = pr;
            elseif (nargin > 2)
                MEusage = MException('KCS2:incorrectUsage',...
                    'Incorrect number of args.');
                throw(MEusage)
            end
          
            % Open port
            self.comPORT = serial(COM, 'BaudRate', 57600, 'DataBits',...
                8, 'Parity', 'none', 'StopBits', 1);
            fopen(self.comPORT);

            % Get settings and set attributes
            self.SN = query(self.comPORT, ['SN?'], '%s\n' ,'%s');
            self.Coupling{1} = query(self.comPORT, '1:COUPLING?', '%s\n' ,'%s');
            self.Coupling{2} = query(self.comPORT, '2:COUPLING?', '%s\n' ,'%s');
            self.ShieldMode{1} = query(self.comPORT, '1:SHIELD?', '%s\n' ,'%s');
            self.ShieldMode{2} = query(self.comPORT, '2:SHIELD?', '%s\n' ,'%s');
            self.OperationMode{1} = query(self.comPORT, '1:MODE?', '%s\n' ,'%s');
            self.OperationMode{2} = query(self.comPORT, '2:MODE?', '%s\n' ,'%s');
            self.FilterType{1} = query(self.comPORT, '1:FILTER?', '%s\n' ,'%s');
            self.FilterType{2} = query(self.comPORT, '2:FILTER?', '%s\n' ,'%s');
            self.FrequencyCutoff{1} = str2double(query(self.comPORT, '1:FC?', '%s\n' ,'%s'));
            self.FrequencyCutoff{2} = str2double(query(self.comPORT, '2:FC?', '%s\n' ,'%s'));
            self.Postgain{1} = str2double(query(self.comPORT, '1:POSTGAIN?', '%s\n' ,'%s'));
            self.Postgain{2} = str2double(query(self.comPORT, '2:POSTGAIN?', '%s\n' ,'%s'));
            self.Pregain{1} = str2double(query(self.comPORT, '1:PREGAIN?', '%s\n' ,'%s'));
            self.Pregain{2} = str2double(query(self.comPORT, '2:PREGAIN?', '%s\n' ,'%s'));
            self.ExcitationVoltage{1} = str2double(query(self.comPORT, '1:EXC?', '%s\n' ,'%s'));
            self.ExcitationVoltage{2} = str2double(query(self.comPORT, '2:EXC?', '%s\n' ,'%s'));
            self.ExcitationType{1} = query(self.comPORT, '1:EXCTYPE?', '%s\n' ,'%s');
            self.ExcitationType{2} = query(self.comPORT, '2:EXCTYPE?', '%s\n' ,'%s');
            self.SenseMode{1} = query(self.comPORT, '1:SENSE?', '%s\n' ,'%s');
            self.SenseMode{2} = query(self.comPORT, '2:SENSE?', '%s\n' ,'%s');
            self.CompensationSwitch{1} = query(self.comPORT, '1:COMPFILT?', '%s\n' ,'%s');
            self.CompensationSwitch{2} = query(self.comPORT, '2:COMPFILT?', '%s\n' ,'%s');
            self.ResonantFrequency{1} = str2double(query(self.comPORT, '1:COMPFILTFC?', '%s\n' ,'%s'));
            self.ResonantFrequency{2} = str2double(query(self.comPORT, '2:COMPFILTFC?', '%s\n' ,'%s'));
            self.QualityFactor{1} = str2double(query(self.comPORT, '1:COMPFILTQ?', '%s\n' ,'%s'));
            self.QualityFactor{2} = str2double(query(self.comPORT, '2:COMPFILTQ?', '%s\n' ,'%s'));
            self.OverloadIn{1} = query(self.comPORT, '1:INOVLD?', '%s\n' ,'%s');
            self.OverloadIn{2} = query(self.comPORT, '2:INOVLD?', '%s\n' ,'%s');
            self.OverloadOut{1} = query(self.comPORT, '1:OUTOVLD?', '%s\n' ,'%s');
            self.OverloadOut{2} = query(self.comPORT, '2:OUTOVLD?', '%s\n' ,'%s');
            self.OverloadOutLimit{1} = str2double(query(self.comPORT, '1:OUTOVLDLIM?', '%s\n' ,'%s'));
            self.OverloadOutLimit{2} = str2double(query(self.comPORT, '2:OUTOVLDLIM?', '%s\n' ,'%s'));
            
            if (self.Printable)
                fprintf(['KSC-2: SN-', self.SN, ...
                    ' HAS BEEN SUCCESSFULLY CONNECTED TO ' , COM, '\r']);
            end
        end
        
        
        % Destructor
        function delete(self)
            fclose(self.comPORT);
            if (self.Printable)
                fprintf(['KSC-2: SN-', self.SN, ...
                 ' HAS BEEN DISCONNECTED FROM COMMUNICATION PORT','\r \r'])
            end
            delete(self.comPORT);
            clear self
        end
        
        function del(self); delete(self); end
        
        
        %% configure KSC 
        function configure(self, channel, coupling, shield, mode)
        % change coupling, shield mode, and operation mode for each channel
            
            coupling = upper(coupling);
            shield = upper(shield);
            mode = upper(mode);
            
            % set coupling (AC, DC)
            % only change if different
            if ~strcmp(self.Coupling{channel}, coupling) 
                fprintf(self.comPORT, [num2str(channel), ':COUPLING = ',...
                    coupling]);
                verify = (fscanf(self.comPORT, '%s'));
                if strcmp(verify, coupling)
                    self.isUpdated = true;
                    self.Coupling{channel} = coupling;
                    self.isUpdated = true;
                else
                    error(['COMMUNICATION ERROR: COUPLING', '\r'])
                end
            end
                
            % set shield mode
            % only change if different
            if ~strcmp(self.ShieldMode{channel}, shield)
                fprintf(self.comPORT, [num2str(channel),':SHIELD = ',shield]);
                verify = (fscanf(self.comPORT, '%s'));
                if strcmp(verify, shield)
                    self.isUpdated = true;                        
                    self.ShieldMode{channel} = shield;
%                     fprintf(['SHIELD FOR CHANNEL ', num2str(CH) ,' SET TO ', SHIELD, '\r']);
                else
                    error(['COMMUNICATION ERROR: MODE', '\r'])
                end

            end


            % set operation mode
            % only change if different
            if ~strcmp(self.OperationMode{channel}, mode)
                fprintf(self.comPORT, [num2str(channel), ':MODE = ', mode]);
                verify = (fscanf(self.comPORT, '%s'));
                if strcmp(verify, mode)
                    self.isUpdated = true;                        
                    self.OperationMode{channel} = mode;
                    self.isUpdated = true;
                else
                    error(['COMMUNICATION ERROR: SHIELD', '\r'])
                end
            end
        end
        
        %% filter KSC
        function filter(self, channel, freq_cut, type)
        % Change the filter type, cutoff frequency

            type = upper(type);
            
            % set FC
            % only change if different
            if ~strcmp(self.FrequencyCutoff{channel}, freq_cut)
                fprintf(self.comPORT, [num2str(channel), ':FC = ',...
                    num2str(freq_cut)]);
                verify = (fscanf(self.comPORT, '%s'));

                FC_round = round(freq_cut/500)*500;
                if freq_cut<250
                    FC_round = 500;
                end

                if str2double(verify) == FC_round
                    self.FrequencyCutoff{channel} = FC_round;
                    self.isUpdated = true;
                else
                    error(['COMMUNICATION ERROR: FC', '\r'])
                end
            end

            % set filter type
            % only change if different
            if ~strcmp(self.FilterType{channel}, type)
                fprintf(self.comPORT,[num2str(channel),':FILTER = ',type]);
                verify = (fscanf(self.comPORT, '%s'));
                if strcmp(verify, type)
                    self.FilterType{channel} = type;
                    self.isUpdated = true;
                else
                    error(['COMMUNICATION ERROR: FILTER TYPE', '\r'])
                end
            end
        end

        
        %% excitation KSC
        function excitation(self, channel, voltage, exc_type, sense)
            
            % make uppercase
            exc_type = upper(exc_type);
            sense = upper(sense);
            
            % set excitation voltage
            % only change if different
            V_round = round(voltage/0.00125)*0.00125;
            if V_round ~= self.ExcitationVoltage{channel}
                fprintf(self.comPORT, [num2str(channel), ':EXC = ',...
                    num2str(voltage)]);
                verify = (fscanf(self.comPORT, '%s'));

                if str2double(verify) == V_round
                    self.ExcitationVoltage{channel} = V_round;
                    self.isUpdated = true;
                else
                    error(['COMMUNICATION ERROR: EXC', '\r'])
                end
            end

            % set excitation voltage type
            % only change if different
            if ~strcmp(self.ExcitationType{channel}, exc_type)
                fprintf(self.comPORT, [num2str(channel), ':EXCTYPE = ',...
                    exc_type]);
                verify = (fscanf(self.comPORT, '%s'));
                if strcmp(verify, exc_type)
                    self.ExcitationType{channel} = exc_type;
                    self.isUpdated = true;
                else
                    error(['COMMUNICATION ERROR: EXCITATION TYPE', '\r'])
                end
            end
                
            % set sense mode
            % only change is different
            if ~strcmp(self.SenseMode{channel}, sense)
                fprintf(self.comPORT, [num2str(channel), ':SENSE = ', sense]);
                verify = (fscanf(self.comPORT, '%s'));
                if strcmp(verify, sense)
                    self.SenseMode{channel} = sense;
                    self.isUpdated = true;                
                else
                    error(['COMMUNICATION ERROR: SENSE MODE', '\r'])
                end
            end
        end
        
        %% cavitycompKSC 
        function cavitycomp(self, channel, compfilt_onoff, varargin)
        % takes the parameters to compensate for the Helmholtz resonance
        % the resonant frequency and quality factor can only be modified
        % when the REZCOMP filter is on
        
            % make uppercase
            compfilt_onoff = upper(compfilt_onoff);
            
            if (length(varargin) > 2)
                error('TOO MANY ARGUMENTS')
            end
            
            if strcmp(compfilt_onoff, 'ON')
                compfilt_fc = varargin{1};
                compfilt_q = varargin{2};
                % set the switch
                % only change if different
                if ~strcmp(self.CompensationSwitch{channel},compfilt_onoff)
                    verifyCC=query(self.comPORT,[num2str(channel),...
                        ':COMPFILT = ',compfilt_onoff]);
                    if strcmp(verifyCC, compfilt_onoff)
                        self.CompensationSwitch{channel} = compfilt_onoff;
                        self.isUpdated = true;
                    else
                        error(['COMMUNICATION ERROR: COMPFILT', '\r']);
                    end
                end
                
                % set the FC
                % only change if different
                if (self.ResonantFrequency{channel}~=compfilt_fc)
                    verifyCCFC=query(self.comPORT,[num2str(channel),...
                        ':COMPFILTFC = ',compfilt_fc]);
                    if strcmp(verifyCCFC, compfilt_fc)
                        self.ResonantFrequency{channel} = compfilt_fc;
                        self.isUpdated = true;
                    else
                        error(['COMMUNICATION ERROR: COMPFILTFC', '\r']);
                    end
                end
                
                % set the Q
                % only change if different
                if (self.QualityFactor{channel}~=compfilt_q)
                    verifyCCQ=query(self.comPORT,[num2str(channel),...
                        ':COMPFILTQ = ',compfilt_q]);
                    if strcmp(verifyCCQ, compfilt_q)
                        self.QualityFactor{channel} = compfilt_q;
                        self.isUpdated = true;
                    else
                        error(['COMMUNICATION ERROR: COMPFILTQ', '\r']);
                    end
                end
                
            elseif strcmp(compfilt_onoff, 'OFF') 
            % in case it's OFF, don't care about FC and Q
                if ~strcmp(self.CompensationSwitch{channel},compfilt_onoff)
                    verifyCC=query(self.comPORT,[num2str(channel),':COMPFILT = ',...
                        compfilt_onoff]);
                    if strcmp(verifyCC, compfilt_onoff)
                        self.CompensationSwitch{channel} = compfilt_onoff;
                        self.isUpdated = true;
                    else
                        error(['COMMUNICATION ERROR: COMPFILT', '\r']);
                    end
                end
            end
            
        end

        %% pregain KSC        
        function pregain(self, channel, gain)
        % set the pregain (automatically sets any number to the closest
        % power of 2)
        % params: 
        % channel: channel to be modified
        % gain: the value for the pregain
        
            % set gain
            % only change if different
            n = nextpow2(gain);
            hi = 2^n;
            lo = 2^(n-1);
            if abs(hi-gain) <= abs(lo-gain)
                GAIN_round = hi;
            else
                GAIN_round = lo;
            end

            if gain>128
                GAIN_round = 128;
            end
            
            if (abs(self.Pregain{channel}-GAIN_round)>0.001)
                fprintf(self.comPORT, [num2str(channel), ':PREGAIN = ',...
                    num2str(gain)]);
                verify = (fscanf(self.comPORT, '%s'));

                if (abs(str2double(verify)- GAIN_round) < 0.001)
                    self.Pregain{channel} = GAIN_round;
                    self.isUpdated = true;
                else
                    error(['COMMUNICATION ERROR: PREGAIN', '\r'])
                end
            end
        end
        
        %% postgain KSC
        function postgain(self, channel, gain)
        % set the postgain (max is 16)
        % params: 
        % channel: channel to be modified
        % gain: the value for the postgain
        
            % set gain
            % only change if different
            GAIN_round = round(gain/0.0125)*0.0125;
            if gain>16
                GAIN_round = 16;
            end
            
            if (abs(self.Postgain{channel}-GAIN_round)>0.001)
                fprintf(self.comPORT,[num2str(channel),':POSTGAIN = ',...
                    num2str(gain)]);
                verify = (fscanf(self.comPORT, '%s'));

                if abs(str2double(verify)- GAIN_round)<0.001
                    self.Postgain{channel} = GAIN_round;
                    self.isUpdated = true;
                else
                    error(['COMMUNICATION ERROR: POSTGAIN', '\r'])
                end
            end
        end
        
        %% overload KSC
        function [ovldIn1,ovldIn2,ovldOut1,ovldOut2] = ovldUpdate(self)
        % simple method to update the state of the overload
            self.OverloadIn{1} = query(self.comPORT, '1:INOVLD?', '%s\n' ,'%s');
            self.OverloadIn{2} = query(self.comPORT, '2:INOVLD?', '%s\n' ,'%s');
            self.OverloadOut{1} = query(self.comPORT, '1:OUTOVLD?', '%s\n' ,'%s');
            self.OverloadOut{2} = query(self.comPORT, '2:OUTOVLD?', '%s\n' ,'%s'); 
            ovldIn1 = self.OverloadIn{1};
            ovldIn2 = self.OverloadIn{2};
            ovldOut1 = self.OverloadOut{1};
            ovldOut2 = self.OverloadOut{2};
        end
        
        %% ovldset KSC
        function setOvldLim(self, channel, limit)
        % set the output voltage limit
            
            lim_round = round(limit/0.1)*0.1;
            if limit > 10.2
                lim_round = 10.2;
            elseif limit < 0.1
                lim_round = 0.1;
            end
            
            %only change if different
            if (self.OverloadOutLimit{channel} ~= lim_round)
                fprintf(self.comPORT,[num2str(channel),...
                    ':OUTOVLDLIM = ',num2str(lim_round)]);
                verify = (fscanf(self.comPORT, '%s'));
                if abs(str2double(verify)- lim_round)<0.001
                    self.OverloadOutLimit{channel} = lim_round;
                    self.isUpdated = true;
                else
                    error(['COMMUNICATION ERROR: OVERLOAD SET', '\r'])
                end
                
            end
        end
        
        %% save KSC
        function save(self)
        % save the state of the KSC-2 in non-volatile memory
        
            % save current state
            % only if it is updated
            if self.isUpdated
            fprintf(self.comPORT, ['SAVE']);
            verify = (fscanf(self.comPORT, '%s'));    
                if strcmp(verify, 'DONE')
                    self.isUpdated = false;
                else
                    error(['COMMUNICATION ERROR: CONFIGURATION NOT SAVED', '\r'])
                end
            end
        end
        
        
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

    end
    
    methods (Static)
        function arr = createArray(COM)
            % create a cell array of KSC2 objects
            
            if (nargin == 0)
                COM = findserial();
            end
            % preallocate cell array
            arr{length(COM)} = [];
            for i = 1:length(COM)
                arr{i} = KSC2(COM{i});
            end
        end
    end
end