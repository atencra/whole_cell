function [trigger, trigger_signal] = axon_findtrig(trigger_signal, Thresh)
% axon_findtrig  Find triggers from abf file trigger trace 
%
%  [trigger, trigger_signal] = axon_findtrig(trigger_signal, Thresh)
%
%  trigger_signal : trigger recording signal. A vector.
%
%  Thresh : threshhold for finding trigger pulses. Set according to the 
%  leading phase of the pulse. The trace is normalized between [-1 , 1]. 
%  so, set to a positive value in [0,1] (usually 0.5) for positive
%  leading edge. Set to [0,-1] for negative edge (usually -0.5) for
%  negative leading edge.
%
%  trigger : Returned Trigger Time Vector (in sample number)
%


narginchk(2,2);



MeanX = mean(trigger_signal(:));
MaxX = max(trigger_signal(:));

% Finding Triggers
trigger = [];
count = 0;

trigger_signal = trigger_signal(:)';

if ( Thresh < 0 )
    trigger_signal(trigger_signal > 0 ) = 0;
    trigger_signal = -1 * trigger_signal;
else
    trigger_signal(trigger_signal < 0 ) = 0;
end

MaxX = max(trigger_signal(:));


X = trigger_signal / MaxX;

trigger_signal = X;

X(X>=abs(Thresh)) = 1;
X(X<abs(Thresh)) = 0;



%Adding First Element to avoid missing trigger 
%if trigger falls exactly on edge
if ( count == 0 )
   X0 = X(1);
   X = [X0 X];
elseif ( length(X)>0 )
   X = [X0 X];	
end


%Finding Triggers
if ( length(X) > 0 )
   %Setting Anything < Tresh to zero
   index = find( X < abs(Thresh) );
   X(index) = zeros(1,length(index));


   %Finding Edges in X
   D = diff(X);
   indexD = find( D >= abs(Thresh) );	%Finding Trigger Locations


   %Converting to Trigger Times
   trigger = [trigger indexD];

   %Finding the Last Element of X. This is placed as the first 
   % element in the new X Array
   X0 = X(length(X));

   %Incrementing Counter
   count = count + 1;

end




%Re-calculating inter-trigger spacing
Dtrigger = diff(trigger);
maxD = max(Dtrigger);

%Finding triple trigger(s)
triple_ind = find(Dtrigger(1:end-1) < 0.25*maxD & Dtrigger(2:end) < 0.25*maxD );
triptrig = trigger(triple_ind);

%Removing additional triggers if extra triple triggers are found
if(isempty(triple_ind))

    disp('Could not find initial triple trigger.');

else %Triple triggers found

   % Multiple triple triggers found. We will assume that the first and 
   % last triple trigger were for the same stimulus. This is the case
   % for the static ripple/moving ripple stimuli, but not for other stimuli
   if( length(triple_ind) == 2 ) 
   %         trigger = trigger( triple_ind(1):(triple_ind(2)-1) );
     trigger = trigger( triple_ind(1):triple_ind(2) );

   %There was only one triple trigger
   else
     trigger = trigger(triple_ind(1):end);
   end

   %Making triple trigger count as one trigger
   trigger = [trigger(1) trigger(4:end)];

end


return;
