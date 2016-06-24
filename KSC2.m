%% Class for the KSC2. Includes API and error handling.
% @author: Emmanuel Koumandakis (emmanuel@kulite.com)
% Based on the MATLAB API developed by Haig Norian and Adam Hurst
classdef KSC2 < handle% < matlab.mixin.SetGet
    
    % most properties are Capitalized to comply with MATLAB Styling
    % apart from SN, comPORT and printable, all other properties are cell
    % arrays of length 2 (1 cell/channel)
    properties (SetAccess = protected)
        comPORT
        SN
        Printable = false;
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
            self.FrequencyCutoff{1} = query(self.comPORT, '1:FC?', '%s\n' ,'%s');
            self.FrequencyCutoff{2} = query(self.comPORT, '2:FC?', '%s\n' ,'%s');
            self.Postgain{1} = query(self.comPORT, '1:POSTGAIN?', '%s\n' ,'%s');
            self.Postgain{2} = query(self.comPORT, '2:POSTGAIN?', '%s\n' ,'%s');
            self.Pregain{1} = query(self.comPORT, '1:PREGAIN?', '%s\n' ,'%s');
            self.Pregain{2} = query(self.comPORT, '2:PREGAIN?', '%s\n' ,'%s');
            self.ExcitationVoltage{1} = query(self.comPORT, '1:EXC?', '%s\n' ,'%s');
            self.ExcitationVoltage{2} = query(self.comPORT, '2:EXC?', '%s\n' ,'%s');
            self.ExcitationType{1} = query(self.comPORT, '1:EXCTYPE?', '%s\n' ,'%s');
            self.ExcitationType{2} = query(self.comPORT, '2:EXCTYPE?', '%s\n' ,'%s');
            self.SenseMode{1} = query(self.comPORT, '1:SENSE?', '%s\n' ,'%s');
            self.SenseMode{2} = query(self.comPORT, '2:SENSE?', '%s\n' ,'%s');
            self.CompensationSwitch{1} = query(self.comPORT, '1:COMPFILT?', '%s\n' ,'%s');
            self.CompensationSwitch{2} = query(self.comPORT, '2:COMPFILT?', '%s\n' ,'%s');
            self.ResonantFrequency{1} = query(self.comPORT, '1:COMPFILTFC?', '%s\n' ,'%s');
            self.ResonantFrequency{2} = query(self.comPORT, '2:COMPFILTFC?', '%s\n' ,'%s');
            self.QualityFactor{1} = query(self.comPORT, '1:COMPFILTQ?', '%s\n' ,'%s');
            self.QualityFactor{2} = query(self.comPORT, '2:COMPFILTQ?', '%s\n' ,'%s');

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
        % change coupling, shield mode, and operation mode for each channel
        function configure(self, channel, coupling, shield, mode)
            
            %SET COUPLING (AC, DC)
            fprintf(self.comPORT, [num2str(channel), ':COUPLING = ',...
                coupling]);
            verify = (fscanf(self.comPORT, '%s'));
            if length(verify) == length(coupling)    
                if verify == coupling
                    self.Coupling{channel} = coupling;
%                     fprintf(['COUPLING FOR CHANNEL ', num2str(CH) ,' SET TO ', COUPLING, '\r']);
                else
                    error(['COMMUNICATION ERROR: COUPLING', '\r'])
                end
            else
                error(['COMMUNICATION ERROR: COUPLING', '\r'])

            end

            %SET SHIELD MODE 
            fprintf(self.comPORT, [num2str(channel),':SHIELD = ',shield]);
            verify = (fscanf(self.comPORT, '%s'));
            if length(verify) == length(shield)    
                if verify == shield
                    self.ShieldMode{channel} = shield;
%                     fprintf(['SHIELD FOR CHANNEL ', num2str(CH) ,' SET TO ', SHIELD, '\r']);
                else
                    error(['COMMUNICATION ERROR: MODE', '\r'])
                end
            else
                error(['COMMUNICATION ERROR: SHIELD', '\r'])

            end


            %SET OPERATION MODE
            fprintf(self.comPORT, [num2str(channel), ':MODE = ', mode]);
            verify = (fscanf(self.comPORT, '%s'));
            if length(verify) == length(mode)    
                if verify == mode
                    self.OperationMode{channel} = mode;
