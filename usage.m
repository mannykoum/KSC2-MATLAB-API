%% usage.m: a usage guide for the KSC2 class
% If you have a KSC2 around, you can try it out.
tic

%%% Constructors
% There are two constructors. One where you can specify the com port the
% KSC-2 is connected to and one where the program finds it on its own
% 
% Example 1:
% 
%  com = 'COM12';
%  ksc = KSC2(com);
% 
% Example 2:
ksc = KSC2;

%%% 
% The third option is to create an array of KSC2 objects. This is 
% extremely useful when multiple KSC-2's are connected. KSC2.createArray is 
% a static method which means that it doesn't need an instance of the 
% object to run. You can try it by commenting out line 11 and 
% uncommenting the following:
%
%  arr = KSC2.createArray();
%  ksc = arr{1};

%%%
% When a KSC2 object is constructed, it queries the KSC-2 signal
% conditioner in order to fill out all the different attributes. You can
% view all of them by typing the variable name as usual...
ksc

% ...and you can access them using dot notation

ksc.FilterType
ksc.SenseMode{2} % for channel 2

%%%
% Methods work in a similar manner as before. For more details, see the
% comments on each individual method. methods can be used either with dot
% notation or by passing the object as a parameter.
configure(ksc, 1, 'AC', 'GROUND', 'OPERATE');
ksc.configure(2, 'DC', 'GROUND', 'OPERATE');
ksc.excitation(1, 10, 'BIPOLAR', 'REMOTE');
excitation(ksc, 2, 12, 'BIPOLAR', 'LOCAL');
ksc.filter(1, 20000, 'FLAT');
ksc.pregain(2, 1);
ksc.postgain(2, 1);

% ovldUpdate is the equivalent of overloadKSC.
% It updates the overload attributes for every channel, input and output.
% It also returns them.
ksc.ovldUpdate()
setOvldLim(ksc, 1, 10);

%  ksc.save()

t2 = toc;
disp(['Time it took to run this script in seconds: ', num2str(t2)])

ksc.del; % same as |ksc.delete();| and |delete(ksc);|