%                     fprintf(['MODE FOR CHANNEL ', num2str(CH) ,' SET TO ', MODE, '\r']);
                else
                    error(['COMMUNICATION ERROR: SHIELD', '\r'])
                end
            else
                error(['COMMUNICATION ERROR: MODE', '\r'])

            end
        end
        
        %% filter KSC
        % Change the filter type, cutoff frequency
        function filter(self, channel, freq_cut, type)

            %SET FC
            fprintf(self.comPORT, [num2str(channel), ':FC = ',...
                num2str(freq_cut)]);
            verify = (fscanf(self.comPORT, '%s'));

            FC_round = round(freq_cut/500)*500;
            if freq_cut<250
                FC_round = 500;
            end

            if str2double(verify) == FC_round
                self.FrequencyCutoff{channel} = FC_round;
%             fprintf(['FILTER CUTOFF FOR CHANNEL ', num2str(channel),...
%                 ' SET TO ', num2str(FC_round), 'Hz', '\r']);
            else
                error(['COMMUNICATION ERROR: FC', '\r'])
            end

            %SET FILTER TYPE
            fprintf(self.comPORT, [num2str(channel), ':FILTER = ', type]);
            verify = (fscanf(self.comPORT, '%s'));
            if length(verify) == length(type)    
                if verify == type
                    self.FilterType{channel} = type;
%                     fprintf(['FILTER TYPE FOR CHANNEL ',...
%                         num2str(channel) ,' SET TO ', type, '\r']);
                else
                    error(['COMMUNICATION ERROR: FILTER TYPE', '\r'])
                end
            else
                error(['COMMUNICATION ERROR: FILTER TYPE', '\r'])

            end

        end

        
        %% excitation KSC
        function excitation(self, channel, voltage, exc_type, sense)

            %SET EXCITATION VOLTAGE
            fprintf(self.comPORT, [num2str(channel), ':EXC = ',...
                num2str(voltage)]);
            verify = (fscanf(self.comPORT, '%s'));
            V_round = round(voltage/0.00125)*0.00125;
            % if V<250
            %     V_round = 500;
            % end

            if str2double(verify) == V_round
                self.ExcitationVoltage{channel} = V_round;
%                 fprintf(['EXCITATION VOLTAGE FOR CHANNEL ', num2str(channel) ,' SET TO ', num2str(V_round), 'V DC', '\r']);
            else
                error(['COMMUNICATION ERROR: EXC', '\r'])
            end

            %SET EXCITATION VOLTAGE TYPE
            fprintf(self.comPORT, [num2str(channel), ':EXCTYPE = ',...
                exc_type]);
            verify = (fscanf(self.comPORT, '%s'));
            if length(verify) == length(exc_type)    
                if verify == exc_type
                    self.ExcitationType = exc_type;
%                     fprintf(['EXCITATION TYPE FOR CHANNEL ', num2str(channel) ,' SET TO ', exc_type, '\r']);
                else
                    error(['COMMUNICATION ERROR: EXCITATION TYPE', '\r'])
                end
            else
                error(['COMMUNICATION ERROR: EXCITATION TYPE', '\r'])
            end

            %SET SENSE
            fprintf(self.comPORT, [num2str(channel), ':SENSE = ', sense]);
            verify = (fscanf(self.comPORT, '%s'));
            if length(verify) == length(sense)    
                if verify == sense
                    self.SenseMode = sense;
%                     fprintf(['SENSE MODE FOR CHANNEL ', num2str(channel) ,' SET TO ', sense, '\r']);
                else
                    error(['COMMUNICATION ERROR: SENSE MODE', '\r'])
                end
            else
                error(['COMMUNICATION ERROR: SENSE MODE', '\r'])

            end
        end
        
%         %% setter methods
%         function self = set.Coupling(self, coupling)
%             if ~(iscell(coupling) && (length(coupling)==2))
%                 error('Incorrect usage of set().')
%             end
%             if (isempty(channel))
%                 self.Coupling = coupling;
%             end
%         end


        %% pregain KSC        
        function pregainKSC(self, channel, gain)
        % set the pregain (automatically sets any number to the closest
        % power of 2)
        % params: 
        % channel: channel to be modified
        % gain: the value for the pregain
        
            %SET GAIN
            fprintf(self.comPORT, [num2str(channel), ':PREGAIN = ',...
                num2str(gain)]);
            verify = (fscanf(self.comPORT, '%s'));

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


            if (abs(str2double(verify)- GAIN_round) < 0.001)
                self.Pregain{channel} = GAIN_round;
%             fprintf(['PREGAIN FOR CHANNEL ', num2str(channel) ,' SET TO ', num2str(GAIN_round), ' V/V', '\r']);
            else
                error(['COMMUNICATION ERROR: PREGAIN', '\r'])
            end
        end
        
        % idea for set() with switch and string parsing
    end
    
end